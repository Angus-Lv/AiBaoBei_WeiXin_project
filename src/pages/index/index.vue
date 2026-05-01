<template>
	<view class="home-container">
		<!-- 顶部导航 -->
		<view class="top-nav" :style="{ paddingTop: statusBarHeight + 'px' }">
			<text class="store-name">爱宝贝儿孕婴生活馆</text>
			<view class="top-right">
				<view class="icon-btn" @tap="handleMessage">
					<text class="icon">💬</text>
					<view class="badge">3</view>
				</view>
				<view class="icon-btn" @tap="handleMember">
					<text class="icon">👑</text>
				</view>
			</view>
		</view>
		
		<!-- 搜索框 -->
		<view class="search-section">
			<view class="search-box">
				<text class="search-icon">🔍</text>
				<input 
					class="search-input" 
					v-model="searchKeyword" 
					placeholder="搜索商品/服务" 
					placeholder-class="search-placeholder"
					@confirm="handleSearchConfirm"
					:focus="searchFocus"
					@focus="handleSearchFocus"
					@blur="handleSearchBlur"
				/>
				<text v-if="searchKeyword" class="search-clear" @tap="handleSearchClear">✕</text>
			</view>
			<view class="hot-tags">
				<text class="tag" @tap="handleSearchTag('奶粉')">奶粉</text>
				<text class="tag" @tap="handleSearchTag('尿裤')">尿裤</text>
				<text class="tag" @tap="handleSearchTag('童装')">童装</text>
				<text class="tag" @tap="handleSearchTag('玩具')">玩具</text>
				<text class="tag" @tap="handleSearchTag('零食')">零食</text>
			</view>
		</view>
		
		<!-- 轮播图 -->
		<view class="swiper-section">
			<swiper class="swiper" :indicator-dots="true" :autoplay="true" :interval="3000" :duration="500" indicator-color="rgba(255,255,255,0.5)" indicator-active-color="#FF69B4">
				<swiper-item v-for="item in swiperList" :key="item.id" class="swiper-item" @tap="handleSwiperItem(item)">
					<image :src="item.image" class="swiper-image" mode="aspectFill" />
					<view class="swiper-title">{{ item.title }}</view>
				</swiper-item>
			</swiper>
		</view>
		
		<!-- 限时秒杀 -->
		<view class="seckill-section">
			<view class="section-header">
				<text class="section-title">今日秒杀</text>
				<text class="more" @tap="handleMoreSeckill">更多 ></text>
			</view>
			<view class="seckill-list">
				<view class="seckill-item" v-for="(item, index) in seckillList" :key="index" @tap="handleSeckillItem(item.id)">
					<view class="seckill-image">
						<image :src="item.image" mode="aspectFill"></image>
					</view>
					<text class="seckill-name">{{ item.name }}</text>
					<view class="seckill-price">
						<text class="current-price">¥{{ item.currentPrice }}</text>
						<text class="original-price">¥{{ item.originalPrice }}</text>
					</view>
				</view>
			</view>
		</view>
		
		<!-- 核心品类 -->
		<view class="category-section">
			<scroll-view scroll-x="true" class="category-scroll">
				<view class="category-item" v-for="(item, index) in categoryList" :key="index" @tap="handleCategory(item.id)">
					<view class="category-icon">{{ item.icon }}</view>
					<text class="category-name">{{ item.name }}</text>
				</view>
			</scroll-view>
		</view>
		
		<!-- 爆款商品 -->
		<view class="hot-section">
			<view class="section-header">
				<text class="section-title">爆款推荐</text>
				<text class="more" @tap="handleMoreHot">更多 ></text>
			</view>
			<view class="hot-grid">
				<view class="hot-item" v-for="(item, index) in hotList" :key="index" @tap="handleHotItem(item.id)">
					<view class="hot-image">
						<image :src="item.image" mode="aspectFill"></image>
						<view class="hot-tag">爆款</view>
					</view>
					<text class="hot-name">{{ item.name }}</text>
					<view class="hot-bottom">
						<text class="hot-price">¥{{ item.price }}</text>
						<text class="hot-sales">已售 {{ item.sales }}</text>
					</view>
				</view>
			</view>
		</view>
		
		<!-- 门店服务 -->
		<view class="service-section">
			<view class="section-header">
				<text class="section-title">门店服务</text>
				<text class="more" @tap="handleMoreService">更多 ></text>
			</view>
			<view class="service-grid">
				<view class="service-item" v-for="(item, index) in serviceList" :key="index" @tap="handleService(item.id)">
					<view class="service-icon">{{ item.icon }}</view>
					<text class="service-name">{{ item.name }}</text>
				</view>
			</view>
		</view>
		
		<!-- 门店信息 -->
		<view class="store-info-section">
			<view class="info-item">
				<text class="info-icon">📍</text>
				<text class="info-text">地址：河南省新乡市马庄乡常兴集村</text>
			</view>
			<view class="info-item">
				<text class="info-icon">⏰</text>
				<text class="info-text">营业时间：07:30-21:00</text>
			</view>
			<view class="info-item">
				<text class="info-icon">📞</text>
				<text class="info-text">电话：13273721553</text>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';

