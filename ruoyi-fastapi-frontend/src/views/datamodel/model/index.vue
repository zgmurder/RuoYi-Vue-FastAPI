<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入模型名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['datamodel:model:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" prop="id" width="60" />
      <el-table-column label="模型名称" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="描述" prop="description" :show-overflow-tooltip="true" />
      <el-table-column label="创建时间" prop="created_at" width="160" />
      <el-table-column label="更新时间" prop="updated_at" width="160" />
      <el-table-column label="操作" width="280" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" icon="CaretRight" @click="handleExecute(row)" v-hasPermi="['datamodel:model:execute']">执行</el-button>
          <el-button link type="primary" icon="Edit" @click="handleEdit(row)" v-hasPermi="['datamodel:model:edit']">编辑</el-button>
          <el-button link type="primary" icon="EditPen" @click="handleRename(row)" v-hasPermi="['datamodel:model:edit']">重命名</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(row)" v-hasPermi="['datamodel:model:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/重命名对话框 -->
    <el-dialog :title="dialog.title" v-model="dialog.visible" width="450px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入模型名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialog.visible = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>

    <!-- 执行结果对话框 -->
    <el-dialog title="执行结果" v-model="resultVisible" width="800px" append-to-body>
      <el-alert v-if="resultError" :title="resultError" type="error" show-icon :closable="false" class="mb8" />
      <el-table v-else :data="resultData" border max-height="400" size="small">
        <el-table-column v-for="col in resultCols" :key="col" :label="col" :prop="col" :show-overflow-tooltip="true" min-width="120" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup name="ModelManage">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { listModel, addModel, updateModel, delModel, executeModel } from '@/api/datamodel/index'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const showSearch = ref(true)
const dataList = ref([])
const queryParams = reactive({ name: '' })
const dialog = reactive({ visible: false, title: '' })
const form = ref({})
const formRef = ref(null)
const rules = { name: [{ required: true, message: '请输入名称', trigger: 'blur' }] }
const resultVisible = ref(false)
const resultData = ref([])
const resultCols = ref([])
const resultError = ref('')

function getList() {
  loading.value = true
  listModel().then(res => {
    let list = res.data || []
    if (queryParams.name) list = list.filter(m => m.name.includes(queryParams.name))
    dataList.value = list
  }).finally(() => loading.value = false)
}
function handleQuery() { getList() }
function resetQuery() { queryParams.name = ''; getList() }
function handleAdd() {
  form.value = { name: '', description: '' }
  dialog.title = '新增模型'; dialog.visible = true
}
function handleRename(row) {
  form.value = { id: row.id, name: row.name, description: row.description }
  dialog.title = '重命名模型'; dialog.visible = true
}
function submitForm() {
  formRef.value.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.id) {
      updateModel(data.id, { name: data.name, description: data.description }).then(() => { ElMessage.success('操作成功'); dialog.visible = false; getList() })
    } else {
      addModel(data).then(() => { ElMessage.success('新增成功'); dialog.visible = false; getList() })
    }
  })
}
function handleEdit(row) {
  // Navigate to workbench with model loaded
  router.push({ path: '/datamodel/workbench', query: { modelId: row.id } })
}
function handleExecute(row) {
  executeModel(row.id).then(res => {
    const d = res.data || {}
    if (d.error) { resultError.value = d.error; resultCols.value = []; resultData.value = [] }
    else {
      resultError.value = ''
      resultCols.value = d.columns || []
      resultData.value = (d.rows || []).map(r => {
        if (r && typeof r === 'object' && !Array.isArray(r)) return r
        const obj = {}
        resultCols.value.forEach((c, i) => { obj[c] = r?.[i] })
        return obj
      })
    }
    resultVisible.value = true
  }).catch(err => { ElMessage.error('执行失败'); })
}
function handleDelete(row) {
  ElMessageBox.confirm('确认删除模型 "' + row.name + '"？', '提示', { type: 'warning' }).then(() => {
    delModel(row.id).then(() => { ElMessage.success('删除成功'); getList() })
  }).catch(() => {})
}

onMounted(() => getList())
</script>
