import { get } from '../utils/request'

export const homeApi = {
  getHomeData: () => get('/api/home'),
  getCategories: () => get('/api/categories'),
  getBanners: () => get('/api/banners')
}
