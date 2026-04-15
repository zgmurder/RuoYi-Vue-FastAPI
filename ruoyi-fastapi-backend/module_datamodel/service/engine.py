"""Dynamic SQL execution engine for the data modeling platform.

Supports cross-datasource operations by materializing seed data
into an in-memory SQLite database before executing operators.

Supported databases: SQLite, MySQL, MariaDB, PostgreSQL, Oracle, SQL Server, ClickHouse

NOTE: This engine uses synchronous operations (sqlite3 in-memory + sync SQLAlchemy engines).
      Call from async code via asyncio.to_thread() or run_in_executor().
"""

import json
import re
import sqlite3
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from module_datamodel.entity.do.datamodel_do import DmDatasource, DmSeed

# Driver mapping: db_type -> SQLAlchemy drivername
DRIVER_MAP = {
    'sqlite': None,
    'mysql': 'mysql+pymysql',
    'mariadb': 'mysql+pymysql',
    'postgresql': 'postgresql+psycopg2',
    'oracle': 'oracle+oracledb',
    'sqlserver': 'mssql+pymssql',
    'clickhouse': 'clickhouse+native',
}

DEFAULT_PORT = {
    'mysql': 3306,
    'mariadb': 3306,
    'postgresql': 5432,
    'oracle': 1521,
    'sqlserver': 1433,
    'clickhouse': 9000,
}


def _build_sync_engine(ds: DmDatasource):
    """Create a synchronous SQLAlchemy engine for a dynamic data source."""
    db_type = ds.db_type

    if db_type == 'sqlite':
        url = f'sqlite:///{ds.database}'
        return create_engine(url, connect_args={'check_same_thread': False})

    driver = DRIVER_MAP.get(db_type)
    if not driver:
        raise ValueError(f'不支持的数据库类型: {db_type}')

    port = ds.port or DEFAULT_PORT.get(db_type, 0)
    query: dict[str, str] = {}
    if db_type in ('mysql', 'mariadb'):
        query['charset'] = 'utf8mb4'

    if db_type == 'oracle':
        url = URL.create(
            drivername=driver,
            username=ds.username,
            password=ds.password,
            host=ds.host,
            port=port,
            query={'service_name': ds.database},
        )
    elif db_type == 'clickhouse':
        url = f'clickhousedb://{ds.username}:{ds.password}@{ds.host}:{port}/{ds.database}'
        return create_engine(url)
    else:
        url = URL.create(
            drivername=driver,
            username=ds.username,
            password=ds.password,
            host=ds.host,
            port=port,
            database=ds.database,
            query=query if query else {},
        )

    return create_engine(url)


def test_connection_sync(ds_data: dict) -> dict:
    """Test a data source connection (sync)."""
    try:
        # Build a temporary DmDatasource-like object
        class _TempDS:
            pass

        obj = _TempDS()
        for k, v in ds_data.items():
            setattr(obj, k, v)

        eng = _build_sync_engine(obj)
        test_sql = 'SELECT 1 FROM DUAL' if ds_data.get('db_type') == 'oracle' else 'SELECT 1'
        with eng.connect() as conn:
            conn.execute(text(test_sql))
        return {'success': True, 'message': '连接成功'}
    except Exception as e:
        return {'success': False, 'message': str(e)}


# -- List tables per database type --

_LIST_TABLES_SQL = {
    'sqlite': "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    'mysql': 'SHOW TABLES',
    'mariadb': 'SHOW TABLES',
    'postgresql': "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename",
    'oracle': 'SELECT table_name FROM user_tables ORDER BY table_name',
    'sqlserver': "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME",
    'clickhouse': 'SHOW TABLES',
}


def list_tables_sync(ds: DmDatasource) -> list[str]:
    """List all tables for a data source (sync)."""
    eng = _build_sync_engine(ds)
    sql = _LIST_TABLES_SQL.get(ds.db_type)
    if not sql:
        return []
    with eng.connect() as conn:
        result = conn.execute(text(sql))
        return [row[0] for row in result.fetchall()]


def _quote_table(table_name: str, db_type: str) -> str:
    if db_type in ('mysql', 'mariadb'):
        return f'`{table_name}`'
    elif db_type in ('postgresql', 'clickhouse'):
        return f'"{table_name}"'
    elif db_type == 'sqlserver':
        return f'[{table_name}]'
    return f'"{table_name}"'


def _limit_sql(db_type: str, table_expr: str, limit: int) -> str:
    if db_type == 'oracle':
        return f'SELECT * FROM {table_expr} WHERE ROWNUM <= {limit}'
    elif db_type == 'sqlserver':
        return f'SELECT TOP {limit} * FROM {table_expr}'
    else:
        return f'SELECT * FROM {table_expr} LIMIT {limit}'


def sample_seed_sync(seed: DmSeed, datasource: DmDatasource, limit: int = 10) -> dict:
    """Get sample data from a seed (sync)."""
    eng = _build_sync_engine(datasource)
    table = _quote_table(seed.table_name, datasource.db_type)
    sql = _limit_sql(datasource.db_type, table, limit)

    with eng.connect() as conn:
        result = conn.execute(text(sql))
        columns = list(result.keys())
        rows = [dict(zip(columns, row)) for row in result.fetchall()]
        return {'columns': columns, 'rows': rows, 'total': len(rows)}


