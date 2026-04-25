<template>
	<view class="login-container">
		<!-- 状态栏 -->
		<view class="status-bar">
			<text class="status-time">{{ currentTime }}</text>
			<text class="status-icons">信号 电池</text>
		</view>
		
		<!-- 标题区域 -->
		<view class="login-header">
			<view class="logo">❤️</view>
			<h1 class="login-title">爱宝贝儿</h1>
			<p class="login-subtitle">爱宝贝儿，还有爱宝贝的你</p>
		</view>
		
		<!-- 登录表单 -->
		<form class="login-form" @submit.prevent="handleLogin">
			<view class="form-group">
				<text class="form-label">账号</text>
				<input 
					type="text" 
					v-model="formData.username" 
					placeholder="请输入账号" 
					class="form-input" 
					required
				/>
			</view>
			
			<view class="form-group">
				<text class="form-label">密码</text>
				<view class="password-input-wrapper">
					<input 
						:type="showPassword ? 'text' : 'password'" 
						v-model="formData.password" 
						placeholder="请输入密码" 
						class="form-input" 
						required
					/>
					<text class="password-toggle" @tap="togglePassword">
						{{ showPassword ? '隐藏' : '显示' }}
					</text>
				</view>
			</view>
			
			<view class="forgot-password">
				<text class="forgot-link" @tap="handleForgotPassword">忘记密码？</text>
			</view>
			
			<button type="submit" class="login-btn">登录</button>
		</form>
		
		<!-- 底部链接 -->
		<view class="login-footer">
			<text>还没有账号？</text>
			<text class="register-link" @tap="handleRegister">立即注册</text>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// 表单数据
const formData = ref({
	username: '',
	password: ''
});

// 密码显示状态
const showPassword = ref(false);

// 当前时间
const currentTime = ref('');

// 切换密码显示状态
const togglePassword = () => {
	showPassword.value = !showPassword.value;
};

// 处理登录
const handleLogin = () => {
	if (formData.value.username && formData.value.password) {
		// 登录成功，设置默认VIP会员
		const userInfo = {
			username: formData.value.username,
			isVip: true,
			vipLevel: 'VIP1',
			points: 100, // 新用户默认赠送100积分
			balance: 0
		};
		
		// 存储用户信息到本地存储
		uni.setStorageSync('userInfo', userInfo);
		
		uni.showToast({
			title: '登录成功！欢迎回来，' + formData.value.username + '\n您已自动成为VIP会员',
			icon: 'success'
		});
		// 登录成功后跳转到首页
		setTimeout(() => {
			uni.switchTab({
				url: '/pages/index/index'
			});
		}, 1500);
	} else {
		uni.showToast({
			title: '请填写完整的账号和密码',
			icon: 'none'
		});
	}
};

// 处理忘记密码
const handleForgotPassword = () => {
	uni.showToast({
		title: '忘记密码功能开发中',
		icon: 'none'
	});
};

// 处理注册
const handleRegister = () => {
	uni.navigateTo({
		url: '/pages/register/register'
	});
};

// 更新当前时间
const updateCurrentTime = () => {
	const now = new Date();
	const hours = now.getHours().toString().padStart(2, '0');
	const minutes = now.getMinutes().toString().padStart(2, '0');
	currentTime.value = `${hours}:${minutes}`;
};

// 生命周期钩子
onMounted(() => {
	updateCurrentTime();
	// 每分钟更新一次时间
	setInterval(updateCurrentTime, 60000);
});
</script>

<style scoped>
/* 全局样式重置 */
.login-container {
	width: 100%;
	min-height: 100vh;
	background: linear-gradient(135deg, #FFFAF0 0%, #FFF0F5 100%);
	padding: 0 20rpx;
	display: flex;
	flex-direction: column;
}

/* 状态栏 */
.status-bar {
	height: 88rpx;
	width: 100%;
	position: fixed;
	top: 0;
	left: 0;
	background-color: #FFB6C1;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 0 20rpx;
	color: white;
	font-size: 28rpx;
	z-index: 100;
}

/* 标题区域 */
.login-header {
	text-align: center;
	margin-top: 160rpx;
	margin-bottom: 80rpx;
}

.logo {
	width: 160rpx;
	height: 160rpx;
	background-color: #FF69B4;
	border-radius: 50%;
	margin: 0 auto 40rpx;
	display: flex;
	justify-content: center;
	align-items: center;
	font-size: 80rpx;
	color: white;
	box-shadow: 0 8rpx 24rpx rgba(255,105,180,0.3);
}

.login-title {
	font-size: 48rpx;
	font-weight: bold;
	color: #FF69B4;
	margin-bottom: 16rpx;
}

.login-subtitle {
	font-size: 28rpx;
	color: #757575;
}

/* 表单区域 */
.login-form {
	width: 100%;
	display: flex;
	flex-direction: column;
	gap: 40rpx;
}

.form-group {
	position: relative;
	width: 100%;
}

.form-label {
	display: block;
	font-size: 28rpx;
	color: #666;
	margin-bottom: 16rpx;
	font-weight: 500;
}

.form-input {
	width: 100%;
	height: 100rpx;
	padding: 0 32rpx;
	border: 4rpx solid #FFE4E1;
	border-radius: 50rpx;
	font-size: 32rpx;
	outline: none;
	transition: all 0.3s ease;
	background-color: white;
	box-shadow: inset 0 4rpx 8rpx rgba(0,0,0,0.05);
}

.form-input:focus {
	border-color: #FF69B4;
	box-shadow: 0 0 0 6rpx rgba(255,105,180,0.1);
}

.password-input-wrapper {
	position: relative;
	width: 100%;
}

.password-toggle {
	position: absolute;
	right: 32rpx;
	top: 50%;
	transform: translateY(-50%);
	color: #757575;
	font-size: 28rpx;
	-webkit-tap-highlight-color: transparent;
}

/* 忘记密码 */
.forgot-password {
	text-align: right;
	margin: 20rpx 0;
}

.forgot-link {
	color: #2196F3;
	text-decoration: none;
	font-size: 28rpx;
	-webkit-tap-highlight-color: transparent;
}

.forgot-link:active {
	color: #1976D2;
}

/* 登录按钮 */
.login-btn {
	width: 100%;
	height: 100rpx;
	background: linear-gradient(135deg, #FF69B4 0%, #FF1493 100%);
	color: white;
	border: none;
	border-radius: 50rpx;
	font-size: 32rpx;
	font-weight: bold;
	cursor: pointer;
	transition: all 0.3s ease;
	box-shadow: 0 8rpx 24rpx rgba(255,105,180,0.3);
	margin-top: 20rpx;
}

.login-btn:active {
	transform: translateY(4rpx);
	box-shadow: 0 4rpx 12rpx rgba(255,105,180,0.3);
}

/* 底部链接 */
.login-footer {
	margin-top: 60rpx;
	text-align: center;
	font-size: 28rpx;
	color: #757575;
	margin-bottom: 100rpx;
}

.register-link {
	color: #FF69B4;
	text-decoration: none;
	font-weight: 500;
	-webkit-tap-highlight-color: transparent;
	margin-left: 8rpx;
}

.register-link:active {
	color: #FF1493;
}
</style>