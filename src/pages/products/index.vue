<template>
  <view class="products-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left">
        <text class="nav-title">商品总览</text>
      </view>
      <view class="nav-center"></view>
      <view class="nav-right"></view>
    </view>
    
    <!-- 搜索栏 -->
    <view class="search-section">
      <view class="search-box">
        <text class="search-icon">🔍</text>
        <input 
          class="search-input" 
          v-model="searchKeyword" 
          placeholder="搜索商品" 
          placeholder-class="search-placeholder"
          @confirm="handleSearch"
        />
        <text v-if="searchKeyword" class="search-clear" @tap="handleSearchClear">✕</text>
      </view>
    </view>
    
    <!-- 品类选择 -->
    <view class="category-section">
      <view class="category-grid">
        <view 
          class="category-item" 
          :class="{ active: currentCategory === category.id }"
          v-for="category in categoryList" 
          :key="category.id" 
          @tap="handleCategoryChange(category.id)"
        >
          <text class="category-text">{{ category.name }}</text>
        </view>
      </view>
    </view>
    
    <!-- 二次筛选 -->
    <view class="filter-section" v-if="currentCategory !== 'all'">
      <view class="filter-title">{{ filterTitle }}</view>
      <scroll-view scroll-x="true" class="filter-scroll">
        <view 
          class="filter-item" 
          :class="{ active: currentFilter === filter.id }"
          v-for="filter in currentFilterList" 
          :key="filter.id" 
          @tap="handleFilterChange(filter.id)"
        >
          <text class="filter-text">{{ filter.name }}</text>
        </view>
      </scroll-view>
    </view>
    
    <!-- 商品列表 -->
    <view class="products-section">
      <view class="products-grid">
        <view 
          class="product-item" 
          v-for="product in filteredProducts" 
          :key="product.id" 
          @tap="handleProductClick(product)"
        >
          <view class="product-image">
            <image :src="product.image" mode="aspectFill"></image>
            <view v-if="product.isSeckill" class="seckill-tag">秒杀</view>
          </view>
          <view class="product-info">
            <text class="product-name">{{ product.name }}</text>
            <text class="product-spec">{{ product.spec }}</text>
            <view class="product-price-row">
              <text class="product-price">¥{{ product.price }}</text>
              <text v-if="product.originalPrice" class="original-price">¥{{ product.originalPrice }}</text>
            </view>
            <view class="product-stats">
              <text class="product-sales">销量 {{ product.sales }}</text>
              <text class="product-stock">库存 {{ product.stock }}</text>
            </view>
          </view>
        </view>
      </view>
      
      <!-- 空状态 -->
      <view class="empty-state" v-if="filteredProducts.length === 0">
        <text class="empty-icon">📦</text>
        <text class="empty-text">暂无商品</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { onShow } from '@dcloudio/uni-app';

// 响应式数据
const searchKeyword = ref('');
const currentCategory = ref('all');
const currentFilter = ref('all');
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

// 生命周期
onMounted(() => {
  statusBarHeight.value = getNavBarHeight();
  // 首次加载时处理
  handleCategoryFromStorage();
});

onShow(() => {
  // 每次页面显示时处理，包括switchTab跳转后
  handleCategoryFromStorage();
});

// 处理来自本地存储的分类
const handleCategoryFromStorage = () => {
  // 从本地存储获取分类ID
  const categoryId = uni.getStorageSync('selectedCategoryId');
  
  if (categoryId) {
    console.log('获取到分类ID:', categoryId, typeof categoryId);
    
    // 直接检查是否为秒杀分类
    if (categoryId === 'seckill') {
      currentCategory.value = 'seckill';
      currentFilter.value = 'all'; // 重置筛选条件
      console.log('切换到分类: 今日秒杀');
    } else {
      // 确保转换为数字
      const numCategoryId = parseInt(categoryId);
      console.log('转换后分类ID:', numCategoryId);
      
      // 映射主页分类ID到商品页面的分类ID
      const categoryMap = {
        1: 'milk',     // 奶粉
        2: 'diaper',   // 尿裤
        3: 'clothes',  // 童装
        4: 'toys',     // 玩具
        5: 'feeding',  // 喂养
        6: 'care',     // 洗护
        7: 'nutrition', // 营养
        8: 'travel'    // 出行
      };
      
      const mappedCategory = categoryMap[numCategoryId];
      console.log('映射后的分类:', mappedCategory);
      
      if (mappedCategory) {
        currentCategory.value = mappedCategory;
        currentFilter.value = 'all'; // 重置筛选条件
        console.log('切换到分类:', mappedCategory);
      }
    }
    
    // 清除本地存储，避免下次重复触发
    uni.removeStorageSync('selectedCategoryId');
  }
};