# ---------------------------------------------------------------------------
# Cross-datasource execution engine (sync — uses in-memory SQLite)
# ---------------------------------------------------------------------------

def _fetch_seed_data_sync(seed: DmSeed, datasource: DmDatasource) -> tuple[list[str], list[tuple]]:
    """Fetch all rows from a seed's underlying table via its own datasource."""
    eng = _build_sync_engine(datasource)
    table = _quote_table(seed.table_name, datasource.db_type)
    sql = f'SELECT * FROM {table}'

    with eng.connect() as conn:
        result = conn.execute(text(sql))
        columns = list(result.keys())
        rows = [tuple(row) for row in result.fetchall()]
        return columns, rows


def _collect_seed_node_ids(node_id: str, nodes: dict, edges: list) -> set[str]:
    node = nodes[node_id]
    if node.get('type') == 'seed':
        return {node_id}
    result = set()
    for e in edges:
        if e['target'] == node_id:
            result |= _collect_seed_node_ids(e['source'], nodes, edges)
    return result


def _sanitize_col(name: str) -> str:
    return name.replace(' ', '_').replace('-', '_').replace('.', '_')


def _materialize_seeds(
    seed_map: dict[int, tuple[DmSeed, DmDatasource]],
    seed_node_ids: set[str],
    nodes: dict,
    mem_conn: sqlite3.Connection,
) -> dict[str, str]:
    """Fetch data from each seed's real datasource and load into in-memory SQLite."""
    node_table_map: dict[str, str] = {}
    cursor = mem_conn.cursor()

    for nid in seed_node_ids:
        node = nodes[nid]
        seed_id = node.get('data', {}).get('seedId')
        if not seed_id:
            raise ValueError(f'种子节点 {nid} 缺少 seedId')

        seed_info = seed_map.get(int(seed_id))
        if not seed_info:
            raise ValueError(f'种子 {seed_id} 不存在')

        seed, datasource = seed_info
        columns, rows = _fetch_seed_data_sync(seed, datasource)

        temp_table = f"seed_{nid.replace('-', '_')}"
        safe_cols = [_sanitize_col(c) for c in columns]

        col_defs = ', '.join(f'"{c}" TEXT' for c in safe_cols)
        cursor.execute(f'DROP TABLE IF EXISTS "{temp_table}"')
        cursor.execute(f'CREATE TABLE "{temp_table}" ({col_defs})')

        if rows:
            placeholders = ', '.join('?' for _ in safe_cols)
            cursor.executemany(
                f'INSERT INTO "{temp_table}" VALUES ({placeholders})',
                [tuple(str(v) if v is not None else None for v in row) for row in rows],
            )

        mem_conn.commit()
        node_table_map[nid] = temp_table

    return node_table_map


def _get_table_columns(mem_conn: sqlite3.Connection, table_name: str) -> list[str]:
    cursor = mem_conn.cursor()
    cursor.execute(f'PRAGMA table_info("{table_name}")')
    return [row[1] for row in cursor.fetchall()]


