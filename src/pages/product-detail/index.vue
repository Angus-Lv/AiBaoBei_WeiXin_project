<template>
  <view class="product-detail-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left" @tap="handleBack">
        <text class="back-icon">←</text>
      </view>
      <view class="nav-center">
        <text class="nav-title">商品详情</text>
      </view>
      <view class="nav-right">
        <text class="share-btn">分享</text>
      </view>
    </view>
    
    <!-- 商品轮播图 -->
    <view class="product-carousel">
      <swiper 
        class="swiper" 
        :indicator-dots="true" 
        :autoplay="true" 
        :interval="3000" 
        :duration="500" 
        indicator-color="rgba(255,255,255,0.5)" 
        indicator-active-color="#FF69B4"
      >
        <swiper-item v-for="(img, index) in product.images" :key="index" class="swiper-item">
          <image :src="img" class="swiper-image" mode="aspectFill" @tap="previewImage(index)" />
        </swiper-item>
      </swiper>
      <view v-if="product.isSeckill" class="seckill-tag">秒杀</view>
    </view>
    
    <!-- 商品信息 -->
    <view class="product-info">
      <view class="price-section">
        <text class="current-price">¥{{ product.price }}</text>
        <text v-if="product.originalPrice" class="original-price">¥{{ product.originalPrice }}</text>
      </view>
      <text class="product-name">{{ product.name }}</text>
      <text class="product-spec">{{ product.spec }}</text>
      <view class="product-stats">
        <text class="sales">销量 {{ product.sales }}</text>
        <text class="stock">库存 {{ product.stock }}</text>
      </view>
    </view>
    
    <!-- 商品详情 -->
    <view class="detail-section">
      <view class="section-title">商品介绍</view>
      <view class="detail-content">
        <view v-for="(img, index) in product.detailImages" :key="index" class="detail-image">
          <image :src="img" mode="widthFix" @tap="previewDetailImage(index)"></image>
        </view>
        <text v-if="!product.detailImages || product.detailImages.length === 0">商品详细描述内容...</text>
        <text v-if="!product.detailImages || product.detailImages.length === 0">这里可以添加商品的详细介绍、规格参数、使用说明等信息。</text>
      </view>
    </view>
    
    <!-- 底部操作栏 -->
    <view class="bottom-bar">
      <view class="cart-btn" @tap="handleCart">
        <text class="icon">🛒</text>
        <text>购物车</text>
      </view>
      <view class="favorite-btn" :class="{ active: isFavorite }" @tap="handleFavorite">
        <text class="icon">{{ isFavorite ? '❤️' : '🤍' }}</text>
        <text>{{ isFavorite ? '已收藏' : '收藏' }}</text>
      </view>
      <view class="buy-btn" @tap="handleBuy">立即购买</view>
    </view>
    
    <!-- 购买弹窗 -->
    <view v-if="showBuyModal" class="buy-modal">
      <view class="modal-content">
        <view class="modal-header">
          <text class="modal-title">选择购买数量</text>
          <text class="modal-close" @tap="showBuyModal = false">×</text>
        </view>
        <view class="modal-body">
          <!-- 商品信息 -->
          <view class="modal-product">
            <image :src="product.image" mode="aspectFill" @tap="previewModalImage"></image>
            <view class="modal-product-info">
              <text class="modal-product-name">{{ product.name }}</text>
              <text class="modal-product-price">¥{{ product.price }}</text>
            </view>
          </view>
          
          <!-- 套餐选择 -->
          <view class="package-section" v-if="product.packages && product.packages.length > 0">
            <text class="package-title">选择套餐</text>
            <view class="package-list">
              <view v-for="(pkg, index) in product.packages" :key="index" class="package-item" :class="{ active: selectedPackage === index }" @tap="selectedPackage = index">
                <text class="package-name">{{ pkg.name }}</text>
                <text class="package-price">¥{{ pkg.price }}</text>
              </view>
            </view>
          </view>
          
          <!-- 数量选择 -->
          <view class="quantity-section">
            <text class="quantity-title">购买数量</text>
            <view class="quantity-control">
              <view class="quantity-btn" @tap="decreaseQuantity" :class="{ disabled: quantity <= 1 }">-</view>
              <view class="quantity-input">{{ quantity }}</view>
              <view class="quantity-btn" @tap="increaseQuantity" :class="{ disabled: quantity >= product.stock }">+</view>
            </view>
          </view>
        </view>
        <view class="modal-footer">
          <view class="total-price">
            <text>合计：</text>
            <text class="total-price-value">¥{{ totalPrice }}</text>
          </view>
          <view class="confirm-btn" @tap="confirmBuy">{{ modalType === 'cart' ? '确认加入购物车' : '确认购买' }}</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { productApi } from '../../api/product'
import { cartApi } from '../../api/cart'
import { favoritesApi } from '../../api/favorites'
import { orderApi } from '../../api/order'

const statusBarHeight = ref(0)
const pageLoading = ref(true)

