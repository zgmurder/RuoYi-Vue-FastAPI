<template>
  <div class="dm-layout">
    <!-- Header -->
    <div class="dm-header">
      <div class="dm-header-left">
        <img :src="logoImg" class="dm-logo" />
        <span class="dm-header-title">数据建模平台</span>
      </div>
      <div class="dm-header-right">
        <el-tooltip content="主题模式" placement="bottom">
          <div class="dm-header-icon" @click="toggleTheme">
            <svg-icon v-if="settingsStore.isDark" icon-class="sunny" />
            <svg-icon v-else icon-class="moon" />
          </div>
        </el-tooltip>
        <el-button text class="dm-header-btn" @click="goAdmin">
          <el-icon><Monitor /></el-icon> 管理系统
        </el-button>
        <el-dropdown trigger="hover" @command="handleCommand">
          <div class="dm-avatar-wrapper">
            <img :src="userStore.avatar" class="dm-avatar" />
            <span class="dm-nickname">{{ userStore.nickName || userStore.name || '用户' }}</span>
            <el-icon class="dm-arrow"><ArrowDown /></el-icon>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人中心</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    <!-- Body -->
    <div class="dm-container">
    <!-- Left Sidebar -->
    <div class="dm-sidebar">
      <el-collapse v-model="activePanel" accordion>
        <!-- 数据库 -->
        <el-collapse-item title="数据库" name="database">
          <template #title><span class="ct"><el-icon><Coin /></el-icon> 数据库</span></template>
          <div class="panel-body">
            <div class="panel-actions">
              <el-button type="primary" size="small" @click="dsDialog.show = true; dsDialog.id = null; Object.assign(dsDialog.form, defaultDsForm())">新增</el-button>
              <el-button size="small" @click="loadDatasources" :loading="ds.loading">刷新</el-button>
            </div>
            <div v-for="item in ds.list" :key="item.id" class="list-item">
              <div class="item-info">
                <div class="item-name"><el-tag size="small">{{ item.db_type }}</el-tag> {{ item.name }} <el-tag v-if="item.is_shared" type="success" size="small" effect="plain">共享</el-tag></div>
                <div class="item-sub">{{ item.host || item.database }}<span v-if="item.create_by" class="item-owner"> · {{ item.create_by }}</span></div>
              </div>
              <div class="item-actions" v-if="isOwner(item)">
                <el-tooltip :content="item.is_shared ? '取消共享' : '共享'" placement="top"><el-button link :type="item.is_shared ? 'warning' : 'success'" size="small" @click="toggleShareDs(item)"><el-icon><Share /></el-icon></el-button></el-tooltip>
                <el-button link type="primary" size="small" @click="editDs(item)"><el-icon><Edit /></el-icon></el-button>
                <el-button link type="danger" size="small" @click="deleteDs(item)"><el-icon><Delete /></el-icon></el-button>
              </div>
            </div>
            <div v-if="!ds.loading && ds.list.length === 0" class="empty-tip">暂无数据源</div>
          </div>
        </el-collapse-item>

        <!-- 种子库 -->
        <el-collapse-item title="种子库" name="seed">
          <template #title><span class="ct"><el-icon><Opportunity /></el-icon> 种子库</span></template>
          <div class="panel-body">
            <div class="panel-actions">
              <el-button type="primary" size="small" @click="seedDialog.show = true; seedDialog.id = null; seedDialog.form = { name: '', datasource_id: null, table_name: '', description: '' }">新增</el-button>
              <el-button size="small" @click="loadSeeds" :loading="seeds.loading">刷新</el-button>
            </div>
            <div v-for="item in seeds.list" :key="item.id" class="list-item draggable" draggable="true" @dragstart="onDragStart($event, 'seed', item)">
              <div class="item-info">
                <div class="item-name">{{ item.name }} <el-tag v-if="item.is_shared" type="success" size="small" effect="plain">共享</el-tag></div>
                <div class="item-sub">{{ item.table_name }}<span v-if="item.create_by" class="item-owner"> · {{ item.create_by }}</span></div>
              </div>
              <div class="item-actions" v-if="isOwner(item)">
                <el-tooltip :content="item.is_shared ? '取消共享' : '共享'" placement="top"><el-button link :type="item.is_shared ? 'warning' : 'success'" size="small" @click="toggleShareSeed(item)"><el-icon><Share /></el-icon></el-button></el-tooltip>
                <el-button link type="danger" size="small" @click="deleteSeed(item)"><el-icon><Delete /></el-icon></el-button>
              </div>
            </div>
            <div v-if="!seeds.loading && seeds.list.length === 0" class="empty-tip">暂无种子</div>
          </div>
        </el-collapse-item>

        <!-- 算子库 -->
        <el-collapse-item title="算子库" name="operator">
          <template #title><span class="ct"><el-icon><SetUp /></el-icon> 算子库</span></template>
          <div class="panel-body">
            <div v-for="item in ops.list" :key="item.id" class="list-item draggable" draggable="true" @dragstart="onDragStart($event, 'operator', item)">
              <div class="item-info">
                <div class="item-name">{{ item.name }} <el-tag v-if="item.is_shared && !item.is_builtin" type="success" size="small" effect="plain">共享</el-tag></div>
                <div class="item-sub">{{ item.op_type }}<span v-if="item.create_by" class="item-owner"> · {{ item.create_by }}</span></div>
              </div>
              <div class="item-actions" v-if="isOwner(item) && !item.is_builtin">
                <el-tooltip :content="item.is_shared ? '取消共享' : '共享'" placement="top"><el-button link :type="item.is_shared ? 'warning' : 'success'" size="small" @click="toggleShareOp(item)"><el-icon><Share /></el-icon></el-button></el-tooltip>
              </div>
            </div>
          </div>
        </el-collapse-item>

        <!-- 模型库 -->
        <el-collapse-item title="模型库" name="model">
          <template #title><span class="ct"><el-icon><DataAnalysis /></el-icon> 模型库</span></template>
          <div class="panel-body">
            <div class="panel-actions">
              <el-button size="small" @click="loadModels" :loading="models.loading">刷新</el-button>
            </div>
            <div v-for="item in models.list" :key="item.id" class="list-item clickable" :class="{ active: currentModel && currentModel.id === item.id }" @click="selectModel(item)">
              <div class="item-info">
                <div class="item-name">{{ item.name }} <el-tag v-if="item.is_shared" type="success" size="small" effect="plain">共享</el-tag></div>
                <div class="item-sub">{{ item.description || '无描述' }}<span v-if="item.create_by" class="item-owner"> · {{ item.create_by }}</span></div>
              </div>
              <div class="item-actions" v-if="isOwner(item)">
                <el-tooltip :content="item.is_shared ? '取消共享' : '共享'" placement="top"><el-button link :type="item.is_shared ? 'warning' : 'success'" size="small" @click.stop="toggleShareModel(item)"><el-icon><Share /></el-icon></el-button></el-tooltip>
                <el-button link type="danger" size="small" @click.stop="deleteModel(item)"><el-icon><Delete /></el-icon></el-button>
              </div>
            </div>
            <div v-if="!models.loading && models.list.length === 0" class="empty-tip">暂无模型</div>
          </div>
        </el-collapse-item>

        <!-- API库 -->
        <el-collapse-item title="API库" name="api">
          <template #title><span class="ct"><el-icon><Link /></el-icon> API库</span></template>
          <div class="panel-body">
            <div class="panel-actions">
              <el-button type="primary" size="small" @click="openApiDialog()">发布API</el-button>
              <el-button size="small" @click="loadApis" :loading="apis.loading">刷新</el-button>
            </div>
            <div v-for="item in apis.list" :key="item.id" class="list-item">
              <div class="item-info">
                <div class="item-name"><el-tag :type="item.enabled ? 'success' : 'info'" size="small">{{ item.enabled ? '启用' : '停用' }}</el-tag> {{ item.name }} <el-tag v-if="item.is_shared" type="success" size="small" effect="plain">共享</el-tag></div>
                <div class="item-sub" style="color: #409eff; font-family: monospace;">/openapi/{{ item.path }}<span v-if="item.create_by" class="item-owner" style="color: var(--dm-text-secondary);"> · {{ item.create_by }}</span></div>
              </div>
              <div class="item-actions" v-if="isOwner(item)">
                <el-tooltip :content="item.is_shared ? '取消共享' : '共享'" placement="top"><el-button link :type="item.is_shared ? 'warning' : 'success'" size="small" @click="toggleShareApi(item)"><el-icon><Share /></el-icon></el-button></el-tooltip>
                <el-button link type="warning" size="small" @click="toggleApi(item)"><el-icon><Switch /></el-icon></el-button>
                <el-button link type="primary" size="small" @click="openApiDialog(item)"><el-icon><Edit /></el-icon></el-button>
                <el-button link type="danger" size="small" @click="deleteApi(item)"><el-icon><Delete /></el-icon></el-button>
              </div>
            </div>
            <div v-if="!apis.loading && apis.list.length === 0" class="empty-tip">暂无已发布API</div>
          </div>
        </el-collapse-item>
      </el-collapse>
    </div>

    <!-- Right: Canvas + Result -->
    <div class="dm-main">
      <!-- Toolbar -->
      <div class="dm-toolbar">
        <el-input v-model="modelName" placeholder="模型名称" size="small" style="width: 180px" />
        <el-input v-model="modelDesc" placeholder="模型描述(可选)" size="small" style="width: 200px" />
        <el-button type="primary" size="small" @click="saveModel" :loading="saving"><el-icon><FolderChecked /></el-icon> 保存模型</el-button>
        <el-button type="success" size="small" @click="execModel" :loading="executing"><el-icon><VideoPlay /></el-icon> 执行模型</el-button>
        <el-button size="small" @click="addResultNode"><el-icon><Flag /></el-icon> 添加结果节点</el-button>
        <el-button size="small" @click="clearCanvas"><el-icon><Delete /></el-icon> 清空画布</el-button>
        <el-tag v-if="currentModel" type="info" size="small" style="margin-left: auto;">当前: {{ currentModel.name }}</el-tag>
      </div>

      <!-- Canvas -->
      <div class="dm-canvas" @drop="onDrop" @dragover.prevent @dragenter.prevent @click="ctxMenu.show = false">
        <VueFlow ref="flowRef" v-model:nodes="nodes" v-model:edges="edges" :node-types="nodeTypes" :default-edge-options="defaultEdgeOptions" fit-view-on-init @node-context-menu="onNodeCtxMenu" @pane-click="ctxMenu.show = false">
          <Background />
          <Controls />
          <MiniMap />
        </VueFlow>
      </div>

      <!-- Context menu -->
      <div v-if="ctxMenu.show" class="context-menu" :style="{ left: ctxMenu.x + 'px', top: ctxMenu.y + 'px' }">
        <div v-if="ctxMenu.nodeType === 'seed'" class="ctx-item" @click="sampleNode"><el-icon><Search /></el-icon> 取样(前10条)</div>
        <div v-if="ctxMenu.nodeType === 'operator'" class="ctx-item" @click="execNode"><el-icon><VideoPlay /></el-icon> 执行</div>
        <div v-if="ctxMenu.nodeType === 'operator'" class="ctx-item" @click="configOp"><el-icon><Setting /></el-icon> 配置</div>
        <div v-if="ctxMenu.nodeType === 'result'" class="ctx-item" @click="execNode"><el-icon><VideoPlay /></el-icon> 执行模型</div>
        <div class="ctx-item danger" @click="deleteNode"><el-icon><Delete /></el-icon> 删除节点</div>
      </div>

      <!-- Result Panel -->
      <div class="dm-result">
        <div class="result-header">
          <span><el-icon><DataLine /></el-icon> 查询结果 <span v-if="result.data">({{ result.data.total }} 条)</span></span>
          <el-button size="small" link @click="result.data = null; result.error = ''">清空</el-button>
        </div>
        <div class="result-body">
          <div v-if="result.loading" class="result-center"><el-icon class="is-loading" :size="20"><Loading /></el-icon> 执行中...</div>
          <div v-else-if="result.error" class="result-center" style="color: #ff4d4f;">{{ result.error }}</div>
          <div v-else-if="!result.data" class="result-center">右键节点选择「取样」或「执行」查看结果</div>
          <el-table v-else :data="result.data.rows" border stripe size="small" style="width: 100%" max-height="200">
            <el-table-column v-for="col in result.data.columns" :key="col" :prop="col" :label="col" :min-width="100" show-overflow-tooltip />
          </el-table>
        </div>
      </div>
    </div>

    <!-- Datasource Dialog -->
    <el-dialog v-model="dsDialog.show" :title="dsDialog.id ? '编辑数据源' : '新增数据源'" width="460px" destroy-on-close>
      <el-form :model="dsDialog.form" label-width="80px" size="default">
        <el-form-item label="名称"><el-input v-model="dsDialog.form.name" placeholder="请输入数据源名称" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="dsDialog.form.db_type" style="width: 100%" @change="onDsTypeChange">
            <el-option label="MySQL" value="mysql" /><el-option label="MariaDB" value="mariadb" /><el-option label="PostgreSQL" value="postgresql" />
            <el-option label="Oracle" value="oracle" /><el-option label="SQL Server" value="sqlserver" /><el-option label="ClickHouse" value="clickhouse" /><el-option label="SQLite" value="sqlite" />
          </el-select>
        </el-form-item>
        <template v-if="dsDialog.form.db_type !== 'sqlite'">
          <el-form-item label="主机"><el-input v-model="dsDialog.form.host" placeholder="127.0.0.1" /></el-form-item>
          <el-form-item label="端口"><el-input-number v-model="dsDialog.form.port" :min="0" :max="65535" style="width: 100%" /></el-form-item>
          <el-form-item label="用户名"><el-input v-model="dsDialog.form.username" /></el-form-item>
          <el-form-item label="密码"><el-input v-model="dsDialog.form.password" type="password" show-password /></el-form-item>
        </template>
        <el-form-item label="数据库"><el-input v-model="dsDialog.form.database" :placeholder="dsDialog.form.db_type === 'sqlite' ? '文件路径' : '数据库名'" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="testDsConn" :loading="dsDialog.testing">测试连接</el-button>
        <el-button type="primary" @click="saveDs" :loading="dsDialog.saving">保存</el-button>
      </template>
    </el-dialog>

    <!-- Seed Dialog -->
    <el-dialog v-model="seedDialog.show" :title="seedDialog.id ? '编辑种子' : '新增种子'" width="460px" destroy-on-close>
      <el-form :model="seedDialog.form" label-width="80px" size="default">
        <el-form-item label="名称"><el-input v-model="seedDialog.form.name" placeholder="种子名称" /></el-form-item>
        <el-form-item label="数据源">
          <el-select v-model="seedDialog.form.datasource_id" style="width: 100%" @change="onSeedDsChange">
            <el-option v-for="d in ds.list" :key="d.id" :label="d.name" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="表名">
          <el-select v-model="seedDialog.form.table_name" style="width: 100%" filterable :loading="seedDialog.tablesLoading">
            <el-option v-for="t in seedDialog.tables" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述"><el-input v-model="seedDialog.form.description" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="seedDialog.show = false">取消</el-button>
        <el-button type="primary" @click="saveSeed" :loading="seedDialog.saving">保存</el-button>
      </template>
    </el-dialog>

    <!-- Operator Config Dialog -->
    <el-dialog v-model="opConfig.show" title="算子配置" width="500px" destroy-on-close>
      <el-form label-width="100px" size="default">
        <template v-if="opConfig.opType === 'join'">
          <el-form-item label="连接类型"><el-select v-model="opConfig.config.joinType" style="width: 100%"><el-option label="INNER JOIN" value="INNER JOIN" /><el-option label="LEFT JOIN" value="LEFT JOIN" /><el-option label="RIGHT JOIN" value="RIGHT JOIN" /><el-option label="FULL JOIN" value="FULL OUTER JOIN" /></el-select></el-form-item>
          <el-form-item label="连接条件"><el-input v-model="opConfig.config.condition" placeholder="t1.id = t2.user_id" /></el-form-item>
        </template>
        <template v-else-if="opConfig.opType === 'filter'">
          <el-form-item label="过滤条件"><el-input v-model="opConfig.config.condition" type="textarea" :rows="3" placeholder="age > 18 AND status = 1" /></el-form-item>
        </template>
        <template v-else-if="opConfig.opType === 'group'">
          <el-form-item label="分组字段"><el-input v-model="opConfig.config.groupFields" placeholder="city, gender" /></el-form-item>
          <el-form-item label="聚合表达式"><el-input v-model="opConfig.config.aggExpr" placeholder="COUNT(*) as cnt" /></el-form-item>
        </template>
        <template v-else-if="opConfig.opType === 'sort'">
          <el-form-item label="排序字段"><el-input v-model="opConfig.config.sortField" placeholder="created_at" /></el-form-item>
          <el-form-item label="排序方向"><el-select v-model="opConfig.config.sortOrder" style="width: 100%"><el-option label="升序 ASC" value="ASC" /><el-option label="降序 DESC" value="DESC" /></el-select></el-form-item>
        </template>
        <template v-else-if="opConfig.opType === 'limit'">
          <el-form-item label="行数限制"><el-input-number v-model="opConfig.config.count" :min="1" :max="100000" style="width: 100%" /></el-form-item>
        </template>
        <template v-else-if="opConfig.opType === 'custom'">
          <el-form-item label="自定义SQL"><el-input v-model="opConfig.config.sql" type="textarea" :rows="5" placeholder="SELECT * FROM {input1} WHERE ..." /></el-form-item>
        </template>
        <template v-else><el-alert type="info" show-icon :closable="false">该算子无需额外配置。</el-alert></template>
      </el-form>
      <template #footer>
        <el-button @click="opConfig.show = false">取消</el-button>
        <el-button type="primary" @click="saveOpConfig">确定</el-button>
      </template>
    </el-dialog>

    <!-- Published API Dialog -->
    <el-dialog v-model="apiDialog.show" :title="apiDialog.id ? '编辑API' : '发布API'" width="560px" destroy-on-close>
      <el-form :model="apiDialog.form" label-width="80px" size="default">
        <el-form-item label="API名称"><el-input v-model="apiDialog.form.name" placeholder="如: 查询用户列表" /></el-form-item>
        <el-form-item label="路径"><el-input v-model="apiDialog.form.path" placeholder="如: user/list"><template #prepend>/openapi/</template></el-input></el-form-item>
        <el-form-item label="关联模型">
          <el-select v-model="apiDialog.form.model_id" style="width: 100%">
            <el-option v-for="m in models.list" :key="m.id" :label="m.name" :value="m.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述"><el-input v-model="apiDialog.form.description" type="textarea" :rows="2" /></el-form-item>
        <el-form-item label="参数列表">
          <div style="width: 100%">
            <div v-for="(p, idx) in apiDialog.params" :key="idx" style="display: flex; gap: 6px; margin-bottom: 6px; align-items: center;">
              <el-input v-model="p.name" placeholder="参数名" style="width: 100px" size="small" />
              <el-select v-model="p.type" style="width: 90px" size="small"><el-option label="string" value="string" /><el-option label="number" value="number" /></el-select>
              <el-checkbox v-model="p.required" size="small">必填</el-checkbox>
              <el-input v-model="p.default" placeholder="默认值" style="width: 90px" size="small" />
              <el-button link type="danger" size="small" @click="apiDialog.params.splice(idx, 1)"><el-icon><Delete /></el-icon></el-button>
            </div>
            <el-button size="small" @click="apiDialog.params.push({ name: '', type: 'string', required: false, default: '' })">添加参数</el-button>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="apiDialog.show = false">取消</el-button>
        <el-button type="primary" @click="saveApi" :loading="apiDialog.saving">{{ apiDialog.id ? '保存' : '发布' }}</el-button>
      </template>
    </el-dialog>
    </div>
  </div>