// 响应式数据
const currentTime = ref('');
const hours = ref('00');
const minutes = ref('00');
const seconds = ref('00');
const searchKeyword = ref('');
const searchFocus = ref(false);
const statusBarHeight = ref(0);

// 获取导航栏高度（兼容小程序和H5）
const getNavBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync();
  const menuBtn = uni.getMenuButtonBoundingClientRect && uni.getMenuButtonBoundingClientRect();
  let navBarHeight = 0;

  if (menuBtn && systemInfo && systemInfo.statusBarHeight) {
    navBarHeight = (menuBtn.top - systemInfo.statusBarHeight) * 2 + menuBtn.height + systemInfo.statusBarHeight;
  } else if (systemInfo && systemInfo.statusBarHeight) {
    navBarHeight = systemInfo.statusBarHeight + 44;
  } else {
    navBarHeight = 44;
  }

  return Math.round(navBarHeight);
};

// 计算状态栏高度
const getStatusBarHeight = () => {
  statusBarHeight.value = getNavBarHeight();
};

// 轮播图数据
const swiperList = ref([
    { id: 1, image: '/static/alice.png', title: '爱宝贝儿孕婴生活馆' },
    { id: 2, image: '/static/alice.png', title: '新品上市' },
    { id: 3, image: '/static/alice.png', title: '会员专享优惠' }
]);

// 模拟数据
const seckillList = ref([
    { id: 1, image: '/static/alice.png', name: '爱他美白金版奶粉', currentPrice: '199', originalPrice: '299' },
    { id: 2, image: '/static/alice.png', name: '花王纸尿裤', currentPrice: '89', originalPrice: '129' },
    { id: 3, image: '/static/alice.png', name: '婴儿连体衣', currentPrice: '59', originalPrice: '99' },
    { id: 4, image: '/static/alice.png', name: '婴儿安抚玩具', currentPrice: '39', originalPrice: '69' }
]);

const categoryList = ref([
	{ id: 1, icon: '🥛', name: '奶粉' },
	{ id: 2, icon: '👶', name: '尿裤' },
	{ id: 3, icon: '👕', name: '童装' },
	{ id: 4, icon: '🧸', name: '玩具' },
	{ id: 5, icon: '🍼', name: '喂养' },
	{ id: 6, icon: '🛁', name: '洗护' },
	{ id: 7, icon: '💊', name: '营养' },
	{ id: 8, icon: '🚗', name: '出行' }
]);

const hotList = ref([
	{ id: 1, image: '/static/alice.png', name: '爱他美白金版奶粉', price: '199', sales: 1258 },
	{ id: 2, image: '/static/alice.png', name: '花王纸尿裤', price: '89', sales: 2341 },
	{ id: 3, image: '/static/alice.png', name: '婴儿连体衣', price: '59', sales: 892 },
	{ id: 4, image: '/static/alice.png', name: '婴儿安抚玩具', price: '39', sales: 1567 }
]);

const serviceList = ref([
	{ id: 1, icon: '🛁', name: '婴儿洗澡', url: '/pages/service/bath/bath' },
	{ id: 2, icon: '📖', name: '宝爸必看', url: '/pages/service/dad/dad' },
	{ id: 3, icon: '🎠', name: '儿童游乐场', url: '/pages/service/playground/playground' },
	{ id: 4, icon: '🎨', name: '早教课程', url: '/pages/service/early-education/early-education' },
	{ id: 5, icon: '✂️', name: '婴儿理发', url: '/pages/service/hair/hair' },
	{ id: 6, icon: '📸', name: '满月照', url: '/pages/service/photo/photo' }
]);

