import { get, post } from '../utils/request'

export const memberApi = {
  recharge: (data) => post('/api/member/recharge', data),
  getRechargeTiers: () => get('/api/member/recharge-tiers'),
  getRechargeRecords: (params) => get('/api/member/recharge-records', params),
  getPointsRecords: (params) => get('/api/member/points-records', params),
  getPointsProducts: () => get('/api/member/points-products'),
  exchangePoints: (data) => post('/api/member/points-exchange', data),
  signIn: () => post('/api/member/sign-in'),
  getSignRecords: (params) => get('/api/member/sign-records', params),
  getSignStatus: () => get('/api/member/sign-status')
}
