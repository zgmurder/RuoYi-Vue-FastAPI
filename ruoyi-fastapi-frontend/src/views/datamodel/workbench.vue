<template>
  <div class="workbench-redirect">
    <el-result icon="success" title="建模工作台已在新窗口中打开">
      <template #extra>
        <el-button type="primary" @click="openWorkbench">重新打开</el-button>
      </template>
    </el-result>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

function openWorkbench() {
  const params = new URLSearchParams()
  if (route.query.modelId) {
    params.set('modelId', String(route.query.modelId))
  }
  const query = params.toString()
  const target = query ? `/datamodel-workbench?${query}` : '/datamodel-workbench'
  window.open(target, '_blank')
}

onMounted(() => {
  openWorkbench()
})
</script>

<style scoped>
.workbench-redirect {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 400px;
}
</style>