const product = ref({
  id: 0, name: '', image: '/static/alice.png',
  images: [], detailImages: [], price: '', originalPrice: '',
  spec: '', sales: 0, stock: 0, isSeckill: false, packages: []
})

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

const isFavorite = ref(false)
const showBuyModal = ref(false)
const modalType = ref('buy')
const quantity = ref(1)
const selectedPackage = ref(0)

const totalPrice = computed(() => {
  if (product.value.packages && product.value.packages.length > 0 && selectedPackage.value < product.value.packages.length) {
    return (parseFloat(product.value.packages[selectedPackage.value].price) * quantity.value).toFixed(2)
  }
  return (parseFloat(product.value.price) * quantity.value).toFixed(2)
})

const loadProductDetail = async (id) => {
  try {
    pageLoading.value = true
    const res = await productApi.getDetail(id)
    if (res && res.data) {
      const item = res.data
      product.value = {
        id: item.id,
        name: item.name || '商品名称',
        image: item.mainImage || item.images?.[0] || '/static/alice.png',
        images: item.images || [item.mainImage].filter(Boolean) || ['/static/alice.png'],
        detailImages: item.detailImages || [],
        price: item.price || '0',
        originalPrice: item.originalPrice || '',
        spec: item.spec || item.specification || '',
        sales: item.sales || item.salesCount || 0,
        stock: item.stock || 0,
        isSeckill: item.isSeckill || false,
        packages: item.packages || item.packageOptions || []
      }
    }
  } catch (e) {
    console.error('商品详情加载失败:', e)
  } finally {
    pageLoading.value = false
  }
}

const checkFavorite = async (productId) => {
  try {
    const res = await favoritesApi.getList({ productId })
    if (res && res.data) {
      const list = res.data.records || res.data.list || res.data || []
      isFavorite.value = list.some(f => f.productId === Number(productId) || f.id === Number(productId))
    }
  } catch (e) {
    const favs = uni.getStorageSync('favorites') || []
    isFavorite.value = favs.includes(String(productId))
  }
}

onMounted(() => {
  statusBarHeight.value = getNavBarHeight()
  const pages = getCurrentPages()
  const currentPage = pages[pages.length - 1]
  const options = currentPage.$page?.options || currentPage.options || {}
  const id = options.id
  if (id) {
    loadProductDetail(id)
    checkFavorite(id)
  }
})

const previewImage = (index) => {
  if (product.value.images && product.value.images.length > 0) {
    uni.previewImage({ current: product.value.images[index], urls: product.value.images, indicator: 'default', loop: true })
  }
}

const previewDetailImage = (index) => {
  if (product.value.detailImages && product.value.detailImages.length > 0) {
    uni.previewImage({ current: product.value.detailImages[index], urls: product.value.detailImages, indicator: 'default', loop: true })
  }
}

const previewModalImage = () => {
  if (product.value.image) {
    uni.previewImage({ current: product.value.image, urls: [product.value.image], indicator: 'default', loop: true })
  }
}

const handleBack = () => { uni.navigateBack() }

const handleCart = () => {
  modalType.value = 'cart'
  showBuyModal.value = true
}

const handleFavorite = async () => {
  try {
    if (isFavorite.value) {
      await favoritesApi.remove(product.value.id)
      isFavorite.value = false
    } else {
      await favoritesApi.add({ productId: product.value.id })
      isFavorite.value = true
    }
    uni.showToast({ title: isFavorite.value ? '收藏成功' : '取消收藏', icon: 'success', duration: 2000 })
  } catch (e) {
    isFavorite.value = !isFavorite.value
    const favs = uni.getStorageSync('favorites') || []
    if (isFavorite.value) {
      if (!favs.includes(String(product.value.id))) favs.push(String(product.value.id))
    } else {
      uni.setStorageSync('favorites', favs.filter(id => id !== String(product.value.id)))
    }
    uni.setStorageSync('favorites', favs)
    uni.showToast({ title: isFavorite.value ? '收藏成功' : '取消收藏', icon: 'success', duration: 2000 })
  }
}

const handleBuy = () => {
  modalType.value = 'buy'
  showBuyModal.value = true
}

const decreaseQuantity = () => { if (quantity.value > 1) quantity.value-- }
const increaseQuantity = () => { if (quantity.value < product.value.stock) quantity.value++ }

const confirmBuy = async () => {
  try {
    if (modalType.value === 'cart') {
      await cartApi.add({
        productId: product.value.id,
        quantity: quantity.value,
        packageIndex: selectedPackage.value
      })
      showBuyModal.value = false
      uni.showToast({ title: '加入购物车成功', icon: 'success', duration: 2000 })
    } else {
      const orderData = {
        items: [{
          productId: product.value.id,
          quantity: quantity.value,
          packageIndex: selectedPackage.value
        }],
        totalAmount: totalPrice.value
      }
      const res = await orderApi.create(orderData)
      showBuyModal.value = false
      if (res && res.data && res.data.id) {
        uni.navigateTo({ url: `/pages/profile/order-detail?id=${res.data.id}` })
      } else {
        uni.showToast({ title: '购买成功', icon: 'success', duration: 2000 })
      }
    }
  } catch (e) {
    console.error('操作失败:', e)
    uni.showToast({ title: '操作失败，请重试', icon: 'none', duration: 2000 })
  }
}
</script>

