"""Business service layer for the data modeling module.

Wraps sync engine operations with asyncio.to_thread() for async compatibility.
"""

import asyncio
import json

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from module_datamodel.dao.datamodel_dao import (
    DatasourceDao,
    ModelDao,
    OperatorDao,
    PublishedApiDao,
    SeedDao,
)
from module_datamodel.entity.do.datamodel_do import (
    DmDatasource,
    DmModel,
    DmOperator,
    DmPublishedApi,
    DmSeed,
)
from module_datamodel.service.engine import (
    execute_model_sync,
    execute_model_with_params_sync,
    execute_node_sync,
    list_tables_sync,
    sample_seed_sync,
    test_connection_sync,
)


async def _build_seed_map(db: AsyncSession, graph_data_str: str) -> dict[int, tuple[DmSeed, DmDatasource]]:
    """Build a mapping of seed_id -> (DmSeed, DmDatasource) from graph data."""
    graph = json.loads(graph_data_str)
    seed_ids = set()
    for node in graph.get('nodes', []):
        if node.get('type') == 'seed':
            sid = node.get('data', {}).get('seedId')
            if sid:
                seed_ids.add(int(sid))

    seed_map: dict[int, tuple[DmSeed, DmDatasource]] = {}
    for sid in seed_ids:
        seed = await SeedDao.get_by_id(db, sid)
        if not seed:
            continue
        ds = await DatasourceDao.get_by_id(db, seed.datasource_id)
        if not ds:
            continue
        seed_map[sid] = (seed, ds)

    return seed_map


# ========== Datasource Service ==========

class DatasourceService:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmDatasource]:
        return await DatasourceDao.get_list(db)

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmDatasource]:
        return await DatasourceDao.get_list_visible(db, username)

    @classmethod
    async def get_by_id(cls, db: AsyncSession, ds_id: int) -> DmDatasource | None:
        return await DatasourceDao.get_by_id(db, ds_id)

    @classmethod
    async def create(cls, db: AsyncSession, data: dict) -> DmDatasource:
        existing = await DatasourceDao.get_by_name(db, data['name'])
        if existing:
            raise ValueError(f"数据源名称「{data['name']}」已存在")
        obj = DmDatasource(**data)
        return await DatasourceDao.create(db, obj)

    @classmethod
    async def update(cls, db: AsyncSession, ds_id: int, data: dict) -> None:
        filtered = {k: v for k, v in data.items() if v is not None}
        if filtered:
            await DatasourceDao.update_by_id(db, ds_id, filtered)

    @classmethod
    async def delete(cls, db: AsyncSession, ds_id: int) -> None:
        await DatasourceDao.delete_by_id(db, ds_id)

    @classmethod
    async def test_connection(cls, data: dict) -> dict:
        return await asyncio.to_thread(test_connection_sync, data)

    @classmethod
    async def list_tables(cls, db: AsyncSession, ds_id: int) -> list[str]:
        ds = await DatasourceDao.get_by_id(db, ds_id)
        if not ds:
            raise ValueError('数据源不存在')
        return await asyncio.to_thread(list_tables_sync, ds)


# ========== Seed Service ==========

class SeedService:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmSeed]:
        return await SeedDao.get_list(db)

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmSeed]:
        return await SeedDao.get_list_visible(db, username)

    @classmethod
    async def get_by_id(cls, db: AsyncSession, seed_id: int) -> DmSeed | None:
        return await SeedDao.get_by_id(db, seed_id)

    @classmethod
    async def create(cls, db: AsyncSession, data: dict) -> DmSeed:
        obj = DmSeed(**data)
        return await SeedDao.create(db, obj)

    @classmethod
    async def update(cls, db: AsyncSession, seed_id: int, data: dict) -> None:
        filtered = {k: v for k, v in data.items() if v is not None}
        if filtered:
            await SeedDao.update_by_id(db, seed_id, filtered)

    @classmethod
    async def delete(cls, db: AsyncSession, seed_id: int) -> None:
        await SeedDao.delete_by_id(db, seed_id)

    @classmethod
    async def sample(cls, db: AsyncSession, seed_id: int, limit: int = 10) -> dict:
        seed = await SeedDao.get_by_id(db, seed_id)
        if not seed:
            raise ValueError('种子不存在')
        ds = await DatasourceDao.get_by_id(db, seed.datasource_id)
        if not ds:
            raise ValueError('数据源不存在')
        return await asyncio.to_thread(sample_seed_sync, seed, ds, limit)


