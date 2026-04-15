<template>
  <div class="app-container">
    <el-form :model="queryParams" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入算子名称" clearable style="width: 220px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="类型" prop="opType">
        <el-input v-model="queryParams.opType" placeholder="请输入算子类型" clearable style="width: 180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['datamodel:operator:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" prop="id" width="60" />
      <el-table-column label="算子名称" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="算子类型" prop="op_type" width="140" />
      <el-table-column label="描述" prop="description" :show-overflow-tooltip="true" />
      <el-table-column label="来源" width="100">
        <template #default="{ row }">
          <el-tag size="small" :type="row.is_builtin ? 'info' : 'success'">
            {{ row.is_builtin ? '内置' : '自定义' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="共享" width="90">
        <template #default="{ row }">
          <el-tag size="small" :type="row.is_shared ? 'success' : 'info'">
            {{ row.is_shared ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="created_at" width="170" />
      <el-table-column label="操作" width="210" fixed="right">
        <template #default="{ row }">
          <el-button
            link
            type="success"
            icon="Share"
            @click="handleShare(row)"
            v-hasPermi="['datamodel:operator:edit']"
            :disabled="row.is_builtin"
          >
            {{ row.is_shared ? '取消共享' : '共享' }}
          </el-button>
          <el-button
            link
            type="danger"
            icon="Delete"
            @click="handleDelete(row)"
            v-hasPermi="['datamodel:operator:remove']"
            :disabled="row.is_builtin"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog :title="dialog.title" v-model="dialog.visible" width="620px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="算子名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入算子名称" />
        </el-form-item>
        <el-form-item label="算子类型" prop="op_type">
          <el-select v-model="form.op_type" placeholder="请选择算子类型" style="width: 100%">
            <el-option label="union" value="union" />
            <el-option label="union_all" value="union_all" />
            <el-option label="intersect" value="intersect" />
            <el-option label="except" value="except" />
            <el-option label="join" value="join" />
            <el-option label="filter" value="filter" />
            <el-option label="group" value="group" />
            <el-option label="sort" value="sort" />
            <el-option label="limit" value="limit" />
            <el-option label="custom" value="custom" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="配置Schema" prop="config_schema">
          <el-input
            v-model="form.config_schema"
            type="textarea"
            :rows="4"
            placeholder='例如: {"sortField":"id","sortOrder":"ASC"}'
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="OperatorManage">
import { ref, reactive, onMounted } from 'vue'
import { listOperator, addOperator, delOperator, shareOperator } from '@/api/datamodel/index'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const showSearch = ref(true)
const dataList = ref([])
const queryParams = reactive({ name: '', opType: '' })
const dialog = reactive({ visible: false, title: '' })
const formRef = ref(null)
const form = ref({
  name: '',
  op_type: 'custom',
  description: '',
  sql_template: '',
  config_schema: '{}',
})

const rules = {
  name: [{ required: true, message: '请输入算子名称', trigger: 'blur' }],
  op_type: [{ required: true, message: '请选择算子类型', trigger: 'change' }],
}

function getList() {
  loading.value = true
  listOperator().then(res => {
    let list = res.data || []
    if (queryParams.name) list = list.filter(item => (item.name || '').includes(queryParams.name))
    if (queryParams.opType) list = list.filter(item => (item.op_type || '').includes(queryParams.opType))
    dataList.value = list
  }).finally(() => {
    loading.value = false
  })
}

function handleQuery() {
  getList()
}

function resetQuery() {
  queryParams.name = ''
  queryParams.opType = ''
  getList()
}

function handleAdd() {
  form.value = {
    name: '',
    op_type: 'custom',
    description: '',
    sql_template: '',
    config_schema: '{}',
  }
  dialog.title = '新增算子'
  dialog.visible = true
}

function submitForm() {
  formRef.value.validate(valid => {
    if (!valid) return

    try {
      JSON.parse(form.value.config_schema || '{}')
    } catch (e) {
      ElMessage.error('配置Schema必须是合法JSON')
      return
    }

    addOperator(form.value).then(() => {
      ElMessage.success('新增成功')
      dialog.visible = false
      getList()
    })
  })
}

function handleDelete(row) {
  if (row.is_builtin) {
    ElMessage.warning('内置算子不允许删除')
    return
  }
  ElMessageBox.confirm(`确认删除算子 "${row.name}"？`, '提示', { type: 'warning' }).then(() => {
    delOperator(row.id).then(() => {
      ElMessage.success('删除成功')
      getList()
    })
  }).catch(() => {})
}

function handleShare(row) {
  if (row.is_builtin) {
    ElMessage.warning('内置算子不支持共享设置')
    return
  }
  shareOperator(row.id).then(() => {
    ElMessage.success(row.is_shared ? '已取消共享' : '已共享')
    getList()
  })
}

onMounted(() => {
  getList()
})
</script>
