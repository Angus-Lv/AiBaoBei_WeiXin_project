// 获取状态栏+导航栏高度（兼容小程序和H5）
export const getNavBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync();
  let navBarHeight = 0;
  
  // 微信小程序需要考虑胶囊按钮位置
  if (systemInfo.platform === 'ios' || systemInfo.platform === 'android') {
    const menuButtonInfo = uni.getMenuButtonBoundingClientRect();
    if (menuButtonInfo) {
      navBarHeight = (menuButtonInfo.top - systemInfo.statusBarHeight) * 2 + 
                      menuButtonInfo.height + systemInfo.statusBarHeight;
    }
  }
  
  // H5或者其他平台，用默认高度
  if (!navBarHeight) {
    navBarHeight = systemInfo.statusBarHeight + 50;
  }
  
  return navBarHeight;
}

// 只获取状态栏高度
export const getStatusBarHeight = () => {
  const systemInfo = uni.getSystemInfoSync();
  return systemInfo.statusBarHeight || 0;
}