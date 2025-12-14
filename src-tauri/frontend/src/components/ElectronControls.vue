<template>
  <div class="electron-controls">
    <!-- Window Controls -->
    <div class="window-controls" v-if="isElectron">
      <button @click="minimizeWindow" class="control-btn minimize" title="Minimize">
        <span>−</span>
      </button>
      <button @click="maximizeWindow" class="control-btn maximize" :title="isMaximized ? 'Restore' : 'Maximize'">
        <span v-if="isMaximized">□</span>
        <span v-else>□</span>
      </button>
      <button @click="closeWindow" class="control-btn close" title="Close">
        <span>×</span>
      </button>
    </div>

    <!-- App Info -->
    <div class="app-info" v-if="appInfo">
      <div class="info-item">
        <strong>{{ appInfo.name }}</strong> v{{ appInfo.version }}
      </div>
      <div class="info-item">
        Platform: {{ appInfo.platform }} ({{ appInfo.arch }})
      </div>
    </div>

    <!-- System Info -->
    <div class="system-info" v-if="systemInfo">
      <div class="info-item">
        CPU: {{ systemInfo.cpus }} cores
      </div>
      <div class="info-item">
        Memory: {{ formatMemory(systemInfo.totalMemory) }} total, {{ formatMemory(systemInfo.freeMemory) }} free
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

// Check if running in Electron
const isElectron = ref(typeof window !== 'undefined' && (window as any).isElectron)

// State
const appInfo = ref<any>(null)
const systemInfo = ref<any>(null)
const isMaximized = ref(false)

// Methods
const minimizeWindow = async () => {
  if (isElectron.value) {
    await (window as any).electronAPI.minimizeWindow()
  }
}

const maximizeWindow = async () => {
  if (isElectron.value) {
    isMaximized.value = await (window as any).electronAPI.maximizeWindow()
  }
}

const closeWindow = async () => {
  if (isElectron.value) {
    await (window as any).electronAPI.closeWindow()
  }
}

const formatMemory = (bytes: number): string => {
  const gb = bytes / (1024 * 1024 * 1024)
  return `${gb.toFixed(1)} GB`
}

const loadAppInfo = async () => {
  if (isElectron.value) {
    try {
      appInfo.value = await (window as any).electronAPI.getAppInfo()
    } catch (error) {
      console.error('Failed to load app info:', error)
    }
  }
}

const loadSystemInfo = async () => {
  if (isElectron.value) {
    try {
      systemInfo.value = await (window as any).electronAPI.getSystemInfo()
    } catch (error) {
      console.error('Failed to load system info:', error)
    }
  }
}

onMounted(async () => {
  if (isElectron.value) {
    await loadAppInfo()
    await loadSystemInfo()
  }
})
</script>

<style scoped>
.electron-controls {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.5rem 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.window-controls {
  display: flex;
  gap: 0.25rem;
  order: 3; /* Push to the right on mobile */
}

.control-btn {
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  transition: all 0.2s ease;
}

.control-btn:hover {
  opacity: 0.8;
}

.control-btn.minimize {
  background: #fbbf24;
  color: #78350f;
}

.control-btn.maximize {
  background: #34d399;
  color: #064e3b;
}

.control-btn.close {
  background: #f87171;
  color: #7f1d1d;
}

.app-info, .system-info {
  display: flex;
  gap: 1rem;
  align-items: center;
  flex-wrap: wrap;
}

.info-item {
  font-size: 0.875rem;
  opacity: 0.9;
}

@media (max-width: 768px) {
  .electron-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .window-controls {
    order: 1;
    justify-content: flex-end;
  }

  .app-info, .system-info {
    order: 2;
    justify-content: center;
  }

  .info-item {
    font-size: 0.75rem;
  }
}
</style>