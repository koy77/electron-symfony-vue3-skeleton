<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useApiStore } from '@/stores/api'

const apiStore = useApiStore()
const message = ref('Welcome to Electron + Vue 3 + Symfony!')

onMounted(async () => {
  await apiStore.fetchStatus()
})
</script>

<template>
  <div class="home">
    <h1>{{ message }}</h1>
    
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
      
      <div class="card">
        <h2>🖥️ Electron</h2>
        <p>Cross-platform desktop application wrapper</p>
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
