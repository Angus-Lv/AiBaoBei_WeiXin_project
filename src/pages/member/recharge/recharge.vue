<template>
	<view class="recharge-container">
		<!-- 会员信息头部 -->
		<view class="member-header">
			<view class="member-status">
				<text class="vip-badge">VIP会员</text>
				<text class="member-level">当前等级: {{ memberLevel }}</text>
			</view>
			<view class="member-points">
				<text class="points-label">我的积分</text>
				<text class="points-value">{{ userPoints }}</text>
			</view>
		</view>
		
		<!-- 充值说明 -->
		<view class="recharge-info">
			<text class="info-title">会员充值</text>
			<text class="info-text">充值金额将自动转换为会员余额，可用于商城购物</text>
			<text class="info-text">充值即送额外金额，多充多送！</text>
		</view>
		
		<!-- 充值档位 -->
		<view class="recharge-tiers">
			<view 
				v-for="(tier, index) in rechargeTiers" 
				:key="tier.id"
				class="tier-card"
				:class="{ 'selected': selectedTierId === tier.id }"
				@tap="selectTier(tier.id)"
			>
				<view class="tier-header">
					<text class="tier-amount">¥{{ tier.amount }}</text>
					<text class="tier-bonus" v-if="tier.bonus > 0">+¥{{ tier.bonus }}</text>
				</view>
				<text class="tier-description" v-if="tier.bonus > 0">
					赠送¥{{ tier.bonus }}，实际到账¥{{ tier.amount + tier.bonus }}
				</text>
				<text class="tier-description" v-else>
					无赠送金额
				</text>
				<view class="tier-footer">
					<text class="tier-tag">{{ tier.tag }}</text>
					<view class="select-icon" v-if="selectedTierId === tier.id">✓</view>
				</view>
			</view>
		</view>
		
		<!-- 充值按钮 -->
		<view class="recharge-btn-container">
			<view 
				class="recharge-btn"
				@tap="handleRecharge"
				:class="{ 'disabled': !selectedTierId }"
			>
				<text class="btn-text">立即充值</text>
			</view>
		</view>
		
		<!-- 充值须知 -->
		<view class="recharge-notice">
			<text class="notice-title">充值须知</text>
			<text class="notice-item">1. 充值金额将实时到账，可在个人中心查看余额</text>
			<text class="notice-item">2. 充值金额不支持退款，请谨慎操作</text>
			<text class="notice-item">3. 充值赠送的金额不可提现，仅可用于商城消费</text>
			<text class="notice-item">4. 如有充值问题，请联系客服处理</text>
		</view>
		
		<!-- 充值成功提示 -->
		<view class="success-toast" v-if="showSuccessToast">
			<text class="toast-icon">🎉</text>
			<text class="toast-text">充值成功！</text>
			<text class="toast-amount">已到账 ¥{{ successAmount }}</text>
			<view class="toast-buttons">
				<view class="toast-btn" @tap="continueRecharge">继续充值</view>
				<view class="toast-btn primary" @tap="backToProfile">返回个人中心</view>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { memberApi } from '../../../api/member'

const statusBarHeight = ref(0)
const pageLoading = ref(true)
const memberLevel = ref('VIP1')
const userPoints = ref(0)
const userBalance = ref(0)
const selectedTierId = ref(null)
const showSuccessToast = ref(false)
const successAmount = ref(0)
const rechargeTiers = ref([])

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

const loadRechargeData = async () => {
  try {
    pageLoading.value = true
    const storedUserInfo = uni.getStorageSync('userInfo')
    if (storedUserInfo) {
      memberLevel.value = storedUserInfo.memberLevel || storedUserInfo.vipLevel || 'VIP1'
      userPoints.value = storedUserInfo.points || 0
      userBalance.value = storedUserInfo.balance || 0
    }

    try {
      const res = await memberApi.getRechargeTiers()
      if (res && res.data) {
        rechargeTiers.value = (res.data || []).map(item => ({
          id: item.id,
          amount: item.amount,
          bonus: item.bonus || item.extraAmount || 0,
          tag: item.tag || ''
        }))
      }
    } catch (e) {
      rechargeTiers.value = [
        { id: 1, amount: 100, bonus: 5, tag: '推荐' },
        { id: 2, amount: 200, bonus: 15, tag: '超值' },
        { id: 3, amount: 500, bonus: 50, tag: '热门' },
        { id: 4, amount: 1000, bonus: 120, tag: '豪礼' },
        { id: 5, amount: 2000, bonus: 280, tag: '尊享' }
      ]
    }
  } catch (e) {
    console.error('充值数据加载失败:', e)
  } finally {
    pageLoading.value = false
  }
}

const handleBack = () => { uni.navigateBack() }

const selectTier = (id) => { selectedTierId.value = id }

