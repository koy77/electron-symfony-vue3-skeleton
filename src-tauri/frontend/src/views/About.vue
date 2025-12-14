<script setup lang="ts">
import { ref } from 'vue'

const features = ref([
  {
    title: 'Dockerized Stack',
    description: 'Complete development environment with Docker Compose',
    icon: '🐳'
  },
  {
    title: 'Hot Module Replacement',
    description: 'Instant feedback during development with Vite HMR',
    icon: '🔥'
  },
  {
    title: 'API Platform',
    description: 'RESTful API with automatic OpenAPI documentation',
    icon: '📚'
  },
  {
    title: 'PostgreSQL',
    description: 'Robust relational database with Doctrine ORM',
    icon: '🗄️'
  }
])
</script>

<template>
  <div class="about">
    <h1>About This Stack</h1>
    
    <div class="intro card">
      <p>
        This is a full-stack application combining the best of modern web technologies
        with desktop application capabilities. Built with developer experience in mind,
        it provides a complete development environment ready to use.
      </p>
    </div>

    <h2>Features</h2>
    <div class="features-grid">
      <div v-for="feature in features" :key="feature.title" class="card feature-card">
        <div class="icon">{{ feature.icon }}</div>
        <h3>{{ feature.title }}</h3>
        <p>{{ feature.description }}</p>
      </div>
    </div>

    <div class="tech-stack card">
      <h2>Technology Stack</h2>
      <ul>
        <li><strong>Frontend:</strong> Vue 3 with TypeScript and Composition API</li>
        <li><strong>Build Tool:</strong> Vite 5 for fast development and optimized builds</li>
        <li><strong>Backend:</strong> Symfony 7.1 with API Platform</li>
        <li><strong>Database:</strong> PostgreSQL 16</li>
        <li><strong>Desktop:</strong> Electron for cross-platform desktop apps</li>
        <li><strong>Infrastructure:</strong> Docker & Docker Compose</li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
.about {
  padding: 2rem 0;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
}

.intro {
  max-width: 800px;
  margin: 0 auto 3rem;
  font-size: 1.1rem;
  line-height: 1.8;
  text-align: center;
}

h2 {
  text-align: center;
  margin: 3rem 0 2rem;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.feature-card {
  text-align: center;
}

.icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.feature-card h3 {
  font-size: 1.3rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.feature-card p {
  color: #666;
}

.tech-stack {
  max-width: 800px;
  margin: 0 auto;
}

.tech-stack ul {
  list-style: none;
  padding: 0;
}

.tech-stack li {
  padding: 0.75rem 0;
  border-bottom: 1px solid #e5e7eb;
  font-size: 1.05rem;
}

.tech-stack li:last-child {
  border-bottom: none;
}

.tech-stack strong {
  color: #667eea;
}
</style>
