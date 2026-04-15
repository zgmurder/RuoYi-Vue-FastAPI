from typing import Annotated

from fastapi import Response
from sqlalchemy.ext.asyncio import AsyncSession

from common.aspect.db_seesion import DBSessionDependency
from common.aspect.interface_auth import UserInterfaceAuthDependency
from common.aspect.pre_auth import CurrentUserDependency, PreAuthDependency
from common.router import APIRouterPro
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_datamodel.entity.vo.datamodel_vo import DatasourceModel, DatasourceUpdateModel, TestConnectionModel
from module_datamodel.service.datamodel_service import DatasourceService
from utils.response_util import ResponseUtil

datasource_controller = APIRouterPro(
    prefix='/datamodel/datasource',
    order_num=80,
    tags=['数据建模-数据源'],
    dependencies=[PreAuthDependency()],
)


@datasource_controller.get(
    '/list',
    summary='获取数据源列表',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:list')],
)
async def get_list(
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await DatasourceService.get_list_visible(query_db, current_user.user.user_name)
    return ResponseUtil.success(data=result)


@datasource_controller.get(
    '/{ds_id}',
    summary='获取数据源详情',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:query')],
)
async def get_one(
    ds_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await DatasourceService.get_by_id(query_db, ds_id)
    if not result:
        return ResponseUtil.failure(msg='数据源不存在')
    return ResponseUtil.success(data=result)


@datasource_controller.post(
    '/',
    summary='新增数据源',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:add')],
)
async def create(
    data: DatasourceModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        payload = data.model_dump()
        payload['create_by'] = current_user.user.user_name
        result = await DatasourceService.create(query_db, payload)
        return ResponseUtil.success(data=result, msg='新增成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@datasource_controller.put(
    '/{ds_id}',
    summary='修改数据源',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:edit')],
)
async def update(
    ds_id: int,
    data: DatasourceUpdateModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        existing = await DatasourceService.get_by_id(query_db, ds_id)
        if not existing:
            return ResponseUtil.failure(msg='数据源不存在')
        if existing.create_by and existing.create_by != current_user.user.user_name:
            return ResponseUtil.failure(msg='只能修改自己创建的数据源')
        await DatasourceService.update(query_db, ds_id, data.model_dump(exclude_unset=True))
        return ResponseUtil.success(msg='修改成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@datasource_controller.delete(
    '/{ds_id}',
    summary='删除数据源',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:remove')],
)
async def delete(
    ds_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await DatasourceService.get_by_id(query_db, ds_id)
    if not existing:
        return ResponseUtil.failure(msg='数据源不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能删除自己创建的数据源')
    await DatasourceService.delete(query_db, ds_id)
    return ResponseUtil.success(msg='删除成功')


@datasource_controller.put(
    '/{ds_id}/share',
    summary='共享/取消共享数据源',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:edit')],
)
async def toggle_share(
    ds_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await DatasourceService.get_by_id(query_db, ds_id)
    if not existing:
        return ResponseUtil.failure(msg='数据源不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能共享自己创建的数据源')
    new_val = not existing.is_shared
    await DatasourceService.update(query_db, ds_id, {'is_shared': new_val})
    return ResponseUtil.success(msg='已共享' if new_val else '已取消共享')


@datasource_controller.post(
    '/test-connection',
    summary='测试数据源连接',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:add')],
)
async def test_connection(data: TestConnectionModel) -> Response:
    result = await DatasourceService.test_connection(data.model_dump())
    if result['success']:
        return ResponseUtil.success(msg=result['message'])
    return ResponseUtil.failure(msg=result['message'])


@datasource_controller.get(
    '/{ds_id}/tables',
    summary='获取数据源表列表',
    dependencies=[UserInterfaceAuthDependency('datamodel:datasource:list')],
)
async def list_tables(
    ds_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        tables = await DatasourceService.list_tables(query_db, ds_id)
        return ResponseUtil.success(data=tables)
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))
