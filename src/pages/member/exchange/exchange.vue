<template>
	<view class="exchange-container">
		<!-- 积分信息 -->
		<view class="points-info">
			<text class="points-label">我的积分</text>
			<text class="points-value">{{ userPoints }}</text>
		</view>
		
		<!-- 兑换商品列表 -->
		<view class="exchange-list">
			<view 
				v-for="(item, index) in exchangeItems" 
				:key="item.id"
				class="exchange-item"
				@tap="selectItem(item)"
				:class="{ 'selected': selectedItem && selectedItem.id === item.id }"
			>
				<view class="item-image">
					<image :src="item.image" :alt="item.name" mode="aspectFill"></image>
				</view>
				<view class="item-info">
					<text class="item-name">{{ item.name }}</text>
					<view class="item-details">
						<view class="points-required">
							<text class="points-icon">🎁</text>
							<text class="points-num">{{ item.points }}</text>
							<text class="points-text">积分</text>
						</view>
						<view class="stock-info">
							<text class="stock-text">库存: {{ item.stock }}</text>
						</view>
					</view>
				</view>
			</view>
		</view>
		
		<!-- 底部兑换按钮 -->
		<view class="bottom-bar">
			<view class="bar-left">
				<text class="selected-info" v-if="selectedItem">
					已选择: {{ selectedItem.name }}
				</text>
				<text class="hint-text" v-else>
					请选择要兑换的商品
				</text>
			</view>
			<view 
				class="exchange-btn"
				@tap="handleExchange"
				:class="{ 'disabled': !selectedItem || selectedItem.points > userPoints || selectedItem.stock <= 0 }"
			>
				<text class="btn-text">立即兑换</text>
			</view>
		</view>
		
		<!-- 兑换成功提示 -->
		<view class="success-toast" v-if="showSuccessToast">
			<text class="toast-icon">🎉</text>
			<text class="toast-text">兑换成功！</text>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { memberApi } from '../../../api/member'

const userPoints = ref(0)
const exchangeItems = ref([])
const selectedItem = ref(null)
const showSuccessToast = ref(false)
const pageLoading = ref(true)

const loadExchangeData = async () => {
  try {
    pageLoading.value = true
    const storedUserInfo = uni.getStorageSync('userInfo')
    userPoints.value = storedUserInfo?.points || 0

    try {
      const res = await memberApi.getPointsProducts()
      if (res && res.data) {
        exchangeItems.value = (res.data || []).map(item => ({
          id: item.id,
          name: item.name || item.productName,
          points: item.points || item.requiredPoints || 0,
          stock: item.stock || 0,
          image: item.image || item.productImage || ''
        }))
      }
    } catch (e) {
      exchangeItems.value = [
        { id: 1, name: '婴儿纸尿裤试用装', points: 200, stock: 50, image: '' },
        { id: 2, name: '婴儿湿巾大包装', points: 300, stock: 30, image: '' },
        { id: 3, name: '婴儿润肤霜', points: 400, stock: 20, image: '' },
        { id: 4, name: '婴儿游泳体验券', points: 500, stock: 10, image: '' }
      ]
    }
  } catch (e) {
    console.error('兑换数据加载失败:', e)
  } finally {
    pageLoading.value = false
  }
}

const selectItem = (item) => { selectedItem.value = item }

const handleExchange = async () => {
  if (!selectedItem.value) {
    uni.showToast({ title: '请选择要兑换的商品', icon: 'none' })
    return
  }
  if (selectedItem.value.points > userPoints.value) {
    uni.showToast({ title: '积分不足', icon: 'none' })
    return
  }
  if (selectedItem.value.stock <= 0) {
    uni.showToast({ title: '商品已售罄', icon: 'none' })
    return
  }

  try {
    const res = await memberApi.exchangePoints({ productId: selectedItem.value.id })
    if (res && res.data) {
      userPoints.value = res.data.remainingPoints || (userPoints.value - selectedItem.value.points)
      selectedItem.value.stock = res.data.remainingStock || (selectedItem.value.stock - 1)
      const storedUserInfo = uni.getStorageSync('userInfo')
      if (storedUserInfo) {
        storedUserInfo.points = userPoints.value
        uni.setStorageSync('userInfo', storedUserInfo)
      }
    } else {
      userPoints.value -= selectedItem.value.points
      selectedItem.value.stock -= 1
    }

    showSuccessToast.value = true
    setTimeout(() => { showSuccessToast.value = false }, 3000)
    uni.showToast({ title: '兑换成功！', icon: 'success' })
  } catch (e) {
    console.error('兑换失败:', e)
  }
}

onMounted(() => { loadExchangeData() })
</script>