# ========== Operator Service ==========

class OperatorService:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmOperator]:
        return await OperatorDao.get_list(db)

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmOperator]:
        return await OperatorDao.get_list_visible(db, username)

    @classmethod
    async def get_by_id(cls, db: AsyncSession, op_id: int) -> DmOperator | None:
        return await OperatorDao.get_by_id(db, op_id)

    @classmethod
    async def create(cls, db: AsyncSession, data: dict) -> DmOperator:
        obj = DmOperator(**data)
        return await OperatorDao.create(db, obj)

    @classmethod
    async def update(cls, db: AsyncSession, op_id: int, data: dict) -> None:
        filtered = {k: v for k, v in data.items() if v is not None}
        if filtered:
            await OperatorDao.update_by_id(db, op_id, filtered)

    @classmethod
    async def delete(cls, db: AsyncSession, op_id: int) -> None:
        op = await OperatorDao.get_by_id(db, op_id)
        if not op:
            raise ValueError('算子不存在')
        if op.is_builtin:
            raise ValueError('内置算子不可删除')
        await OperatorDao.delete_by_id(db, op_id)

    @classmethod
    async def init_builtin(cls, db: AsyncSession) -> None:
        """Initialize built-in operators if not present."""
        BUILTINS = [
            {'name': '并集 (UNION)', 'op_type': 'union', 'description': '取两个集合的并集（去重）'},
            {'name': '全并集 (UNION ALL)', 'op_type': 'union_all', 'description': '取两个集合的并集（不去重）'},
            {'name': '交集 (INTERSECT)', 'op_type': 'intersect', 'description': '取两个集合的交集'},
            {'name': '差集 (EXCEPT)', 'op_type': 'except', 'description': '取第一个集合减去第二个集合'},
            {'name': '连接 (JOIN)', 'op_type': 'join', 'description': '表连接',
             'config_schema': '{"joinType":"INNER JOIN","condition":"t1.id = t2.id"}'},
            {'name': '过滤 (FILTER)', 'op_type': 'filter', 'description': '条件过滤',
             'config_schema': '{"condition":"1=1"}'},
            {'name': '分组 (GROUP)', 'op_type': 'group', 'description': '分组聚合',
             'config_schema': '{"groupFields":"","aggExpr":"COUNT(*)"}'},
            {'name': '排序 (SORT)', 'op_type': 'sort', 'description': '排序',
             'config_schema': '{"sortField":"id","sortOrder":"ASC"}'},
            {'name': '限制 (LIMIT)', 'op_type': 'limit', 'description': '限制返回行数',
             'config_schema': '{"count":100}'},
            {'name': '自定义SQL', 'op_type': 'custom', 'description': '自定义SQL，用 {input1} 引用输入表',
             'config_schema': '{"sql":"SELECT * FROM {input1}"}'},
        ]
        for b in BUILTINS:
            existing = await OperatorDao.get_by_op_type(db, b['op_type'])
            if not existing:
                obj = DmOperator(
                    name=b['name'],
                    op_type=b['op_type'],
                    description=b.get('description', ''),
                    sql_template=b.get('sql_template', ''),
                    is_builtin=True,
                    config_schema=b.get('config_schema', '{}'),
                )
                db.add(obj)
        await db.commit()


# ========== Model Service ==========

