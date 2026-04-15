<template>
  <div class="operator-node" @contextmenu.prevent>
    <Handle type="target" :position="Position.Left" />
    <Handle type="source" :position="Position.Right" />
    <div class="node-icon">{{ iconMap[data.opType] || 'O' }}</div>
    <div class="node-label">{{ data.label }}</div>
    <div class="node-sub">{{ data.opType }}</div>
  </div>
</template>

<script setup>
import { Handle, Position } from '@vue-flow/core'
defineProps({ data: Object })
const iconMap = { union: 'U', union_all: 'U+', intersect: 'I', except: 'E', join: 'J', filter: 'F', group: 'G', sort: 'S', limit: 'L', custom: 'C' }
</script>

<style scoped>
.operator-node { padding: 10px 16px; border-radius: 8px; background: linear-gradient(135deg, #fff7e6, #ffe7ba); border: 2px solid #ffa940; min-width: 120px; text-align: center; box-shadow: 0 2px 8px rgba(255, 169, 64, 0.2); }
.node-icon { width: 28px; height: 28px; border-radius: 50%; background: #fa8c16; color: #fff; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: bold; font-size: 12px; }
.node-label { font-size: 13px; font-weight: 600; color: #873800; }
.node-sub { font-size: 11px; color: #d48806; margin-top: 2px; }
</style>

<style>
html.dark .operator-node { background: linear-gradient(135deg, #2b1d11, #362312) !important; border-color: #d48806 !important; box-shadow: 0 2px 8px rgba(212,136,6,0.3) !important; }
html.dark .operator-node .node-label { color: #ffc069 !important; }
html.dark .operator-node .node-sub { color: #d48806 !important; }
</style>