// 品类数据
const categoryList = ref([
  { id: 'all', name: '全部' },
  { id: 'seckill', name: '今日秒杀' },
  { id: 'milk', name: '奶粉' },
  { id: 'diaper', name: '尿裤' },
  { id: 'clothes', name: '童装' },
  { id: 'toys', name: '玩具' },
  { id: 'feeding', name: '喂养' },
  { id: 'care', name: '洗护' },
  { id: 'nutrition', name: '营养' },
  { id: 'travel', name: '出行' }
]);

// 筛选条件配置
const filterConfig = {
  milk: {
    title: '按段数筛选',
    options: [
      { id: 'all', name: '全部段数' },
      { id: '1', name: '一段(0-6个月)' },
      { id: '2', name: '二段(6-12个月)' },
      { id: '3', name: '三段(12-36个月)' },
      { id: '4', name: '四段(3岁以上)' }
    ]
  },
  diaper: {
    title: '按尺码筛选',
    options: [
      { id: 'all', name: '全部尺码' },
      { id: 'nb', name: 'NB(新生儿)' },
      { id: 's', name: 'S(小码)' },
      { id: 'm', name: 'M(中码)' },
      { id: 'l', name: 'L(大码)' },
      { id: 'xl', name: 'XL(加大码)' }
    ]
  },
  clothes: {
    title: '按年龄筛选',
    options: [
      { id: 'all', name: '全部年龄' },
      { id: '0-1', name: '0-1岁' },
      { id: '1-3', name: '1-3岁' },
      { id: '3-6', name: '3-6岁' },
      { id: '6+', name: '6岁以上' }
    ]
  },
  toys: {
    title: '按类型筛选',
    options: [
      { id: 'all', name: '全部类型' },
      { id: 'educational', name: '益智玩具' },
      { id: 'plush', name: '毛绒玩具' },
      { id: 'outdoor', name: '户外玩具' },
      { id: 'musical', name: '音乐玩具' }
    ]
  },
  feeding: {
    title: '按类型筛选',
    options: [
      { id: 'all', name: '全部类型' },
      { id: 'bottle', name: '奶瓶' },
      { id: 'nipple', name: '奶嘴' },
      { id: 'bowl', name: '餐具' },
      { id: 'other', name: '其他' }
    ]
  },
  care: {
    title: '按类型筛选',
    options: [
      { id: 'all', name: '全部类型' },
      { id: 'bath', name: '洗浴用品' },
      { id: 'skin', name: '护肤用品' },
      { id: 'diaper', name: '纸尿裤' },
      { id: 'other', name: '其他' }
    ]
  },
  nutrition: {
    title: '按类型筛选',
    options: [
      { id: 'all', name: '全部类型' },
      { id: 'vitamin', name: '维生素' },
      { id: 'calcium', name: '钙铁锌' },
      { id: 'probiotics', name: '益生菌' },
      { id: 'other', name: '其他' }
    ]
  },
  travel: {
    title: '按类型筛选',
    options: [
      { id: 'all', name: '全部类型' },
      { id: 'stroller', name: '推车' },
      { id: 'carrier', name: '背带' },
      { id: 'car', name: '安全座椅' },
      { id: 'other', name: '其他' }
    ]
  }
};

