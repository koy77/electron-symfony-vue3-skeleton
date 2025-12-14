<template>
  <div class="tauri-controls">
    <div class="window-controls" v-if="isTauri">
      <button @click="minimizeWindow" class="control-btn minimize" title="Minimize">−</button>
      <button @click="toggleMaximize" class="control-btn maximize" :title="isMaximized ? 'Restore' : 'Maximize'">□</button>
      <button @click="closeWindow" class="control-btn close" title="Close">×</button>
    </div>

    <div class="app-info" v-if="appInfo">
      <div class="info-item"><strong>{{ appInfo.name }}</strong> v{{ appInfo.version }}</div>
      <div class="info-item">Platform: {{ appInfo.platform || 'desktop' }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
let isTauri = ref(false)
const isMaximized = ref(false)
const appInfo = ref<any>(null)

onMounted(() => {
  // detect Tauri runtime
  isTauri.value = typeof (window as any).__TAURI_IPC__ !== 'undefined'
  if (isTauri.value) {
    // lazy import Tauri window API
    import('@tauri-apps/api/window')
      .then(mod => {
        const appWindow = mod.appWindow
        appWindow.isMaximized().then(m => (isMaximized.value = m))
      })
      .catch(() => {})

    // Try to get app info via invoke (if provided by Rust)
    import('@tauri-apps/api/tauri')
      .then(({ invoke }) => invoke('get_app_info').then((res: any) => (appInfo.value = res)).catch(() => {}))
      .catch(() => {})
  }
})

const minimizeWindow = async () => {
  if (!isTauri.value) return
  const { appWindow } = await import('@tauri-apps/api/window')
  appWindow.minimize()
}

const toggleMaximize = async () => {
  if (!isTauri.value) return
  const { appWindow } = await import('@tauri-apps/api/window')
  const maximized = await appWindow.isMaximized()
  if (maximized) {
    appWindow.unmaximize()
    isMaximized.value = false
  } else {
    appWindow.maximize()
    isMaximized.value = true
  }
}

const closeWindow = async () => {
  if (!isTauri.value) return
  const { appWindow } = await import('@tauri-apps/api/window')
  appWindow.close()
}
</script>

<style scoped>
.tauri-controls { background: linear-gradient(135deg,#667eea 0%,#764ba2 100%); color: white; padding:0.5rem 1rem; display:flex; justify-content:space-between; align-items:center; gap:1rem }
.window-controls { display:flex; gap:0.25rem }
.control-btn { width:24px; height:24px; border:none; border-radius:4px; display:flex; align-items:center; justify-content:center; cursor:pointer; font-size:14px; font-weight:bold }
.control-btn.minimize { background:#fbbf24; color:#78350f }
.control-btn.maximize { background:#34d399; color:#064e3b }
.control-btn.close { background:#f87171; color:#7f1d1d }
.info-item { font-size:0.875rem; opacity:0.9 }
</style>
