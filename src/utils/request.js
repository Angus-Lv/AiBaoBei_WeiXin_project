const BASE_URL = 'http://localhost:8080'
const TOKEN_KEY = 'auth_token'
const USER_KEY = 'user_info'

const getToken = () => {
  return uni.getStorageSync(TOKEN_KEY) || ''
}

const setToken = (token) => {
  uni.setStorageSync(TOKEN_KEY, token)
}

const removeToken = () => {
  uni.removeStorageSync(TOKEN_KEY)
}

const getBaseUrl = () => {
  return BASE_URL
}

const request = (options) => {
  return new Promise((resolve, reject) => {
    const token = getToken()
    const header = {
      'Content-Type': 'application/json',
      ...options.header
    }

    if (token) {
      header['Authorization'] = `Bearer ${token}`
    }

    uni.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data || {},
      header,
      timeout: 15000,
      success: (res) => {
        const { statusCode, data } = res

        if (statusCode === 401) {
          removeToken()
          uni.removeStorageSync(USER_KEY)
          const pages = getCurrentPages()
          const currentPage = pages[pages.length - 1]
          if (currentPage && currentPage.route !== 'pages/login/login') {
            uni.showToast({ title: '登录已过期，请重新登录', icon: 'none', duration: 2000 })
            setTimeout(() => {
              uni.navigateTo({ url: '/pages/login/login' })
            }, 1500)
          }
          reject(new Error('未授权'))
          return
        }

        if (statusCode === 200 && data.code === 200) {
          resolve(data)
        } else if (data.code) {
          uni.showToast({ title: data.message || '请求失败', icon: 'none', duration: 2000 })
          reject(new Error(data.message || '请求失败'))
        } else {
          resolve(data)
        }
      },
      fail: (err) => {
        uni.showToast({ title: '网络请求失败，请检查网络连接', icon: 'none', duration: 2000 })
        reject(err)
      }
    })
  })
}

const get = (url, params = {}) => {
  const queryString = Object.keys(params)
    .filter(key => params[key] !== undefined && params[key] !== null && params[key] !== '')
    .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
    .join('&')

  return request({
    url: queryString ? `${url}?${queryString}` : url,
    method: 'GET'
  })
}

const post = (url, data = {}) => {
  return request({
    url,
    method: 'POST',
    data
  })
}

const put = (url, data = {}) => {
  return request({
    url,
    method: 'PUT',
    data
  })
}

const del = (url, data = {}) => {
  return request({
    url,
    method: 'DELETE',
    data
  })
}

export { get, post, put, del, setToken, removeToken, getToken, getBaseUrl }
export default { get, post, put, del, setToken, removeToken, getToken, getBaseUrl }
