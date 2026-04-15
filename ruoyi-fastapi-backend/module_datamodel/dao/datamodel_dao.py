from sqlalchemy import delete, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from module_datamodel.entity.do.datamodel_do import (
    DmDatasource,
    DmModel,
    DmOperator,
    DmPublishedApi,
    DmSeed,
)


class DatasourceDao:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmDatasource]:
        result = await db.execute(select(DmDatasource).order_by(DmDatasource.id.desc()))
        return list(result.scalars().all())

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmDatasource]:
        result = await db.execute(
            select(DmDatasource)
            .where(or_(DmDatasource.create_by == username, DmDatasource.is_shared == True, DmDatasource.create_by == ''))
            .order_by(DmDatasource.id.desc())
        )
        return list(result.scalars().all())

    @classmethod
    async def get_by_id(cls, db: AsyncSession, ds_id: int) -> DmDatasource | None:
        result = await db.execute(select(DmDatasource).where(DmDatasource.id == ds_id))
        return result.scalars().first()

    @classmethod
    async def get_by_name(cls, db: AsyncSession, name: str) -> DmDatasource | None:
        result = await db.execute(select(DmDatasource).where(DmDatasource.name == name))
        return result.scalars().first()

    @classmethod
    async def create(cls, db: AsyncSession, obj: DmDatasource) -> DmDatasource:
        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj

    @classmethod
    async def update_by_id(cls, db: AsyncSession, ds_id: int, data: dict) -> None:
        await db.execute(update(DmDatasource).where(DmDatasource.id == ds_id).values(**data))
        await db.commit()

    @classmethod
    async def delete_by_id(cls, db: AsyncSession, ds_id: int) -> None:
        await db.execute(delete(DmDatasource).where(DmDatasource.id == ds_id))
        await db.commit()


class SeedDao:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmSeed]:
        result = await db.execute(select(DmSeed).order_by(DmSeed.id.desc()))
        return list(result.scalars().all())

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmSeed]:
        result = await db.execute(
            select(DmSeed)
            .where(or_(DmSeed.create_by == username, DmSeed.is_shared == True, DmSeed.create_by == ''))
            .order_by(DmSeed.id.desc())
        )
        return list(result.scalars().all())

    @classmethod
    async def get_by_id(cls, db: AsyncSession, seed_id: int) -> DmSeed | None:
        result = await db.execute(select(DmSeed).where(DmSeed.id == seed_id))
        return result.scalars().first()

    @classmethod
    async def create(cls, db: AsyncSession, obj: DmSeed) -> DmSeed:
        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj

    @classmethod
    async def update_by_id(cls, db: AsyncSession, seed_id: int, data: dict) -> None:
        await db.execute(update(DmSeed).where(DmSeed.id == seed_id).values(**data))
        await db.commit()

    @classmethod
    async def delete_by_id(cls, db: AsyncSession, seed_id: int) -> None:
        await db.execute(delete(DmSeed).where(DmSeed.id == seed_id))
        await db.commit()


class OperatorDao:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmOperator]:
        result = await db.execute(select(DmOperator).order_by(DmOperator.id.desc()))
        return list(result.scalars().all())

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmOperator]:
        result = await db.execute(
            select(DmOperator)
            .where(or_(DmOperator.create_by == username, DmOperator.is_shared == True, DmOperator.is_builtin == True, DmOperator.create_by == ''))
            .order_by(DmOperator.id.desc())
        )
        return list(result.scalars().all())

    @classmethod
    async def get_by_id(cls, db: AsyncSession, op_id: int) -> DmOperator | None:
        result = await db.execute(select(DmOperator).where(DmOperator.id == op_id))
        return result.scalars().first()

    @classmethod
    async def get_by_op_type(cls, db: AsyncSession, op_type: str) -> DmOperator | None:
        result = await db.execute(select(DmOperator).where(DmOperator.op_type == op_type))
        return result.scalars().first()

    @classmethod
    async def create(cls, db: AsyncSession, obj: DmOperator) -> DmOperator:
        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj

    @classmethod
    async def update_by_id(cls, db: AsyncSession, op_id: int, data: dict) -> None:
        await db.execute(update(DmOperator).where(DmOperator.id == op_id).values(**data))
        await db.commit()

    @classmethod
    async def delete_by_id(cls, db: AsyncSession, op_id: int) -> None:
        await db.execute(delete(DmOperator).where(DmOperator.id == op_id))
        await db.commit()


class ModelDao:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmModel]:
        result = await db.execute(select(DmModel).order_by(DmModel.id.desc()))
        return list(result.scalars().all())

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmModel]:
        result = await db.execute(
            select(DmModel)
            .where(or_(DmModel.create_by == username, DmModel.is_shared == True, DmModel.create_by == ''))
            .order_by(DmModel.id.desc())
        )
        return list(result.scalars().all())

    @classmethod
    async def get_by_id(cls, db: AsyncSession, model_id: int) -> DmModel | None:
        result = await db.execute(select(DmModel).where(DmModel.id == model_id))
        return result.scalars().first()

    @classmethod
    async def create(cls, db: AsyncSession, obj: DmModel) -> DmModel:
        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj

    @classmethod
    async def update_by_id(cls, db: AsyncSession, model_id: int, data: dict) -> None:
        await db.execute(update(DmModel).where(DmModel.id == model_id).values(**data))
        await db.commit()

    @classmethod
    async def delete_by_id(cls, db: AsyncSession, model_id: int) -> None:
        await db.execute(delete(DmModel).where(DmModel.id == model_id))
        await db.commit()


class PublishedApiDao:

    @classmethod
    async def get_list(cls, db: AsyncSession) -> list[DmPublishedApi]:
        result = await db.execute(select(DmPublishedApi).order_by(DmPublishedApi.id.desc()))
        return list(result.scalars().all())

    @classmethod
    async def get_list_visible(cls, db: AsyncSession, username: str) -> list[DmPublishedApi]:
        result = await db.execute(
            select(DmPublishedApi)
            .where(or_(DmPublishedApi.create_by == username, DmPublishedApi.is_shared == True, DmPublishedApi.create_by == ''))
            .order_by(DmPublishedApi.id.desc())
        )
        return list(result.scalars().all())

    @classmethod
    async def get_by_id(cls, db: AsyncSession, api_id: int) -> DmPublishedApi | None:
        result = await db.execute(select(DmPublishedApi).where(DmPublishedApi.id == api_id))
        return result.scalars().first()

    @classmethod
    async def get_by_path(cls, db: AsyncSession, path: str) -> DmPublishedApi | None:
        result = await db.execute(select(DmPublishedApi).where(DmPublishedApi.path == path))
        return result.scalars().first()

    @classmethod
    async def create(cls, db: AsyncSession, obj: DmPublishedApi) -> DmPublishedApi:
        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj

    @classmethod
    async def update_by_id(cls, db: AsyncSession, api_id: int, data: dict) -> None:
        await db.execute(update(DmPublishedApi).where(DmPublishedApi.id == api_id).values(**data))
        await db.commit()

    @classmethod
    async def delete_by_id(cls, db: AsyncSession, api_id: int) -> None:
        await db.execute(delete(DmPublishedApi).where(DmPublishedApi.id == api_id))
        await db.commit()
