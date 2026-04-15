from typing import Annotated

from fastapi import Query, Response
from sqlalchemy.ext.asyncio import AsyncSession

from common.aspect.db_seesion import DBSessionDependency
from common.aspect.interface_auth import UserInterfaceAuthDependency
from common.aspect.pre_auth import CurrentUserDependency, PreAuthDependency
from common.router import APIRouterPro
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_datamodel.entity.vo.datamodel_vo import SeedModel, SeedUpdateModel
from module_datamodel.service.datamodel_service import SeedService
from utils.response_util import ResponseUtil

seed_controller = APIRouterPro(
    prefix='/datamodel/seed',
    order_num=81,
    tags=['数据建模-种子'],
    dependencies=[PreAuthDependency()],
)


@seed_controller.get(
    '/list',
    summary='获取种子列表',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:list')],
)
async def get_list(
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await SeedService.get_list_visible(query_db, current_user.user.user_name)
    return ResponseUtil.success(data=result)


@seed_controller.get(
    '/{seed_id}',
    summary='获取种子详情',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:query')],
)
async def get_one(
    seed_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await SeedService.get_by_id(query_db, seed_id)
    if not result:
        return ResponseUtil.failure(msg='种子不存在')
    return ResponseUtil.success(data=result)


@seed_controller.post(
    '/',
    summary='新增种子',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:add')],
)
async def create(
    data: SeedModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        payload = data.model_dump()
        payload['create_by'] = current_user.user.user_name
        result = await SeedService.create(query_db, payload)
        return ResponseUtil.success(data=result, msg='新增成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@seed_controller.put(
    '/{seed_id}',
    summary='修改种子',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:edit')],
)
async def update(
    seed_id: int,
    data: SeedUpdateModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        existing = await SeedService.get_by_id(query_db, seed_id)
        if not existing:
            return ResponseUtil.failure(msg='种子不存在')
        if existing.create_by and existing.create_by != current_user.user.user_name:
            return ResponseUtil.failure(msg='只能修改自己创建的种子')
        await SeedService.update(query_db, seed_id, data.model_dump(exclude_unset=True))
        return ResponseUtil.success(msg='修改成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@seed_controller.delete(
    '/{seed_id}',
    summary='删除种子',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:remove')],
)
async def delete(
    seed_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await SeedService.get_by_id(query_db, seed_id)
    if not existing:
        return ResponseUtil.failure(msg='种子不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能删除自己创建的种子')
    await SeedService.delete(query_db, seed_id)
    return ResponseUtil.success(msg='删除成功')


@seed_controller.put(
    '/{seed_id}/share',
    summary='共享/取消共享种子',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:edit')],
)
async def toggle_share(
    seed_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await SeedService.get_by_id(query_db, seed_id)
    if not existing:
        return ResponseUtil.failure(msg='种子不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能共享自己创建的种子')
    new_val = not existing.is_shared
    await SeedService.update(query_db, seed_id, {'is_shared': new_val})
    return ResponseUtil.success(msg='已共享' if new_val else '已取消共享')


@seed_controller.get(
    '/{seed_id}/sample',
    summary='种子取样',
    dependencies=[UserInterfaceAuthDependency('datamodel:seed:list')],
)
async def sample(
    seed_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
    limit: int = Query(default=10, ge=1, le=1000),
) -> Response:
    try:
        result = await SeedService.sample(query_db, seed_id, limit)
        return ResponseUtil.success(data=result)
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))
