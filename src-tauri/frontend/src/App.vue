<script setup lang="ts">
import { RouterView } from 'vue-router'
import ElectronControls from '@/components/ElectronControls.vue'
</script>

<template>
  <div id="app">
    <!-- Electron Controls (only shown in Electron) -->
    <ElectronControls v-if="typeof window !== 'undefined' && (window as any).isElectron" />
    
    <header>
      <nav>
        <RouterLink to="/">Home</RouterLink>
        <RouterLink to="/about">About</RouterLink>
      </nav>
    </header>
    <main>
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

nav {
  display: flex;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

nav a {
  color: white;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.1rem;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

nav a:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

nav a.router-link-active {
  background: rgba(255, 255, 255, 0.3);
}

main {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
}
</style>
