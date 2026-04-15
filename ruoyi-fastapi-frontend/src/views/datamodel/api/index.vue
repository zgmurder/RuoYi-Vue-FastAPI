<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入API名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['datamodel:api:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" prop="id" width="60" />
      <el-table-column label="API名称" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="路径" prop="path" :show-overflow-tooltip="true">
        <template #default="{ row }">
          <el-tag size="small">/openapi/{{ row.path }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="关联模型" prop="model_name" :show-overflow-tooltip="true" />
      <el-table-column label="描述" prop="description" :show-overflow-tooltip="true" />
      <el-table-column label="状态" prop="enabled" width="80">
        <template #default="{ row }">
          <el-tag :type="row.enabled ? 'success' : 'info'" size="small">{{ row.enabled ? '启用' : '停用' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="created_at" width="160" />
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" icon="CopyDocument" @click="handleCopyUrl(row)">复制</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(row)" v-hasPermi="['datamodel:api:edit']">修改</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(row)" v-hasPermi="['datamodel:api:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/修改对话框 -->
    <el-dialog :title="dialog.title" v-model="dialog.visible" width="600px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="API名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入API名称" />
        </el-form-item>
        <el-form-item label="路径" prop="path">
          <el-input v-model="form.path" placeholder="请输入路径 (如: my-api)">
            <template #prepend>/openapi/</template>
          </el-input>
        </el-form-item>
        <el-form-item label="关联模型" prop="model_id">
          <el-select v-model="form.model_id" placeholder="选择模型" style="width: 100%">
            <el-option v-for="m in models" :key="m.id" :label="m.name" :value="m.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="参数定义" prop="params">
          <el-input v-model="form.params" type="textarea" :rows="3" placeholder='[{"name":"param1","type":"string","required":true,"default":""}]' />
        </el-form-item>
        <el-form-item label="状态" prop="enabled">
          <el-switch v-model="form.enabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="ApiManage">
import { ref, reactive, onMounted } from 'vue'
import { listPublishedApi, addPublishedApi, updatePublishedApi, delPublishedApi, listModel } from '@/api/datamodel/index'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const showSearch = ref(true)
const dataList = ref([])
const models = ref([])
const queryParams = reactive({ name: '' })
const dialog = reactive({ visible: false, title: '' })
const form = ref({})
const formRef = ref(null)
const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  path: [{ required: true, message: '请输入路径', trigger: 'blur' }],
  model_id: [{ required: true, message: '请选择模型', trigger: 'change' }],
}

function getList() {
  loading.value = true
  Promise.all([listPublishedApi(), listModel()]).then(([apiRes, modelRes]) => {
    models.value = modelRes.data || []
    const modelMap = {}
    models.value.forEach(m => modelMap[m.id] = m.name)
    let list = (apiRes.data || []).map(a => ({ ...a, model_name: modelMap[a.model_id] || a.model_id }))
    if (queryParams.name) list = list.filter(a => a.name.includes(queryParams.name))
    dataList.value = list
  }).finally(() => loading.value = false)
}
function handleQuery() { getList() }
function resetQuery() { queryParams.name = ''; getList() }
function handleAdd() {
  form.value = { name: '', path: '', model_id: null, description: '', params: '[]', enabled: true }
  dialog.title = '新增API'; dialog.visible = true
}
function handleUpdate(row) {
  form.value = { ...row, params: typeof row.params === 'string' ? row.params : JSON.stringify(row.params || []) }
  dialog.title = '修改API'; dialog.visible = true
}
function submitForm() {
  formRef.value.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.id) {
      updatePublishedApi(data.id, data).then(() => { ElMessage.success('修改成功'); dialog.visible = false; getList() })
    } else {
      addPublishedApi(data).then(() => { ElMessage.success('新增成功'); dialog.visible = false; getList() })
    }
  })
}
function handleDelete(row) {
  ElMessageBox.confirm('确认删除API "' + row.name + '"？', '提示', { type: 'warning' }).then(() => {
    delPublishedApi(row.id).then(() => { ElMessage.success('删除成功'); getList() })
  }).catch(() => {})
}
function handleCopyUrl(row) {
  const url = window.location.origin + '/openapi/' + row.path
  navigator.clipboard.writeText(url).then(() => ElMessage.success('已复制: ' + url)).catch(() => ElMessage.error('复制失败'))
}

onMounted(() => getList())
</script>
