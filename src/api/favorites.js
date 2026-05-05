import { get, post, del } from '../utils/request'

export const favoritesApi = {
  getList: (params) => get('/api/favorites', params),
  add: (data) => post('/api/favorites', data),
  remove: (id) => del(`/api/favorites/${id}`),
  batchRemove: (data) => del('/api/favorites/batch-delete', data)
}
