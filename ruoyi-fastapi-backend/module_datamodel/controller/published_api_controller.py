import json
from typing import Annotated

from fastapi import Request, Response
from sqlalchemy.ext.asyncio import AsyncSession

from common.aspect.db_seesion import DBSessionDependency
from common.aspect.interface_auth import UserInterfaceAuthDependency
from common.aspect.pre_auth import CurrentUserDependency, PreAuthDependency
from common.router import APIRouterPro
from module_admin.entity.vo.user_vo import CurrentUserModel
from module_datamodel.entity.vo.datamodel_vo import PublishedApiCreateModel, PublishedApiUpdateModel
from module_datamodel.service.datamodel_service import PublishedApiService
from utils.response_util import ResponseUtil

# ---- CRUD (requires auth) ----

api_controller = APIRouterPro(
    prefix='/datamodel/published-api',
    order_num=84,
    tags=['数据建模-API管理'],
    dependencies=[PreAuthDependency()],
)


@api_controller.get(
    '/list',
    summary='获取已发布API列表',
    dependencies=[UserInterfaceAuthDependency('datamodel:api:list')],
)
async def get_list(
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await PublishedApiService.get_list_visible(query_db, current_user.user.user_name)
    return ResponseUtil.success(data=result)


@api_controller.get(
    '/{api_id}',
    summary='获取API详情',
    dependencies=[UserInterfaceAuthDependency('datamodel:api:query')],
)
async def get_one(
    api_id: int,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    result = await PublishedApiService.get_by_id(query_db, api_id)
    if not result:
        return ResponseUtil.failure(msg='API不存在')
    return ResponseUtil.success(data=result)


@api_controller.post(
    '/',
    summary='发布API',
    dependencies=[UserInterfaceAuthDependency('datamodel:api:add')],
)
async def create(
    data: PublishedApiCreateModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        payload = data.model_dump()
        payload['create_by'] = current_user.user.user_name
        result = await PublishedApiService.create(query_db, payload)
        return ResponseUtil.success(data=result, msg='发布成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@api_controller.put(
    '/{api_id}',
    summary='修改API',
    dependencies=[UserInterfaceAuthDependency('datamodel:api:edit')],
)
async def update(
    api_id: int,
    data: PublishedApiUpdateModel,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        existing = await PublishedApiService.get_by_id(query_db, api_id)
        if not existing:
            return ResponseUtil.failure(msg='API不存在')
        if existing.create_by and existing.create_by != current_user.user.user_name:
            return ResponseUtil.failure(msg='只能修改自己创建的API')
        await PublishedApiService.update(query_db, api_id, data.model_dump(exclude_unset=True))
        return ResponseUtil.success(msg='修改成功')
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))


@api_controller.delete(
    '/{api_id}',
    summary='删除API',
    dependencies=[UserInterfaceAuthDependency('datamodel:api:remove')],
)
async def delete(
    api_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await PublishedApiService.get_by_id(query_db, api_id)
    if not existing:
        return ResponseUtil.failure(msg='API不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能删除自己创建的API')
    await PublishedApiService.delete(query_db, api_id)
    return ResponseUtil.success(msg='删除成功')


@api_controller.put(
    '/{api_id}/share',
    summary='共享/取消共享API',
    dependencies=[UserInterfaceAuthDependency('datamodel:api:edit')],
)
async def toggle_share(
    api_id: int,
    current_user: Annotated[CurrentUserModel, CurrentUserDependency()],
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    existing = await PublishedApiService.get_by_id(query_db, api_id)
    if not existing:
        return ResponseUtil.failure(msg='API不存在')
    if existing.create_by and existing.create_by != current_user.user.user_name:
        return ResponseUtil.failure(msg='只能共享自己创建的API')
    new_val = not existing.is_shared
    await PublishedApiService.update(query_db, api_id, {'is_shared': new_val})
    return ResponseUtil.success(msg='已共享' if new_val else '已取消共享')


# ---- Dynamic invocation (no auth — public open API) ----

openapi_controller = APIRouterPro(
    prefix='/openapi',
    order_num=85,
    tags=['数据建模-开放API'],
)


@openapi_controller.get(
    '/{api_path:path}',
    summary='调用已发布API (GET)',
)
async def call_api_get(
    api_path: str,
    request: Request,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    params = dict(request.query_params)
    return await _invoke_api(api_path, params, query_db)


@openapi_controller.post(
    '/{api_path:path}',
    summary='调用已发布API (POST)',
)
async def call_api_post(
    api_path: str,
    request: Request,
    query_db: Annotated[AsyncSession, DBSessionDependency()],
) -> Response:
    try:
        body = await request.json()
    except Exception:
        body = {}
    params = dict(request.query_params)
    params.update(body)
    return await _invoke_api(api_path, params, query_db)


async def _invoke_api(api_path: str, params: dict, db: AsyncSession) -> Response:
    try:
        result = await PublishedApiService.invoke(db, api_path, params)
        return ResponseUtil.success(data=result)
    except ValueError as e:
        return ResponseUtil.failure(msg=str(e))
