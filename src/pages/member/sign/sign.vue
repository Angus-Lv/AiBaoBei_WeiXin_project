<template>
	<view class="sign-container">
		<!-- 积分信息 -->
		<view class="points-info">
			<text class="points-label">我的积分</text>
			<text class="points-value">{{ userPoints }}</text>
		</view>
		
		<!-- 签到日历 -->
		<view class="calendar-section">
			<view class="section-header">
				<text class="section-title">签到日历</text>
			</view>
			<view class="calendar-grid">
				<view 
					v-for="(day, index) in calendarDays" 
					:key="index"
					class="calendar-day"
					:class="{
						'today': day.isToday,
						'signed': day.isSigned,
						'past': day.isPast,
						'future': day.isFuture
					}"
				>
					<text class="day-number">{{ day.day }}</text>
					<text v-if="day.isSigned" class="sign-icon">✓</text>
				</view>
			</view>
		</view>
		
		<!-- 今日奖励 -->
		<view class="reward-section">
			<view class="section-header">
				<text class="section-title">今日奖励</text>
			</view>
			<view class="reward-card">
				<view class="reward-icon">🎁</view>
				<text class="reward-text">今日签到可获得</text>
				<text class="reward-points">{{ dailyPoints }} 积分</text>
			</view>
		</view>
		
		<!-- 连续签到福利 -->
		<view class="continuous-reward-section">
			<view class="section-header">
				<text class="section-title">连续签到福利</text>
			</view>
			<view class="continuous-reward-list">
				<view 
					v-for="(reward, index) in continuousRewards" 
					:key="index"
					class="continuous-reward-item"
					:class="{ 'completed': reward.days <= continuousDays }"
				>
					<text class="reward-days">{{ reward.days }}天</text>
					<text class="reward-description">{{ reward.reward }}</text>
					<text v-if="reward.days <= continuousDays" class="reward-status">已完成</text>
					<text v-else class="reward-status">进行中</text>
				</view>
			</view>
		</view>
		
		<!-- 一键签到按钮 -->
		<view class="sign-btn-container">
			<view 
				class="sign-btn"
				@tap="handleSign"
				:class="{ 'signed': hasSignedToday }"
				:disabled="hasSignedToday"
			>
				<text class="sign-btn-text">{{ hasSignedToday ? '今日已签到' : '一键签到' }}</text>
			</view>
		</view>
		
		<!-- 签到成功提示 -->
		<view class="success-toast" v-if="showSuccessToast">
			<text class="toast-icon">🎉</text>
			<text class="toast-text">签到成功！</text>
			<text class="toast-points">获得 {{ dailyPoints }} 积分</text>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// 用户数据
const userPoints = ref(100); // 默认积分
const dailyPoints = ref(5); // 每日签到积分
const continuousDays = ref(3); // 连续签到天数
const hasSignedToday = ref(false); // 今日是否已签到
const showSuccessToast = ref(false); // 显示签到成功提示

// 检查登录状态（已关闭）
const checkLoginStatus = () => {
	return true;
};

// 初始化用户积分
const initUserPoints = () => {
	const storedUserInfo = uni.getStorageSync('userInfo');
	if (storedUserInfo && storedUserInfo.points !== undefined) {
		userPoints.value = storedUserInfo.points;
	}
};

// 保存用户积分
const saveUserPoints = () => {
	const storedUserInfo = uni.getStorageSync('userInfo');
	if (storedUserInfo) {
		storedUserInfo.points = userPoints.value;
		uni.setStorageSync('userInfo', storedUserInfo);
	}
};

// 签到日历数据
const calendarDays = ref([]);

// 连续签到福利
const continuousRewards = ref([
	{ days: 3, reward: '额外 10 积分' },
	{ days: 7, reward: '额外 30 积分' },
	{ days: 15, reward: '额外 50 积分' },
	{ days: 30, reward: '额外 100 积分' }
]);

// 生成日历数据
const generateCalendar = () => {
	const days = [];
	const today = new Date();
	const currentDate = today.getDate();
	const currentMonth = today.getMonth();
	const currentYear = today.getFullYear();
	
	// 生成当月30天的数据
	for (let i = 1; i <= 30; i++) {
		const date = new Date(currentYear, currentMonth, i);
		const isToday = i === currentDate;
		const isPast = i < currentDate;
		const isFuture = i > currentDate;
		const isSigned = isPast && Math.random() > 0.5; // 模拟过去的签到状态
		
		days.push({
			day: i,
			isToday,
			isPast,
			isFuture,
			isSigned
		});
	}
	
	calendarDays.value = days;
};

// 事件处理
const handleSign = () => {
	if (!checkLoginStatus()) return;
	if (hasSignedToday.value) {
		uni.showToast({
			title: '今日已签到',
			icon: 'none'
		});
		return;
	}
	
	// 模拟签到成功
	hasSignedToday.value = true;
	userPoints.value += dailyPoints.value;
	continuousDays.value += 1;
	
	// 保存用户积分
	saveUserPoints();
	
	// 更新日历状态
	const todayIndex = calendarDays.value.findIndex(day => day.isToday);
	if (todayIndex !== -1) {
		calendarDays.value[todayIndex].isSigned = true;
	}
	
	// 显示成功提示
	showSuccessToast.value = true;
	
	// 3秒后隐藏提示
	setTimeout(() => {
		showSuccessToast.value = false;
	}, 3000);
	
	// 显示成功信息
	uni.showToast({
		title: '签到成功！获得 5 积分',
		icon: 'success'
	});
};