</template>

<script setup name="DataModel">
import { ref, reactive, markRaw, onMounted, nextTick } from 'vue'
import { VueFlow, useVueFlow, MarkerType } from '@vue-flow/core'
import { Background } from '@vue-flow/background'
import { Controls } from '@vue-flow/controls'
import { MiniMap } from '@vue-flow/minimap'
import '@vue-flow/core/dist/style.css'
import '@vue-flow/core/dist/theme-default.css'
import '@vue-flow/controls/dist/style.css'
import '@vue-flow/minimap/dist/style.css'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Coin, Opportunity, SetUp, DataAnalysis, Link, Edit, Delete, FolderChecked,
  VideoPlay, Flag, Search, Setting, Loading, DataLine, Switch, Share,
  User, Monitor, SwitchButton, ArrowDown
} from '@element-plus/icons-vue'
import logoImg from '@/assets/logo/logo.png'
import SeedNode from './components/Canvas/SeedNode.vue'
import OperatorNode from './components/Canvas/OperatorNode.vue'
import ResultNode from './components/Canvas/ResultNode.vue'
import {
  listDatasource, addDatasource, updateDatasource, delDatasource, testConnection, listTables, shareDatasource,
  listSeed, addSeed, delSeed, sampleSeed, shareSeed,
  listOperator, shareOperator,
  listModel, addModel, updateModel, delModel, executeNode, shareModel,
  listPublishedApi, addPublishedApi, updatePublishedApi, delPublishedApi, sharePublishedApi
} from '@/api/datamodel'
import useUserStore from '@/store/modules/user'
import useSettingsStore from '@/store/modules/settings'