// 商品数据
const productList = ref([
	{ id: 1, category: 'milk', image: '/static/logo.png', name: '爱他美白金版奶粉', spec: '800g/罐', price: '199', originalPrice: '299', sales: 1258, stock: 200, filter: '1', isSeckill: true },
	{ id: 2, category: 'milk', image: '/static/logo.png', name: '美赞臣蓝臻奶粉', spec: '900g/罐', price: '259', sales: 986, stock: 150, filter: '2', isSeckill: false },
	{ id: 3, category: 'milk', image: '/static/logo.png', name: '惠氏启赋奶粉', spec: '800g/罐', price: '299', sales: 756, stock: 120, filter: '3', isSeckill: false },
	{ id: 4, category: 'diaper', image: '/static/logo.png', name: '花王纸尿裤', spec: 'M码 64片/包', price: '89', originalPrice: '129', sales: 2341, stock: 350, filter: 'm', isSeckill: true },
	{ id: 5, category: 'diaper', image: '/static/logo.png', name: '大王纸尿裤', spec: 'L码 54片/包', price: '79', sales: 1892, stock: 280, filter: 'l', isSeckill: false },
	{ id: 6, category: 'clothes', image: '/static/logo.png', name: '婴儿连体衣', spec: '1-3岁 粉色', price: '59', originalPrice: '99', sales: 892, stock: 150, filter: '1-3', isSeckill: true },
	{ id: 7, category: 'clothes', image: '/static/logo.png', name: '儿童T恤', spec: '3-6岁 蓝色', price: '45', sales: 654, stock: 200, filter: '3-6', isSeckill: false },
	{ id: 8, category: 'toys', image: '/static/logo.png', name: '婴儿安抚玩具', spec: '毛绒玩具', price: '39', originalPrice: '69', sales: 1567, stock: 300, filter: 'plush', isSeckill: true },
	{ id: 9, category: 'toys', image: '/static/logo.png', name: '积木玩具', spec: '益智玩具', price: '89', sales: 432, stock: 180, filter: 'educational', isSeckill: false },
	{ id: 10, category: 'feeding', image: '/static/logo.png', name: '贝亲奶瓶', spec: '160ml 宽口', price: '79', sales: 1123, stock: 250, filter: 'bottle', isSeckill: false },
	{ id: 11, category: 'feeding', image: '/static/logo.png', name: 'NUK奶嘴', spec: '0-6个月', price: '25', sales: 876, stock: 400, filter: 'nipple', isSeckill: false },
	{ id: 12, category: 'care', image: '/static/logo.png', name: '婴儿洗衣液', spec: '1L/瓶', price: '49', sales: 2345, stock: 320, filter: 'skin', isSeckill: false },
	{ id: 13, category: 'care', image: '/static/logo.png', name: '婴儿沐浴露', spec: '500ml/瓶', price: '35', sales: 1876, stock: 280, filter: 'bath', isSeckill: false }
]);

// 计算属性：当前筛选标题
const filterTitle = computed(() => {
  if (currentCategory.value === 'all') return '';
  return filterConfig[currentCategory.value]?.title || '';
});

// 计算属性：当前筛选选项
const currentFilterList = computed(() => {
  if (currentCategory.value === 'all') return [];
  return filterConfig[currentCategory.value]?.options || [];
});

// 计算属性：过滤后的商品列表
const filteredProducts = computed(() => {
  let products = productList.value;
  
  // 按品类筛选
  if (currentCategory.value !== 'all') {
    if (currentCategory.value === 'seckill') {
      // 筛选秒杀商品
      products = products.filter(p => p.isSeckill);
    } else {
      // 筛选普通分类商品
      products = products.filter(p => p.category === currentCategory.value);
    }
  }
  
  // 按二次条件筛选
  if (currentFilter.value !== 'all' && currentCategory.value !== 'all' && currentCategory.value !== 'seckill') {
    products = products.filter(p => p.filter === currentFilter.value);
  }
  
  // 按搜索关键词筛选
  if (searchKeyword.value.trim()) {
    const keyword = searchKeyword.value.trim().toLowerCase();
    products = products.filter(p => 
      p.name.toLowerCase().includes(keyword) || 
      p.spec.toLowerCase().includes(keyword)
    );
  }
  
  return products;
});

// 事件处理：品类切换
const handleCategoryChange = (categoryId) => {
  currentCategory.value = categoryId;
  currentFilter.value = 'all';
  console.log('切换品类:', categoryId);
};

// 事件处理：筛选条件切换
const handleFilterChange = (filterId) => {
  currentFilter.value = filterId;
  console.log('切换筛选:', filterId);
};