<style scoped>
/* 页面容器 */
.exchange-container {
	width: 100%;
	min-height: 100vh;
	background-color: #f8f9fa;
	position: relative;
}

/* 积分信息 */
.points-info {
	height: 80px;
	background-color: #FFB6C1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	margin-bottom: 16px;
}

.points-label {
	font-size: 14px;
	color: rgba(255, 255, 255, 0.9);
	margin-bottom: 4px;
}

.points-value {
	font-size: 24px;
	font-weight: bold;
	color: white;
}

/* 兑换商品列表 */
.exchange-list {
	padding: 0 16px;
	margin-bottom: 80px;
}

.exchange-item {
	background-color: white;
	border-radius: 12px;
	margin-bottom: 12px;
	padding: 12px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
	transition: all 0.3s ease;
	display: flex;
	gap: 12px;
}

.exchange-item.selected {
	border: 2px solid #FF69B4;
	box-shadow: 0 4px 12px rgba(255, 105, 180, 0.2);
}

.item-image {
	width: 100px;
	height: 100px;
	border-radius: 8px;
	overflow: hidden;
	flex-shrink: 0;
}

.item-image image {
	width: 100%;
	height: 100%;
}

.item-info {
	flex: 1;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.item-name {
	font-size: 16px;
	font-weight: bold;
	color: #333;
	margin-bottom: 12px;
	display: block;
}

.item-details {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.points-required {
	display: flex;
	align-items: center;
	gap: 4px;
}

.points-icon {
	font-size: 16px;
}

.points-num {
	font-size: 18px;
	font-weight: bold;
	color: #FF69B4;
}

.points-text {
	font-size: 14px;
	color: #666;
}

.stock-info {
	display: flex;
	align-items: center;
}

.stock-text {
	font-size: 14px;
	color: #999;
}

/* 底部兑换按钮 */
.bottom-bar {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	height: 60px;
	background-color: white;
	border-top: 1px solid #f0f0f0;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 16px;
	box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
	z-index: 99;
}

.bar-left {
	flex: 1;
	margin-right: 16px;
}

.selected-info {
	font-size: 14px;
	color: #333;
	line-height: 1.4;
}

.hint-text {
	font-size: 14px;
	color: #999;
}

.exchange-btn {
	width: 120px;
	height: 40px;
	background-color: #FF69B4;
	border-radius: 20px;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
}

.exchange-btn.disabled {
	background-color: #FFC0CB;
	opacity: 0.6;
}

.btn-text {
	font-size: 15px;
	font-weight: bold;
	color: white;
}

/* 兑换成功提示 */
.success-toast {
	position: fixed;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	background-color: rgba(0, 0, 0, 0.8);
	color: white;
	padding: 20px;
	border-radius: 12px;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 12px;
	z-index: 9999;
}

.toast-icon {
	font-size: 32px;
}

.toast-text {
	font-size: 16px;
	font-weight: bold;
}

/* 适配 rpx */
@media screen and (max-width: 750rpx) {
	.exchange-container {
		width: 100%;
	}
	
	.points-info {
		height: 160rpx;
	}
	
	.points-label {
		font-size: 28rpx;
		margin-bottom: 8rpx;
	}
	
	.points-value {
		font-size: 48rpx;
	}
	
	.exchange-list {
		padding: 0 32rpx;
		margin-bottom: 160rpx;
	}
	
	.exchange-item {
		margin-bottom: 24rpx;
		padding: 24rpx;
		border-radius: 24rpx;
		gap: 24rpx;
	}
	
	.item-image {
		width: 200rpx;
		height: 200rpx;
		border-radius: 16rpx;
	}
	
	.item-name {
		font-size: 32rpx;
		margin-bottom: 16rpx;
	}
	
	.points-icon {
		font-size: 32rpx;
	}
	
	.points-num {
		font-size: 36rpx;
	}
	
	.points-text {
		font-size: 28rpx;
	}
	
	.stock-text {
		font-size: 28rpx;
	}
	
	.bottom-bar {
		height: 120rpx;
		padding: 0 32rpx;
	}
	
	.selected-info {
		font-size: 28rpx;
	}
	
	.hint-text {
		font-size: 28rpx;
	}
	
	.exchange-btn {
		width: 240rpx;
		height: 80rpx;
		border-radius: 40rpx;
	}
	
	.btn-text {
		font-size: 30rpx;
	}
	
	.success-toast {
		padding: 40rpx;
		border-radius: 24rpx;
		gap: 24rpx;
	}
	
	.toast-icon {
		font-size: 64rpx;
	}
	
	.toast-text {
		font-size: 32rpx;
	}
}
</style>