import { get } from '../utils/request'

export const productApi = {
  getList: (params) => get('/api/products', params),
  getDetail: (id) => get(`/api/products/${id}`)
}
