import { get, post, put, del } from '../utils/request'

export const cartApi = {
  getList: () => get('/api/cart'),
  add: (data) => post('/api/cart/add', data),
  update: (id, data) => put(`/api/cart/${id}`, data),
  remove: (id) => del(`/api/cart/${id}`),
  clear: () => del('/api/cart/clear')
}
