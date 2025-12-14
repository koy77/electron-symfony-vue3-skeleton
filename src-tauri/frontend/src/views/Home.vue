<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useApiStore } from '@/stores/api'

const apiStore = useApiStore()
const message = ref('Welcome to Electron + Vue 3 + Symfony!')

// Check if running in Electron
const isElectron = computed(() => {
  return typeof window !== 'undefined' && (window as any).isElectron
})

// Update message based on environment
const displayMessage = computed(() => {
  if (isElectron.value) {
    return '🖥️ Electron Desktop App + Vue 3 + Symfony!'
  }
  return '🌐 Web App + Vue 3 + Symfony!'
})

onMounted(async () => {
  await apiStore.fetchStatus()
})
</script>

<template>
  <div class="home">
    <h1>{{ displayMessage }}</h1>
    
    <div class="environment-badge" v-if="isElectron">
      <span class="badge electron">🖥️ Running in Electron</span>
    </div>
    
    <div class="cards-grid">
      <div class="card">
        <h2>🚀 Vue 3 + TypeScript</h2>
        <p>Modern reactive frontend with full TypeScript support and Composition API</p>
      </div>
      
      <div class="card">
        <h2>⚡ Vite</h2>
        <p>Lightning-fast HMR and optimized build tooling</p>
      </div>
      
      <div class="card">
        <h2>🎯 Symfony 7</h2>
        <p>Powerful PHP backend with API Platform</p>
      </div>
      
      <div class="card" :class="{ 'electron-card': isElectron }">
        <h2>🖥️ Electron</h2>
        <p v-if="isElectron">Cross-platform desktop application with native window controls</p>
        <p v-else>Desktop application mode available</p>
      </div>
    </div>

    <!-- Electron-specific features -->
    <div class="electron-features" v-if="isElectron">
      <div class="card">
        <h2>🔧 Desktop Features</h2>
        <div class="feature-list">
          <div class="feature-item">✅ Native window controls</div>
          <div class="feature-item">✅ File system access</div>
          <div class="feature-item">✅ System information</div>
          <div class="feature-item">✅ Application menu</div>
          <div class="feature-item">✅ Cross-platform support</div>
        </div>
      </div>
    </div>

    <div class="api-status card">
      <h2>API Status</h2>
      <p v-if="apiStore.loading">Loading...</p>
      <p v-else-if="apiStore.error" class="error">{{ apiStore.error }}</p>
      <div v-else>
        <p class="success">✓ Backend API is ready</p>
        <button @click="apiStore.fetchStatus">Refresh Status</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home {
  padding: 2rem 0;
}

h1 {
  text-align: center;
  margin-bottom: 3rem;
  animation: fadeInDown 0.6s ease;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.card {
  animation: fadeInUp 0.6s ease;
}

.card h2 {
  margin-bottom: 0.75rem;
}

.card p {
  color: #666;
  line-height: 1.6;
}

.api-status {
  max-width: 600px;
  margin: 0 auto;
  text-align: center;
}

.success {
  color: #10b981;
  font-weight: 600;
  font-size: 1.1rem;
  margin-bottom: 1rem;
}

.error {
  color: #ef4444;
  font-weight: 600;
}

@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.environment-badge {
  text-align: center;
  margin-bottom: 2rem;
}

.badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.875rem;
}

.badge.electron {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 6px rgba(102, 126, 234, 0.3);
}

.electron-card {
  border: 2px solid #667eea;
  box-shadow: 0 4px 6px rgba(102, 126, 234, 0.2);
}

.electron-features {
  margin-bottom: 3rem;
}

.feature-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.5rem;
  margin-top: 1rem;
}

.feature-item {
  background: rgba(102, 126, 234, 0.1);
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 0.875rem;
  color: #667eea;
  font-weight: 500;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
