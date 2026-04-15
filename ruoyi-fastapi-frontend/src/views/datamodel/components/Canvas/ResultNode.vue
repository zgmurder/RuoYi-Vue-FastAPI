<template>
  <div class="result-node" @contextmenu.prevent>
    <Handle type="target" :position="Position.Left" />
    <div class="node-icon">R</div>
    <div class="node-label">结果输出</div>
  </div>
</template>

<script setup>
import { Handle, Position } from '@vue-flow/core'
</script>

<style scoped>
.result-node { padding: 10px 16px; border-radius: 8px; background: linear-gradient(135deg, #e6f7ff, #bae7ff); border: 2px solid #40a9ff; min-width: 120px; text-align: center; box-shadow: 0 2px 8px rgba(64, 169, 255, 0.2); }
.node-icon { width: 28px; height: 28px; border-radius: 50%; background: #1890ff; color: #fff; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: bold; font-size: 14px; }
.node-label { font-size: 13px; font-weight: 600; color: #003a8c; }
</style>

<style>
html.dark .result-node { background: linear-gradient(135deg, #111d2c, #15293e) !important; border-color: #177ddc !important; box-shadow: 0 2px 8px rgba(23,125,220,0.3) !important; }
html.dark .result-node .node-label { color: #69c0ff !important; }
</style>
