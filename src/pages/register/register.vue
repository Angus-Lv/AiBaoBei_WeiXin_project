<template>
	<view class="register-container">
		<view class="register-header">
			<view class="logo">❤️</view>
			<h1 class="register-title">爱宝贝儿</h1>
			<p class="register-subtitle">欢迎加入，一起开启美好时光</p>
		</view>
		
		<view class="register-form">
			<view class="form-group">
				<text class="form-label">账号</text>
				<input 
					type="text" 
					v-model="formData.username" 
					placeholder="请设置账号" 
					class="form-input" 
				/>
			</view>
			
			<view class="form-group">
				<text class="form-label">密码</text>
				<view class="password-input-wrapper">
					<input 
						:type="showPassword ? 'text' : 'password'" 
						v-model="formData.password" 
						placeholder="请设置密码" 
						class="form-input" 
					/>
					<text class="password-toggle" @tap="togglePassword">
						{{ showPassword ? '隐藏' : '显示' }}
					</text>
				</view>
			</view>
			
			<view class="form-group">
				<text class="form-label">确认密码</text>
				<view class="password-input-wrapper">
					<input 
						:type="showConfirmPassword ? 'text' : 'password'" 
						v-model="formData.confirmPassword" 
						placeholder="请确认密码" 
						class="form-input" 
					/>
					<text class="password-toggle" @tap="toggleConfirmPassword">
						{{ showConfirmPassword ? '隐藏' : '显示' }}
					</text>
				</view>
			</view>
			
			<button class="register-btn" @tap="handleRegister" :disabled="loading">
				{{ loading ? '注册中...' : '注册' }}
			</button>
		</view>
		
		<view class="register-footer">
			<text>已有账号？</text>
			<text class="login-link" @tap="navigateToLogin">立即登录</text>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { authApi } from '../../api/auth';

const formData = ref({ username: '', password: '', confirmPassword: '' });
const showPassword = ref(false);
const showConfirmPassword = ref(false);
const loading = ref(false);

const togglePassword = () => { 
  showPassword.value = !showPassword.value;
};

const toggleConfirmPassword = () => { 
  showConfirmPassword.value = !showConfirmPassword.value;
};

const handleRegister = async () => {
  if (!formData.value.username.trim()) {
    uni.showToast({ title: '请设置账号', icon: 'none', duration: 2000 });
    return;
  }
  if (!formData.value.password.trim()) {
    uni.showToast({ title: '请设置密码', icon: 'none', duration: 2000 });
    return;
  }
  if (formData.value.password !== formData.value.confirmPassword) {
    uni.showToast({ title: '两次输入的密码不一致', icon: 'none', duration: 2000 });
    return;
  }
  
  if (loading.value) return;
  
  try {
    loading.value = true;
    console.log('正在发送注册请求...', {
      username: formData.value.username.trim(),
      password: formData.value.password.trim()
    });
    
    const res = await authApi.register({
      username: formData.value.username.trim(),
      password: formData.value.password.trim()
    });
    
    console.log('注册响应:', res);
    
    uni.showToast({ title: '注册成功！欢迎加入爱宝贝儿', icon: 'success', duration: 1500 });
    setTimeout(() => { 
      uni.navigateTo({ url: '/pages/login/login' });
    }, 1500);
  } catch (e) {
    console.error('注册失败:', e);
    const errorMsg = e.message || e.msg || '注册失败，请检查网络';
    uni.showToast({ title: errorMsg, icon: 'none', duration: 2000 });
  } finally {
    loading.value = false;
  }
};

const navigateToLogin = () => {
  uni.navigateTo({ url: '/pages/login/login' });
};

onMounted(() => {
  console.log('注册页面加载完成');
});
</script>

<style scoped>
.register-container {
	width: 100%;
	min-height: 100vh;
	background: linear-gradient(135deg, #FFFAF0 0%, #FFF0F5 100%);
	padding: 0 40rpx;
	display: flex;
	flex-direction: column;
}

.register-header {
	text-align: center;
	margin-top: 160rpx;
	margin-bottom: 60rpx;
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

.register-title {
	font-size: 48rpx;
	font-weight: bold;
	color: #FF69B4;
	margin-bottom: 16rpx;
}

.register-subtitle {
	font-size: 28rpx;
	color: #757575;
}

.register-form {
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
	box-sizing: border-box;
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
}

.register-btn {
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

.register-btn:active {
	transform: translateY(4rpx);
	box-shadow: 0 4rpx 12rpx rgba(255,105,180,0.3);
}

.register-btn:disabled {
	opacity: 0.7;
}

.register-footer {
	margin-top: 60rpx;
	text-align: center;
	font-size: 28rpx;
	color: #757575;
	margin-bottom: 100rpx;
}

.login-link {
	color: #FF69B4;
	text-decoration: none;
	font-weight: 500;
	margin-left: 8rpx;
}

.login-link:active {
	color: #FF1493;
}
</style>