// 定时器
let timeInterval = null;
let countdownInterval = null;

// 方法
const updateCurrentTime = () => {
	const now = new Date();
	const hours = now.getHours().toString().padStart(2, '0');
	const minutes = now.getMinutes().toString().padStart(2, '0');
	currentTime.value = `${hours}:${minutes}`;
};

const updateCountdown = () => {
	// 模拟倒计时，假设距结束还有2小时30分钟
	const totalSeconds = 2 * 3600 + 30 * 60;
	let remainingSeconds = totalSeconds;
	
	const calculateTime = () => {
		remainingSeconds = (remainingSeconds - 1 + totalSeconds) % totalSeconds;
		
		hours.value = Math.floor(remainingSeconds / 3600).toString().padStart(2, '0');
		minutes.value = Math.floor((remainingSeconds % 3600) / 60).toString().padStart(2, '0');
		seconds.value = (remainingSeconds % 60).toString().padStart(2, '0');
	};
	
	calculateTime();
	countdownInterval = setInterval(calculateTime, 1000);
};

// 事件处理
const handleMessage = () => {
	console.log('查看消息');
	uni.navigateTo({
		url: '/pages/message/message'
	});
};

const handleMember = () => {
	console.log('会员中心');
	// TODO: 跳转到会员中心页
	// uni.navigateTo({
	//     url: '/pages/member/center'
	// });
};

const handleSearch = (keyword) => {
	console.log('搜索:', keyword);
};

// 搜索框确认事件
const handleSearchConfirm = () => {
	if (!searchKeyword.value.trim()) {
		uni.showToast({
			title: '请输入搜索内容',
			icon: 'none',
			duration: 2000
		});
		return;
	}
	console.log('执行搜索:', searchKeyword.value);
	// TODO: 调用后端搜索接口
	// 这里可以添加跳转到搜索结果页的逻辑
};

// 搜索框获得焦点
const handleSearchFocus = () => {
	searchFocus.value = true;
	console.log('搜索框获得焦点');
};

// 搜索框失去焦点
const handleSearchBlur = () => {
	searchFocus.value = false;
	console.log('搜索框失去焦点');
};

// 清空搜索内容
const handleSearchClear = () => {
	searchKeyword.value = '';
	console.log('清空搜索内容');
};

// 点击热门标签搜索
const handleSearchTag = (tag) => {
	searchKeyword.value = tag;
	console.log('点击热门标签:', tag);
	// TODO: 可以直接执行搜索或跳转到搜索结果页
};

// 轮播图点击事件
const handleSwiperItem = (item) => {
	console.log('点击轮播图:', item);
	// TODO: 跳转到活动详情页或商品列表页
	// uni.navigateTo({
	//     url: `/pages/activity/detail?id=${item.id}`
	// });
};

const handleMoreSeckill = () => {
	console.log('更多秒杀');
	// 跳转到商品页的秒杀分类
	uni.setStorageSync('selectedCategoryId', 'seckill');
	uni.switchTab({
		url: '/pages/products/index'
	});
};

const handleSeckillItem = (id) => {
	console.log('查看秒杀商品:', id);
	// 跳转到商品详情页
	uni.navigateTo({
		url: `/pages/product-detail/index?id=${id}&isSeckill=true`
	});
};

const handleCategory = (id) => {
	console.log('查看分类:', id);
	// 使用本地存储传递分类ID
	uni.setStorageSync('selectedCategoryId', id);
	// 跳转到现有的商品页面，保持tabBar可见
	uni.switchTab({
		url: '/pages/products/index'
	});
};

const handleMoreHot = () => {
	console.log('更多爆款');
	// 跳转到爆款推荐页面
	uni.navigateTo({
		url: '/pages/hot/index'
	});
};

const handleHotItem = (id) => {
	console.log('查看商品:', id);
	// 跳转到商品详情页
	uni.navigateTo({
	    url: `/pages/product-detail/index?id=${id}`
	});
};

const handleMoreService = () => {
	console.log('更多服务');
	// TODO: 跳转到服务列表页
	// uni.navigateTo({
	//     url: '/pages/service/list'
	// });
};

