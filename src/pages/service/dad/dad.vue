<template>
	<view class="dad-container">
		<!-- 顶部导航栏 -->
		<view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
			<view class="nav-left" @tap="handleBack">
				<text class="back-icon">←</text>
			</view>
			<text class="nav-title">宝爸必看</text>
			<view class="nav-right"></view>
		</view>
		
		<!-- 内容列表 -->
		<view class="content-list">
			<view class="content-item" v-for="(item, index) in contentList" :key="index" @tap="handleContentItem(item)">
				<view class="content-image">
					<image :src="item.image" mode="aspectFill"></image>
				</view>
				<view class="content-info">
					<text class="content-title">{{ item.title }}</text>
					<text class="content-desc">{{ item.description }}</text>
					<view class="content-bottom">
						<text class="content-tag">{{ item.tag }}</text>
						<text class="content-time">{{ item.time }}</text>
					</view>
				</view>
			</view>
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

// 内容列表
const contentList = ref([
	{
		id: 1,
		title: '新手爸爸必读：如何正确抱宝宝',
		description: '抱宝宝看似简单，其实有很多讲究。正确的抱姿不仅能让宝宝感到舒适，还能促进宝宝的发育。',
		image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=father%20holding%20baby%20carefully%20with%20love&image_size=landscape_16_9',
		tag: '育儿知识',
		time: '5分钟阅读'
	},
	{
		id: 2,
		title: '宝宝哭闹怎么办？宝爸应对指南',
		description: '宝宝哭闹是新手爸爸最头疼的问题之一。学会识别宝宝哭闹的原因，就能更好地安抚宝宝。',
		image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=father%20comforting%20crying%20baby%20with%20patience&image_size=landscape_16_9',
		tag: '育儿技巧',
		time: '8分钟阅读'
	},
	{
		id: 3,
		title: '爸爸带娃的10个实用技巧',
		description: '从换尿布到哄睡，这些实用技巧让爸爸也能成为带娃高手，让妈妈放心休息。',
		image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=father%20taking%20care%20of%20baby%20with%20confidence&image_size=landscape_16_9',
		tag: '实用技巧',
		time: '10分钟阅读'
	},
	{
		id: 4,
		title: '如何给宝宝洗澡？新手爸爸教程',
		description: '给宝宝洗澡需要特别注意水温和手法。跟着专业护理师学习正确的洗澡方法。',
		image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=father%20bathing%20baby%20with%20care%20and%20love&image_size=landscape_16_9',
		tag: '护理教程',
		time: '6分钟阅读'
	},
	{
		id: 5,
		title: '宝宝睡眠规律培养指南',
		description: '良好的睡眠习惯对宝宝的成长发育至关重要。爸爸也能参与培养宝宝的睡眠规律。',
		image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=father%20putting%20baby%20to%20sleep%20peacefully&image_size=landscape_16_9',
		tag: '睡眠指导',
		time: '7分钟阅读'
	},
	{
		id: 6,
		title: '爸爸如何参与宝宝早期教育',
		description: '早期教育不只是妈妈的责任。爸爸的陪伴和互动对宝宝的智力发育同样重要。',
		image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=father%20playing%20with%20baby%20educational%20toys&image_size=landscape_16_9',
		tag: '早期教育',
		time: '9分钟阅读'
	}
]);

// 事件处理
const handleBack = () => {
	uni.navigateBack();
};

const handleContentItem = (item) => {
	console.log('查看内容:', item);
	// TODO: 跳转到内容详情页
	uni.showToast({
		title: '功能开发中',
		icon: 'none'
	});
};
</script>

<style scoped>
.dad-container {
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

/* 内容列表 */
.content-list {
	padding: 84px 15px 15px;
}

.content-item {
	display: flex;
	background-color: white;
	border-radius: 8px;
	padding: 12px;
	margin-bottom: 10px;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
	transition: all 0.3s ease;
}

.content-item:active {
	transform: scale(0.98);
}

.content-image {
	width: 100px;
	height: 100px;
	background-color: #f0f0f0;
	border-radius: 6px;
	overflow: hidden;
	margin-right: 12px;
	flex-shrink: 0;
}

.content-image image {
	width: 100%;
	height: 100%;
	display: block;
}

.content-info {
	flex: 1;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.content-title {
	font-size: 15px;
	font-weight: bold;
	color: #333;
	margin-bottom: 6px;
	display: -webkit-box;
	display: -moz-box;
	display: box;
	-webkit-line-clamp: 2;
	-moz-line-clamp: 2;
	line-clamp: 2;
	-webkit-box-orient: vertical;
	-moz-box-orient: vertical;
	box-orient: vertical;
	overflow: hidden;
	text-overflow: ellipsis;
	line-height: 1.3;
}

.content-desc {
	font-size: 13px;
	color: #666;
	margin-bottom: 8px;
	display: -webkit-box;
	display: -moz-box;
	display: box;
	-webkit-line-clamp: 2;
	-moz-line-clamp: 2;
	line-clamp: 2;
	-webkit-box-orient: vertical;
	-moz-box-orient: vertical;
	box-orient: vertical;
	overflow: hidden;
	text-overflow: ellipsis;
	line-height: 1.4;
}

.content-bottom {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.content-tag {
	font-size: 11px;
	color: #FF69B4;
	background-color: #FFE4E1;
	padding: 3px 8px;
	border-radius: 4px;
}

.content-time {
	font-size: 11px;
	color: #999;
}
</style>