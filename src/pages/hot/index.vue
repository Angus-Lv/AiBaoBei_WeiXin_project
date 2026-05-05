<template>
  <view class="hot-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left" @tap="handleBack">
        <text class="back-icon">←</text>
      </view>
      <text class="nav-title">爆款推荐</text>
      <view class="nav-right"></view>
    </view>
    
    <!-- 头部横幅 -->
    <view class="hot-header">
      <view class="hot-banner">
        <text class="hot-banner-title">限时特惠</text>
        <text class="hot-banner-subtitle">爆款商品低至3折</text>
      </view>
    </view>
    
    <!-- 商品列表 -->
    <view class="hot-list">
      <view class="hot-item" v-for="(item, index) in hotProducts" :key="item.id" @tap="handleHotItem(item.id)">
        <view class="hot-image">
          <image :src="item.image" mode="aspectFill"></image>
          <view class="hot-tag">爆款</view>
          <view v-if="item.originalPrice" class="discount-tag">
            {{ Math.round((1 - item.price / item.originalPrice) * 100) }}%OFF
          </view>
        </view>
        <view class="hot-info">
          <text class="hot-name">{{ item.name }}</text>
          <text class="hot-spec">{{ item.spec }}</text>
          <view class="hot-bottom">
            <view class="price-section">
              <text class="hot-price">¥{{ item.price }}</text>
              <text v-if="item.originalPrice" class="hot-original-price">¥{{ item.originalPrice }}</text>
            </view>
            <text class="hot-sales">已售 {{ item.sales }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { productApi } from '../../api/product'

const hotProducts = ref([])
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

const loadHotProducts = async () => {
  try {
    pageLoading.value = true
    const res = await productApi.getList({ page: 1, pageSize: 20, sort: 'sales', order: 'desc' })
    if (res && res.data) {
      const list = res.data.records || res.data.list || res.data || []
      hotProducts.value = list.map(item => ({
        id: item.id,
        image: item.image || item.mainImage || '/static/alice.png',
        name: item.name,
        price: item.price,
        originalPrice: item.originalPrice,
        spec: item.spec || item.specification || '',
        sales: item.sales || item.salesCount || 0
      }))
    }
  } catch (e) {
    console.error('爆款推荐加载失败:', e)
  } finally {
    pageLoading.value = false
  }
}

const handleBack = () => { uni.navigateBack() }

const handleHotItem = (id) => {
  uni.navigateTo({ url: `/pages/product-detail/index?id=${id}` })
}

onMounted(() => {
  statusBarHeight.value = getNavBarHeight()
  loadHotProducts()
})
</script>

<style>
.hot-container {
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
  padding: 50px 15px 0;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.nav-left {
  width: 40px;
  display: flex;
  align-items: center;
}

.back-icon {
  font-size: 18px;
  color: white;
  font-weight: bold;
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

/* 头部横幅 */
.hot-header {
  padding-top: 94px;
}

.hot-banner {
  background: linear-gradient(135deg, #FF69B4 0%, #FFB6C1 100%);
  padding: 20px 15px;
  text-align: center;
  color: white;
  border-bottom-left-radius: 20px;
  border-bottom-right-radius: 20px;
  margin-bottom: 15px;
  box-shadow: 0 4px 6px rgba(255, 105, 180, 0.2);
}

.hot-banner-title {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 8px;
  display: block;
}

.hot-banner-subtitle {
  font-size: 14px;
  opacity: 0.9;
}

/* 商品列表 */
.hot-list {
  padding: 0 15px 20px;
}

.hot-item {
  display: flex;
  background-color: white;
  border-radius: 12px;
  padding: 15px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.hot-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background-color: #FF69B4;
  border-top-left-radius: 12px;
  border-bottom-left-radius: 12px;
}

.hot-item:active {
  transform: translateY(2px);
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

.hot-image {
  width: 100px;
  height: 100px;
  background-color: #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
  margin-right: 15px;
  position: relative;
  flex-shrink: 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.hot-image image {
  width: 100%;
  height: 100%;
  display: block;
  transition: transform 0.3s ease;
}

.hot-item:active .hot-image image {
  transform: scale(1.05);
}

.hot-tag {
  position: absolute;
  top: 8px;
  left: 8px;
  background-color: #FF69B4;
  color: white;
  font-size: 12px;
  font-weight: bold;
  padding: 4px 8px;
  border-radius: 4px;
  z-index: 1;
  box-shadow: 0 2px 4px rgba(255, 105, 180, 0.3);
}

.discount-tag {
  position: absolute;
  top: 8px;
  right: 8px;
  background-color: #FF4500;
  color: white;
  font-size: 10px;
  font-weight: bold;
  padding: 2px 6px;
  border-radius: 4px;
  z-index: 1;
  box-shadow: 0 2px 4px rgba(255, 69, 0, 0.3);
}

.hot-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 100px;
}

.hot-name {
  font-size: 15px;
  color: #333;
  line-height: 1.4;
  margin-bottom: 6px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
  font-weight: 500;
}

.hot-spec {
  font-size: 12px;
  color: #999;
  margin-bottom: 8px;
  line-height: 1.3;
}

.hot-bottom {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.price-section {
  display: flex;
  align-items: baseline;
  gap: 8px;
}

.hot-price {
  font-size: 18px;
  font-weight: bold;
  color: #FF69B4;
}

.hot-original-price {
  font-size: 12px;
  color: #999;
  text-decoration: line-through;
}

.hot-sales {
  font-size: 12px;
  color: #999;
  background-color: #f5f5f5;
  padding: 2px 8px;
  border-radius: 10px;
}
</style>