class ModelService:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmModel]:
        return await ModelDao.get_list(db)

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmModel]:
        return await ModelDao.get_list_visible(db, username)

    @classmethod
    async def get_by_id(cls, db: AsyncSession, model_id: int) -> DmModel | None:
        return await ModelDao.get_by_id(db, model_id)

    @classmethod
    async def create(cls, db: AsyncSession, data: dict) -> DmModel:
        obj = DmModel(**data)
        return await ModelDao.create(db, obj)

    @classmethod
    async def update(cls, db: AsyncSession, model_id: int, data: dict) -> None:
        filtered = {k: v for k, v in data.items() if v is not None}
        if filtered:
            await ModelDao.update_by_id(db, model_id, filtered)

    @classmethod
    async def delete(cls, db: AsyncSession, model_id: int) -> None:
        await ModelDao.delete_by_id(db, model_id)

    @classmethod
    async def execute(cls, db: AsyncSession, model_id: int) -> dict:
        model = await ModelDao.get_by_id(db, model_id)
        if not model:
            raise ValueError('模型不存在')
        seed_map = await _build_seed_map(db, model.graph_data)
        return await asyncio.to_thread(execute_model_sync, seed_map, model.graph_data)

    @classmethod
    async def execute_node(cls, db: AsyncSession, node_id: str, graph_data: str) -> dict:
        seed_map = await _build_seed_map(db, graph_data)
        return await asyncio.to_thread(execute_node_sync, seed_map, node_id, graph_data)


# ========== Published API Service ==========

class PublishedApiService:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmPublishedApi]:
        return await PublishedApiDao.get_list(db)

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmPublishedApi]:
        return await PublishedApiDao.get_list_visible(db, username)

    @classmethod
    async def get_by_id(cls, db: AsyncSession, api_id: int) -> DmPublishedApi | None:
        return await PublishedApiDao.get_by_id(db, api_id)

    @classmethod
    async def create(cls, db: AsyncSession, data: dict) -> DmPublishedApi:
        path = data.get('path', '').strip().strip('/')
        data['path'] = path
        existing = await PublishedApiDao.get_by_path(db, path)
        if existing:
            raise ValueError(f"路径「{path}」已被占用")
        # Validate model exists
        model = await ModelDao.get_by_id(db, data['model_id'])
        if not model:
            raise ValueError('关联的模型不存在')
        obj = DmPublishedApi(**data)
        return await PublishedApiDao.create(db, obj)

    @classmethod
    async def update(cls, db: AsyncSession, api_id: int, data: dict) -> None:
        filtered = {k: v for k, v in data.items() if v is not None}
        if 'path' in filtered:
            filtered['path'] = filtered['path'].strip().strip('/')
        if filtered:
            await PublishedApiDao.update_by_id(db, api_id, filtered)

    @classmethod
    async def delete(cls, db: AsyncSession, api_id: int) -> None:
        await PublishedApiDao.delete_by_id(db, api_id)

    @classmethod
    async def invoke(cls, db: AsyncSession, api_path: str, params: dict) -> dict:
        api_path = api_path.strip('/')
        api = await PublishedApiDao.get_by_path(db, api_path)
        if not api:
            raise ValueError(f'API 接口 /{api_path} 不存在')
        if not api.enabled:
            raise ValueError('该 API 已停用')

        model = await ModelDao.get_by_id(db, api.model_id)
        if not model:
            raise ValueError('关联的模型不存在')

        # Validate params
        param_defs = json.loads(api.params) if api.params else []
        for p in param_defs:
            name = p['name']
            if p.get('required') and name not in params:
                if p.get('default', '') != '':
                    params[name] = p['default']
                else:
                    raise ValueError(f'缺少必填参数: {name}')
            if name not in params and p.get('default', '') != '':
                params[name] = p['default']

        seed_map = await _build_seed_map(db, model.graph_data)
        return await asyncio.to_thread(
            execute_model_with_params_sync, seed_map, model.graph_data, params
        )