const handleRecharge = async () => {
  if (!selectedTierId.value) {
    uni.showToast({ title: '请选择充值套餐', icon: 'none' })
    return
  }
  const selectedTier = rechargeTiers.value.find(tier => tier.id === selectedTierId.value)
  if (!selectedTier) return

  try {
    const res = await memberApi.recharge({ tierId: selectedTier.id, amount: selectedTier.amount })
    if (res && res.data) {
      userBalance.value = res.data.totalBalance || (userBalance.value + selectedTier.amount + selectedTier.bonus)
      memberLevel.value = res.data.memberLevel || memberLevel.value
      successAmount.value = res.data.addedAmount || (selectedTier.amount + selectedTier.bonus)

      const storedUserInfo = uni.getStorageSync('userInfo')
      if (storedUserInfo) {
        storedUserInfo.balance = userBalance.value
        storedUserInfo.memberLevel = memberLevel.value
        uni.setStorageSync('userInfo', storedUserInfo)
      }
    } else {
      userBalance.value += selectedTier.amount + selectedTier.bonus
      successAmount.value = selectedTier.amount + selectedTier.bonus
    }

    showSuccessToast.value = true
    uni.showToast({ title: '充值成功！', icon: 'success' })
  } catch (e) {
    console.error('充值失败:', e)
  }
}

const continueRecharge = () => {
  showSuccessToast.value = false
  selectedTierId.value = null
}

const backToProfile = () => {
  showSuccessToast.value = false
  uni.navigateBack({ delta: 1 })
}

onMounted(() => {
  statusBarHeight.value = getNavBarHeight()
  loadRechargeData()
})
</script>

<style scoped>
/* 页面容器 */
.recharge-container {
	width: 100%;
	min-height: 100vh;
	background-color: #f8f9fa;
	position: relative;
}

