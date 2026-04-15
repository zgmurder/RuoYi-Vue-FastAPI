<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入种子名称" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['datamodel:seed:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="dataList">
      <el-table-column label="ID" prop="id" width="60" />
      <el-table-column label="种子名称" prop="name" :show-overflow-tooltip="true" />
      <el-table-column label="数据源" prop="datasource_name" :show-overflow-tooltip="true" />
      <el-table-column label="表名" prop="table_name" :show-overflow-tooltip="true" />
      <el-table-column label="描述" prop="description" :show-overflow-tooltip="true" />
      <el-table-column label="创建时间" prop="created_at" width="160" />
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" icon="View" @click="handlePreview(row)" v-hasPermi="['datamodel:seed:preview']">预览</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(row)" v-hasPermi="['datamodel:seed:edit']">修改</el-button>
          <el-button link type="danger" icon="Delete" @click="handleDelete(row)" v-hasPermi="['datamodel:seed:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/修改对话框 -->
    <el-dialog :title="dialog.title" v-model="dialog.visible" width="550px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="种子名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入种子名称" />
        </el-form-item>
        <el-form-item label="数据源" prop="datasource_id">
          <el-select v-model="form.datasource_id" placeholder="选择数据源" style="width: 100%" @change="onDatasourceChange">
            <el-option v-for="ds in datasources" :key="ds.id" :label="ds.name" :value="ds.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="表名" prop="table_name">
          <el-select v-model="form.table_name" placeholder="选择表" style="width: 100%" filterable :loading="tablesLoading">
            <el-option v-for="t in tables" :key="t" :label="t" :value="t" />
          </el-select>
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

    <!-- 预览对话框 -->
    <el-dialog title="数据预览" v-model="previewVisible" width="800px" append-to-body>
      <el-table :data="previewData" border max-height="400" size="small">
        <el-table-column v-for="col in previewCols" :key="col" :label="col" :prop="col" :show-overflow-tooltip="true" min-width="120" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup name="SeedManage">
import { ref, reactive, onMounted } from 'vue'
import { listSeed, addSeed, updateSeed, delSeed, sampleSeed, listDatasource, listTables } from '@/api/datamodel/index'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const showSearch = ref(true)
const dataList = ref([])
const datasources = ref([])
const tables = ref([])
const tablesLoading = ref(false)
const queryParams = reactive({ name: '' })
const dialog = reactive({ visible: false, title: '' })
const form = ref({})
const formRef = ref(null)
const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  datasource_id: [{ required: true, message: '请选择数据源', trigger: 'change' }],
  table_name: [{ required: true, message: '请选择表', trigger: 'change' }],
}
const previewVisible = ref(false)
const previewData = ref([])
const previewCols = ref([])

function getList() {
  loading.value = true
  Promise.all([listSeed(), listDatasource()]).then(([seedRes, dsRes]) => {
    datasources.value = dsRes.data || []
    const dsMap = {}
    datasources.value.forEach(d => dsMap[d.id] = d.name)
    let list = (seedRes.data || []).map(s => ({ ...s, datasource_name: dsMap[s.datasource_id] || s.datasource_id }))
    if (queryParams.name) list = list.filter(s => s.name.includes(queryParams.name))
    dataList.value = list
  }).finally(() => loading.value = false)
}
function handleQuery() { getList() }
function resetQuery() { queryParams.name = ''; getList() }
function handleAdd() {
  form.value = { name: '', datasource_id: null, table_name: '', description: '' }
  tables.value = []; dialog.title = '新增种子'; dialog.visible = true
}
function handleUpdate(row) {
  form.value = { ...row }
  if (row.datasource_id) onDatasourceChange(row.datasource_id)
  dialog.title = '修改种子'; dialog.visible = true
}
function onDatasourceChange(dsId) {
  tablesLoading.value = true; tables.value = []
  listTables(dsId).then(res => { tables.value = res.data || [] }).finally(() => tablesLoading.value = false)
}
function submitForm() {
  formRef.value.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.id) {
      updateSeed(data.id, data).then(() => { ElMessage.success('修改成功'); dialog.visible = false; getList() })
    } else {
      addSeed(data).then(() => { ElMessage.success('新增成功'); dialog.visible = false; getList() })
    }
  })
}
function handleDelete(row) {
  ElMessageBox.confirm('确认删除种子 "' + row.name + '"？', '提示', { type: 'warning' }).then(() => {
    delSeed(row.id).then(() => { ElMessage.success('删除成功'); getList() })
  }).catch(() => {})
}
function handlePreview(row) {
  sampleSeed(row.id, 20).then(res => {
    const d = res.data || {}
    previewCols.value = d.columns || []
    previewData.value = (d.rows || []).map(r => {
      if (r && typeof r === 'object' && !Array.isArray(r)) return r
      const obj = {}
      previewCols.value.forEach((c, i) => { obj[c] = r?.[i] })
      return obj
    })
    previewVisible.value = true
  })
}

onMounted(() => getList())
</script>
