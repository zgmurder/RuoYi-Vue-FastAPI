from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, Integer, String, Text
from sqlalchemy.sql import func
from config.database import Base


class DmDatasource(Base):
    """数据源表"""

    __tablename__ = 'dm_datasource'
    __table_args__ = {'comment': '数据建模-数据源'}

    id = Column(Integer, primary_key=True, autoincrement=True, comment='数据源ID')
    name = Column(String(100), nullable=False, unique=True, comment='数据源名称')
    db_type = Column(String(50), nullable=False, comment='数据库类型')
    host = Column(String(255), default='', comment='主机地址')
    port = Column(Integer, default=0, comment='端口')
    database = Column(String(255), nullable=False, comment='数据库名')
    username = Column(String(100), default='', comment='用户名')
    password = Column(String(255), default='', comment='密码')
    create_by = Column(String(64), default='', comment='创建者')
    is_shared = Column(Boolean, default=False, comment='是否共享')
    created_at = Column(DateTime, server_default=func.now(), comment='创建时间')
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment='更新时间')


class DmSeed(Base):
    """种子表"""

    __tablename__ = 'dm_seed'
    __table_args__ = {'comment': '数据建模-种子'}

    id = Column(Integer, primary_key=True, autoincrement=True, comment='种子ID')
    name = Column(String(100), nullable=False, comment='种子名称')
    datasource_id = Column(Integer, nullable=False, comment='数据源ID')
    table_name = Column(String(255), nullable=False, comment='表名')
    description = Column(Text, default='', comment='描述')
    create_by = Column(String(64), default='', comment='创建者')
    is_shared = Column(Boolean, default=False, comment='是否共享')
    created_at = Column(DateTime, server_default=func.now(), comment='创建时间')


class DmOperator(Base):
    """算子表"""

    __tablename__ = 'dm_operator'
    __table_args__ = {'comment': '数据建模-算子'}

    id = Column(Integer, primary_key=True, autoincrement=True, comment='算子ID')
    name = Column(String(100), nullable=False, comment='算子名称')
    op_type = Column(String(50), nullable=False, comment='算子类型')
    description = Column(Text, default='', comment='描述')
    sql_template = Column(Text, default='', comment='SQL模板')
    is_builtin = Column(Boolean, default=False, comment='是否内置')
    config_schema = Column(Text, default='{}', comment='配置schema')
    create_by = Column(String(64), default='', comment='创建者')
    is_shared = Column(Boolean, default=False, comment='是否共享')
    created_at = Column(DateTime, server_default=func.now(), comment='创建时间')


class DmModel(Base):
    """模型表"""

    __tablename__ = 'dm_model'
    __table_args__ = {'comment': '数据建模-模型'}

    id = Column(Integer, primary_key=True, autoincrement=True, comment='模型ID')
    name = Column(String(100), nullable=False, comment='模型名称')
    description = Column(Text, default='', comment='描述')
    graph_data = Column(Text, default='{}', comment='图数据JSON')
    create_by = Column(String(64), default='', comment='创建者')
    is_shared = Column(Boolean, default=False, comment='是否共享')
    created_at = Column(DateTime, server_default=func.now(), comment='创建时间')
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment='更新时间')


class DmPublishedApi(Base):
    """已发布API表"""

    __tablename__ = 'dm_published_api'
    __table_args__ = {'comment': '数据建模-已发布API'}

    id = Column(Integer, primary_key=True, autoincrement=True, comment='API ID')
    name = Column(String(100), nullable=False, comment='API名称')
    path = Column(String(255), nullable=False, unique=True, comment='路径')
    model_id = Column(Integer, nullable=False, comment='模型ID')
    description = Column(Text, default='', comment='描述')
    params = Column(Text, default='[]', comment='参数定义JSON')
    enabled = Column(Boolean, default=True, comment='是否启用')
    create_by = Column(String(64), default='', comment='创建者')
    is_shared = Column(Boolean, default=False, comment='是否共享')
    created_at = Column(DateTime, server_default=func.now(), comment='创建时间')
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment='更新时间')
