<template>
  <view class="early-education-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left" @tap="handleBack">
        <text class="back-icon">←</text>
      </view>
      <text class="nav-title">早教课程</text>
      <view class="nav-right"></view>
    </view>
    
    <!-- 头部横幅 -->
    <view class="early-education-header">
      <view class="early-education-banner">
        <image src="https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=early%20education%20classroom%20colorful%20children%20learning%20together&image_size=landscape_16_9" mode="aspectFill" class="banner-image"></image>
        <view class="banner-overlay">
          <text class="banner-title">早教课程</text>
          <text class="banner-subtitle">科学·专业·全面</text>
        </view>
      </view>
    </view>
    
    <!-- 课程介绍 -->
    <view class="course-intro">
      <view class="section-title">课程介绍</view>
      <view class="intro-content">
        <text class="intro-text">
          我们的早教课程针对0-3岁婴幼儿，通过科学的教育方法，促进孩子的智力、语言、运动和社交能力全面发展，为孩子的未来奠定坚实的基础。
        </text>
      </view>
    </view>
    
    <!-- 课程列表 -->
    <view class="course-list">
      <view class="section-title">课程列表</view>
      <view class="courses">
        <view class="course-item" v-for="(course, index) in courses" :key="index" @tap="handleCourseDetail(course)">
          <view class="course-image">
            <image :src="course.image" mode="aspectFill"></image>
          </view>
          <view class="course-info">
            <text class="course-name">{{ course.name }}</text>
            <text class="course-age">{{ course.age }}</text>
            <text class="course-desc">{{ course.description }}</text>
            <text class="course-price">{{ course.price }}</text>
          </view>
        </view>
      </view>
    </view>
    
    <!-- 教师团队 -->
    <view class="teacher-team">
      <view class="section-title">教师团队</view>
      <view class="teachers">
        <view class="teacher-item" v-for="(teacher, index) in teachers" :key="index">
          <image :src="teacher.image" mode="aspectFill" class="teacher-image"></image>
          <text class="teacher-name">{{ teacher.name }}</text>
          <text class="teacher-title">{{ teacher.title }}</text>
        </view>
      </view>
    </view>
    
    <!-- 预约按钮 -->
    <view class="booking-section">
      <button class="booking-btn" @tap="handleBooking">立即预约试听</button>
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

// 课程数据
const courses = ref([
  {
    name: '启蒙课程',
    age: '0-12个月',
    description: '通过感官刺激和亲子互动，促进宝宝的视觉、听觉、触觉等感官发育',
    price: '¥128/课时',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=babies%20sensory%20play%20colorful%20toys%20parent%20interaction&image_size=landscape_16_9'
  },
  {
    name: '运动课程',
    age: '1-2岁',
    description: '通过各种运动游戏，发展宝宝的大运动和精细动作能力',
    price: '¥138/课时',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=toddler%20motor%20skills%20development%20playing%20active%20games&image_size=landscape_16_9'
  },
  {
    name: '语言课程',
    age: '1.5-3岁',
    description: '通过故事、儿歌等形式，培养宝宝的语言表达和理解能力',
    price: '¥148/课时',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20language%20learning%20story%20time%20teacher%20reading&image_size=landscape_16_9'
  },
  {
    name: '社交课程',
    age: '2-3岁',
    description: '通过集体游戏和合作活动，培养宝宝的社交能力和情绪管理能力',
    price: '¥158/课时',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=children%20social%20interaction%20group%20play%20cooperation&image_size=landscape_16_9'
  }
]);

// 教师数据
const teachers = ref([
  {
    name: '李老师',
    title: '资深早教专家',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=professional%20female%20early%20education%20teacher%20smiling&image_size=portrait_4_3'
  },
  {
    name: '王老师',
    title: '儿童发展顾问',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=professional%20male%20early%20education%20teacher%20friendly&image_size=portrait_4_3'
  },
  {
    name: '张老师',
    title: '音乐教育专家',
    image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=professional%20female%20music%20teacher%20early%20education&image_size=portrait_4_3'
  }
]);

// 事件处理
const handleBack = () => {
  uni.navigateBack();
};

const handleCourseDetail = (course) => {
  console.log('查看课程详情:', course);
  uni.showToast({
    title: '课程详情功能开发中',
    icon: 'none'
  });
};

const handleBooking = () => {
  console.log('预约试听');
  uni.showToast({
    title: '预约功能开发中',
    icon: 'none'
  });
};
</script>

<style scoped>
.early-education-container {
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
.early-education-header {
  padding-top: 74px;
  position: relative;
}

.early-education-banner {
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

/* 课程介绍 */
.course-intro {
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

/* 课程列表 */
.course-list {
  background-color: white;
  margin: 10px 0;
  padding: 15px;
}

.course-item {
  display: flex;
  background-color: #f9f9f9;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.course-item:active {
  transform: scale(0.98);
}

.course-image {
  width: 100px;
  height: 100px;
  flex-shrink: 0;
}

.course-image image {
  width: 100%;
  height: 100%;
  display: block;
}

.course-info {
  flex: 1;
  padding: 10px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.course-name {
  font-size: 15px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.course-age {
  font-size: 12px;
  color: #FF69B4;
  background-color: #FFE4E1;
  padding: 2px 6px;
  border-radius: 4px;
  align-self: flex-start;
  margin-bottom: 5px;
}

.course-desc {
  font-size: 13px;
  color: #666;
  line-height: 1.3;
  margin-bottom: 5px;
  flex: 1;
}

.course-price {
  font-size: 14px;
  color: #FF69B4;
  font-weight: bold;
  align-self: flex-end;
}

/* 教师团队 */
.teacher-team {
  background-color: white;
  margin: 10px 0;
  padding: 15px;
}

.teachers {
  display: flex;
  gap: 15px;
  overflow-x: auto;
  padding-bottom: 10px;
}

.teacher-item {
  flex: 0 0 100px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.teacher-image {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin-bottom: 10px;
  object-fit: cover;
}

.teacher-name {
  font-size: 14px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.teacher-title {
  font-size: 12px;
  color: #666;
  text-align: center;
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