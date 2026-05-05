import { get, post } from '../utils/request'

export const serviceApi = {
  getList: (params) => get('/api/services', params),
  getDetail: (id) => get(`/api/services/${id}`),
  createBooking: (data) => post('/api/bookings', data),
  getBookings: (params) => get('/api/bookings', params),
  cancelBooking: (id) => post(`/api/bookings/${id}/cancel`)
}