/* 会员信息头部 */
.member-header {
	background: linear-gradient(135deg, #FFB6C1 0%, #FF69B4 100%);
	padding: 24rpx;
	border-radius: 0 0 24rpx 24rpx;
	color: white;
	margin-bottom: 24rpx;
}

.member-status {
	display: flex;
	align-items: center;
	gap: 12rpx;
	margin-bottom: 16rpx;
}

.vip-badge {
	background-color: rgba(255, 255, 255, 0.3);
	padding: 4rpx 12rpx;
	border-radius: 16rpx;
	font-size: 24rpx;
	font-weight: bold;
}

.member-level {
	font-size: 24rpx;
	opacity: 0.9;
}

.member-points {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding-top: 16rpx;
	border-top: 1rpx solid rgba(255, 255, 255, 0.2);
}

.points-label {
	font-size: 24rpx;
	opacity: 0.9;
}

.points-value {
	font-size: 32rpx;
	font-weight: bold;
}

/* 充值说明 */
.recharge-info {
	background-color: white;
	padding: 24rpx;
	margin-bottom: 24rpx;
	border-radius: 16rpx;
	margin: 0 24rpx 24rpx;
}

.info-title {
	font-size: 28rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 12rpx;
	display: block;
}

.info-text {
	font-size: 24rpx;
	color: #666;
	line-height: 1.4;
	margin-bottom: 8rpx;
	display: block;
}

/* 充值档位 */
.recharge-tiers {
	padding: 0 24rpx;
	margin-bottom: 32rpx;
}

.tier-card {
	background-color: white;
	border-radius: 16rpx;
	padding: 28rpx;
	margin-bottom: 20rpx;
	border: 2rpx solid #f0f0f0;
	transition: all 0.3s ease;
	position: relative;
}

.tier-card.selected {
	border-color: #FF69B4;
	background-color: #FFF0F5;
	box-shadow: 0 4rpx 16rpx rgba(255, 105, 180, 0.2);
}

.tier-header {
	display: flex;
	justify-content: space-between;
	align-items: baseline;
	margin-bottom: 12rpx;
}

.tier-amount {
	font-size: 36rpx;
	font-weight: bold;
	color: #333;
}

.tier-bonus {
	font-size: 24rpx;
	color: #FF69B4;
	font-weight: bold;
}

.tier-description {
	font-size: 24rpx;
	color: #666;
	margin-bottom: 16rpx;
	display: block;
}

.tier-footer {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.tier-tag {
	background-color: #FFE4E1;
	color: #FF69B4;
	padding: 4rpx 12rpx;
	border-radius: 12rpx;
	font-size: 20rpx;
	font-weight: bold;
}

.select-icon {
	width: 32rpx;
	height: 32rpx;
	background-color: #FF69B4;
	color: white;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20rpx;
	font-weight: bold;
}

/* 充值按钮 */
.recharge-btn-container {
	padding: 0 24rpx;
	margin-bottom: 32rpx;
}

.recharge-btn {
	height: 80rpx;
	background-color: #FF69B4;
	border-radius: 40rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
	box-shadow: 0 4rpx 16rpx rgba(255, 105, 180, 0.3);
}

.recharge-btn.disabled {
	background-color: #FFC0CB;
	box-shadow: none;
	opacity: 0.6;
}

.btn-text {
	font-size: 28rpx;
	font-weight: bold;
	color: white;
}

/* 充值须知 */
.recharge-notice {
	padding: 0 24rpx;
	margin-bottom: 40rpx;
}

.notice-title {
	font-size: 24rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 12rpx;
	display: block;
}

.notice-item {
	font-size: 22rpx;
	color: #666;
	line-height: 1.4;
	margin-bottom: 8rpx;
	display: block;
}

/* 充值成功提示 */
.success-toast {
	position: fixed;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	background-color: white;
	border-radius: 24rpx;
	padding: 40rpx;
	width: 80%;
	max-width: 500rpx;
	box-shadow: 0 8rpx 32rpx rgba(0, 0, 0, 0.2);
	z-index: 9999;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 20rpx;
}

.toast-icon {
	font-size: 64rpx;
}

.toast-text {
	font-size: 32rpx;
	font-weight: bold;
	color: #333;
}

.toast-amount {
	font-size: 28rpx;
	color: #FF69B4;
	font-weight: bold;
}

.toast-buttons {
	display: flex;
	gap: 20rpx;
	margin-top: 12rpx;
	width: 100%;
}

.toast-btn {
	flex: 1;
	height: 60rpx;
	border: 2rpx solid #FF69B4;
	border-radius: 30rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24rpx;
	color: #FF69B4;
	transition: all 0.3s ease;
}

.toast-btn.primary {
	background-color: #FF69B4;
	color: white;
}

.toast-btn:active {
	opacity: 0.8;
}

/* 适配 rpx */
@media screen and (max-width: 750rpx) {
	.recharge-container {
		width: 100%;
	}
	
	.member-header {
		padding: 48rpx;
		border-radius: 0 0 48rpx 48rpx;
		margin-bottom: 48rpx;
	}
	
	.member-status {
		gap: 24rpx;
		margin-bottom: 32rpx;
	}
	
	.vip-badge {
		padding: 8rpx 24rpx;
		border-radius: 32rpx;
		font-size: 48rpx;
	}
	
	.member-level {
		font-size: 48rpx;
	}
	
	.member-points {
		padding-top: 32rpx;
	}
	
	.points-label {
		font-size: 48rpx;
	}
	
	.points-value {
		font-size: 64rpx;
	}
	
	.recharge-info {
		padding: 48rpx;
		margin: 0 48rpx 48rpx;
		border-radius: 32rpx;
	}
	
	.info-title {
		font-size: 56rpx;
		margin-bottom: 24rpx;
	}
	
	.info-text {
		font-size: 48rpx;
		margin-bottom: 16rpx;
	}
	
	.recharge-tiers {
		padding: 0 48rpx;
		margin-bottom: 64rpx;
	}
	
	.tier-card {
		padding: 56rpx;
		margin-bottom: 40rpx;
		border-radius: 32rpx;
		border-width: 4rpx;
	}
	
	.tier-amount {
		font-size: 72rpx;
	}
	
	.tier-bonus {
		font-size: 48rpx;
	}
	
	.tier-description {
		font-size: 48rpx;
		margin-bottom: 32rpx;
	}
	
	.tier-tag {
		padding: 8rpx 24rpx;
		border-radius: 24rpx;
		font-size: 40rpx;
	}
	
	.select-icon {
		width: 64rpx;
		height: 64rpx;
		font-size: 40rpx;
	}
	
	.recharge-btn-container {
		padding: 0 48rpx;
		margin-bottom: 64rpx;
	}
	
	.recharge-btn {
		height: 160rpx;
		border-radius: 80rpx;
	}
	
	.btn-text {
		font-size: 56rpx;
	}
	
	.recharge-notice {
		padding: 0 48rpx;
		margin-bottom: 80rpx;
	}
	
	.notice-title {
		font-size: 48rpx;
		margin-bottom: 24rpx;
	}
	
	.notice-item {
		font-size: 44rpx;
		margin-bottom: 16rpx;
	}
	
	.success-toast {
		border-radius: 48rpx;
		padding: 80rpx;
		gap: 40rpx;
	}
	
	.toast-icon {
		font-size: 128rpx;
	}
	
	.toast-text {
		font-size: 64rpx;
	}
	
	.toast-amount {
		font-size: 56rpx;
	}
	
	.toast-buttons {
		gap: 40rpx;
		margin-top: 24rpx;
	}
	
	.toast-btn {
		height: 120rpx;
		border-radius: 60rpx;
		font-size: 48rpx;
	}
}
</style>