def _process_node(
    node_id: str,
    nodes: dict,
    edges: list,
    table_map: dict[str, str],
    mem_conn: sqlite3.Connection,
    cache: dict[str, str],
) -> str:
    if node_id in cache:
        return cache[node_id]

    node = nodes[node_id]
    node_type = node.get('type', '')

    if node_type == 'seed':
        cache[node_id] = table_map[node_id]
        return cache[node_id]

    incoming = [e for e in edges if e['target'] == node_id]
    if not incoming:
        raise ValueError(f'节点 {node_id} 没有输入连接')

    input_tables = [
        _process_node(e['source'], nodes, edges, table_map, mem_conn, cache)
        for e in incoming
    ]

    if node_type == 'result':
        if len(input_tables) == 1:
            cache[node_id] = input_tables[0]
            return cache[node_id]
        raise ValueError('结果节点只能有一个输入')

    op_type = node.get('data', {}).get('opType', 'union')
    config = node.get('data', {}).get('config', {})
    result_table = f"op_{node_id.replace('-', '_').replace(' ', '_')}"
    cursor = mem_conn.cursor()

    SET_OPS = {'union': 'UNION', 'union_all': 'UNION ALL', 'intersect': 'INTERSECT', 'except': 'EXCEPT'}

    if op_type in SET_OPS:
        all_cols = [_get_table_columns(mem_conn, t) for t in input_tables]
        common = [c for c in all_cols[0] if all(c in cs for cs in all_cols[1:])]
        if not common:
            raise ValueError(
                f'集合运算失败: 输入表之间没有同名列。'
                f'左侧列: {all_cols[0]}, 右侧列: {all_cols[1] if len(all_cols) > 1 else "无"}'
            )
        col_list = ', '.join(f'"{c}"' for c in common)
        parts = [f'SELECT {col_list} FROM "{t}"' for t in input_tables]
        sql = f' {SET_OPS[op_type]} '.join(parts)

    elif op_type == 'join':
        if len(input_tables) < 2:
            raise ValueError('JOIN 算子需要至少两个输入')
        join_type = config.get('joinType', 'INNER JOIN')
        condition = config.get('condition', '1=1')
        sql = f'SELECT * FROM "{input_tables[0]}" AS t1 {join_type} "{input_tables[1]}" AS t2 ON {condition}'

    elif op_type == 'filter':
        condition = config.get('condition', '1=1')
        sql = f'SELECT * FROM "{input_tables[0]}" WHERE {condition}'

    elif op_type == 'group':
        group_fields = config.get('groupFields', '')
        agg_expr = config.get('aggExpr', '*')
        if group_fields:
            sql = f'SELECT {group_fields}, {agg_expr} FROM "{input_tables[0]}" GROUP BY {group_fields}'
        else:
            sql = f'SELECT {agg_expr} FROM "{input_tables[0]}"'

    elif op_type == 'sort':
        sort_field = config.get('sortField', '1')
        sort_order = config.get('sortOrder', 'ASC')
        sql = f'SELECT * FROM "{input_tables[0]}" ORDER BY {sort_field} {sort_order}'

    elif op_type == 'limit':
        limit_count = config.get('count', 100)
        sql = f'SELECT * FROM "{input_tables[0]}" LIMIT {limit_count}'

    elif op_type == 'custom':
        custom_sql = config.get('sql', '')
        if not custom_sql:
            raise ValueError('自定义算子需要提供 SQL')
        for i, t in enumerate(input_tables):
            custom_sql = custom_sql.replace(f'{{input{i+1}}}', f'"{t}"')
        sql = custom_sql

    else:
        raise ValueError(f'不支持的算子类型: {op_type}')

    cursor.execute(f'DROP TABLE IF EXISTS "{result_table}"')
    cursor.execute(f'CREATE TABLE "{result_table}" AS {sql}')
    mem_conn.commit()

    cache[node_id] = result_table
    return result_table


def execute_node_sync(
    seed_map: dict[int, tuple[DmSeed, DmDatasource]],
    node_id: str,
    graph_data_str: str,
) -> dict:
    """Execute a specific node in the model graph (sync)."""
    graph = json.loads(graph_data_str)
    nodes_list = graph.get('nodes', [])
    nodes = {n['id']: n for n in nodes_list}
    edges = graph.get('edges', [])

    if node_id not in nodes:
        raise ValueError(f'节点 {node_id} 不存在')

    seed_node_ids = _collect_seed_node_ids(node_id, nodes, edges)
    if not seed_node_ids:
        raise ValueError('模型中没有有效的种子节点')

    mem_conn = sqlite3.connect(':memory:')
    try:
        table_map = _materialize_seeds(seed_map, seed_node_ids, nodes, mem_conn)
        cache: dict[str, str] = {}
        final_table = _process_node(node_id, nodes, edges, table_map, mem_conn, cache)

        cursor = mem_conn.cursor()
        cursor.execute(f'SELECT * FROM "{final_table}"')
        columns = [desc[0] for desc in cursor.description] if cursor.description else []
        rows = [dict(zip(columns, row)) for row in cursor.fetchall()]

        sql_summary = f'-- 最终结果来自表: {final_table}\nSELECT * FROM "{final_table}"'
        return {'columns': columns, 'rows': rows, 'total': len(rows), 'sql': sql_summary}
    finally:
        mem_conn.close()


def execute_model_sync(
    seed_map: dict[int, tuple[DmSeed, DmDatasource]],
    model_graph_str: str,
) -> dict:
    """Execute the entire model (sync)."""
    graph = json.loads(model_graph_str)
    nodes_list = graph.get('nodes', [])

    result_nodes = [n for n in nodes_list if n.get('type') == 'result']
    if not result_nodes:
        raise ValueError('模型中没有结果节点')

    return execute_node_sync(seed_map, result_nodes[0]['id'], model_graph_str)


def _substitute_params(graph_data_str: str, params: dict) -> str:
    """Replace ${param_name} placeholders in operator configs."""
    graph = json.loads(graph_data_str)
    for node in graph.get('nodes', []):
        config = node.get('data', {}).get('config')
        if not config or not isinstance(config, dict):
            continue
        for key, val in config.items():
            if isinstance(val, str):
                def _replacer(m: re.Match) -> str:
                    name = m.group(1)
                    if name in params:
                        return str(params[name])
                    return m.group(0)
                config[key] = re.sub(r'\$\{(\w+)\}', _replacer, val)
    return json.dumps(graph, ensure_ascii=False)


def execute_model_with_params_sync(
    seed_map: dict[int, tuple[DmSeed, DmDatasource]],
    model_graph_str: str,
    params: dict,
) -> dict:
    """Execute a model with parameter substitution (sync)."""
    substituted = _substitute_params(model_graph_str, params)
    return execute_model_sync(seed_map, substituted)
