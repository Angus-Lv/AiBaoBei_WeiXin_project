import { get, post, put, del } from '../utils/request'

export const addressApi = {
  getList: () => get('/api/addresses'),
  add: (data) => post('/api/addresses', data),
  update: (id, data) => put(`/api/addresses/${id}`, data),
  setDefault: (id) => put(`/api/addresses/${id}/default`),
  remove: (id) => del(`/api/addresses/${id}`)
}