const userStore = useUserStore()
const settingsStore = useSettingsStore()

// 初始化时获取用户信息
if (!userStore.name) {
  userStore.getInfo()
}

async function toggleTheme(event) {
  const x = event?.clientX || window.innerWidth / 2
  const y = event?.clientY || window.innerHeight / 2
  const wasDark = settingsStore.isDark
  const isReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  const isSupported = document.startViewTransition && !isReducedMotion
  if (!isSupported) { settingsStore.toggleTheme(); return }
  try {
    const transition = document.startViewTransition(async () => {
      await new Promise(r => setTimeout(r, 10))
      settingsStore.toggleTheme()
      await nextTick()
    })
    await transition.ready
    const endRadius = Math.hypot(Math.max(x, window.innerWidth - x), Math.max(y, window.innerHeight - y))
    const clipPath = [`circle(0px at ${x}px ${y}px)`, `circle(${endRadius}px at ${x}px ${y}px)`]
    document.documentElement.animate(
      { clipPath: !wasDark ? [...clipPath].reverse() : clipPath },
      { duration: 650, easing: 'cubic-bezier(0.4, 0, 0.2, 1)', fill: 'forwards', pseudoElement: !wasDark ? '::view-transition-old(root)' : '::view-transition-new(root)' }
    )
    await transition.finished
  } catch (e) { settingsStore.toggleTheme() }
}

