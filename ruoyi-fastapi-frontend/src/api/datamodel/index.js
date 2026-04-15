import request from '@/utils/request'

// 数据源列表
export function listDatasource() {
  return request({ url: '/datamodel/datasource/list', method: 'get' })
}

// 数据源详情
export function getDatasource(id) {
  return request({ url: '/datamodel/datasource/' + id, method: 'get' })
}

// 新增数据源
export function addDatasource(data) {
  return request({ url: '/datamodel/datasource/', method: 'post', data })
}

// 修改数据源
export function updateDatasource(id, data) {
  return request({ url: '/datamodel/datasource/' + id, method: 'put', data })
}

// 删除数据源
export function delDatasource(id) {
  return request({ url: '/datamodel/datasource/' + id, method: 'delete' })
}

// 共享/取消共享数据源
export function shareDatasource(id) {
  return request({ url: '/datamodel/datasource/' + id + '/share', method: 'put' })
}

// 测试连接
export function testConnection(data) {
  return request({ url: '/datamodel/datasource/test-connection', method: 'post', data })
}

// 获取表列表
export function listTables(id) {
  return request({ url: '/datamodel/datasource/' + id + '/tables', method: 'get' })
}

// 种子列表
export function listSeed() {
  return request({ url: '/datamodel/seed/list', method: 'get' })
}

// 新增种子
export function addSeed(data) {
  return request({ url: '/datamodel/seed/', method: 'post', data })
}

// 修改种子
export function updateSeed(id, data) {
  return request({ url: '/datamodel/seed/' + id, method: 'put', data })
}

// 删除种子
export function delSeed(id) {
  return request({ url: '/datamodel/seed/' + id, method: 'delete' })
}

// 共享/取消共享种子
export function shareSeed(id) {
  return request({ url: '/datamodel/seed/' + id + '/share', method: 'put' })
}

// 种子取样
export function sampleSeed(id, limit = 10) {
  return request({ url: '/datamodel/seed/' + id + '/sample', method: 'get', params: { limit } })
}

// 算子列表
export function listOperator() {
  return request({ url: '/datamodel/operator/list', method: 'get' })
}

// 新增算子
export function addOperator(data) {
  return request({ url: '/datamodel/operator/', method: 'post', data })
}

// 删除算子
export function delOperator(id) {
  return request({ url: '/datamodel/operator/' + id, method: 'delete' })
}

// 共享/取消共享算子
export function shareOperator(id) {
  return request({ url: '/datamodel/operator/' + id + '/share', method: 'put' })
}

// 模型列表
export function listModel() {
  return request({ url: '/datamodel/model/list', method: 'get' })
}

// 模型详情
export function getModel(id) {
  return request({ url: '/datamodel/model/' + id, method: 'get' })
}

// 新增模型
export function addModel(data) {
  return request({ url: '/datamodel/model/', method: 'post', data })
}

// 修改模型
export function updateModel(id, data) {
  return request({ url: '/datamodel/model/' + id, method: 'put', data })
}

// 删除模型
export function delModel(id) {
  return request({ url: '/datamodel/model/' + id, method: 'delete' })
}

// 共享/取消共享模型
export function shareModel(id) {
  return request({ url: '/datamodel/model/' + id + '/share', method: 'put' })
}

// 执行模型
export function executeModel(id) {
  return request({ url: '/datamodel/model/' + id + '/execute', method: 'post' })
}

// 执行节点
export function executeNode(data) {
  return request({ url: '/datamodel/model/execute-node', method: 'post', data })
}

// 已发布API列表
export function listPublishedApi() {
  return request({ url: '/datamodel/published-api/list', method: 'get' })
}

// 发布API
export function addPublishedApi(data) {
  return request({ url: '/datamodel/published-api/', method: 'post', data })
}

// 修改API
export function updatePublishedApi(id, data) {
  return request({ url: '/datamodel/published-api/' + id, method: 'put', data })
}

// 删除API
export function delPublishedApi(id) {
  return request({ url: '/datamodel/published-api/' + id, method: 'delete' })
}

// 共享/取消共享API
export function sharePublishedApi(id) {
  return request({ url: '/datamodel/published-api/' + id + '/share', method: 'put' })
}
