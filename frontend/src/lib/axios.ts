import { useAuthStore } from '@/stores/auth.store';
import axios, { AxiosError } from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  withCredentials: false,
});


api.interceptors.request.use((config) => {
  const tenantId = useAuthStore.getState().tenantId
  const accessToken = useAuthStore.getState().accessToken

  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`
  }

  if (tenantId) {
    config.headers['X-Tenant-ID'] = tenantId
  }

  return config
})

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    const status = error.response?.status;
    const authStore = useAuthStore.getState()

    if (status === 401) {
      authStore.clearAuth();
      window.location.href = '/login';
    }

    if (status === 403) {
      // authStore.setTenantId(null);

      // window.location.href = '/select-tenant'
      window.history.back();
    }

    return Promise.reject(error)
  }
)

export default api
