from typing import Annotated

from fastapi import Response
from sqlalchemy.ext.asyncio import AsyncSession

from common.aspect.db_seesion import DBSessionDependency
from common.aspect.interface_auth import UserInterfaceAuthDependency
from common.aspect.pre_auth import CurrentUserDependency, PreAuthDependency
from common.router import APIRouterPro
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_datamodel.entity.vo.datamodel_vo import ExecuteNodeModel, ModelCreateModel, ModelUpdateModel
from module_datamodel.service.datamodel_service import ModelService
from utils.response_util import ResponseUtil

model_controller = APIRouterPro(
    prefix='/datamodel/model',
    order_num=83,
    tags=['数据建模-模型'],
    dependencies=[PreAuthDependency()],
)


@model_controller.get(
    '/list',
    summary='获取模型列表',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:list')],
)
async def get_list(
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await ModelService.get_list_visible(query_db, current_user.user.user_name)
    return ResponseUtil.success(data=result)


@model_controller.get(
    '/{model_id}',
    summary='获取模型详情',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:query')],
)
async def get_one(
    model_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await ModelService.get_by_id(query_db, model_id)
    if not result:
        return ResponseUtil.failure(msg='模型不存在')
    return ResponseUtil.success(data=result)


@model_controller.post(
    '/',
    summary='新增模型',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:add')],
)
async def create(
    data: ModelCreateModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        payload = data.model_dump()
        payload['create_by'] = current_user.user.user_name
        result = await ModelService.create(query_db, payload)
        return ResponseUtil.success(data=result, msg='新增成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@model_controller.put(
    '/{model_id}',
    summary='修改模型',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:edit')],
)
async def update(
    model_id: int,
    data: ModelUpdateModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        existing = await ModelService.get_by_id(query_db, model_id)
        if not existing:
            return ResponseUtil.failure(msg='模型不存在')
        if existing.create_by and existing.create_by != current_user.user.user_name:
            return ResponseUtil.failure(msg='只能修改自己创建的模型')
        await ModelService.update(query_db, model_id, data.model_dump(exclude_unset=True))
        return ResponseUtil.success(msg='修改成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@model_controller.delete(
    '/{model_id}',
    summary='删除模型',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:remove')],
)
async def delete(
    model_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await ModelService.get_by_id(query_db, model_id)
    if not existing:
        return ResponseUtil.failure(msg='模型不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能删除自己创建的模型')
    await ModelService.delete(query_db, model_id)
    return ResponseUtil.success(msg='删除成功')


@model_controller.put(
    '/{model_id}/share',
    summary='共享/取消共享模型',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:edit')],
)
async def toggle_share(
    model_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await ModelService.get_by_id(query_db, model_id)
    if not existing:
        return ResponseUtil.failure(msg='模型不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能共享自己创建的模型')
    new_val = not existing.is_shared
    await ModelService.update(query_db, model_id, {'is_shared': new_val})
    return ResponseUtil.success(msg='已共享' if new_val else '已取消共享')


@model_controller.post(
    '/{model_id}/execute',
    summary='执行模型',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:execute')],
)
async def execute(
    model_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        result = await ModelService.execute(query_db, model_id)
        return ResponseUtil.success(data=result)
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@model_controller.post(
    '/execute-node',
    summary='执行指定节点',
    dependencies=[UserInterfaceAuthDependency('datamodel:model:execute')],
)
async def execute_node(
    data: ExecuteNodeModel,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        result = await ModelService.execute_node(query_db, data.node_id, data.graph_data)
        return ResponseUtil.success(data=result)
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))
