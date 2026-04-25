<template>
  <view class="orders-container">
    <!-- 顶部导航栏 -->
    <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
      <view class="nav-left" @tap="handleBack">
        <text class="back-icon">←</text>
      </view>
      <text class="nav-title">我的订单</text>
      <view class="nav-right"></view>
    </view>
    
    <!-- 订单状态分类 -->
    <view class="order-tabs">
      <view 
        class="order-tab" 
        v-for="tab in orderTabs" 
        :key="tab.id"
        :class="{ active: selectedTab === tab.id }"
        @tap="handleTabChange(tab.id)"
      >
        <text class="tab-icon">{{ tab.icon }}</text>
        <text class="tab-text">{{ tab.name }}</text>
      </view>
    </view>
    
    <!-- 订单列表 -->
    <view class="order-list">
      <!-- 全部订单 -->
      <view v-if="selectedTab === 'all'">
        <view class="order-item" v-for="(order, index) in allOrders" :key="index">
          <view class="order-header">
            <text class="order-id">订单号: {{ order.orderId }}</text>
            <text class="order-status" :class="order.statusClass">{{ order.status }}</text>
          </view>
          <view class="order-products">
            <view class="product-item" v-for="(product, pIndex) in order.products" :key="pIndex">
              <view class="product-image">
                <image :src="product.image" mode="aspectFill"></image>
              </view>
              <view class="product-info">
                <text class="product-name">{{ product.name }}</text>
                <view class="product-price">¥{{ product.price }}</view>
              </view>
              <view class="product-quantity">x{{ product.quantity }}</view>
            </view>
          </view>
          <view class="order-footer">
            <text class="order-total">共{{ order.totalQuantity }}件商品 合计: ¥{{ order.totalPrice }}</text>
            <view class="order-actions">
              <view class="action-btn secondary" v-if="order.status === '待付款'" @tap="handleCancelOrder(order.orderId)">
                取消订单
              </view>
              <view class="action-btn primary" v-if="order.status === '待付款'" @tap="handlePayOrder(order.orderId)">
                立即付款
              </view>
              <view class="action-btn secondary" v-if="order.status === '已完成'" @tap="handleRebuy(order)">
                再次购买
              </view>
            </view>
          </view>
        </view>
      </view>
      
      <!-- 待付款 -->
      <view v-else-if="selectedTab === 'pending'">
        <view class="order-item" v-for="(order, index) in pendingOrders" :key="index">
          <!-- 订单内容与上面类似 -->
          <view class="order-header">
            <text class="order-id">订单号: {{ order.orderId }}</text>
            <text class="order-status pending">{{ order.status }}</text>
          </view>
          <view class="order-products">
            <view class="product-item" v-for="(product, pIndex) in order.products" :key="pIndex">
              <view class="product-image">
                <image :src="product.image" mode="aspectFill"></image>
              </view>
              <view class="product-info">
                <text class="product-name">{{ product.name }}</text>
                <view class="product-price">¥{{ product.price }}</view>
              </view>
              <view class="product-quantity">x{{ product.quantity }}</view>
            </view>
          </view>
          <view class="order-footer">
            <text class="order-total">共{{ order.totalQuantity }}件商品 合计: ¥{{ order.totalPrice }}</text>
            <view class="order-actions">
              <view class="action-btn secondary" @tap="handleCancelOrder(order.orderId)">
                取消订单
              </view>
              <view class="action-btn primary" @tap="handlePayOrder(order.orderId)">
                立即付款
              </view>
            </view>
          </view>
        </view>
      </view>
      
      <!-- 已完成 -->
      <view v-else-if="selectedTab === 'completed'">
        <view class="order-item" v-for="(order, index) in completedOrders" :key="index">
          <!-- 订单内容与上面类似 -->
          <view class="order-header">
            <text class="order-id">订单号: {{ order.orderId }}</text>
            <text class="order-status completed">{{ order.status }}</text>
          </view>
          <view class="order-products">
            <view class="product-item" v-for="(product, pIndex) in order.products" :key="pIndex">
              <view class="product-image">
                <image :src="product.image" mode="aspectFill"></image>
              </view>
              <view class="product-info">
                <text class="product-name">{{ product.name }}</text>
                <view class="product-price">¥{{ product.price }}</view>
              </view>
              <view class="product-quantity">x{{ product.quantity }}</view>
            </view>
          </view>
          <view class="order-footer">
            <text class="order-total">共{{ order.totalQuantity }}件商品 合计: ¥{{ order.totalPrice }}</text>
            <view class="order-actions">
              <view class="action-btn secondary" @tap="handleRebuy(order)">
                再次购买
              </view>
            </view>
          </view>
        </view>
      </view>
      
      <!-- 空状态 -->
      <view class="empty-state" v-if="getCurrentOrders.length === 0">
        <text class="empty-icon">📋</text>
        <text class="empty-text">暂无{{ getCurrentTabName }}订单</text>
        <text class="empty-subtext">快去挑选心仪的商品吧</text>
        <view class="empty-btn" @tap="handleGoShopping">
          <text class="empty-btn-text">去逛逛</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';

// 响应式数据
const selectedTab = ref('all');

// 状态栏高度
const statusBarHeight = ref(0);

// 计算状态栏高度
const getStatusBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync();
  statusBarHeight.value = (systemInfo.statusBarHeight || 0) + 50; // 增加50px的padding，约5cm
};

// 生命周期
onMounted(() => {
  getStatusBarHeight();
});

