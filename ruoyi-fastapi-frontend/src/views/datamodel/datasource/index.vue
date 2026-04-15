<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入数据源名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="类型" prop="dbType">
        <el-select v-model="queryParams.dbType" placeholder="数据库类型" clearable style="width: 150px">
          <el-option label="MySQL" value="mysql" />
          <el-option label="PostgreSQL" value="postgresql" />
          <el-option label="SQLite" value="sqlite" />
          <el-option label="Oracle" value="oracle" />
          <el-option label="SQL Server" value="sqlserver" />
          <el-option label="ClickHouse" value="clickhouse" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['datamodel:datasource:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" prop="id" width="60" />
      <el-table-column label="名称" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="类型" prop="db_type" width="120" />
      <el-table-column label="主机" prop="host" :show-overflow-tooltip="true" />
      <el-table-column label="端口" prop="port" width="80" />
      <el-table-column label="数据库" prop="database" :show-overflow-tooltip="true" />
      <el-table-column label="用户名" prop="username" width="120" />
      <el-table-column label="创建时间" prop="created_at" width="160" />
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" icon="Connection" @click="handleTest(row)" v-hasPermi="['datamodel:datasource:test']">测试</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(row)" v-hasPermi="['datamodel:datasource:edit']">修改</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(row)" v-hasPermi="['datamodel:datasource:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/修改对话框 -->
    <el-dialog :title="dialog.title" v-model="dialog.visible" width="550px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入数据源名称" />
        </el-form-item>
        <el-form-item label="类型" prop="db_type">
          <el-select v-model="form.db_type" placeholder="选择数据库类型" style="width: 100%">
            <el-option label="MySQL" value="mysql" />
            <el-option label="PostgreSQL" value="postgresql" />
            <el-option label="SQLite" value="sqlite" />
            <el-option label="Oracle" value="oracle" />
            <el-option label="SQL Server" value="sqlserver" />
            <el-option label="ClickHouse" value="clickhouse" />
          </el-select>
        </el-form-item>
        <el-form-item label="主机" prop="host" v-if="form.db_type !== 'sqlite'">
          <el-input v-model="form.host" placeholder="请输入主机地址" />
        </el-form-item>
        <el-form-item label="端口" prop="port" v-if="form.db_type !== 'sqlite'">
          <el-input-number v-model="form.port" :min="0" :max="65535" style="width: 100%" />
        </el-form-item>
        <el-form-item label="数据库" prop="database">
          <el-input v-model="form.database" placeholder="请输入数据库名" />
        </el-form-item>
        <el-form-item label="用户名" prop="username" v-if="form.db_type !== 'sqlite'">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="form.db_type !== 'sqlite'">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="DatasourceManage">
import { ref, reactive, onMounted } from 'vue'
import { listDatasource, addDatasource, updateDatasource, delDatasource, testConnection } from '@/api/datamodel/index'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const showSearch = ref(true)
const dataList = ref([])
const queryParams = reactive({ name: '', dbType: '' })
const dialog = reactive({ visible: false, title: '' })
const form = ref({})
const formRef = ref(null)
const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  db_type: [{ required: true, message: '请选择类型', trigger: 'change' }],
  database: [{ required: true, message: '请输入数据库名', trigger: 'blur' }],
}

function getList() {
  loading.value = true
  listDatasource().then(res => {
    let list = res.data || []
    if (queryParams.name) list = list.filter(d => d.name.includes(queryParams.name))
    if (queryParams.dbType) list = list.filter(d => d.db_type === queryParams.dbType)
    dataList.value = list
  }).finally(() => loading.value = false)
}
function handleQuery() { getList() }
function resetQuery() { queryParams.name = ''; queryParams.dbType = ''; getList() }
function handleAdd() {
  form.value = { name: '', db_type: 'mysql', host: '', port: 3306, database: '', username: '', password: '' }
  dialog.title = '新增数据源'; dialog.visible = true
}
function handleUpdate(row) {
  form.value = { ...row }
  dialog.title = '修改数据源'; dialog.visible = true
}
function submitForm() {
  formRef.value.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.id) {
      updateDatasource(data.id, data).then(() => { ElMessage.success('修改成功'); dialog.visible = false; getList() })
    } else {
      addDatasource(data).then(() => { ElMessage.success('新增成功'); dialog.visible = false; getList() })
    }
  })
}
function handleDelete(row) {
  ElMessageBox.confirm('确认删除数据源 "' + row.name + '"？', '提示', { type: 'warning' }).then(() => {
    delDatasource(row.id).then(() => { ElMessage.success('删除成功'); getList() })
  }).catch(() => {})
}
function handleTest(row) {
  testConnection(row).then(res => {
    if (res.code === 200) ElMessage.success('连接成功')
    else ElMessage.error(res.msg || '连接失败')
  }).catch(() => ElMessage.error('连接失败'))
}

onMounted(() => getList())
</script>
