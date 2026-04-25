<template>
	<view class="hair-container">
		<!-- 服务图片展示 -->
		<view class="image-section">
			<swiper class="image-swiper" :indicator-dots="true" :autoplay="true" :interval="3000" :duration="500">
				<swiper-item v-for="(image, index) in hairImages" :key="index">
					<image :src="image" class="swiper-image" mode="aspectFill"></image>
				</swiper-item>
			</swiper>
		</view>
		
		<!-- 服务介绍 -->
		<view class="service-info">
			<view class="service-header">
				<text class="service-title">婴儿理发</text>
				<text class="service-price">¥29</text>
			</view>
			<view class="service-description">
				<text class="description-text">专业婴儿理发服务，使用安全无刺激的理发工具，由经验丰富的理发师操作，让宝宝享受舒适的理发体验。</text>
				<view class="service-features">
					<view class="feature-item">
						<text class="feature-icon">✂️</text>
						<text class="feature-text">专业理发工具</text>
					</view>
					<view class="feature-item">
						<text class="feature-icon">👨‍🎨</text>
						<text class="feature-text">经验丰富理发师</text>
					</view>
					<view class="feature-item">
						<text class="feature-icon">🛡️</text>
						<text class="feature-text">安全卫生环境</text>
					</view>
					<view class="feature-item">
						<text class="feature-icon">🎁</text>
						<text class="feature-text">赠送纪念品</text>
					</view>
				</view>
			</view>
		</view>
		
		<!-- 预约信息 -->
		<view class="booking-section">
			<view class="section-header">
				<text class="section-title">预约信息</text>
			</view>
			
			<!-- 日期选择 -->
			<view class="booking-item">
				<text class="booking-label">选择日期</text>
				<view class="date-picker">
					<view 
						v-for="(date, index) in availableDates" 
						:key="index"
						class="date-item"
						:class="{ 'selected': selectedDate === date.date }"
						@tap="selectDate(date)"
					>
						<text class="date-week">{{ date.week }}</text>
						<text class="date-number">{{ date.date }}</text>
					</view>
				</view>
			</view>
			
			<!-- 时段选择 -->
			<view class="booking-item">
				<text class="booking-label">选择时段</text>
				<view class="time-picker">
					<view 
						v-for="(time, index) in availableTimes" 
						:key="index"
						class="time-item"
						:class="{ 'selected': selectedTime === time, 'disabled': !isTimeAvailable(time) }"
						@tap="selectTime(time)"
					>
						<text class="time-text">{{ time }}</text>
					</view>
				</view>
			</view>
			
			<!-- 宝宝信息 -->
			<view class="booking-item">
				<text class="booking-label">宝宝信息</text>
				<view class="baby-info">
					<input 
						class="info-input"
						v-model="babyName"
						placeholder="宝宝姓名"
						placeholder-class="placeholder-text"
					/>
					<input 
						class="info-input"
						v-model="babyAge"
						placeholder="宝宝月龄"
						placeholder-class="placeholder-text"
					/>
				</view>
			</view>
			
			<!-- 联系信息 -->
			<view class="booking-item">
				<text class="booking-label">联系信息</text>
				<view class="contact-info">
					<input 
						class="info-input"
						v-model="contactName"
						placeholder="联系人姓名"
						placeholder-class="placeholder-text"
					/>
					<input 
						class="info-input"
						v-model="contactPhone"
						placeholder="手机号码"
						placeholder-class="placeholder-text"
						type="number"
					/>
				</view>
			</view>
		</view>
		
		<!-- 预约按钮 -->
		<view class="booking-btn-container">
			<view 
				class="booking-btn"
				@tap="submitBooking"
				:class="{ 'disabled': !canSubmit }"
			>
				<text class="btn-text">确认预约</text>
			</view>
		</view>
		
		<!-- 预约成功提示 -->
		<view class="success-toast" v-if="showSuccess">
			<text class="toast-icon">🎉</text>
			<text class="toast-title">预约成功！</text>
			<text class="toast-content">我们会尽快与您联系确认预约详情</text>
			<view class="toast-btn" @tap="closeToast">确定</view>
		</view>
	</view>
