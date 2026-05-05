<template>
  <view class="products-container">
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left"></view>
      <view class="nav-center">
        <text class="nav-title">商品总览</text>
      </view>
      <view class="nav-right"></view>
    </view>
    
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
    
    <scroll-view 
      class="category-scroll" 
      scroll-x 
      :show-scrollbar="false"
    >
      <view class="category-list">
        <view 
          class="category-item" 
          :class="{ active: currentCategory === 'all' }"
          @tap="handleCategoryChange('all')"
        >
          <text class="category-text">全部</text>
        </view>
        <view 
          class="category-item" 
          :class="{ active: currentCategory === 'seckill' }"
          @tap="handleCategoryChange('seckill')"
        >
          <text class="category-text">今日秒杀</text>
        </view>
        <view 
          v-for="category in uniqueCategories" 
          :key="category.id"
          class="category-item" 
          :class="{ active: currentCategory === category.id }"
          @tap="handleCategoryChange(category.id)"
        >
          <text class="category-text">{{ category.name }}</text>
        </view>
      </view>
    </scroll-view>
    
    <view class="divider"></view>
    
    <scroll-view 
      class="products-scroll"
      scroll-y 
      :refresher-enabled="true"
      :refresher-triggered="refreshing"
      @refresherrefresh="handleRefresh"
      @scrolltolower="handleLoadMore"
      :scroll-with-animation="true"
    >
      <view class="products-section">
        <view class="products-grid">
          <view 
            v-for="product in productList" 
            :key="product.id" 
            class="product-item"
            @tap="handleProductClick(product)"
          >
            <view class="product-image">
              <image :src="product.image" mode="aspectFill" />
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
        
        <view v-if="loading" class="loading-state">
          <text class="loading-text">加载中...</text>
        </view>
        
        <view v-if="!loading && !hasMore && productList.length > 0" class="no-more-state">
          <text class="no-more-text">— 已加载全部商品 —</text>
        </view>
        
        <view v-if="!loading && productList.length === 0" class="empty-state">
          <text class="empty-icon">📦</text>
          <text class="empty-text">暂无商品</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { onShow } from '@dcloudio/uni-app';
import { productApi } from '../../api/product';
import { homeApi } from '../../api/home';

const searchKeyword = ref('');
const currentCategory = ref('all');
const statusBarHeight = ref(0);
const refreshing = ref(false);
const loading = ref(false);
const hasMore = ref(true);
const currentPage = ref(1);
const pageSize = 20;

const categoryList = ref([]);
const productList = ref([]);

const uniqueCategories = computed(() => {
  const seen = new Set();
  return categoryList.value.filter(cat => {
    const id = String(cat.id);
    if (seen.has(id) || id === 'all' || id === 'seckill' || cat.name === '全部') {
      return false;
    }
    seen.add(id);
    return true;
  });
});

const getStatusBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync();
  return systemInfo.statusBarHeight || 0;
};

const loadCategories = async () => {
  try {
    const res = await homeApi.getHomeData();
    const categories = [];
    
    if (res && res.data && res.data.categories && Array.isArray(res.data.categories)) {
      res.data.categories.forEach(item => {
        const id = item.value || item.id;
        const name = item.name;
        if (id && name) {
          categories.push({ id: String(id), name });
        }
      });
    }
    
    categoryList.value = categories;
  } catch (e) {
    console.error('分类加载失败:', e);
    categoryList.value = [
      { id: 'milk', name: '奶粉' },
      { id: 'diaper', name: '尿裤' },
      { id: 'clothes', name: '童装' },
      { id: 'toys', name: '玩具' },
      { id: 'feeding', name: '喂养' },
      { id: 'care', name: '洗护' },
      { id: 'nutrition', name: '营养' },
      { id: 'travel', name: '出行' }
    ];
  }
};

const loadProducts = async (page = 1, append = false) => {
  if (loading.value) return;
  
  loading.value = true;
  
  try {
    const params = { page, pageSize };
    
    if (searchKeyword.value.trim()) {
      params.keyword = searchKeyword.value.trim();
    }
    
    const res = await productApi.getList(params);
    
    if (res && res.data) {
      const data = res.data.records || res.data.list || [];
      let newProducts = data.map(item => {
        const categoryValue = item.category || item.categoryId || item.category_id || '';
        return {
          id: item.id,
          category: String(categoryValue).toLowerCase(),
          image: item.image || item.mainImage || '/static/logo.png',
          name: item.name || '',
          spec: item.spec || item.specification || '',
          price: item.price,
          originalPrice: item.originalPrice,
          sales: item.sales || item.salesCount || 0,
          stock: item.stock || 0,
          isSeckill: item.isSeckill === true || item.isSeckill === 'true'
        };
      });
      
      if (currentCategory.value !== 'all') {
        if (currentCategory.value === 'seckill') {
          newProducts = newProducts.filter(p => p.isSeckill);
        } else {
          const targetCategory = String(currentCategory.value).toLowerCase();
          newProducts = newProducts.filter(p => p.category === targetCategory);
        }
      }
      
      if (append) {
        productList.value = [...productList.value, ...newProducts];
      } else {
        productList.value = newProducts;
      }
      
      hasMore.value = newProducts.length >= pageSize;
    } else {
      if (!append) {
        productList.value = [];
      }
      hasMore.value = false;
    }
  } catch (e) {
    console.error('商品列表加载失败:', e);
    if (!append) {
      productList.value = [];
    }
  } finally {
    loading.value = false;
    refreshing.value = false;
  }
};

