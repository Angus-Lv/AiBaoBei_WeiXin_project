<template>
  <view class="custom-tabbar">
    <view
      class="tabbar-item"
      v-for="item in tabbarItems"
      :key="item.path"
      :class="{ active: currentPath === item.path }"
      @click="switchTab(item)"
    >
      <view class="tabbar-icon">
        <image
          :src="currentPath === item.path ? item.selectedIcon : item.icon"
          mode="aspectFit"
          class="tabbar-image"
        ></image>
      </view>
      <text class="tabbar-text">{{ item.text }}</text>
      <view v-if="item.badge && item.badge > 0" class="tabbar-badge">
        {{ item.badge > 99 ? '99+' : item.badge }}
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { onShow, onHide } from '@dcloudio/uni-app';

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['change']);

const currentPath = ref('');
const tabbarItems = ref([]);

const defaultItems = [
  {
    path: '/pages/index/index',
    text: '首页',
    icon: '/static/tabbar/home.png',
    selectedIcon: '/static/tabbar/home-active.png',
    badge: 0
  },
  {
    path: '/pages/products/index',
    text: '商品',
    icon: '/static/tabbar/products.png',
    selectedIcon: '/static/tabbar/products-active.png',
    badge: 0
  },
  {
    path: '/pages/profile/index',
    text: '我的',
    icon: '/static/tabbar/profile.png',
    selectedIcon: '/static/tabbar/profile-active.png',
    badge: 0
  }
];

const initTabbarItems = () => {
  tabbarItems.value = props.items.length > 0 ? props.items : defaultItems;
};

const switchTab = (item) => {
  if (currentPath.value === item.path) {
    emit('change', { type: 'reselect', item });
    return;
  }

  emit('change', { type: 'switch', item });

  uni.switchTab({
    url: item.path,
    fail: () => {
      uni.navigateTo({
        url: item.path
      });
    }
  });
};

const updateCurrentPath = () => {
  const pages = getCurrentPages();
  if (pages.length > 0) {
    const currentPage = pages[pages.length - 1];
    const route = '/' + currentPage.route;

    const matchedItem = tabbarItems.value.find(item => item.path === route);
    if (matchedItem) {
      currentPath.value = route;
    }
  }
};

const setBadge = (path, count) => {
  const item = tabbarItems.value.find(t => t.path === path);
  if (item) {
    item.badge = count;
  }
};

const clearBadge = (path) => {
  setBadge(path, 0);
};

const clearAllBadges = () => {
  tabbarItems.value.forEach(item => {
    item.badge = 0;
  });
};

const getItem = (path) => {
  return tabbarItems.value.find(item => item.path === path);
};

const addItem = (item) => {
  if (!tabbarItems.value.find(t => t.path === item.path)) {
    tabbarItems.value.push(item);
  }
};

const removeItem = (path) => {
  const index = tabbarItems.value.findIndex(t => t.path === path);
  if (index > -1) {
    tabbarItems.value.splice(index, 1);
  }
};

const updateItem = (path, updates) => {
  const item = tabbarItems.value.find(t => t.path === path);
  if (item) {
    Object.assign(item, updates);
  }
};

defineExpose({
  setBadge,
  clearBadge,
  clearAllBadges,
  getItem,
  addItem,
  removeItem,
  updateItem
});

onMounted(() => {
  initTabbarItems();
  updateCurrentPath();
});

onShow(() => {
  updateCurrentPath();
});

onHide(() => {
  emit('change', { type: 'hide' });
});
</script>

<style>
.custom-tabbar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 100rpx;
  background-color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: space-around;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.08);
  padding-bottom: env(safe-area-inset-bottom);
  z-index: 9999;
}

.tabbar-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  cursor: pointer;
}

.tabbar-item:active {
  transform: scale(0.95);
  background-color: rgba(255, 105, 180, 0.05);
}

.tabbar-icon {
  width: 52rpx;
  height: 52rpx;
  margin-bottom: 4rpx;
  position: relative;
}

.tabbar-image {
  width: 100%;
  height: 100%;
  opacity: 0.5;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.tabbar-item.active .tabbar-image {
  opacity: 1;
  transform: scale(1.1);
}

.tabbar-text {
  font-size: 22rpx;
  color: #999999;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-weight: 400;
}

.tabbar-item.active .tabbar-text {
  color: #FF69B4;
  font-weight: 600;
  transform: translateY(-2rpx);
}

.tabbar-badge {
  position: absolute;
  top: 8rpx;
  right: 50%;
  transform: translateX(30rpx);
  min-width: 32rpx;
  height: 32rpx;
  background: linear-gradient(135deg, #FF69B4 0%, #FF1493 100%);
  border-radius: 16rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20rpx;
  color: #ffffff;
  font-weight: 600;
  padding: 0 8rpx;
  box-shadow: 0 2px 8px rgba(255, 105, 180, 0.4);
  animation: badge-pop 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes badge-pop {
  0% {
    transform: translateX(30rpx) scale(0);
  }
  50% {
    transform: translateX(30rpx) scale(1.2);
  }
  100% {
    transform: translateX(30rpx) scale(1);
  }
}
</style>