</template>

<script setup>
import { ref, computed } from 'vue';

// 检查登录状态（已关闭）
const checkLoginStatus = () => {
	return true;
};

// 服务图片
const hairImages = ref([
	'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=baby%20haircut%20service%20in%20pink%20room%20with%20professional%20barber&image_size=landscape_16_9',
	'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=baby%20haircut%20with%20gentle%20care%20and%20toys&image_size=landscape_16_9',
	'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=professional%20baby%20haircutting%20service&image_size=landscape_16_9'
]);

// 可预约日期
const availableDates = ref([
	{ date: '2026-01-30', week: '周五' },
	{ date: '2026-01-31', week: '周六' },
	{ date: '2026-02-01', week: '周日' },
	{ date: '2026-02-02', week: '周一' },
	{ date: '2026-02-03', week: '周二' }
]);

// 可预约时段
const availableTimes = ref([
	'09:00-10:00',
	'10:00-11:00',
	'11:00-12:00',
	'14:00-15:00',
	'15:00-16:00',
	'16:00-17:00'
]);

// 预约信息
const selectedDate = ref('');
const selectedTime = ref('');
const babyName = ref('');
const babyAge = ref('');
const contactName = ref('');
const contactPhone = ref('');
const showSuccess = ref(false);

// 选择日期
const selectDate = (date) => {
	selectedDate.value = date.date;
	// 重置时段选择
	selectedTime.value = '';
};

// 选择时段
const selectTime = (time) => {
	if (isTimeAvailable(time) && selectedDate.value) {
		selectedTime.value = time;
	}
};

// 检查时段是否可用
const isTimeAvailable = (time) => {
	// 模拟某些时段已被预约
	const bookedTimes = ['10:00-11:00', '15:00-16:00'];
	return !bookedTimes.includes(time);
};

// 是否可以提交
const canSubmit = computed(() => {
	return selectedDate.value && 
		   selectedTime.value && 
		   babyName.value.trim() && 
		   babyAge.value.trim() && 
		   contactName.value.trim() && 
		   contactPhone.value.trim() && 
		   contactPhone.value.length === 11;
});

// 提交预约
const submitBooking = () => {
	if (!checkLoginStatus()) return;
	if (!selectedDate.value) {
		uni.showToast({
			title: '请选择预约日期',
			icon: 'none'
		});
		return;
	}
	if (!selectedTime.value) {
		uni.showToast({
			title: '请选择预约时段',
			icon: 'none'
		});
		return;
	}
	if (!babyName.value.trim()) {
		uni.showToast({
			title: '请填写宝宝姓名',
			icon: 'none'
		});
		return;
	}
	if (!babyAge.value.trim()) {
		uni.showToast({
			title: '请填写宝宝月龄',
			icon: 'none'
		});
		return;
	}
	if (!contactName.value.trim()) {
		uni.showToast({
			title: '请填写联系人姓名',
			icon: 'none'
		});
		return;
	}
	if (!contactPhone.value.trim()) {
		uni.showToast({
			title: '请填写手机号码',
			icon: 'none'
		});
		return;
	}
	if (contactPhone.value.length !== 11) {
		uni.showToast({
			title: '请输入11位手机号码',
			icon: 'none'
		});
		return;
	}
	
	// 模拟预约提交
	console.log('预约信息:', {
		date: selectedDate.value,
		time: selectedTime.value,
		babyName: babyName.value,
		babyAge: babyAge.value,
		contactName: contactName.value,
		contactPhone: contactPhone.value
	});
	
	// 显示成功提示
	showSuccess.value = true;
};

// 关闭提示
const closeToast = () => {
	showSuccess.value = false;
	// 重置表单
	selectedDate.value = '';
	selectedTime.value = '';
	babyName.value = '';
	babyAge.value = '';
	contactName.value = '';
	contactPhone.value = '';
	
	// 返回上一页
	setTimeout(() => {
		uni.navigateBack();
	}, 500);
};
</script>