// 订单状态分类
const orderTabs = ref([
  { id: 'all', name: '全部', icon: '📦' },
  { id: 'pending', name: '待付款', icon: '💳' },
  { id: 'completed', name: '已完成', icon: '✅' }
]);

// 模拟订单数据
const allOrders = ref([
  {
    orderId: '20240129001',
    status: '待付款',
    statusClass: 'pending',
    totalPrice: '288',
    totalQuantity: 2,
    products: [
      { id: 1, name: '爱他美白金版奶粉', price: '199', quantity: 1, image: '/static/alice.png' },
      { id: 2, name: '花王纸尿裤', price: '89', quantity: 1, image: '/static/alice.png' }
    ]
  },
  {
    orderId: '20240129003',
    status: '已完成',
    statusClass: 'completed',
    totalPrice: '59',
    totalQuantity: 1,
    products: [
      { id: 3, name: '婴儿连体衣', price: '59', quantity: 1, image: '/static/alice.png' }
    ]
  }
]);

// 计算属性：按状态分类订单
const pendingOrders = computed(() => {
  return allOrders.value.filter(order => order.status === '待付款');
});

const completedOrders = computed(() => {
  return allOrders.value.filter(order => order.status === '已完成');
});

// 当前选中的订单列表
const getCurrentOrders = computed(() => {
  switch (selectedTab.value) {
    case 'pending': return pendingOrders.value;
    case 'completed': return completedOrders.value;
    default: return allOrders.value;
  }
});

// 当前选中的标签名称
const getCurrentTabName = computed(() => {
  const tab = orderTabs.value.find(t => t.id === selectedTab.value);
  return tab ? tab.name : '';
});

// 事件处理
const handleBack = () => {
  uni.navigateBack();
};

const handleTabChange = (tabId) => {
  selectedTab.value = tabId;
};

const handleCancelOrder = (orderId) => {
  console.log('取消订单:', orderId);
  uni.showModal({
    title: '取消订单',
    content: '确定要取消这个订单吗？',
    success: (res) => {
      if (res.confirm) {
        // 实际项目中这里会调用取消订单的API
        uni.showToast({
          title: '订单已取消',
          icon: 'success',
          duration: 2000
        });
      }
    }
  });
};

const handlePayOrder = (orderId) => {
  console.log('支付订单:', orderId);
  // 实际项目中这里会跳转到支付页面
  uni.showToast({
    title: '跳转到支付页面',
    icon: 'none',
    duration: 2000
  });
};

const handleRebuy = (order) => {
  console.log('再次购买:', order);
  // 实际项目中这里会将商品添加到购物车
  uni.showToast({
    title: '商品已加入购物车',
    icon: 'success',
    duration: 2000
  });
};

const handleGoShopping = () => {
  console.log('去逛逛');
  uni.switchTab({
    url: '/pages/products/index'
  });
};
</script>

<style>
.orders-container {
  width: 100%;
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* 顶部导航栏 */
.nav-bar {
  height: 94px;
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

/* 订单状态分类 */
.order-tabs {
  display: flex;
  background-color: white;
  padding: 10px 0;
  margin-top: 94px;
  position: sticky;
  top: 94px;
  z-index: 99;
  border-bottom: 1px solid #f0f0f0;
}

.order-tab {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 10px 0;
  position: relative;
}

.order-tab.active {
  color: #FF69B4;
}

.order-tab.active::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 25%;
  width: 50%;
  height: 3px;
  background-color: #FF69B4;
  border-radius: 3px;
}

.tab-icon {
  font-size: 20px;
}

.tab-text {
  font-size: 12px;
}

/* 订单列表 */
.order-list {
  padding: 10px;
}

.order-item {
  background-color: white;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 10px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #f0f0f0;
}

.order-id {
  font-size: 12px;
  color: #666;
}

.order-status {
  font-size: 14px;
  font-weight: bold;
}

.order-status.pending {
  color: #FF9500;
}

.order-status.completed {
  color: #4CD964;
}

/* 订单商品 */
.order-products {
  margin-bottom: 10px;
}

.product-item {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.product-item:last-child {
  margin-bottom: 0;
}

.product-image {
  width: 60px;
  height: 60px;
  background-color: #f0f0f0;
  border-radius: 4px;
  overflow: hidden;
  margin-right: 10px;
  flex-shrink: 0;
}

.product-image image {
  width: 100%;
  height: 100%;
  display: block;
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 60px;
}

.product-name {
  font-size: 14px;
  color: #333;
  line-height: 1.3;
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
}

.product-price {
  font-size: 14px;
  color: #333;
}

.product-quantity {
  font-size: 12px;
  color: #999;
  margin-left: 10px;
}

/* 订单底部 */
.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 10px;
  border-top: 1px solid #f0f0f0;
}

.order-total {
  font-size: 12px;
  color: #666;
}

.order-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 12px;
  text-align: center;
}

.action-btn.primary {
  background-color: #FF69B4;
  color: white;
}

.action-btn.secondary {
  background-color: #f5f5f5;
  color: #666;
  border: 1px solid #ddd;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.empty-text {
  font-size: 16px;
  color: #333;
  margin-bottom: 8px;
}

.empty-subtext {
  font-size: 14px;
  color: #999;
  margin-bottom: 24px;
}

.empty-btn {
  padding: 10px 24px;
  background-color: #FFB6C1;
  border-radius: 20px;
}

.empty-btn-text {
  font-size: 14px;
  font-weight: bold;
  color: white;
}
</style>