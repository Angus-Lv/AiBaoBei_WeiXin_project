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
				@tap="handleSignIn"
				:class="{ 'signed': todaySigned }"
				:disabled="todaySigned"
			>
				<text class="sign-btn-text">{{ todaySigned ? '今日已签到' : '一键签到' }}</text>
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
import { ref, onMounted } from 'vue'
import { memberApi } from '../../../api/member'

const statusBarHeight = ref(0)
const pageLoading = ref(true)
const userPoints = ref(0)
const dailyPoints = ref(5)
const continuousDays = ref(0)
const todaySigned = ref(false)

const calendarDays = ref([])
const continuousRewards = ref([
  { days: 3, reward: '额外 10 积分' },
  { days: 7, reward: '额外 30 积分' },
  { days: 15, reward: '额外 50 积分' },
  { days: 30, reward: '额外 100 积分' }
])

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

const loadSignData = async () => {
  try {
    pageLoading.value = true
    const storedUserInfo = uni.getStorageSync('userInfo')
    userPoints.value = storedUserInfo?.points || 0

    try {
      const statusRes = await memberApi.getSignStatus()
      if (statusRes && statusRes.data) {
        todaySigned.value = statusRes.data.todaySigned || false
        dailyPoints.value = statusRes.data.dailyPoints || 5
        continuousDays.value = statusRes.data.continuousDays || 0
      }

      const recordsRes = await memberApi.getSignRecords({ page: 1, pageSize: 30 })
      if (recordsRes && recordsRes.data) {
        const records = recordsRes.data.records || recordsRes.data.list || recordsRes.data || []
        generateCalendar(records)
      } else {
        generateCalendar([])
      }
    } catch (e) {
      generateCalendar([])
    }
  } catch (e) {
    console.error('签到数据加载失败:', e)
  } finally {
    pageLoading.value = false
  }
}

const generateCalendar = (signedRecords) => {
  const days = []
  const today = new Date()
  const currentDate = today.getDate()
  const currentMonth = today.getMonth()
  const currentYear = today.getFullYear()
  const signedDays = signedRecords.map(r => {
    const d = new Date(r.signDate || r.createTime)
    return d.getDate()
  })

  for (let i = 1; i <= 30; i++) {
    const isToday = i === currentDate
    const isPast = i < currentDate
    const isFuture = i > currentDate
    const isSigned = isToday ? todaySigned.value : signedDays.includes(i)

    days.push({ day: i, isToday, isPast, isFuture, isSigned })
  }

  calendarDays.value = days
}

const handleBack = () => { uni.navigateBack() }

const handleSignIn = async () => {
  if (todaySigned.value) {
    uni.showToast({ title: '今日已签到', icon: 'none' })
    return
  }
  try {
    const res = await memberApi.signIn()
    if (res && res.data) {
      todaySigned.value = true
      continuousDays.value = res.data.continuousDays || (continuousDays.value + 1)
      const earned = res.data.points || dailyPoints.value
      userPoints.value = res.data.totalPoints || (userPoints.value + earned)

      const storedUserInfo = uni.getStorageSync('userInfo')
      if (storedUserInfo) {
        storedUserInfo.points = userPoints.value
        uni.setStorageSync('userInfo', storedUserInfo)
      }

      uni.showToast({ title: `签到成功！+${earned}积分`, icon: 'success' })
      loadSignData()
    }
  } catch (e) {
    console.error('签到失败:', e)
  }
}

onMounted(() => {
  statusBarHeight.value = getNavBarHeight()
  loadSignData()
})
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