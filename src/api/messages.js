import { get, put, del } from '../utils/request'

export const messagesApi = {
  getList: (params) => get('/api/messages', params),
  markRead: (id) => put(`/api/messages/${id}/read`),
  markAllRead: () => put('/api/messages/read-all'),
  remove: (id) => del(`/api/messages/${id}`)
}
