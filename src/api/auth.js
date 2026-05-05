import { post, get, put } from '../utils/request'

export const authApi = {
  login: (data) => post('/api/auth/login', data),
  register: (data) => post('/api/auth/register', data)
}

export const userApi = {
  getInfo: () => get('/api/user/info'),
  updateInfo: (data) => put('/api/user/info', data),
  changePassword: (data) => post('/api/user/change-password', data)
}