function goAdmin() {
  window.open('/', '_blank')
}

function handleCommand(command) {
  if (command === 'profile') {
    window.open('/user/profile', '_blank')
  } else if (command === 'logout') {
    ElMessageBox.confirm('确定注销并退出系统吗？', '提示', { type: 'warning' }).then(() => {
      userStore.logOut().then(() => {
        window.location.href = '/login'
      })
    }).catch(() => {})
  }
}

// ========== 权限：判断是否为创建者 ==========
function isOwner(item) {
  if (!item.create_by) return true
  return item.create_by === userStore.name
}

// ========== State ==========
const activePanel = ref('database')

const ds = reactive({ list: [], loading: false })
const seeds = reactive({ list: [], loading: false })
const ops = reactive({ list: [], loading: false })
const models = reactive({ list: [], loading: false })
const apis = reactive({ list: [], loading: false })
const result = reactive({ data: null, loading: false, error: '' })

const currentModel = ref(null)
const modelName = ref('')
const modelDesc = ref('')
const saving = ref(false)
const executing = ref(false)

// ========== Data Loading ==========
async function loadDatasources() { ds.loading = true; try { const r = await listDatasource(); ds.list = r.data || [] } finally { ds.loading = false } }
async function loadSeeds() { seeds.loading = true; try { const r = await listSeed(); seeds.list = r.data || [] } finally { seeds.loading = false } }
async function loadOps() { ops.loading = true; try { const r = await listOperator(); ops.list = r.data || [] } finally { ops.loading = false } }
async function loadModels() { models.loading = true; try { const r = await listModel(); models.list = r.data || [] } finally { models.loading = false } }
async function loadApis() { apis.loading = true; try { const r = await listPublishedApi(); apis.list = r.data || [] } finally { apis.loading = false } }