// 生命周期
onMounted(() => {
	if (!checkLoginStatus()) return;
	initUserPoints();
	generateCalendar();
});
</script>

<style scoped>
/* 页面容器 */
.sign-container {
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

/* 通用区块样式 */
.calendar-section,
.reward-section,
.continuous-reward-section {
	background-color: white;
	margin-bottom: 16px;
	padding: 16px;
}

.section-header {
	margin-bottom: 16px;
}

.section-title {
	font-size: 16px;
	font-weight: bold;
	color: #333;
}

/* 签到日历 */
.calendar-grid {
	display: grid;
	grid-template-columns: repeat(7, 1fr);
	gap: 8px;
}

.calendar-day {
	width: 40px;
	height: 40px;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	border-radius: 8px;
	background-color: #f8f9fa;
	position: relative;
	transition: all 0.3s ease;
}

.calendar-day.today {
	background-color: #FFE4E1;
	border: 1px solid #FF69B4;
}

.calendar-day.signed {
	background-color: #FFB6C1;
	color: white;
}

.calendar-day.past {
	opacity: 0.8;
}

.calendar-day.future {
	opacity: 0.5;
}

.day-number {
	font-size: 14px;
	color: #333;
}

.calendar-day.signed .day-number {
	color: white;
}

.sign-icon {
	font-size: 12px;
	font-weight: bold;
	color: white;
	position: absolute;
	bottom: 2px;
}

/* 今日奖励 */
.reward-card {
	background-color: #FFE4E1;
	border-radius: 12px;
	padding: 20px;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 12px;
}

.reward-icon {
	font-size: 32px;
}

.reward-text {
	font-size: 14px;
	color: #333;
}

.reward-points {
	font-size: 20px;
	font-weight: bold;
	color: #FF69B4;
}

/* 连续签到福利 */
.continuous-reward-list {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.continuous-reward-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 12px;
	background-color: #f8f9fa;
	border-radius: 8px;
	transition: all 0.3s ease;
}

.continuous-reward-item.completed {
	background-color: #FFE4E1;
	border: 1px solid #FF69B4;
}

.reward-days {
	font-size: 14px;
	font-weight: bold;
	color: #333;
}

.reward-description {
	flex: 1;
	margin: 0 12px;
	font-size: 14px;
	color: #666;
}

.reward-status {
	font-size: 12px;
	color: #999;
}

.continuous-reward-item.completed .reward-status {
	color: #FF69B4;
	font-weight: bold;
}

/* 一键签到按钮 */
.sign-btn-container {
	padding: 0 16px;
	margin-bottom: 80px;
}

.sign-btn {
	height: 50px;
	background-color: #FF69B4;
	border-radius: 25px;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
	box-shadow: 0 4px 12px rgba(255, 105, 180, 0.3);
}

.sign-btn.signed {
	background-color: #FFC0CB;
	box-shadow: none;
}

.sign-btn-text {
	font-size: 16px;
	font-weight: bold;
	color: white;
}

/* 签到成功提示 */
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

.toast-points {
	font-size: 14px;
	color: #FFB6C1;
}

/* 适配 rpx */
@media screen and (max-width: 750rpx) {
	.sign-container {
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
	
	.calendar-section,
	.reward-section,
	.continuous-reward-section {
		padding: 32rpx;
		margin-bottom: 32rpx;
	}
	
	.section-header {
		margin-bottom: 32rpx;
	}
	
	.section-title {
		font-size: 32rpx;
	}
	
	.calendar-grid {
		gap: 16rpx;
	}
	
	.calendar-day {
		width: 80rpx;
		height: 80rpx;
		border-radius: 16rpx;
	}
	
	.day-number {
		font-size: 28rpx;
	}
	
	.sign-icon {
		font-size: 24rpx;
		bottom: 4rpx;
	}
	
	.reward-card {
		border-radius: 24rpx;
		padding: 40rpx;
		gap: 24rpx;
	}
	
	.reward-icon {
		font-size: 64rpx;
	}
	
	.reward-text {
		font-size: 28rpx;
	}
	
	.reward-points {
		font-size: 40rpx;
	}
	
	.continuous-reward-list {
		gap: 24rpx;
	}
	
	.continuous-reward-item {
		padding: 24rpx;
		border-radius: 16rpx;
	}
	
	.reward-days {
		font-size: 28rpx;
	}
	
	.reward-description {
		font-size: 28rpx;
		margin: 0 24rpx;
	}
	
	.reward-status {
		font-size: 24rpx;
	}
	
	.sign-btn-container {
		padding: 0 32rpx;
		margin-bottom: 160rpx;
	}
	
	.sign-btn {
		height: 100rpx;
		border-radius: 50rpx;
	}
	
	.sign-btn-text {
		font-size: 32rpx;
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
	
	.toast-points {
		font-size: 28rpx;
	}
}
</style>