from typing import Annotated

from fastapi import Response
from sqlalchemy.ext.asyncio import AsyncSession

from common.aspect.db_seesion import DBSessionDependency
from common.aspect.interface_auth import UserInterfaceAuthDependency
from common.aspect.pre_auth import CurrentUserDependency, PreAuthDependency
from common.router import APIRouterPro
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_datamodel.entity.vo.datamodel_vo import OperatorModel
from module_datamodel.service.datamodel_service import OperatorService
from utils.response_util import ResponseUtil

operator_controller = APIRouterPro(
    prefix='/datamodel/operator',
    order_num=82,
    tags=['数据建模-算子'],
    dependencies=[PreAuthDependency()],
)


@operator_controller.get(
    '/list',
    summary='获取算子列表',
    dependencies=[UserInterfaceAuthDependency('datamodel:operator:list')],
)
async def get_list(
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await OperatorService.get_list_visible(query_db, current_user.user.user_name)
    return ResponseUtil.success(data=result)


@operator_controller.post(
    '/',
    summary='新增自定义算子',
    dependencies=[UserInterfaceAuthDependency('datamodel:operator:add')],
)
async def create(
    data: OperatorModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        payload = data.model_dump()
        payload['create_by'] = current_user.user.user_name
        result = await OperatorService.create(query_db, payload)
        return ResponseUtil.success(data=result, msg='新增成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@operator_controller.delete(
    '/{op_id}',
    summary='删除算子',
    dependencies=[UserInterfaceAuthDependency('datamodel:operator:remove')],
)
async def delete(
    op_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        existing = await OperatorService.get_by_id(query_db, op_id)
        if not existing:
            return ResponseUtil.failure(msg='算子不存在')
        if existing.create_by and existing.create_by != current_user.user.user_name:
            return ResponseUtil.failure(msg='只能删除自己创建的算子')
        await OperatorService.delete(query_db, op_id)
        return ResponseUtil.success(msg='删除成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@operator_controller.put(
    '/{op_id}/share',
    summary='共享/取消共享算子',
    dependencies=[UserInterfaceAuthDependency('datamodel:operator:edit')],
)
async def toggle_share(
    op_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await OperatorService.get_by_id(query_db, op_id)
    if not existing:
        return ResponseUtil.failure(msg='算子不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能共享自己创建的算子')
    new_val = not existing.is_shared
    await OperatorService.update(query_db, op_id, {'is_shared': new_val})
    return ResponseUtil.success(msg='已共享' if new_val else '已取消共享')
