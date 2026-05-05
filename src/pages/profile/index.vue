<template>
	<view class="profile-container">
		<!-- 用户信息 -->
		<view class="user-section">
			<view class="user-avatar">
				<text class="avatar-icon">👤</text>
			</view>
			<view class="user-info">
				<text class="user-name">{{ userInfo.username || '未登录' }}</text>
				<text class="user-tip" v-if="userInfo.memberLevel">
					{{ userInfo.memberLevel }}会员，积分: {{ userInfo.points }}
				</text>
				<text class="user-tip" v-else>
					点击登录，享受更多服务
				</text>
			</view>
			<view class="login-btn" @tap="handleLogin" v-if="!userInfo.username">
				<text class="login-btn-text">登录/注册</text>
			</view>
			<view class="vip-badge" v-else-if="userInfo.memberLevel">
				<text class="vip-text">{{ userInfo.memberLevel }}</text>
			</view>
		</view>
		
		<!-- 会员服务 -->
		<view class="member-section">
			<view class="section-header">
				<text class="section-title">会员服务</text>
			</view>
			<view class="member-grid">
				<view class="member-item" @tap="handleMemberRecharge">
					<view class="member-icon">💰</view>
					<text class="member-name">会员充值</text>
				</view>
				<view class="member-item" @tap="handlePointsExchange">
					<view class="member-icon">💎</view>
					<text class="member-name">会员积分</text>
				</view>
			</view>
		</view>
		
		<!-- 我的服务 -->
		<view class="services-section">
			<view class="section-header">
				<text class="section-title">我的服务</text>
			</view>
			<view class="service-list">
				<view class="service-item" @tap="handleOrderManagement">
				<view class="service-icon">📋</view>
				<text class="service-name">我的订单</text>
				<text class="service-arrow">›</text>
			</view>
			<view class="service-item" @tap="handleMyFavorites">
				<view class="service-icon">❤️</view>
				<text class="service-name">我的收藏</text>
				<text class="service-arrow">›</text>
			</view>
			<view class="service-item" @tap="handleSignIn">
				<view class="service-icon">📅</view>
				<text class="service-name">每日签到</text>
				<text class="service-arrow">›</text>
			</view>
			<view class="service-item" @tap="handleMessages">
				<view class="service-icon">💬</view>
				<text class="service-name">消息通知</text>
				<text class="service-arrow">›</text>
			</view>
			</view>
		</view>
		
		<!-- 其他功能 -->
		<view class="other-section">
			<view class="section-header">
				<text class="section-title">其他功能</text>
			</view>
			<view class="service-list">
				<!-- 客服中心和设置已移除 -->
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { userApi } from '../../api/auth'

const userInfo = ref({
  username: '',
  avatarUrl: '/static/alice.png',
  mobile: '',
  memberLevel: '',
  points: 0,
  balance: '0.00'
})
const statusBarHeight = ref(0)

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

const loadUserInfo = async () => {
  try {

    // 尝试使用本地存储的数据
    const storedUserInfo = uni.getStorageSync('userInfo')

    // 如果已登录，尝试调用用户信息接口
    const token = uni.getStorageSync('auth_token')
    if (token) {
      try {
        const res = await userApi.getInfo()
        if (res && res.data) {
          userInfo.value = {
            username: res.data.username || storedUserInfo?.username || '',
            avatarUrl: res.data.avatarUrl || '/static/alice.png',
            mobile: res.data.mobile || '',
            memberLevel: res.data.memberLevel || res.data.vipLevel || '',
            points: res.data.points || 0,
            balance: res.data.balance || '0.00'
          }
          // 更新本地存储的用户信息
          uni.setStorageSync('userInfo', { 
            ...storedUserInfo, 
            ...userInfo.value 
          })
          return
        }
      } catch (e) {
        console.error('获取用户信息失败:', e)
      }
    }

    if (storedUserInfo) {
      userInfo.value = {
        username: storedUserInfo.username || '',
        avatarUrl: storedUserInfo.avatarUrl || '/static/alice.png',
        mobile: storedUserInfo.mobile || '',
        memberLevel: storedUserInfo.memberLevel || storedUserInfo.vipLevel || '',
        points: storedUserInfo.points || 0,
        balance: storedUserInfo.balance || '0.00'
      }
    }
  } catch (e) {
    console.error('用户信息处理失败:', e)
  }
}