onMounted(() => { loadDatasources(); loadSeeds(); loadOps(); loadModels(); loadApis() })

// ========== Datasource CRUD ==========
const defaultDsForm = () => ({ name: '', db_type: 'mysql', host: '127.0.0.1', port: 3306, database: '', username: 'root', password: '' })
const dsDialog = reactive({ show: false, id: null, form: defaultDsForm(), testing: false, saving: false })

const portMap = { mysql: 3306, mariadb: 3306, postgresql: 5432, oracle: 1521, sqlserver: 1433, clickhouse: 9000 }
function onDsTypeChange(val) {
  dsDialog.form.port = portMap[val] || 0
  dsDialog.form.username = val === 'oracle' ? 'system' : val === 'sqlserver' ? 'sa' : val === 'clickhouse' ? 'default' : 'root'
}

function editDs(item) { dsDialog.id = item.id; Object.assign(dsDialog.form, item); dsDialog.show = true }
async function deleteDs(item) {
  await ElMessageBox.confirm(`确定删除数据源「${item.name}」？`, '提示', { type: 'warning' })
  await delDatasource(item.id); ElMessage.success('删除成功'); loadDatasources()
}
async function toggleShareDs(item) {
  await shareDatasource(item.id); ElMessage.success(item.is_shared ? '已取消共享' : '已共享'); loadDatasources()
}
async function testDsConn() {
  dsDialog.testing = true
  try { const r = await testConnection(dsDialog.form); r.code === 200 ? ElMessage.success(r.msg) : ElMessage.error(r.msg) }
  catch (e) { ElMessage.error('连接失败') }
  finally { dsDialog.testing = false }
}
async function saveDs() {
  if (!dsDialog.form.name || !dsDialog.form.database) { ElMessage.warning('请填写必填项'); return }
  dsDialog.saving = true
  try {
    if (dsDialog.id) { await updateDatasource(dsDialog.id, dsDialog.form); ElMessage.success('更新成功') }
    else { await addDatasource(dsDialog.form); ElMessage.success('创建成功') }
    dsDialog.show = false; loadDatasources()
  } catch (e) { ElMessage.error(e.response?.data?.msg || '操作失败') }
  finally { dsDialog.saving = false }
}

// ========== Seed CRUD ==========
const seedDialog = reactive({ show: false, id: null, form: { name: '', datasource_id: null, table_name: '', description: '' }, tables: [], tablesLoading: false, saving: false })

async function onSeedDsChange(dsId) {
  seedDialog.tablesLoading = true; seedDialog.tables = []
  try { const r = await listTables(dsId); seedDialog.tables = r.data || [] }
  finally { seedDialog.tablesLoading = false }
}
async function saveSeed() {
  if (!seedDialog.form.name || !seedDialog.form.datasource_id || !seedDialog.form.table_name) { ElMessage.warning('请填写必填项'); return }
  seedDialog.saving = true
  try { await addSeed(seedDialog.form); ElMessage.success('创建成功'); seedDialog.show = false; loadSeeds() }
  catch (e) { ElMessage.error(e.response?.data?.msg || '操作失败') }
  finally { seedDialog.saving = false }
}
async function deleteSeed(item) {
  await ElMessageBox.confirm(`确定删除种子「${item.name}」？`, '提示', { type: 'warning' })
  await delSeed(item.id); ElMessage.success('删除成功'); loadSeeds()
}
async function toggleShareSeed(item) {
  await shareSeed(item.id); ElMessage.success(item.is_shared ? '已取消共享' : '已共享'); loadSeeds()
}

