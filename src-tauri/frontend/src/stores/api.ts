import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'

// Resolve API base URL with sensible defaults for host (localhost:8001) and Docker (env override)
let API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8001'

// Normalize some common misconfigurations
if (API_URL === 'http://localhost:8000') {
    // When backend is exposed on host port 8001, using 8000 will fail with a network error
    API_URL = 'http://localhost:8001'
}

export const useApiStore = defineStore('api', () => {
    const loading = ref(false)
    const error = ref<string | null>(null)
    const data = ref<any>(null)

    async function fetchStatus() {
        loading.value = true
        error.value = null

        try {
            const response = await axios.get(`${API_URL}/api`)
            data.value = response.data
        } catch (err: any) {
            error.value = err.message || 'Failed to connect to API'
            console.error('API Error:', err)
        } finally {
            loading.value = false
        }
    }

    return {
        loading,
        error,
        data,
        fetchStatus,
    }
})