<style>
.product-detail-container {
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
  display: flex;
  align-items: center;
}

.back-icon {
  font-size: 18px;
  color: white;
}

.nav-center {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: white;
}

.nav-right {
  width: 40px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.share-btn {
  font-size: 14px;
  color: white;
}

/* 商品轮播图 */
.product-carousel {
  width: 100%;
  height: 300px;
  background-color: #f5f5f5;
  position: relative;
  margin-top: 94px;
  overflow: hidden;
}

.swiper {
  width: 100%;
  height: 100%;
}

.swiper-item {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.swiper-image {
  width: 100%;
  height: 100%;
  display: block;
}

.seckill-tag {
  position: absolute;
  top: 12px;
  left: 12px;
  background-color: #FF69B4;
  color: white;
  font-size: 14px;
  font-weight: bold;
  padding: 6px 12px;
  border-radius: 6px;
  z-index: 1;
}

/* 商品信息 */
.product-info {
  background-color: white;
  padding: 15px;
  margin-bottom: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.price-section {
  display: flex;
  align-items: baseline;
  margin-bottom: 10px;
}

.current-price {
  font-size: 24px;
  font-weight: bold;
  color: #FF69B4;
  margin-right: 12px;
}

.original-price {
  font-size: 14px;
  color: #999;
  text-decoration: line-through;
}

.product-name {
  font-size: 16px;
  font-weight: 500;
  color: #333;
  line-height: 1.4;
  margin-bottom: 8px;
}

.product-spec {
  font-size: 14px;
  color: #666;
  margin-bottom: 10px;
}

.product-stats {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #999;
}

.sales,
.stock {
  flex: 1;
}

/* 商品详情 */
.detail-section {
  background-color: white;
  padding: 15px;
  margin-bottom: 70px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

/* 图标样式 */
.icon {
  font-size: 18px;
}

.section-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 10px;
}

.detail-content {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}

.detail-image {
  margin-bottom: 10px;
  width: 100%;
}

.detail-image image {
  width: 100%;
  display: block;
}

/* 底部操作栏 */
.bottom-bar {
  display: flex;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 56px;
  background-color: white;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
  z-index: 99;
  padding: 0 16px;
}

.cart-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #666;
  border-right: none;
  gap: 4px;
}

.favorite-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #666;
  border-right: none;
  gap: 4px;
}

.favorite-btn.active {
  color: #FF69B4;
}

.buy-btn {
  flex: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  color: white;
  background-color: #FF69B4;
  border-radius: 24px;
  margin: 8px 0;
  box-shadow: 0 2px 8px rgba(255, 105, 180, 0.3);
  transition: all 0.3s ease;
}

.buy-btn:active {
  transform: scale(0.98);
  box-shadow: 0 1px 4px rgba(255, 105, 180, 0.3);
}

/* 购买弹窗 */
.buy-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  width: 100%;
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
  max-height: 80vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.modal-title {
  font-size: 16px;
  font-weight: 500;
  color: #333;
}

.modal-close {
  font-size: 24px;
  color: #999;
  padding: 0 8px;
}

.modal-body {
  padding: 15px;
}

.modal-product {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}

.modal-product image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
}

.modal-product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.modal-product-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  line-height: 1.3;
}

.modal-product-price {
  font-size: 16px;
  font-weight: bold;
  color: #FF69B4;
}

.package-section {
  margin-bottom: 20px;
}

.package-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin-bottom: 10px;
}

.package-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.package-item {
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 20px;
  font-size: 14px;
  color: #666;
  background-color: white;
  transition: all 0.3s ease;
}

.package-item.active {
  border-color: #FF69B4;
  background-color: #FFF0F5;
  color: #FF69B4;
}

.quantity-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.quantity-title {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.quantity-control {
  display: flex;
  align-items: center;
  gap: 16px;
}

.quantity-btn {
  width: 32px;
  height: 32px;
  border: 1px solid #ddd;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  color: #666;
  background-color: white;
  transition: all 0.3s ease;
}

.quantity-btn.disabled {
  color: #ccc;
  border-color: #eee;
}

.quantity-input {
  font-size: 14px;
  color: #333;
  min-width: 40px;
  text-align: center;
}

.modal-footer {
  padding: 15px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.total-price {
  font-size: 14px;
  color: #333;
}

.total-price-value {
  font-size: 18px;
  font-weight: bold;
  color: #FF69B4;
  margin-left: 4px;
}

.confirm-btn {
  padding: 8px 24px;
  background-color: #FF69B4;
  color: white;
  font-size: 14px;
  font-weight: 500;
  border-radius: 20px;
  transition: all 0.3s ease;
}

.confirm-btn:active {
  opacity: 0.8;
}
</style>