const handleService = (id) => {
	console.log('查看服务:', id);
	// 根据id找到对应的服务
	const service = serviceList.value.find(item => item.id === id);
	if (service && service.url) {
		// 跳转到对应的服务页面
		uni.navigateTo({
			url: service.url
		});
	} else {
		// 服务功能开发中
		uni.showToast({
			title: '服务功能开发中',
			icon: 'none'
		});
	}
};

// 生命周期
onMounted(() => {
	// 获取状态栏高度
	getStatusBarHeight();
	
	// 优先执行关键渲染任务
	updateCurrentTime();
	timeInterval = setInterval(updateCurrentTime, 60000);
	
	// 延迟执行非关键任务，给页面渲染留出时间
	setTimeout(() => {
		updateCountdown();
	}, 500);
});

onUnmounted(() => {
	if (timeInterval) clearInterval(timeInterval);
	if (countdownInterval) clearInterval(countdownInterval);
});
</script>

<style>
/* 全局样式 */
.home-container {
	width: 100%;
	min-height: 100vh;
	background-color: #f8f9fa;
	overflow: auto;
}

/* 顶部导航 */
.top-nav {
	min-height: 44px;
	width: 100%;
	background-color: #FFB6C1;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 0 15px;
	will-change: transform;
	transform: translateZ(0);
	backface-visibility: hidden;
	position: relative;
	z-index: 1000;
	box-sizing: border-box;
}

.store-name {
	color: white;
	font-size: 16px;
	font-weight: bold;
}

.top-right {
	display: flex;
	align-items: center;
	gap: 15px;
}

.icon-btn {
	position: relative;
	display: flex;
	align-items: center;
	gap: 4px;
}

.icon {
	font-size: 18px;
}

.badge {
	position: absolute;
	top: -5px;
	right: -5px;
	height: 16px;
	min-width: 16px;
	background-color: #ff4757;
	color: white;
	font-size: 10px;
	border-radius: 8px;
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 0 4px;
}

/* 搜索框 */
.search-section {
	padding: 10px 15px;
	background-color: white;
}

.search-box {
	height: 36px;
	background-color: #f5f5f5;
	border-radius: 18px;
	display: flex;
	align-items: center;
	padding: 0 15px;
	margin-bottom: 8px;
	position: relative;
}

.search-icon {
	font-size: 14px;
	margin-right: 6px;
	color: #999;
	flex-shrink: 0;
}

.search-input {
	flex: 1;
	font-size: 14px;
	color: #333;
	background: transparent;
	border: none;
	outline: none;
	height: 100%;
	line-height: 36px;
}

.search-placeholder {
	font-size: 14px;
	color: #999;
}

.search-clear {
	font-size: 16px;
	color: #999;
	margin-left: 8px;
	flex-shrink: 0;
	padding: 4px;
	cursor: pointer;
}

.search-clear:active {
	color: #666;
}

.hot-tags {
	display: flex;
	gap: 8px;
	flex-wrap: wrap;
}

.tag {
	font-size: 12px;
	color: #666;
	padding: 4px 10px;
	background-color: #f5f5f5;
	border-radius: 8px;
}

/* 轮播图 */
.swiper-section {
	width: 100%;
	height: 150px;
	background-color: #f0f0f0;
	margin-bottom: 10px;
	overflow: hidden;
}

.swiper {
	width: 100%;
	height: 100%;
}

.swiper-item {
	width: 100%;
	height: 100%;
	position: relative;
}

.swiper-image {
	width: 100%;
	height: 100%;
	display: block;
}

.swiper-title {
	position: absolute;
	bottom: 0;
	left: 0;
	right: 0;
	background: linear-gradient(transparent, rgba(0,0,0,0.6));
	color: white;
	padding: 20px 15px 10px;
	font-size: 14px;
	font-weight: 500;
}

/* 限时秒杀 */
.seckill-section {
	background-color: white;
	padding: 10px 15px;
	margin-bottom: 10px;
}

.section-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10px;
}

.section-title {
	font-size: 16px;
	font-weight: bold;
	color: #333;
}

.countdown {
	display: flex;
	align-items: center;
	gap: 6px;
}

.countdown-label {
	font-size: 12px;
	color: #666;
}

.countdown-time {
	display: flex;
	align-items: center;
	gap: 4px;
}

.countdown-item {
	height: 20px;
	width: 20px;
	background-color: #333;
	color: white;
	font-size: 12px;
	border-radius: 4px;
	display: flex;
	justify-content: center;
	align-items: center;
}