<style scoped>
.hair-container {
	width: 100%;
	min-height: 100vh;
	background-color: #f8f9fa;
	padding-bottom: 80px;
}

.image-section {
	width: 100%;
	height: 200px;
}

.image-swiper {
	width: 100%;
	height: 100%;
}

.swiper-image {
	width: 100%;
	height: 100%;
}

.service-info {
	background-color: white;
	padding: 16px;
	margin-bottom: 12px;
}

.service-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 12px;
}

.service-title {
	font-size: 18px;
	font-weight: bold;
	color: #333;
}

.service-price {
	font-size: 16px;
	font-weight: bold;
	color: #FF69B4;
	background-color: #FFE4E1;
	padding: 4px 12px;
	border-radius: 12px;
}

.service-description {
	margin-bottom: 8px;
}

.description-text {
	font-size: 14px;
	color: #666;
	line-height: 1.4;
	margin-bottom: 12px;
}

.service-features {
	display: flex;
	flex-wrap: wrap;
	gap: 12px;
}

.feature-item {
	display: flex;
	align-items: center;
	gap: 6px;
	background-color: #f8f9fa;
	padding: 8px 12px;
	border-radius: 16px;
}

.feature-icon {
	font-size: 14px;
}

.feature-text {
	font-size: 12px;
	color: #666;
}

.booking-section {
	background-color: white;
	padding: 16px;
	margin-bottom: 12px;
}

.section-header {
	margin-bottom: 16px;
}

.section-title {
	font-size: 16px;
	font-weight: bold;
	color: #333;
}

.booking-item {
	margin-bottom: 20px;
}

.booking-label {
	font-size: 14px;
	color: #666;
	margin-bottom: 10px;
	display: block;
}

.date-picker {
	display: flex;
	gap: 10px;
	overflow-x: auto;
	padding-bottom: 8px;
}

.date-item {
	min-width: 60px;
	height: 70px;
	background-color: #f8f9fa;
	border-radius: 8px;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
}

.date-item.selected {
	background-color: #FFB6C1;
	color: white;
}

.date-week {
	font-size: 12px;
	margin-bottom: 4px;
}

.date-number {
	font-size: 16px;
	font-weight: bold;
}

.time-picker {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
}

.time-item {
	padding: 10px 16px;
	background-color: #f8f9fa;
	border-radius: 20px;
	transition: all 0.3s ease;
}

.time-item.selected {
	background-color: #FF69B4;
	color: white;
}

.time-item.disabled {
	background-color: #e0e0e0;
	color: #999;
	cursor: not-allowed;
}

.time-text {
	font-size: 14px;
}

.baby-info,
.contact-info {
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.info-input {
	height: 44px;
	background-color: #f8f9fa;
	border-radius: 8px;
	padding: 0 12px;
	font-size: 14px;
	color: #333;
}

.placeholder-text {
	color: #999;
}

.booking-btn-container {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	background-color: white;
	padding: 16px;
	box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.05);
	z-index: 100;
	height: 80px;
	display: flex;
	align-items: center;
}

.booking-btn {
	width: 100%;
	height: 48px;
	background-color: #FF69B4;
	border-radius: 24px;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
}

.booking-btn.disabled {
	background-color: #FFC0CB;
	opacity: 0.6;
}

.btn-text {
	font-size: 16px;
	font-weight: bold;
	color: white;
}

.success-toast {
	position: fixed;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	background-color: white;
	border-radius: 16px;
	padding: 30px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
	z-index: 9999;
	width: 80%;
	max-width: 300px;
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 16px;
}

.toast-icon {
	font-size: 48px;
}

.toast-title {
	font-size: 18px;
	font-weight: bold;
	color: #333;
}

.toast-content {
	font-size: 14px;
	color: #666;
	text-align: center;
	line-height: 1.4;
}

.toast-btn {
	width: 100%;
	height: 44px;
	background-color: #FF69B4;
	border-radius: 22px;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-top: 8px;
}

.toast-btn text {
	font-size: 16px;
	font-weight: bold;
	color: white;
}
</style>