<template>
	<view class="login-container">
		<view class="login-header">
			<view class="logo">❤️</view>
			<h1 class="login-title">爱宝贝儿</h1>
			<p class="login-subtitle">爱宝贝儿，还有爱宝贝的你</p>
		</view>
		
		<view class="login-form">
			<view class="form-group">
				<text class="form-label">账号</text>
				<input 
					type="text" 
					v-model="formData.username" 
					placeholder="请输入账号" 
					class="form-input" 
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
					/>
					<text class="password-toggle" @tap="togglePassword">
						{{ showPassword ? '隐藏' : '显示' }}
					</text>
				</view>
			</view>
			
			<view class="forgot-password">
				<text class="forgot-link" @tap="handleForgotPassword">忘记密码？</text>
			</view>
			
			<button class="login-btn" @tap="handleLogin" :disabled="loading">
				{{ loading ? '登录中...' : '登录' }}
			</button>
		</view>
		
		<view class="login-footer">
			<text>还没有账号？</text>
			<text class="register-link" @tap="handleRegister">立即注册</text>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { authApi } from '../../api/auth';
import { setToken } from '../../utils/request';

const formData = ref({ username: '', password: '' });
const showPassword = ref(false);
const loading = ref(false);

const togglePassword = () => { 
  showPassword.value = !showPassword.value;
};

const handleLogin = async () => {
  if (!formData.value.username.trim()) {
    uni.showToast({ title: '请输入账号', icon: 'none', duration: 2000 });
    return;
  }
  if (!formData.value.password.trim()) {
    uni.showToast({ title: '请输入密码', icon: 'none', duration: 2000 });
    return;
  }
  
  if (loading.value) return;
  
  try {
    loading.value = true;
    console.log('正在发送登录请求...', {
      username: formData.value.username.trim(),
      password: formData.value.password.trim()
    });
    
    const res = await authApi.login({
      username: formData.value.username.trim(),
      password: formData.value.password.trim()
    });
    
    console.log('登录响应:', res);
    
    if (res) {
      const token = res.data?.token || res.token || res.data;
      const userInfo = res.data?.userInfo || res.userInfo || { username: formData.value.username.trim() };
      
      if (token) {
        setToken(token);
        uni.setStorageSync('userInfo', userInfo);
        uni.showToast({ title: '登录成功！', icon: 'success', duration: 1500 });
        
        setTimeout(() => { 
          uni.switchTab({ url: '/pages/index/index' });
        }, 1500);
      } else {
        uni.showToast({ title: '登录失败，未获取到token', icon: 'none', duration: 2000 });
      }
    } else {
      uni.showToast({ title: '登录失败，请重试', icon: 'none', duration: 2000 });
    }
  } catch (e) {
    console.error('登录失败:', e);
    const errorMsg = e.message || e.msg || '登录失败，请检查网络';
    uni.showToast({ title: errorMsg, icon: 'none', duration: 2000 });
  } finally {
    loading.value = false;
  }
};

const handleForgotPassword = () => {
  uni.showToast({ title: '忘记密码功能开发中', icon: 'none' });
};

const handleRegister = () => {
  uni.navigateTo({ url: '/pages/register/register' });
};

onMounted(() => {
  console.log('登录页面加载完成');
});
</script>

<style scoped>
.login-container {
	width: 100%;
	min-height: 100vh;
	background: linear-gradient(135deg, #FFFAF0 0%, #FFF0F5 100%);
	padding: 0 40rpx;
	display: flex;
	flex-direction: column;
}

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

.forgot-password {
	text-align: right;
	margin: 20rpx 0;
}

.forgot-link {
	color: #2196F3;
	text-decoration: none;
	font-size: 28rpx;
}

.forgot-link:active {
	color: #1976D2;
}

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

.login-btn:disabled {
	opacity: 0.7;
}

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
	margin-left: 8rpx;
}

.register-link:active {
	color: #FF1493;
}
</style>
