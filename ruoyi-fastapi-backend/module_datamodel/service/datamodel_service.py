"""Business service layer for the data modeling module.

Wraps sync engine operations with asyncio.to_thread() for async compatibility.
"""

import asyncio
import json
import re
import uuid
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from module_ai.dao.ai_model_dao import AiModelDao
from module_ai.entity.vo.ai_model_vo import AiModelModel
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
from utils.common_util import CamelCaseUtil
from utils.crypto_util import CryptoUtil
from utils.ai_util import AiUtil


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
    def _extract_json_object(cls, text: str) -> dict:
        """Extract the first JSON object from a model response."""
        cleaned = text.strip()
        if cleaned.startswith('```'):
            cleaned = re.sub(r'^```(?:json)?\s*', '', cleaned, flags=re.IGNORECASE)
            cleaned = re.sub(r'\s*```$', '', cleaned)
        try:
            return json.loads(cleaned)
        except Exception:
            pass

        match = re.search(r'\{[\s\S]*\}', cleaned)
        if not match:
            raise ValueError('AI 返回格式无法解析，请重试')
        return json.loads(match.group(0))

    @classmethod
    def _safe_config(cls, op_type: str, config: dict) -> dict:
        """Keep only known keys for each operator configuration."""
        base_map = {
            'join': {'joinType': 'INNER JOIN', 'condition': 't1.id = t2.id'},
            'filter': {'condition': '1=1'},
            'group': {'groupFields': '', 'aggExpr': 'COUNT(*)'},
            'sort': {'sortField': 'id', 'sortOrder': 'ASC'},
            'limit': {'count': 100},
            'custom': {'sql': 'SELECT * FROM {input1}'},
        }
        defaults = base_map.get(op_type, {})
        if not defaults:
            return {}
        result = defaults.copy()
        for key in defaults:
            if key in config and config[key] is not None:
                result[key] = config[key]
        return result

    @classmethod
    def _normalize_graph_data(
        cls,
        raw_graph: dict,
        seed_dict: dict[int, DmSeed],
        op_dict: dict[int, DmOperator],
        include_result_node: bool,
    ) -> dict:
        """Normalize and validate graph data returned by the model."""
        raw_nodes = raw_graph.get('nodes') if isinstance(raw_graph, dict) else None
        raw_edges = raw_graph.get('edges') if isinstance(raw_graph, dict) else None
        if not isinstance(raw_nodes, list):
            raise ValueError('AI 返回的 nodes 不是数组')
        if raw_edges is None:
            raw_edges = []
        if not isinstance(raw_edges, list):
            raise ValueError('AI 返回的 edges 不是数组')

        nodes = []
        id_mapping: dict[str, str] = {}
        used_node_ids = set()
        result_exists = False
        for idx, node in enumerate(raw_nodes):
            if not isinstance(node, dict):
                continue
            node_type = str(node.get('type') or '').strip()
            if node_type not in {'seed', 'operator', 'result'}:
                continue

            raw_id = str(node.get('id') or '').strip() or f'node_{idx + 1}'
            if raw_id in used_node_ids:
                raw_id = f'{raw_id}_{idx + 1}'
            used_node_ids.add(raw_id)
            id_mapping[str(node.get('id') or raw_id)] = raw_id

            pos = node.get('position') if isinstance(node.get('position'), dict) else {}
            data = node.get('data') if isinstance(node.get('data'), dict) else {}
            item = {
                'id': raw_id,
                'type': node_type,
                'position': {
                    'x': float(pos.get('x', 120 + idx * 140)),
                    'y': float(pos.get('y', 100 + (idx % 3) * 120)),
                },
                'data': {'label': str(data.get('label') or '').strip()},
            }

            if node_type == 'seed':
                seed_id = data.get('seedId') or data.get('seed_id')
                try:
                    seed_id = int(seed_id)
                except Exception:
                    seed_id = None
                if seed_id not in seed_dict:
                    continue
                seed = seed_dict[seed_id]
                item['data']['seedId'] = seed.id
                item['data']['tableName'] = seed.table_name
                if not item['data']['label']:
                    item['data']['label'] = seed.name

            elif node_type == 'operator':
                op_id = data.get('operatorId') or data.get('operator_id')
                try:
                    op_id = int(op_id)
                except Exception:
                    op_id = None
                if op_id not in op_dict:
                    continue
                op = op_dict[op_id]
                item['data']['operatorId'] = op.id
                item['data']['opType'] = op.op_type
                if not item['data']['label']:
                    item['data']['label'] = op.name
                user_config = data.get('config') if isinstance(data.get('config'), dict) else {}
                item['data']['config'] = cls._safe_config(op.op_type, user_config)

            elif node_type == 'result':
                if not item['data']['label']:
                    item['data']['label'] = '结果输出'
                result_exists = True

            nodes.append(item)

        if include_result_node and not result_exists:
            result_id = f'result_{uuid.uuid4().hex[:8]}'
            nodes.append(
                {
                    'id': result_id,
                    'type': 'result',
                    'position': {'x': 760, 'y': 220},
                    'data': {'label': '结果输出'},
                }
            )
            if nodes:
                source_candidate = None
                for node in reversed(nodes):
                    if node['type'] in {'operator', 'seed'}:
                        source_candidate = node['id']
                        break
                if source_candidate:
                    raw_edges.append({'source': source_candidate, 'target': result_id})

        valid_node_ids = {node['id'] for node in nodes}
        edges = []
        for idx, edge in enumerate(raw_edges):
            if not isinstance(edge, dict):
                continue
            source = str(edge.get('source') or '').strip()
            target = str(edge.get('target') or '').strip()
            source = id_mapping.get(source, source)
            target = id_mapping.get(target, target)
            if source not in valid_node_ids or target not in valid_node_ids or source == target:
                continue
            edges.append({'id': f'e_{idx + 1}', 'source': source, 'target': target})

        return {'nodes': nodes, 'edges': edges}

    @classmethod
    async def _run_agent_text(cls, prompt_text: str, model: Any) -> str:
        """Run model once and return plain text."""
        from agno.agent import Agent

        agent = Agent(
            model=model,
            markdown=False,
            description='你是数据建模助手，请严格返回JSON。',
        )
        try:
            run_output = await agent.arun(prompt_text, stream=False)
        except TypeError:
            run_output = await asyncio.to_thread(agent.run, prompt_text)

        if isinstance(run_output, str):
            return run_output
        if hasattr(run_output, 'content') and getattr(run_output, 'content'):
            return str(getattr(run_output, 'content'))
        if hasattr(run_output, 'to_dict'):
            run_dict = run_output.to_dict()
            if isinstance(run_dict, dict) and run_dict.get('content'):
                return str(run_dict.get('content'))
        return str(run_output)

    @classmethod
    async def generate_graph_by_ai(
        cls,
        db: AsyncSession,
        username: str,
        prompt: str,
        ai_model_id: int | None = None,
        include_result_node: bool = True,
    ) -> dict:
        if not prompt or len(prompt.strip()) < 5:
            raise ValueError('请输入更详细的建模需求（至少5个字符）')

        model_row = None
        if ai_model_id:
            model_row = await AiModelDao.get_ai_model_detail_by_id(db, ai_model_id)
            if not model_row:
                raise ValueError('指定的 AI 模型不存在')
        else:
            candidates = await AiModelDao.get_ai_model_list(
                db,
                query_object=AiModelModel(status='0'),
                data_scope_sql=True,
                is_page=False,
            )
            if candidates:
                first = candidates[0]
                model_row = await AiModelDao.get_ai_model_detail_by_id(db, first.get('modelId'))

        if not model_row:
            raise ValueError('没有可用的 AI 模型，请先到 AI 模型管理中启用模型')

        ai_model = AiModelModel(**CamelCaseUtil.transform_result(model_row))
        if not ai_model.api_key:
            raise ValueError('当前 AI 模型未配置 API Key')

        real_api_key = CryptoUtil.decrypt(ai_model.api_key)
        llm_model = AiUtil.get_model_from_factory(
            provider=ai_model.provider,
            model_code=ai_model.model_code,
            model_name=ai_model.model_name,
            api_key=real_api_key,
            base_url=ai_model.base_url,
            temperature=0.2 if ai_model.temperature is None else ai_model.temperature,
            max_tokens=ai_model.max_tokens or 2000,
        )

        seed_list = await SeedService.get_list_visible(db, username)
        op_list = await OperatorService.get_list_visible(db, username)
        if not seed_list:
            raise ValueError('当前没有可用种子，请先创建种子再进行 AI 建模')
        if not op_list:
            raise ValueError('当前没有可用算子，请先初始化算子再进行 AI 建模')

        seed_desc = [
            {'seedId': s.id, 'name': s.name, 'tableName': s.table_name, 'description': s.description or ''}
            for s in seed_list
        ]
        op_desc = [
            {'operatorId': o.id, 'name': o.name, 'opType': o.op_type, 'description': o.description or ''}
            for o in op_list
        ]

        prompt_text = f"""
你是 SQL 数据建模专家。根据用户需求输出可直接用于 VueFlow 的 graph_data JSON。
必须遵守：
1) 只返回 JSON，不要任何解释、不要 markdown。
2) JSON 结构必须是：{{"modelName":"", "modelDescription":"", "graphData":{{"nodes":[...], "edges":[...]}}}}
3) 节点 type 仅可为 seed/operator/result。
4) seed 节点 data 必须包含 seedId；operator 节点 data 必须包含 operatorId 和 opType，可包含 config。
5) edges 的 source/target 必须引用 nodes 里的 id。
6) 优先使用最少节点完成需求，避免无意义复杂链路。

可用 seeds：
{json.dumps(seed_desc, ensure_ascii=False)}

可用 operators：
{json.dumps(op_desc, ensure_ascii=False)}

用户需求：
{prompt.strip()}
""".strip()

        raw_text = await cls._run_agent_text(prompt_text, llm_model)
        parsed = cls._extract_json_object(raw_text)
        graph_data = parsed.get('graphData') if isinstance(parsed, dict) else None
        if not isinstance(graph_data, dict):
            raise ValueError('AI 返回缺少 graphData，请重试')

        seed_dict = {s.id: s for s in seed_list}
        op_dict = {o.id: o for o in op_list}
        normalized = cls._normalize_graph_data(graph_data, seed_dict, op_dict, include_result_node)
        if not normalized.get('nodes'):
            raise ValueError('AI 未生成有效节点，请补充更具体的业务需求后重试')

        return {
            'model_name': str(parsed.get('modelName') or '').strip(),
            'model_description': str(parsed.get('modelDescription') or '').strip(),
            'graph_data': normalized,
            'model_id': ai_model.model_id,
            'model_provider': ai_model.provider or '',
            'model_code': ai_model.model_code or '',
        }

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