// ========== Vue Flow Canvas ==========
const nodes = ref([])
const edges = ref([])
const nodeTypes = { seed: markRaw(SeedNode), operator: markRaw(OperatorNode), result: markRaw(ResultNode) }
const defaultEdgeOptions = { animated: true, style: { stroke: '#b1b1b7', strokeWidth: 2 }, markerEnd: MarkerType.ArrowClosed }

const { screenToFlowCoordinate, onConnect, addEdges } = useVueFlow()
onConnect((params) => addEdges([params]))

let nodeCounter = 0
function onDragStart(e, type, data) { e.dataTransfer.setData('application/json', JSON.stringify({ type, data })) }
function onDrop(e) {
  const raw = e.dataTransfer?.getData('application/json'); if (!raw) return
  const { type, data } = JSON.parse(raw)
  const position = screenToFlowCoordinate({ x: e.clientX, y: e.clientY })
  nodeCounter++
  const id = `node_${Date.now()}_${nodeCounter}`
  if (type === 'seed') {
    nodes.value.push({ id, type: 'seed', position, data: { label: data.name, tableName: data.table_name, seedId: data.id } })
  } else if (type === 'operator') {
    const cs = data.config_schema ? JSON.parse(data.config_schema) : {}
    nodes.value.push({ id, type: 'operator', position, data: { label: data.name, opType: data.op_type, operatorId: data.id, config: { ...cs } } })
  }
}

// ========== Context Menu ==========
const ctxMenu = reactive({ show: false, x: 0, y: 0, nodeId: '', nodeType: '' })
function onNodeCtxMenu({ event, node }) { event.preventDefault(); ctxMenu.show = true; ctxMenu.x = event.clientX; ctxMenu.y = event.clientY; ctxMenu.nodeId = node.id; ctxMenu.nodeType = node.type || '' }
function deleteNode() { ctxMenu.show = false; nodes.value = nodes.value.filter(n => n.id !== ctxMenu.nodeId); edges.value = edges.value.filter(e => e.source !== ctxMenu.nodeId && e.target !== ctxMenu.nodeId) }

async function sampleNode() {
  ctxMenu.show = false; const node = nodes.value.find(n => n.id === ctxMenu.nodeId); if (!node) return
  result.loading = true; result.data = null; result.error = ''
  try { const r = await sampleSeed(node.data.seedId); result.data = r.data }
  catch (e) { result.error = e.response?.data?.msg || e.message }
  finally { result.loading = false }
}

function buildGraphData() {
  return { nodes: nodes.value.map(n => ({ id: n.id, type: n.type, position: n.position, data: n.data })), edges: edges.value.map(e => ({ id: e.id, source: e.source, target: e.target })) }
}

async function execNode() {
  ctxMenu.show = false; result.loading = true; result.data = null; result.error = ''
  try { const r = await executeNode({ node_id: ctxMenu.nodeId, graph_data: JSON.stringify(buildGraphData()) }); result.data = r.data }
  catch (e) { result.error = e.response?.data?.msg || e.message }
  finally { result.loading = false }
}

// ========== Operator Config ==========
const opConfig = reactive({ show: false, nodeId: '', opType: '', config: {} })
function configOp() {
  ctxMenu.show = false; const node = nodes.value.find(n => n.id === ctxMenu.nodeId); if (!node) return
  opConfig.show = true; opConfig.nodeId = node.id; opConfig.opType = node.data.opType; opConfig.config = { ...node.data.config }
}
async function toggleShareOp(item) {
  await shareOperator(item.id); ElMessage.success(item.is_shared ? '已取消共享' : '已共享'); loadOps()
}
function saveOpConfig() {
  const node = nodes.value.find(n => n.id === opConfig.nodeId)
  if (node) node.data = { ...node.data, config: { ...opConfig.config } }
  opConfig.show = false; ElMessage.success('配置已保存')
}

// ========== Model Operations ==========
async function saveModel() {
  if (!modelName.value) { ElMessage.warning('请输入模型名称'); return }
  if (nodes.value.length === 0) { ElMessage.warning('画布为空'); return }
  if (currentModel.value && !isOwner(currentModel.value)) { ElMessage.warning('不能修改他人创建的模型，请另存为新模型'); return }
  saving.value = true
  try {
    const gd = JSON.stringify(buildGraphData())
    if (currentModel.value) { await updateModel(currentModel.value.id, { name: modelName.value, description: modelDesc.value, graph_data: gd }); ElMessage.success('模型已更新') }
    else { const r = await addModel({ name: modelName.value, description: modelDesc.value, graph_data: gd }); currentModel.value = r.data; ElMessage.success('模型已保存') }
    loadModels()
  } catch (e) { ElMessage.error(e.response?.data?.msg || '保存失败') }
  finally { saving.value = false }
}

async function execModel() {
  const rn = nodes.value.filter(n => n.type === 'result'); if (!rn.length) { ElMessage.warning('请先添加结果节点'); return }
  executing.value = true; result.loading = true; result.data = null; result.error = ''
  try { const r = await executeNode({ node_id: rn[0].id, graph_data: JSON.stringify(buildGraphData()) }); result.data = r.data }
  catch (e) { result.error = e.response?.data?.msg || e.message }
  finally { executing.value = false; result.loading = false }
}

