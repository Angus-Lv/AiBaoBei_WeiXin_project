<template>
  <view class="favorites-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left" @tap="handleBack">
        <text class="back-icon">←</text>
      </view>
      <text class="nav-title">我的收藏</text>
      <view class="nav-right"></view>
    </view>
    
    <!-- 收藏列表 -->
    <view class="favorites-list">
      <view class="favorites-item" v-for="(item, index) in favoritesList" :key="index" @tap="handleFavoritesItem(item.id)">
        <view class="favorites-image">
          <image :src="item.image" mode="aspectFill"></image>
        </view>
        <view class="favorites-info">
          <text class="favorites-name">{{ item.name }}</text>
          <text class="favorites-price">¥{{ item.price }}</text>
          <view class="favorites-bottom">
            <text class="favorites-sales">已售 {{ item.sales }}</text>
            <view class="favorites-action" @tap.stop="handleRemoveFavorites(index)">
              <text class="favorites-action-icon">❤️</text>
              <text class="favorites-action-text">取消收藏</text>
            </view>
          </view>
        </view>
      </view>
      
      <!-- 空状态 -->
      <view class="empty-state" v-if="favoritesList.length === 0">
        <text class="empty-icon">💖</text>
        <text class="empty-text">暂无收藏商品</text>
        <text class="empty-subtext">去逛逛，收藏喜欢的商品吧</text>
        <view class="empty-btn" @tap="handleGoShopping">
          <text class="empty-btn-text">去逛逛</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { favoritesApi } from '../../api/favorites'

const favoritesList = ref([])
const statusBarHeight = ref(0)
const pageLoading = ref(true)

const getNavBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync()
  const menuBtn = uni.getMenuButtonBoundingClientRect && uni.getMenuButtonBoundingClientRect()
  let navBarHeight = 0
  if (menuBtn && systemInfo && systemInfo.statusBarHeight) {
    navBarHeight = (menuBtn.top - systemInfo.statusBarHeight) * 2 + menuBtn.height + systemInfo.statusBarHeight
  } else if (systemInfo && systemInfo.statusBarHeight) {
    navBarHeight = systemInfo.statusBarHeight + 44
  } else {
    navBarHeight = 44
  }
  return Math.round(navBarHeight)
}

const loadFavorites = async () => {
  try {
    pageLoading.value = true
    const res = await favoritesApi.getList({ page: 1, pageSize: 50 })
    if (res && res.data) {
      const list = res.data.records || res.data.list || res.data || []
      favoritesList.value = list.map(item => ({
        id: item.productId || item.id,
        image: item.image || item.productImage || '/static/logo.png',
        name: item.name || item.productName,
        price: item.price,
        sales: item.sales || 0
      }))
    }
  } catch (e) {
    console.error('收藏加载失败:', e)
    const favs = uni.getStorageSync('favorites') || []
    favoritesList.value = favs.map(id => ({ id: Number(id), image: '/static/logo.png', name: '商品', price: '0', sales: 0 }))
  } finally {
    pageLoading.value = false
  }
}

const checkLoginStatus = () => true

const handleBack = () => { uni.navigateBack() }

const handleFavoritesItem = (id) => {
  uni.navigateTo({ url: `/pages/product-detail/index?id=${id}` })
}

const handleRemoveFavorites = async (index) => {
  if (!checkLoginStatus()) return
  const item = favoritesList.value[index]
  uni.showModal({
    title: '取消收藏',
    content: '确定要取消收藏这个商品吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await favoritesApi.remove(item.id)
        } catch (e) {}
        favoritesList.value.splice(index, 1)
        uni.showToast({ title: '已取消收藏', icon: 'success', duration: 2000 })
      }
    }
  })
}

const handleGoShopping = () => {
  uni.switchTab({ url: '/pages/products/index' })
}

onMounted(() => {
  if (!checkLoginStatus()) return
  statusBarHeight.value = getNavBarHeight()
  loadFavorites()
})
</script>

<style>
.favorites-container {
  width: 100%;
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* 顶部导航栏 */
.nav-bar {
  height: 94px;
  background-color: #FFB6C1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 15px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
}

.nav-left {
  width: 40px;
}

.back-icon {
  font-size: 18px;
  color: white;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: white;
  flex: 1;
  text-align: center;
}

.nav-right {
  width: 40px;
}

/* 收藏列表 */
.favorites-list {
  padding: 104px 15px 15px;
}

.favorites-item {
  display: flex;
  background-color: white;
  border-radius: 8px;
  padding: 10px;
  margin-bottom: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.favorites-item:active {
  transform: scale(0.98);
}

.favorites-image {
  width: 80px;
  height: 80px;
  background-color: #f0f0f0;
  border-radius: 6px;
  overflow: hidden;
  margin-right: 10px;
  flex-shrink: 0;
}

.favorites-image image {
  width: 100%;
  height: 100%;
  display: block;
}

.favorites-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.favorites-name {
  font-size: 14px;
  color: #333;
  line-height: 1.4;
  margin-bottom: 8px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.favorites-price {
  font-size: 16px;
  font-weight: bold;
  color: #FF69B4;
  margin-bottom: 8px;
}

.favorites-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.favorites-sales {
  font-size: 12px;
  color: #999;
}

.favorites-action {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  background-color: #f5f5f5;
  border-radius: 4px;
}

.favorites-action-icon {
  font-size: 12px;
}

.favorites-action-text {
  font-size: 12px;
  color: #666;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 16px;
  color: #333;
  margin-bottom: 8px;
}

.empty-subtext {
  font-size: 14px;
  color: #999;
  margin-bottom: 24px;
}

.empty-btn {
  padding: 10px 24px;
  background-color: #FFB6C1;
  border-radius: 20px;
}

.empty-btn-text {
  font-size: 14px;
  font-weight: bold;
  color: white;
}
</style>