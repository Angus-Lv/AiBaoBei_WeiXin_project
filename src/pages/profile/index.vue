<template>
	<view class="profile-container">
		<!-- 用户信息 -->
		<view class="user-section">
			<view class="user-avatar">
				<text class="avatar-icon">👤</text>
			</view>
			<view class="user-info">
				<text class="user-name">{{ userInfo.username || '未登录' }}</text>
				<text class="user-tip" v-if="userInfo.isVip">
					{{ userInfo.vipLevel }}会员，积分: {{ userInfo.points }}
				</text>
				<text class="user-tip" v-else>
					点击登录，享受更多服务
				</text>
			</view>
			<view class="login-btn" @tap="handleLogin" v-if="!userInfo.username">
				<text class="login-btn-text">登录/注册</text>
			</view>
			<view class="vip-badge" v-else-if="userInfo.isVip">
				<text class="vip-text">{{ userInfo.vipLevel }}</text>
			</view>
		</view>
		
		<!-- 会员服务 -->
		<view class="member-section">
			<view class="section-header">
				<text class="section-title">会员服务</text>
			</view>
			<view class="member-grid">
				<view class="member-item" @tap="handleMemberBenefit(1)">
					<view class="member-icon">💰</view>
					<text class="member-name">会员充值</text>
				</view>
				<view class="member-item" @tap="handleMemberBenefit(2)">
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
				<view class="service-item" @tap="handleService('orders')">
				<view class="service-icon">📋</view>
				<text class="service-name">我的订单</text>
				<text class="service-arrow">›</text>
			</view>
			<view class="service-item" @tap="handleService('favorites')">
				<view class="service-icon">❤️</view>
				<text class="service-name">我的收藏</text>
				<text class="service-arrow">›</text>
			</view>
			<view class="service-item" @tap="handleCheckin">
				<view class="service-icon">📅</view>
				<text class="service-name">每日签到</text>
				<text class="service-arrow">›</text>
			</view>
			<view class="service-item" @tap="handleMessage">
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
import { ref, onMounted } from 'vue';

// 用户信息
const userInfo = ref({
	username: '',
	isVip: false,
	vipLevel: '',
	points: 0,
	balance: 0
});

// 初始化用户信息
const initUserInfo = () => {
	const storedUserInfo = uni.getStorageSync('userInfo');
	if (storedUserInfo) {
		userInfo.value = storedUserInfo;
	}
};

// 检查登录状态（已关闭）
const checkLoginStatus = () => {
	return true;
};

// 事件处理
const handleLogin = () => {
	console.log('跳转到登录页');
	uni.navigateTo({
		url: '/pages/login/login'
	});
};

const handleMemberBenefit = (id) => {
	if (!checkLoginStatus()) return;
	console.log('会员福利:', id);
	if (id === 1) {
		// 跳转到会员充值页
		uni.navigateTo({
			url: '/pages/member/recharge/recharge'
		});
	} else if (id === 2) {
		// 跳转到积分兑换页
		uni.navigateTo({
			url: '/pages/member/exchange/exchange'
		});
	} else {
		// TODO: 其他会员福利
		uni.showToast({
			title: '该功能暂未实现',
			icon: 'none'
		});
	}
};

// 生命周期
onMounted(() => {
	initUserInfo();
});


const handleService = (type) => {
	if (!checkLoginStatus()) return;
	console.log('我的服务:', type);
	if (type === 'orders') {
		// 跳转到订单页
		uni.navigateTo({
			url: '/pages/profile/orders'
		});
	} else if (type === 'favorites') {
		// 跳转到收藏页
		uni.navigateTo({
			url: '/pages/profile/favorites'
		});
	}
};

const handleCheckin = () => {
	if (!checkLoginStatus()) return;
	console.log('跳转到签到页');
	uni.navigateTo({
		url: '/pages/member/sign/sign'
	});
};

const handleMessage = () => {
	if (!checkLoginStatus()) return;
	console.log('跳转到消息页');
	uni.navigateTo({
		url: '/pages/message/message'
	});
};
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