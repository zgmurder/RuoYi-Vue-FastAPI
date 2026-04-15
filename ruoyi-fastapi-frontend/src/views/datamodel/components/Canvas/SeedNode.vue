<template>
  <div class="seed-node" @contextmenu.prevent>
    <Handle type="source" :position="Position.Right" />
    <div class="node-icon">S</div>
    <div class="node-label">{{ data.label }}</div>
    <div class="node-sub">{{ data.tableName }}</div>
  </div>
</template>

<script setup>
import { Handle, Position } from '@vue-flow/core'
defineProps({ data: Object })
</script>

<style scoped>
.seed-node { padding: 10px 16px; border-radius: 8px; background: linear-gradient(135deg, #f6ffed, #d9f7be); border: 2px solid #73d13d; min-width: 120px; text-align: center; box-shadow: 0 2px 8px rgba(115, 209, 61, 0.2); }
.node-icon { width: 28px; height: 28px; border-radius: 50%; background: #52c41a; color: #fff; display: flex; align-items: center; justify-content: center; margin: 0 auto 6px; font-weight: bold; font-size: 14px; }
.node-label { font-size: 13px; font-weight: 600; color: #135200; }
.node-sub { font-size: 11px; color: #389e0d; margin-top: 2px; }
</style>

<style>
html.dark .seed-node { background: linear-gradient(135deg, #162312, #1d3712) !important; border-color: #49aa19 !important; box-shadow: 0 2px 8px rgba(73,170,25,0.3) !important; }
html.dark .seed-node .node-label { color: #95de64 !important; }
html.dark .seed-node .node-sub { color: #6abe39 !important; }
</style>
