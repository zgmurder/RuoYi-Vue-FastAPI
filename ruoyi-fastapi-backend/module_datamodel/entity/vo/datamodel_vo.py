from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional


# ========== DataSource ==========

class DatasourceModel(BaseModel):
    name: str = Field(..., description='数据源名称')
    db_type: str = Field(..., description='数据库类型')
    host: str = Field(default='', description='主机地址')
    port: int = Field(default=0, description='端口')
    database: str = Field(..., description='数据库名')
    username: str = Field(default='', description='用户名')
    password: str = Field(default='', description='密码')


class DatasourceUpdateModel(BaseModel):
    name: Optional[str] = None
    db_type: Optional[str] = None
    host: Optional[str] = None
    port: Optional[int] = None
    database: Optional[str] = None
    username: Optional[str] = None
    password: Optional[str] = None


class DatasourceOutModel(BaseModel):
    id: int
    name: str
    db_type: str
    host: str
    port: int
    database: str
    username: str
    created_at: Optional[datetime] = None

    model_config = {'from_attributes': True}


# ========== Seed ==========

class SeedModel(BaseModel):
    name: str = Field(..., description='种子名称')
    datasource_id: int = Field(..., description='数据源ID')
    table_name: str = Field(..., description='表名')
    description: str = Field(default='', description='描述')


class SeedUpdateModel(BaseModel):
    name: Optional[str] = None
    datasource_id: Optional[int] = None
    table_name: Optional[str] = None
    description: Optional[str] = None


class SeedOutModel(BaseModel):
    id: int
    name: str
    datasource_id: int
    table_name: str
    description: str
    created_at: Optional[datetime] = None

    model_config = {'from_attributes': True}


# ========== Operator ==========

class OperatorModel(BaseModel):
    name: str = Field(..., description='算子名称')
    op_type: str = Field(..., description='算子类型')
    description: str = Field(default='', description='描述')
    sql_template: str = Field(default='', description='SQL模板')
    config_schema: str = Field(default='{}', description='配置schema')


class OperatorOutModel(BaseModel):
    id: int
    name: str
    op_type: str
    description: str
    sql_template: str
    is_builtin: bool
    config_schema: str
    created_at: Optional[datetime] = None

    model_config = {'from_attributes': True}


# ========== Model ==========

class ModelCreateModel(BaseModel):
    name: str = Field(..., description='模型名称')
    description: str = Field(default='', description='描述')
    graph_data: str = Field(default='{}', description='图数据JSON')


class ModelUpdateModel(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    graph_data: Optional[str] = None


class ModelOutModel(BaseModel):
    id: int
    name: str
    description: str
    graph_data: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = {'from_attributes': True}


# ========== Published API ==========

class PublishedApiCreateModel(BaseModel):
    name: str = Field(..., description='API名称')
    path: str = Field(..., description='路径')
    model_id: int = Field(..., description='模型ID')
    description: str = Field(default='', description='描述')
    params: str = Field(default='[]', description='参数定义JSON')


class PublishedApiUpdateModel(BaseModel):
    name: Optional[str] = None
    path: Optional[str] = None
    model_id: Optional[int] = None
    description: Optional[str] = None
    params: Optional[str] = None
    enabled: Optional[bool] = None


class PublishedApiOutModel(BaseModel):
    id: int
    name: str
    path: str
    model_id: int
    description: str
    params: str
    enabled: bool
    created_at: Optional[datetime] = None

    model_config = {'from_attributes': True}


# ========== Execution ==========

class ExecuteNodeModel(BaseModel):
    node_id: str = Field(..., description='节点ID')
    graph_data: str = Field(..., description='图数据JSON')


class TestConnectionModel(BaseModel):
    db_type: str
    host: str = ''
    port: int = 0
    database: str = ''
    username: str = ''
    password: str = ''
