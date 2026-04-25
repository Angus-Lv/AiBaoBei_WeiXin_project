<template>
	<view class="message-container">
		<!-- 消息分类标签 -->
		<view class="message-tabs">
			<view 
				v-for="tab in messageTabs" 
				:key="tab.id"
				class="tab-item"
				:class="{ 'active': activeTab === tab.id }"
				@tap="switchTab(tab.id)"
			>
				<text class="tab-text">{{ tab.name }}</text>
				<view v-if="tab.badge" class="tab-badge">{{ tab.badge }}</view>
			</view>
		</view>
		
		<!-- 消息列表 -->
		<view class="message-list">
			<view 
				v-for="(message, index) in filteredMessages" 
				:key="message.id"
				class="message-item"
				:class="{ 'unread': !message.isRead }"
				@tap="handleMessageTap(message)"
			>
				<view class="message-icon">
					<text class="icon">{{ message.icon }}</text>
				</view>
				<view class="message-content">
					<view class="message-header">
						<text class="message-title">{{ message.title }}</text>
						<text class="message-time">{{ message.time }}</text>
					</view>
					<text class="message-body">{{ message.content }}</text>
				</view>
				<view class="message-actions">
					<view 
						class="action-btn"
						@tap.stop="markAsRead(message)"
					>
						<text class="action-icon">✓</text>
					</view>
					<view 
						class="action-btn"
						@tap.stop="deleteMessage(message.id)"
					>
						<text class="action-icon">×</text>
					</view>
				</view>
			</view>
			
			<!-- 空状态 -->
			<view v-if="filteredMessages.length === 0" class="empty-state">
				<text class="empty-icon">📭</text>
				<text class="empty-text">暂无消息</text>
			</view>
		</view>
	</view>
</template>

<script setup>
import { ref, computed } from 'vue';

// 消息分类标签
const messageTabs = ref([
	{ id: 'all', name: '全部', badge: 3 },
	{ id: 'order', name: '订单通知', badge: 1 },
	{ id: 'activity', name: '活动通知', badge: 2 }
]);

// 活跃标签
const activeTab = ref('all');

// 消息数据
const messages = ref([
	{
		id: 1,
		title: '订单未支付提醒',
		content: '您有一笔订单尚未支付，请尽快完成支付，以免影响订单处理。',
		time: '10:30',
		icon: '📋',
		type: 'order',
		isRead: false,
		url: '/pages/profile/index'
	},
	{
		id: 2,
		title: '新品上市',
		content: '爱他美白金版奶粉新品上市，限时8折优惠，快来看看吧！',
		time: '09:15',
		icon: '🎉',
		type: 'activity',
		isRead: false,
		url: '/pages/products/index'
	},
	{
		id: 3,
		title: '会员专享福利',
		content: '亲爱的会员，本月专享福利已更新，点击查看详情。',
		time: '昨天',
		icon: '👑',
		type: 'activity',
		isRead: false,
		url: '/pages/member/exchange/exchange'
	},
	{
		id: 4,
		title: '订单已发货',
		content: '您的订单已发货，预计3天内送达，请保持电话畅通。',
		time: '2026-01-28',
		icon: '📦',
		type: 'order',
		isRead: true,
		url: '/pages/profile/index'
	},
	{
		id: 5,
		title: '限时秒杀',
		content: '今日秒杀活动开始啦，爆款商品低至5折，错过再等一年！',
		time: '2026-01-27',
		icon: '⏰',
		type: 'activity',
		isRead: true,
		url: '/pages/index/index'
	}
]);

// 过滤消息
const filteredMessages = computed(() => {
	if (activeTab.value === 'all') {
		return messages.value;
	}
	return messages.value.filter(msg => msg.type === activeTab.value);
});

// 切换标签
const switchTab = (tabId) => {
	activeTab.value = tabId;
};

// 处理消息点击
const handleMessageTap = (message) => {
	// 标记为已读
	if (!message.isRead) {
		message.isRead = true;
		// 更新标签徽章
		updateTabBadges();
	}
	
	// 跳转到对应页面
	if (message.url) {
		uni.navigateTo({
			url: message.url
		});
	}
};

// 标记为已读
const markAsRead = (message) => {
	message.isRead = true;
	// 更新标签徽章
	updateTabBadges();
	
	uni.showToast({
		title: '已标记为已读',
		icon: 'success',
		duration: 1500
	});
};

// 删除消息
const deleteMessage = (messageId) => {
	uni.showModal({
		title: '确认删除',
		content: '确定要删除这条消息吗？',
		confirmText: '删除',
		cancelText: '取消',
		success: (res) => {
			if (res.confirm) {
				// 从消息列表中删除
				const index = messages.value.findIndex(msg => msg.id === messageId);
				if (index !== -1) {
					messages.value.splice(index, 1);
					// 更新标签徽章
					updateTabBadges();
					
					uni.showToast({
						title: '消息已删除',
						icon: 'success',
						duration: 1500
					});
				}
			}
		}
	});
};