// 事件处理：搜索
const handleSearch = () => {
  if (!searchKeyword.value.trim()) {
    uni.showToast({
      title: '请输入搜索内容',
      icon: 'none',
      duration: 2000
    });
    return;
  }
  console.log('搜索商品:', searchKeyword.value);
};

// 事件处理：清空搜索
const handleSearchClear = () => {
  searchKeyword.value = '';
  console.log('清空搜索');
};

// 事件处理：点击商品
const handleProductClick = (product) => {
  console.log('查看商品:', product);
  // 跳转到商品详情页
  uni.navigateTo({
    url: `/pages/product-detail/index?id=${product.id}`
  });
};
</script>

<style>
.products-container {
  width: 100%;
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* 顶部导航栏 */
.nav-bar {
  min-height: 44px;
  background-color: #FFB6C1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 15px;
  position: sticky;
  top: 0;
  z-index: 100;
  box-sizing: border-box;
}

.nav-left {
  width: 40px;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: white;
  flex: 1;
  text-align: center;
}

.nav-center {
  flex: 1;
}

.nav-right {
  width: 40px;
}

/* 搜索栏 */
.search-section {
  background-color: white;
  padding: 8px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.search-box {
  display: flex;
  align-items: center;
  height: 32px;
  background-color: #f5f5f5;
  border-radius: 16px;
  padding: 0 12px;
  position: relative;
}

.search-icon {
  font-size: 12px;
  color: #999;
  margin-right: 6px;
}

.search-input {
  flex: 1;
  font-size: 13px;
  color: #333;
  background: transparent;
  border: none;
  outline: none;
  height: 100%;
}

.search-placeholder {
  color: #999;
}

.search-clear {
  font-size: 14px;
  color: #999;
  padding: 2px;
  margin-left: 6px;
}

/* 品类选择 */
.category-section {
  background-color: white;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
}

.category-item {
  padding: 6px 0;
  border-radius: 16px;
  background-color: #f5f5f5;
  text-align: center;
  transition: all 0.3s ease;
}

.category-item.active {
  background-color: #FFB6C1;
}

.category-text {
  font-size: 12px;
  color: #333;
}

.category-item.active .category-text {
  color: white;
  font-weight: 500;
}

/* 二次筛选 */
.filter-section {
  background-color: white;
  padding: 8px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.filter-title {
  font-size: 12px;
  font-weight: 500;
  color: #666;
  margin-bottom: 6px;
}

.filter-scroll {
  white-space: nowrap;
}

.filter-item {
  display: inline-block;
  padding: 4px 10px;
  margin-right: 6px;
  border: 1px solid #ddd;
  border-radius: 14px;
  background-color: white;
  transition: all 0.3s ease;
}

.filter-item.active {
  border-color: #FFB6C1;
  background-color: #FFF0F5;
}

.filter-text {
  font-size: 11px;
  color: #666;
}

.filter-item.active .filter-text {
  color: #FFB6C1;
  font-weight: 500;
}

/* 商品列表 */
.products-section {
  padding: 12px;
  padding-bottom: 60px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.product-item {
  background-color: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  transition: all 0.3s ease;
}

.product-item:active {
  transform: scale(0.98);
  box-shadow: 0 1px 4px rgba(0,0,0,0.1);
}

.product-image {
  width: 100%;
  height: 180px;
  background-color: #f5f5f5;
  position: relative;
}

.product-image image {
  width: 100%;
  height: 100%;
  display: block;
}

.seckill-tag {
  position: absolute;
  top: 8px;
  left: 8px;
  background-color: #FF69B4;
  color: white;
  font-size: 12px;
  font-weight: bold;
  padding: 4px 8px;
  border-radius: 4px;
  z-index: 1;
}

.product-info {
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.product-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  line-height: 1.3;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  display: box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  box-orient: vertical;
}

.product-spec {
  font-size: 12px;
  color: #999;
}

.product-price-row {
  display: flex;
  align-items: center;
}

.product-price {
  font-size: 16px;
  font-weight: bold;
  color: #ff4757;
  margin-right: 8px;
}

.original-price {
  font-size: 12px;
  color: #999;
  text-decoration: line-through;
  align-self: flex-end;
  margin-bottom: 2px;
}

.product-stats {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #999;
}

.product-sales,
.product-stock {
  flex: 1;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.empty-text {
  font-size: 14px;
  color: #999;
}
</style>