function addResultNode() { nodeCounter++; nodes.value.push({ id: `result_${Date.now()}`, type: 'result', position: { x: 600, y: 200 }, data: { label: '结果输出' } }) }
function clearCanvas() { nodes.value = []; edges.value = []; result.data = null; result.error = ''; currentModel.value = null; modelName.value = ''; modelDesc.value = '' }

function selectModel(item) {
  currentModel.value = item; modelName.value = item.name; modelDesc.value = item.description
  try { const g = JSON.parse(item.graph_data); nodes.value = g.nodes || []; edges.value = (g.edges || []).map(e => ({ ...e, animated: true, style: { stroke: '#b1b1b7', strokeWidth: 2 }, markerEnd: MarkerType.ArrowClosed })) }
  catch { nodes.value = []; edges.value = [] }
}

async function deleteModel(item) {
  await ElMessageBox.confirm(`确定删除模型「${item.name}」？`, '提示', { type: 'warning' })
  await delModel(item.id); ElMessage.success('删除成功')
  if (currentModel.value?.id === item.id) currentModel.value = null
  loadModels()
}
async function toggleShareModel(item) {
  await shareModel(item.id); ElMessage.success(item.is_shared ? '已取消共享' : '已共享'); loadModels()
}

// ========== Published API ==========
const apiDialog = reactive({ show: false, id: null, form: { name: '', path: '', model_id: null, description: '' }, params: [], saving: false })

function openApiDialog(item) {
  if (item) { apiDialog.id = item.id; Object.assign(apiDialog.form, { name: item.name, path: item.path, model_id: item.model_id, description: item.description || '' }); try { apiDialog.params = JSON.parse(item.params || '[]') } catch { apiDialog.params = [] } }
  else { apiDialog.id = null; apiDialog.form = { name: '', path: '', model_id: null, description: '' }; apiDialog.params = [] }
  apiDialog.show = true
}

async function saveApi() {
  const f = apiDialog.form
  if (!f.name || !f.path || !f.model_id) { ElMessage.warning('请填写必填项'); return }
  apiDialog.saving = true
  const payload = { ...f, params: JSON.stringify(apiDialog.params.filter(p => p.name)) }
  try {
    if (apiDialog.id) { await updatePublishedApi(apiDialog.id, payload); ElMessage.success('更新成功') }
    else { await addPublishedApi(payload); ElMessage.success('发布成功') }
    apiDialog.show = false; loadApis()
  } catch (e) { ElMessage.error(e.response?.data?.msg || '操作失败') }
  finally { apiDialog.saving = false }
}

async function deleteApi(item) {
  await ElMessageBox.confirm(`确定删除API「${item.name}」？`, '提示', { type: 'warning' })
  await delPublishedApi(item.id); ElMessage.success('删除成功'); loadApis()
}

async function toggleApi(item) {
  try { await updatePublishedApi(item.id, { enabled: !item.enabled }); ElMessage.success(item.enabled ? '已停用' : '已启用'); loadApis() }
  catch (e) { ElMessage.error('操作失败') }
}
async function toggleShareApi(item) {
  await sharePublishedApi(item.id); ElMessage.success(item.is_shared ? '已取消共享' : '已共享'); loadApis()
}
</script>

<style scoped>
/* === Light mode CSS variables (default) === */
.dm-layout {
  --dm-bg: #ffffff;
  --dm-bg-secondary: #fafafa;
  --dm-bg-hover: #f7f8fa;
  --dm-text: #303133;
  --dm-text-secondary: #999;
  --dm-text-muted: #ccc;
  --dm-border: #e8e8e8;
  --dm-border-light: #f0f0f0;
  --dm-active-bg: #e6f7ff;
  --dm-active-border: #91d5ff;
  --dm-ctx-hover: #f5f5f5;
  --dm-ctx-danger-hover: #fff1f0;
  --dm-canvas-bg: #fafafa;
  --dm-icon-color: #5a5e66;
}

/* === Layout === */
.dm-layout { display: flex; flex-direction: column; height: 100vh; width: 100vw; position: fixed; top: 0; left: 0; z-index: 1000; background: var(--dm-bg); color: var(--dm-text); }
.dm-header { height: 50px; display: flex; align-items: center; justify-content: space-between; padding: 0 16px; background: var(--navbar-bg, var(--dm-bg)); box-shadow: 0 1px 4px rgba(0,21,41,0.08); flex-shrink: 0; z-index: 1; }
.dm-header-left { display: flex; align-items: center; gap: 10px; }
.dm-logo { width: 32px; height: 32px; }
.dm-header-title { font-size: 16px; font-weight: 600; color: var(--navbar-text, var(--dm-text)); }
.dm-header-right { display: flex; align-items: center; gap: 8px; height: 100%; }
.dm-header-btn { font-size: 14px; color: var(--dm-icon-color) !important; padding: 0 8px; height: 100%; }
.dm-header-btn:hover { background: rgba(128,128,128,0.1) !important; }
.dm-header-icon { display: flex; align-items: center; justify-content: center; width: 40px; height: 100%; cursor: pointer; font-size: 18px; color: var(--dm-icon-color); transition: background 0.3s, transform 0.3s; }
.dm-header-icon:hover { background: rgba(128,128,128,0.1); }
.dm-header-icon svg { transition: transform 0.3s; }
.dm-header-icon:hover svg { transform: scale(1.15); }
.dm-avatar-wrapper { display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 0 8px; height: 50px; transition: background 0.3s; }
.dm-avatar-wrapper:hover { background: rgba(128,128,128,0.1); }
.dm-avatar { width: 30px; height: 30px; border-radius: 50%; }
.dm-nickname { font-size: 14px; font-weight: bold; color: var(--navbar-text, var(--dm-text)); }
.dm-arrow { font-size: 12px; color: var(--dm-icon-color); }