// 更新标签徽章
const updateTabBadges = () => {
	// 计算未读消息数量
	const unreadCount = messages.value.filter(msg => !msg.isRead).length;
	const unreadOrderCount = messages.value.filter(msg => !msg.isRead && msg.type === 'order').length;
	const unreadActivityCount = messages.value.filter(msg => !msg.isRead && msg.type === 'activity').length;
	
	// 更新标签徽章
	messageTabs.value[0].badge = unreadCount > 0 ? unreadCount : 0;
	messageTabs.value[1].badge = unreadOrderCount > 0 ? unreadOrderCount : 0;
	messageTabs.value[2].badge = unreadActivityCount > 0 ? unreadActivityCount : 0;
};
</script>

<style scoped>
/* 页面容器 */
.message-container {
	width: 100%;
	min-height: 100vh;
	background-color: #f8f9fa;
}

/* 消息分类标签 */
.message-tabs {
	display: flex;
	background-color: white;
	border-bottom: 1px solid #f0f0f0;
	position: sticky;
	top: 0;
	z-index: 10;
}

.tab-item {
	flex: 1;
	height: 44px;
	display: flex;
	align-items: center;
	justify-content: center;
	position: relative;
	transition: all 0.3s ease;
}

.tab-item.active {
	color: #FF69B4;
}

.tab-text {
	font-size: 15px;
	color: #666;
}

.tab-item.active .tab-text {
	font-weight: bold;
	color: #FF69B4;
}

.tab-badge {
	position: absolute;
	top: 8px;
	right: 30%;
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

/* 消息列表 */
.message-list {
	padding: 10px 0;
}

.message-item {
	display: flex;
	align-items: flex-start;
	padding: 15px;
	background-color: white;
	margin-bottom: 1px;
	transition: all 0.3s ease;
}

.message-item.unread {
	background-color: #FFE4E1;
}

.message-icon {
	width: 40px;
	height: 40px;
	background-color: #FFB6C1;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-right: 12px;
	flex-shrink: 0;
}

.icon {
	font-size: 20px;
}

.message-content {
	flex: 1;
	min-width: 0;
}

.message-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 6px;
}

.message-title {
	font-size: 15px;
	font-weight: bold;
	color: #333;
	flex: 1;
	margin-right: 12px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.message-time {
	font-size: 12px;
	color: #999;
	flex-shrink: 0;
}

.message-body {
	font-size: 14px;
	color: #666;
	line-height: 1.4;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	line-clamp: 2;
	-webkit-box-orient: vertical;
}

.message-actions {
	display: flex;
	flex-direction: column;
	gap: 8px;
	margin-left: 12px;
	opacity: 0;
	transition: opacity 0.3s ease;
}

.message-item:active .message-actions {
	opacity: 1;
}

.action-btn {
	width: 28px;
	height: 28px;
	background-color: #f0f0f0;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
}

.action-btn:active {
	background-color: #e0e0e0;
}

.action-icon {
	font-size: 14px;
	color: #666;
}

/* 空状态 */
.empty-state {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 60px 0;
	color: #999;
}

.empty-icon {
	font-size: 48px;
	margin-bottom: 16px;
}

.empty-text {
	font-size: 14px;
}

/* 适配 rpx */
@media screen and (max-width: 750rpx) {
	.message-container {
		width: 100%;
	}
	
	.message-tabs {
		height: 88rpx;
	}
	
	.tab-item {
		height: 88rpx;
	}
	
	.tab-text {
		font-size: 30rpx;
	}
	
	.tab-badge {
		top: 16rpx;
		right: 30%;
		height: 32rpx;
		min-width: 32rpx;
		font-size: 20rpx;
		border-radius: 16rpx;
		padding: 0 8rpx;
	}
	
	.message-list {
		padding: 20rpx 0;
	}
	
	.message-item {
		padding: 30rpx;
		margin-bottom: 2rpx;
	}
	
	.message-icon {
		width: 80rpx;
		height: 80rpx;
		margin-right: 24rpx;
	}
	
	.icon {
		font-size: 40rpx;
	}
	
	.message-header {
		margin-bottom: 12rpx;
	}
	
	.message-title {
		font-size: 30rpx;
		margin-right: 24rpx;
	}
	
	.message-time {
		font-size: 24rpx;
	}
	
	.message-body {
		font-size: 28rpx;
	}
	
	.message-actions {
		gap: 16rpx;
		margin-left: 24rpx;
	}
	
	.action-btn {
		width: 56rpx;
		height: 56rpx;
	}
	
	.action-icon {
		font-size: 28rpx;
	}
	
	.empty-state {
		padding: 120rpx 0;
	}
	
	.empty-icon {
		font-size: 96rpx;
		margin-bottom: 32rpx;
	}
	
	.empty-text {
		font-size: 28rpx;
	}
}
</style>