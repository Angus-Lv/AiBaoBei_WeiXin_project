import { get, post, put } from '../utils/request'

export const orderApi = {
  create: (data) => post('/api/orders', data),
  getList: (params) => get('/api/orders', params),
  getDetail: (id) => get(`/api/orders/${id}`),
  cancel: (id) => put(`/api/orders/${id}/cancel`),
  confirm: (id) => put(`/api/orders/${id}/confirm`),
  pay: (id) => post(`/api/orders/${id}/pay`)
}