const handleCategoryChange = (categoryId) => {
  currentCategory.value = categoryId;
  currentPage.value = 1;
  hasMore.value = true;
  loadProducts(1, false);
};

const handleSearch = () => {
  currentPage.value = 1;
  hasMore.value = true;
  loadProducts(1, false);
};

const handleSearchClear = () => {
  searchKeyword.value = '';
  currentPage.value = 1;
  hasMore.value = true;
  loadProducts(1, false);
};

const handleRefresh = () => {
  refreshing.value = true;
  currentPage.value = 1;
  hasMore.value = true;
  loadProducts(1, false);
};

const handleLoadMore = () => {
  if (hasMore.value && !loading.value && !refreshing.value) {
    currentPage.value++;
    loadProducts(currentPage.value, true);
  }
};

const handleProductClick = (product) => {
  uni.navigateTo({ url: `/pages/product-detail/index?id=${product.id}` });
};

onMounted(() => {
  statusBarHeight.value = getStatusBarHeight();
  loadCategories();
  loadProducts(1, false);
});

onShow(() => {
  const categoryId = uni.getStorageSync('selectedCategoryId');
  const searchKw = uni.getStorageSync('searchKeyword');
  
  if (searchKw) {
    searchKeyword.value = searchKw;
    uni.removeStorageSync('searchKeyword');
  }
  
  if (categoryId) {
    currentCategory.value = categoryId;
    uni.removeStorageSync('selectedCategoryId');
    currentPage.value = 1;
    hasMore.value = true;
    loadProducts(1, false);
  }
});
</script>

<style scoped>
.products-container {
  width: 100%;
  min-height: 100vh;
  background-color: #f8f9fa;
}

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

.nav-left, .nav-right {
  width: 40px;
}

.nav-title {
  font-size: 16px;
  font-weight: bold;
  color: white;
}

.search-section {
  background-color: white;
  padding: 10px 12px;
  border-bottom: 1px solid #f0f0f0;
}

.search-box {
  display: flex;
  align-items: center;
  height: 36px;
  background-color: #f5f5f5;
  border-radius: 18px;
  padding: 0 15px;
}

.search-icon {
  font-size: 14px;
  color: #999;
  margin-right: 8px;
}

.search-input {
  flex: 1;
  font-size: 14px;
  color: #333;
  background: transparent;
  border: none;
  outline: none;
}

.search-placeholder {
  color: #999;
}

.search-clear {
  font-size: 16px;
  color: #999;
  padding: 2px;
}

.category-scroll {
  white-space: nowrap;
  background-color: white;
  padding: 10px 0;
  border-bottom: 1px solid #f5f5f5;
}

.category-list {
  display: inline-flex;
  padding: 0 12px;
  gap: 8px;
}

.category-item {
  padding: 7px 16px;
  border-radius: 18px;
  background: linear-gradient(180deg, #fafafa 0%, #f5f5f5 100%);
  border: 1px solid #f0f0f0;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
}

.category-item:active {
  transform: scale(0.96);
}

.category-item.active {
  background: linear-gradient(135deg, #FFB6C1 0%, #FF69B4 100%);
  border: 1px solid #FF69B4;
  box-shadow: 0 4px 12px rgba(255, 105, 180, 0.25),
              0 2px 4px rgba(255, 182, 193, 0.15);
}

.category-text {
  font-size: 13px;
  color: #666;
  font-weight: 500;
  letter-spacing: 0.2px;
}

.category-item.active .category-text {
  color: white;
  font-weight: 600;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.08);
}

.divider {
  height: 8px;
  background-color: #f8f9fa;
}

.products-scroll {
  height: calc(100vh - 160px);
}

.products-section {
  padding: 12px;
  padding-bottom: 20px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.product-item {
  background-color: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.product-item:active {
  transform: scale(0.98);
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
}

.product-info {
  padding: 12px;
}

.product-name {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  line-height: 1.3;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-spec {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}

.product-price-row {
  display: flex;
  align-items: center;
  margin-top: 8px;
}

.product-price {
  font-size: 16px;
  font-weight: bold;
  color: #ff4757;
}

.original-price {
  font-size: 12px;
  color: #999;
  text-decoration: line-through;
  margin-left: 6px;
}

.product-stats {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: #999;
  margin-top: 6px;
}

.loading-state, .no-more-state {
  text-align: center;
  padding: 15px 0;
}

.loading-text, .no-more-text {
  font-size: 13px;
  color: #999;
}

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
