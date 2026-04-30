# 预约功能 API 文档

## 1. 服务类型列表

| 服务类型 | serviceType 值 | 页面路径 |
|---------|---------------|---------|
| 儿童游乐场 | playground | src/pages/service/playground/playground.vue |
| 满月照 | photo | src/pages/service/photo/photo.vue |
| 理发 | hair | src/pages/service/hair/hair.vue |

## 2. 通用请求格式

### 2.1 接口信息
- **请求方式**：POST
- **请求路径**：`/api/booking`
- **Content-Type**：`application/json`

### 2.2 通用请求参数
```json
{
  "serviceType": "string", // 服务类型
  "date": "string", // 预约日期，格式：YYYY-MM-DD
  "time": "string", // 预约时段，格式：HH:00-HH:00
  "babyName": "string", // 宝宝姓名
  "babyAge": "string", // 宝宝月龄
  "contactName": "string", // 联系人姓名
  "contactPhone": "string" // 联系人手机号码，11位数字
}
```

## 3. 各服务类型详细格式

### 3.1 儿童游乐场 (playground)

**请求示例**：
```json
{
  "serviceType": "playground",
  "date": "2026-04-26",
  "time": "10:00-11:00",
  "babyName": "小明",
  "babyAge": "36",
  "contactName": "张女士",
  "contactPhone": "13800138000"
}
```

**开放时间**：
- 周一至周五：10:00 - 19:00
- 周六至周日：09:00 - 20:00

**可预约时段**：
- 09:00-10:00
- 10:00-11:00
- 11:00-12:00
- 14:00-15:00
- 15:00-16:00
- 16:00-17:00
- 17:00-18:00
- 18:00-19:00

### 3.2 满月照 (photo)

**请求示例**：
```json
{
  "serviceType": "photo",
  "date": "2026-04-26",
  "time": "14:00-15:00",
  "babyName": "小红",
  "babyAge": "1",
  "contactName": "李女士",
  "contactPhone": "13900139000"
}
```

**开放时间**：
- 周一至周日：09:00 - 17:00

**可预约时段**：
- 09:00-10:00
- 10:00-11:00
- 11:00-12:00
- 14:00-15:00
- 15:00-16:00
- 16:00-17:00

### 3.3 理发 (hair)

**请求示例**：
```json
{
  "serviceType": "hair",
  "date": "2026-04-26",
  "time": "11:00-12:00",
  "babyName": "小华",
  "babyAge": "24",
  "contactName": "王先生",
  "contactPhone": "13700137000"
}
```

**开放时间**：
- 周一至周日：09:00 - 17:00

**可预约时段**：
- 09:00-10:00
- 10:00-11:00
- 11:00-12:00
- 14:00-15:00
- 15:00-16:00
- 16:00-17:00

## 4. 响应格式

### 4.1 成功响应
```json
{
  "code": 200,
  "message": "预约成功",
  "data": {
    "bookingId": "123456", // 预约ID
    "serviceType": "playground", // 服务类型
    "date": "2026-04-26", // 预约日期
    "time": "10:00-11:00", // 预约时段
    "status": "pending" // 预约状态：pending（待确认）、confirmed（已确认）、cancelled（已取消）
  }
}
```

### 4.2 失败响应
```json
{
  "code": 400,
  "message": "预约失败，该时段已被预约"
}
```

## 5. 数据验证规则

| 字段 | 类型 |  必填 | 验证规则 |
|------|------|------|----------|
| serviceType | string | 是 | 必须为 playground、photo 或 hair 之一 |
| date | string | 是 | 格式为 YYYY-MM-DD，且必须是未来日期 |
| time | string | 是 | 格式为 HH:00-HH:00，且必须在对应服务的开放时间内 |
| babyName | string | 是 | 非空字符串 |
| babyAge | string | 是 | 非空字符串 |
| contactName | string | 是 | 非空字符串 |
| contactPhone | string | 是 | 11位数字 |

## 6. 前端实现示例

```javascript
// 儿童游乐场预约提交示例
const submitBooking = () => {
  // 表单验证
  if (!selectedDate.value) {
    uni.showToast({ title: '请选择预约日期', icon: 'none' });
    return;
  }
  // 其他验证...
  
  // API调用
  uni.request({
    url: '/api/booking',
    method: 'POST',
    data: {
      serviceType: 'playground',
      date: selectedDate.value,
      time: selectedTime.value,
      babyName: babyName.value,
      babyAge: babyAge.value,
      contactName: contactName.value,
      contactPhone: contactPhone.value
    },
    success: (res) => {
      if (res.statusCode === 200 && res.data.code === 200) {
        showSuccess.value = true;
      } else {
        uni.showToast({ title: res.data.message || '预约失败', icon: 'none' });
      }
    },
    fail: () => {
      uni.showToast({ title: '网络错误，请稍后重试', icon: 'none' });
    }
  });
};
```