/* === Body === */
.dm-container { display: flex; flex: 1; gap: 0; overflow: hidden; }
.dm-sidebar { width: 280px; border-right: 1px solid var(--dm-border); overflow: auto; background: var(--dm-bg); flex-shrink: 0; }
.dm-main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.dm-toolbar { display: flex; align-items: center; gap: 8px; padding: 8px 12px; background: var(--dm-bg-secondary); border-bottom: 1px solid var(--dm-border-light); flex-shrink: 0; flex-wrap: wrap; }
.dm-canvas { flex: 1; position: relative; background: var(--dm-canvas-bg); }
.dm-result { height: 220px; border-top: 1px solid var(--dm-border); display: flex; flex-direction: column; flex-shrink: 0; background: var(--dm-bg); }
.result-header { display: flex; justify-content: space-between; align-items: center; padding: 6px 12px; background: var(--dm-bg-secondary); font-size: 13px; font-weight: 600; border-bottom: 1px solid var(--dm-border-light); }
.result-body { flex: 1; overflow: auto; }
.result-center { display: flex; align-items: center; justify-content: center; gap: 8px; height: 100%; color: var(--dm-text-secondary); font-size: 13px; }

/* === Sidebar panels === */
.panel-body { padding: 8px; }
.panel-actions { display: flex; gap: 4px; margin-bottom: 8px; }
.list-item { display: flex; align-items: center; justify-content: space-between; padding: 6px 8px; border: 1px solid var(--dm-border-light); border-radius: 6px; margin-bottom: 4px; transition: background 0.2s; }
.list-item:hover { background: var(--dm-bg-hover); }
.list-item.active { background: var(--dm-active-bg); border-color: var(--dm-active-border); }
.list-item.draggable { cursor: grab; }
.list-item.clickable { cursor: pointer; }
.item-info { flex: 1; min-width: 0; }
.item-name { font-size: 12px; font-weight: 500; display: flex; align-items: center; gap: 4px; }
.item-sub { font-size: 11px; color: var(--dm-text-secondary); margin-top: 8px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-actions { display: flex; gap: 2px; flex-shrink: 0; }
.item-owner { color: var(--dm-text-muted); font-style: italic; }
.empty-tip { text-align: center; padding: 16px; color: var(--dm-text-muted); font-size: 12px; }
.ct { display: flex; align-items: center; gap: 6px; font-weight: 600; }

/* === Context menu === */
.context-menu { position: fixed; z-index: 9999; background: var(--dm-bg); border: 1px solid var(--dm-border); border-radius: 6px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); padding: 4px 0; min-width: 140px; }
.ctx-item { padding: 6px 16px; font-size: 13px; cursor: pointer; display: flex; align-items: center; gap: 6px; color: var(--dm-text); }
.ctx-item:hover { background: var(--dm-ctx-hover); }
.ctx-item.danger { color: #ff4d4f; }
.ctx-item.danger:hover { background: var(--dm-ctx-danger-hover); }

/* === Sidebar collapse === */
.dm-sidebar :deep(.el-collapse) { border: none; }
.dm-sidebar :deep(.el-collapse-item__header) { padding: 0 12px; font-size: 13px; background: var(--dm-bg-secondary); border-bottom: 1px solid var(--dm-border-light); }
.dm-sidebar :deep(.el-collapse-item__content) { padding: 0; }

/* === Vue Flow dark mode overrides === */
.dm-canvas :deep(.vue-flow) { background: var(--dm-canvas-bg); }
.dm-canvas :deep(.vue-flow__background) { stroke: var(--dm-border) !important; }
.dm-canvas :deep(.vue-flow__minimap) { background: var(--dm-bg-secondary); }
.dm-canvas :deep(.vue-flow__controls) { background: var(--dm-bg); border: 1px solid var(--dm-border); box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
.dm-canvas :deep(.vue-flow__controls-button) { background: var(--dm-bg); border-bottom: 1px solid var(--dm-border-light); color: var(--dm-text); fill: var(--dm-text); }
.dm-canvas :deep(.vue-flow__controls-button:hover) { background: var(--dm-bg-hover); }
.dm-canvas :deep(.vue-flow__controls-button svg) { fill: var(--dm-icon-color); }
.dm-canvas :deep(.vue-flow__edge-path) { stroke: var(--dm-text-secondary); }
.dm-canvas :deep(.vue-flow__node) { background: var(--dm-bg); border: 1px solid var(--dm-border); color: var(--dm-text); border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
</style>

<!-- Dark mode variable overrides (non-scoped so html.dark selector works) -->
<style>
html.dark .dm-layout {
  --dm-bg: #141414;
  --dm-bg-secondary: #1d1e1f;
  --dm-bg-hover: #2d2d2d;
  --dm-text: #d0d0d0;
  --dm-text-secondary: #8c8c8c;
  --dm-text-muted: #555;
  --dm-border: #303030;
  --dm-border-light: #303030;
  --dm-active-bg: #111d2c;
  --dm-active-border: #153450;
  --dm-ctx-hover: #2d2d2d;
  --dm-ctx-danger-hover: #2c1519;
  --dm-canvas-bg: #1a1a1a;
  --dm-icon-color: #d0d0d0;
}
html.dark .dm-header { box-shadow: 0 1px 4px rgba(0,0,0,0.3); }
html.dark .vue-flow__minimap { background: #1d1e1f !important; }
</style>