const handleOrderManagement = () => {
  uni.navigateTo({ url: '/pages/profile/orders' })
}

const handleMyFavorites = () => {
  uni.navigateTo({ url: '/pages/profile/favorites' })
}

const handleServiceBooking = () => {
  uni.showToast({ title: '服务预约功能开发中', icon: 'none' })
}

const handleMemberCenter = () => {
  uni.navigateTo({ url: '/pages/member/recharge/recharge' })
}

const handleSignIn = () => {
  uni.navigateTo({ url: '/pages/member/sign/sign' })
}

const handlePointsExchange = () => {
  uni.navigateTo({ url: '/pages/member/exchange/exchange' })
}

// 跳转到会员充值页
const handleMemberRecharge = () => {
  uni.navigateTo({ url: '/pages/member/recharge/recharge' })
}

const handleAbout = () => {
  uni.showToast({ title: '关于爱宝贝儿孕婴生活馆', icon: 'none' })
}

const handleLogin = () => {
  uni.navigateTo({ url: '/pages/login/login' })
}

const handleMessages = () => {
  uni.navigateTo({ url: '/pages/message/message' })
}

// 修改密码
const handleChangePassword = () => {
  uni.showToast({ title: '密码修改功能开发中', icon: 'none' })
}

// 退出登录
const handleLogout = () => {
  uni.showModal({
    title: '退出登录',
    content: '确定要退出登录吗？',
    success: (res) => {
      if (res.confirm) {
        uni.removeStorageSync('auth_token')
        uni.removeStorageSync('userInfo')
        uni.showToast({ title: '已退出登录', icon: 'success' })
        setTimeout(() => {
          uni.switchTab({ url: '/pages/index/index' })
        }, 1000)
      }
    }
  })
}

onMounted(() => {
  statusBarHeight.value = getNavBarHeight()
  loadUserInfo()
})
</script>

<style>
.profile-container {
	width: 100%;
	min-height: 100vh;
	background-color: #f8f9fa;
}

.user-section {
	background-color: #FFB6C1;
	padding: 40rpx;
	display: flex;
	align-items: center;
	gap: 30rpx;
}

.user-avatar {
	width: 160rpx;
	height: 160rpx;
	background-color: white;
	border-radius: 50%;
	display: flex;
	justify-content: center;
	align-items: center;
}

.avatar-icon {
	font-size: 80rpx;
}

.user-info {
	flex: 1;
}

.user-name {
	font-size: 36rpx;
	font-weight: bold;
	color: white;
	margin-bottom: 10rpx;
	display: block;
}

.user-tip {
	font-size: 28rpx;
	color: rgba(255, 255, 255, 0.8);
}

.login-btn {
	padding: 16rpx 32rpx;
	background-color: white;
	border-radius: 40rpx;
}

.login-btn-text {
		font-size: 28rpx;
		font-weight: bold;
		color: #FF69B4;
	}

	.vip-badge {
	padding: 16rpx 32rpx;
	background-color: #FFD700;
	border-radius: 40rpx;
	}

	.vip-text {
	font-size: 28rpx;
	font-weight: bold;
	color: #8B4513;
	}

.section-header {
	padding: 30rpx;
	background-color: white;
}

.section-title {
	font-size: 32rpx;
	font-weight: bold;
	color: #333;
}

.member-section {
	background-color: white;
	margin-top: 20rpx;
	padding-bottom: 30rpx;
}

.member-grid {
	display: flex;
	gap: 30rpx;
	padding: 0 30rpx;
}

.member-item {
	flex: 1;
	height: 160rpx;
	background-color: #f8f9fa;
	border-radius: 16rpx;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	gap: 16rpx;
}

.member-icon {
	font-size: 48rpx;
}

.member-name {
	font-size: 28rpx;
	color: #333;
}

.services-section,
.other-section {
	background-color: white;
	margin-top: 20rpx;
	padding-bottom: 120rpx;
}

.service-list {
	padding: 0 30rpx;
}

.service-item {
	display: flex;
	align-items: center;
	gap: 24rpx;
	padding: 30rpx 0;
	border-bottom: 2rpx solid #f0f0f0;
}

.service-item:last-child {
	border-bottom: none;
}

.service-icon {
	font-size: 40rpx;
	width: 60rpx;
}

.service-name {
	flex: 1;
	font-size: 30rpx;
	color: #333;
}

.service-arrow {
	font-size: 28rpx;
	color: #999;
}
</style>