.countdown-separator {
	font-size: 12px;
	color: #333;
	font-weight: bold;
}

.more {
	font-size: 12px;
	color: #999;
}

.seckill-list {
	display: flex;
	gap: 10px;
	overflow-x: auto;
	padding-bottom: 5px;
}

.seckill-item {
	flex-shrink: 0;
	width: 90px;
}

.seckill-image {
	height: 90px;
	width: 100%;
	background-color: #f0f0f0;
	border-radius: 4px;
	margin-bottom: 6px;
}

.seckill-image image {
	width: 100%;
	height: 100%;
	border-radius: 4px;
}

.seckill-name {
	font-size: 12px;
	color: #333;
	margin-bottom: 4px;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	line-clamp: 2;
	-webkit-box-orient: vertical;
}

.seckill-price {
	display: flex;
	align-items: center;
	gap: 4px;
}

.current-price {
	font-size: 14px;
	color: #ff4757;
	font-weight: bold;
}

.original-price {
	font-size: 10px;
	color: #999;
	text-decoration: line-through;
}

/* 核心品类 */
.category-section {
	background-color: white;
	padding: 10px 0;
	margin-bottom: 10px;
}

.category-scroll {
	overflow-x: auto;
	padding: 0 15px;
	white-space: nowrap;
}

.category-item {
	display: inline-block;
	text-align: center;
	margin-right: 20px;
	width: 60px;
}

.category-item:last-child {
	margin-right: 0;
}

.category-icon {
	font-size: 24px;
	display: block;
	margin-bottom: 6px;
}

.category-name {
	font-size: 12px;
	color: #333;
	display: block;
}

/* 爆款商品 */
.hot-section {
	background-color: white;
	padding: 10px 15px;
	margin-bottom: 10px;
	display: block;
}

.hot-grid {
	display: grid;
	grid-template-columns: repeat(2, 1fr);
	gap: 10px;
}

.hot-item {
	display: flex;
	flex-direction: column;
	gap: 6px;
	background-color: #f8f9fa;
	border-radius: 8px;
	padding: 10px;
	transition: all 0.3s ease;
}

.hot-item:active {
	transform: scale(0.98);
}

.hot-image {
	height: 120px;
	width: 100%;
	background-color: #f0f0f0;
	border-radius: 6px;
	overflow: hidden;
	position: relative;
}

.hot-image image {
	width: 100%;
	height: 100%;
	border-radius: 6px;
	display: block;
}

.hot-tag {
	position: absolute;
	top: 6px;
	left: 6px;
	background-color: #FF69B4;
	color: white;
	font-size: 12px;
	font-weight: bold;	
	padding: 4px 8px;
	border-radius: 4px;
	z-index: 1;
}

.hot-name {
	font-size: 14px;
	color: #333;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	line-clamp: 2;
	-webkit-box-orient: vertical;
	line-height: 1.3;
}

.hot-bottom {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.hot-price {
	font-size: 16px;
	color: #FF69B4;
	font-weight: bold;
}

.hot-sales {
	font-size: 12px;
	color: #999;
}

/* 门店服务 */
.service-section {
	background-color: white;
	padding: 10px 15px;
	margin-bottom: 10px;
	display: block;
}

.service-grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 10px;
}

.service-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 6px;
}

.service-icon {
	font-size: 24px;
}

.service-name {
	font-size: 12px;
	color: #333;
}

/* 门店信息 */
.store-info-section {
	background-color: white;
	padding: 10px 15px;
	margin-bottom: 60px;
	display: block;
}

.info-item {
	display: flex;
	align-items: center;
	gap: 8px;
	margin-bottom: 8px;
}

.info-item:last-child {
	margin-bottom: 0;
}

.info-icon {
	font-size: 14px;
}

.info-text {
	font-size: 12px;
	color: #666;
	flex: 1;
}

/* 点击反馈 */
.icon-btn,
.tag,
.seckill-item,
.category-item,
.scene-item,
.hot-item,
.service-item,
.member-item,
.more {
	-webkit-tap-highlight-color: transparent;
	cursor: pointer;
}

.icon-btn:active,
.tag:active,
.seckill-item:active,
.category-item:active,
.scene-item:active,
.hot-item:active,
.service-item:active,
.member-item:active,
.more:active {
	opacity: 0.7;
}
</style>