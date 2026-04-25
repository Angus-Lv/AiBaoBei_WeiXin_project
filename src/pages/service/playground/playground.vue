<template>
  <view class="playground-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left" @tap="handleBack">
        <text class="back-icon">←</text>
      </view>
      <text class="nav-title">儿童游乐场</text>
      <view class="nav-right"></view>
    </view>
    
    <!-- 头部横幅 -->
    <view class="playground-header">
      <view class="playground-banner">
        <image src="https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20playground%20colorful%20indoor%20play%20area&image_size=landscape_16_9" mode="aspectFill" class="banner-image"></image>
        <view class="banner-overlay">
          <text class="banner-title">儿童游乐场</text>
          <text class="banner-subtitle">安全·快乐·成长</text>
        </view>
      </view>
    </view>
    
    <!-- 服务介绍 -->
    <view class="service-intro">
      <view class="section-title">服务介绍</view>
      <view class="intro-content">
        <text class="intro-text">
          我们的儿童游乐场为0-6岁儿童提供安全、有趣的游乐环境，配备专业的游乐设施和护理人员，让孩子们在玩耍中快乐成长。
        </text>
      </view>
    </view>
    
    <!-- 游乐设施 -->
    <view class="facilities">
      <view class="section-title">游乐设施</view>
      <view class="facilities-list">
        <view class="facility-item" v-for="(item, index) in facilities" :key="index">
          <image :src="item.image" mode="aspectFill" class="facility-image"></image>
          <text class="facility-name">{{ item.name }}</text>
          <text class="facility-desc">{{ item.description }}</text>
        </view>
      </view>
    </view>
    
    <!-- 开放时间 -->
    <view class="opening-hours">
      <view class="section-title">开放时间</view>
      <view class="hours-content">
        <view class="hour-item" v-for="(item, index) in openingHours" :key="index">
          <text class="hour-day">{{ item.day }}</text>
          <text class="hour-time">{{ item.time }}</text>
        </view>
      </view>
    </view>
    
    <!-- 价格信息 -->
    <view class="price-info">
      <view class="section-title">价格信息</view>
      <view class="price-content">
        <view class="price-item" v-for="(item, index) in priceList" :key="index">
          <text class="price-name">{{ item.name }}</text>
          <text class="price-value">{{ item.price }}</text>
        </view>
      </view>
    </view>
    
    <!-- 预约按钮 -->
    <view class="booking-section">
      <button class="booking-btn" @tap="handleBooking">立即预约</button>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// 状态栏高度
const statusBarHeight = ref(0);

// 计算状态栏高度
const getStatusBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync();
  statusBarHeight.value = (systemInfo.statusBarHeight || 0) + 30; // 增加30px的padding，约3cm
};

// 生命周期
onMounted(() => {
  getStatusBarHeight();
});

// 游乐设施数据
const facilities = ref([
  {
    name: '海洋球池',
    description: '安全无毒的海洋球，让孩子在球池中尽情玩耍',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20playing%20in%20ball%20pit%20colorful%20plastic%20balls&image_size=landscape_16_9'
  },
  {
    name: '滑梯组合',
    description: '适合不同年龄段的滑梯，锻炼孩子的平衡能力',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20slide%20indoor%20playground%20colorful%20structure&image_size=landscape_16_9'
  },
  {
    name: '蹦蹦床',
    description: '弹性适中的蹦蹦床，增强孩子的弹跳能力',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20jumping%20on%20trampoline%20indoor%20playground&image_size=landscape_16_9'
  },
  {
    name: '积木区',
    description: '益智积木，培养孩子的创造力和动手能力',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20playing%20with%20building%20blocks%20colorful%20toys&image_size=landscape_16_9'
  }
]);

// 开放时间
const openingHours = ref([
  { day: '周一至周五', time: '10:00 - 19:00' },
  { day: '周六至周日', time: '9:00 - 20:00' }
]);

// 价格信息
const priceList = ref([
  { name: '单次票', price: '¥38/次' },
  { name: '月卡', price: '¥380/月' },
  { name: '季卡', price: '¥980/季' },
  { name: '年卡', price: '¥3280/年' }
]);

// 事件处理
const handleBack = () => {
  uni.navigateBack();
};

const handleBooking = () => {
  console.log('预约儿童游乐场');
  uni.showToast({
    title: '预约功能开发中',
    icon: 'none'
  });
};
</script>

<style scoped>
.playground-container {
  width: 100%;
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* 顶部导航栏 */
.nav-bar {
  min-height: 74px;
  background-color: #FFB6C1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 15px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
}

.nav-left {
  width: 40px;
}

.back-icon {
  font-size: 18px;
  color: white;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: white;
  flex: 1;
  text-align: center;
}

.nav-right {
  width: 40px;
}

/* 头部横幅 */
.playground-header {
  padding-top: 74px;
  position: relative;
}

.playground-banner {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.banner-image {
  width: 100%;
  height: 100%;
  display: block;
}

.banner-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.6));
  padding: 20px 15px;
  color: white;
}

.banner-title {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 5px;
  display: block;
}

.banner-subtitle {
  font-size: 14px;
  opacity: 0.9;
}

/* 服务介绍 */
.service-intro {
  background-color: white;
  margin: 10px 0;
  padding: 15px;
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
  padding-left: 10px;
  border-left: 4px solid #FF69B4;
}

.intro-content {
  line-height: 1.5;
  color: #666;
  font-size: 14px;
}

/* 游乐设施 */
.facilities {
  background-color: white;
  margin: 10px 0;
  padding: 15px;
}

.facilities-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.facility-item {
  width: calc(50% - 5px);
  background-color: #f9f9f9;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.facility-image {
  width: 100%;
  height: 120px;
  display: block;
}

.facility-name {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  padding: 10px 10px 5px;
}

.facility-desc {
  font-size: 12px;
  color: #666;
  padding: 0 10px 10px;
  line-height: 1.3;
}

/* 开放时间 */
.opening-hours {
  background-color: white;
  margin: 10px 0;
  padding: 15px;
}

.hours-content {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.hour-item {
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
  border-bottom: 1px solid #f0f0f0;
}

.hour-day {
  font-size: 14px;
  color: #333;
}

.hour-time {
  font-size: 14px;
  color: #666;
}

/* 价格信息 */
.price-info {
  background-color: white;
  margin: 10px 0;
  padding: 15px;
}

.price-content {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.price-item {
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
  border-bottom: 1px solid #f0f0f0;
}

.price-name {
  font-size: 14px;
  color: #333;
}

.price-value {
  font-size: 14px;
  color: #FF69B4;
  font-weight: bold;
}

/* 预约按钮 */
.booking-section {
  padding: 20px 15px;
  margin-bottom: 20px;
}

.booking-btn {
  width: 100%;
  height: 44px;
  background-color: #FF69B4;
  color: white;
  font-size: 16px;
  font-weight: bold;
  border: none;
  border-radius: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.booking-btn:active {
  background-color: #FF1493;
}
</style>