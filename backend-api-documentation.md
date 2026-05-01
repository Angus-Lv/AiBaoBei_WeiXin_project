# 爱宝贝儿后端接口文档

## 1. 认证模块

### 1.1 用户登录
- **接口路径**: `/api/auth/login`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | username | string | 是 | 用户名 |
  | password | string | 是 | 密码 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "登录成功",
    "data": {
      "token": "JWT token",
      "user": {
        "id": 1,
        "username": "admin",
        "vipLevel": "VIP1",
        "points": 100,
        "balance": 0
      }
    }
  }
  ```

### 1.2 用户注册
- **接口路径**: `/api/auth/register`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | username | string | 是 | 用户名 |
  | password | string | 是 | 密码 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "注册成功",
    "data": {
      "userId": 1
    }
  }
  ```

## 2. 会员服务模块

### 2.1 会员充值
- **接口路径**: `/api/member/recharge`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | tierId | number | 是 | 充值档位ID |
  | amount | number | 是 | 充值金额 |
  | bonus | number | 是 | 赠送金额 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "充值成功",
    "data": {
      "transactionId": "TX123456",
      "totalAmount": 550,
      "balance": 550
    }
  }
  ```

### 2.2 获取会员信息
- **接口路径**: `/api/member/info`
- **请求方法**: GET
- **请求头**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | Authorization | string | 是 | Bearer token |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "vipLevel": "VIP1",
      "points": 100,
      "balance": 550
    }
  }
  ```

## 3. 商品模块

### 3.1 获取商品列表
- **接口路径**: `/api/products`
- **请求方法**: GET
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | category | string | 否 | 商品分类 |
  | filter | string | 否 | 筛选条件 |
  | keyword | string | 否 | 搜索关键词 |
  | page | number | 否 | 页码 |
  | pageSize | number | 否 | 每页数量 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "list": [
        {
          "id": 1,
          "category": "milk",
          "image": "/src/static/logo.png",
          "name": "爱他美白金版奶粉",
          "spec": "800g/罐",
          "price": "199",
          "originalPrice": "299",
          "sales": 1258,
          "stock": 200,
          "isSeckill": true
        }
      ],
      "total": 100,
      "page": 1,
      "pageSize": 20
    }
  }
  ```

### 3.2 获取商品详情
- **接口路径**: `/api/products/{id}`
- **请求方法**: GET
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | id | number | 是 | 商品ID |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "id": 1,
      "name": "爱他美白金版奶粉",
      "image": "/src/static/logo.png",
      "images": ["/src/static/logo.png", "/src/static/logo.png"],
      "detailImages": ["/src/static/logo.png", "/src/static/logo.png"],
      "price": "199",
      "originalPrice": "299",
      "spec": "800g/罐",
      "sales": 1258,
      "stock": 200,
      "isSeckill": true,
      "packages": [
        { "name": "单罐", "price": "199" },
        { "name": "两罐套装", "price": "380" }
      ]
    }
  }
  ```

### 3.3 加入购物车
- **接口路径**: `/api/cart/add`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | productId | number | 是 | 商品ID |
  | quantity | number | 是 | 数量 |
  | packageId | number | 否 | 套餐ID |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "加入购物车成功",
    "data": {
      "cartId": 1,
      "productId": 1,
      "quantity": 1
    }
  }
  ```

## 4. 订单模块

### 4.1 创建订单
- **接口路径**: `/api/orders`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | products | array | 是 | 商品列表 |
  | totalPrice | number | 是 | 总价 |
  | addressId | number | 是 | 地址ID |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "订单创建成功",
    "data": {
      "orderId": "20240129001",
      "status": "待付款",
      "totalPrice": 288,
      "createTime": "2024-01-29 12:00:00"
    }
  }
  ```

### 4.2 获取订单列表
- **接口路径**: `/api/orders`
- **请求方法**: GET
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | status | string | 否 | 订单状态 |
  | page | number | 否 | 页码 |
  | pageSize | number | 否 | 每页数量 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "list": [
        {
          "orderId": "20240129001",
          "status": "待付款",
          "totalPrice": "288",
          "totalQuantity": 2,
          "createTime": "2024-01-29 12:00:00",
          "products": [
            { "id": 1, "name": "爱他美白金版奶粉", "price": "199", "quantity": 1, "image": "/src/static/logo.png" }
          ]
        }
      ],
      "total": 10,
      "page": 1,
      "pageSize": 20
    }
  }
  ```

### 4.3 取消订单
- **接口路径**: `/api/orders/{orderId}/cancel`
- **请求方法**: PUT
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | orderId | string | 是 | 订单ID |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "订单已取消",
    "data": {
      "orderId": "20240129001",
      "status": "已取消"
    }
  }
  ```

### 4.4 支付订单
- **接口路径**: `/api/orders/{orderId}/pay`
- **请求方法**: PUT
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | orderId | string | 是 | 订单ID |
  | payMethod | string | 是 | 支付方式 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "支付成功",
    "data": {
      "orderId": "20240129001",
      "status": "已完成",
      "payTime": "2024-01-29 12:30:00"
    }
  }
  ```

## 5. 收藏模块

### 5.1 获取收藏列表
- **接口路径**: `/api/favorites`
- **请求方法**: GET
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | page | number | 否 | 页码 |
  | pageSize | number | 否 | 每页数量 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "list": [
        {
          "id": 1,
          "productId": 1,
          "image": "/src/static/logo.png",
          "name": "爱他美白金版奶粉",
          "price": "199",
          "sales": 1258,
          "createTime": "2024-01-29 10:00:00"
        }
      ],
      "total": 5,
      "page": 1,
      "pageSize": 20
    }
  }
  ```

### 5.2 添加收藏
- **接口路径**: `/api/favorites`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | productId | number | 是 | 商品ID |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "收藏成功",
    "data": {
      "favoriteId": 1,
      "productId": 1
    }
  }
  ```

### 5.3 取消收藏
- **接口路径**: `/api/favorites/{id}`
- **请求方法**: DELETE
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | id | number | 是 | 收藏ID |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "取消收藏成功"
  }
  ```

## 6. 个人中心模块

### 6.1 获取用户信息
- **接口路径**: `/api/user/info`
- **请求方法**: GET
- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "id": 1,
      "username": "admin",
      "vipLevel": "VIP1",
      "points": 100,
      "balance": 550,
      "avatar": "",
      "nickname": ""
    }
  }
  ```

### 6.2 更新用户信息
- **接口路径**: `/api/user/info`
- **请求方法**: PUT
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | nickname | string | 否 | 昵称 |
  | avatar | string | 否 | 头像 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "更新成功",
    "data": {
      "id": 1,
      "nickname": "新昵称",
      "avatar": "头像URL"
    }
  }
  ```

## 7. 服务预约模块

### 7.1 获取服务列表
- **接口路径**: `/api/services`
- **请求方法**: GET
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | type | string | 否 | 服务类型 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "list": [
        {
          "id": 1,
          "name": "婴儿游泳",
          "price": 58,
          "description": "专业婴儿游泳服务",
          "duration": 30
        }
      ]
    }
  }
  ```

### 7.2 提交服务预约
- **接口路径**: `/api/services/book`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | serviceId | number | 是 | 服务ID |
  | date | string | 是 | 预约日期 |
  | time | string | 是 | 预约时间 |
  | babyName | string | 是 | 宝宝姓名 |
  | babyAge | string | 是 | 宝宝年龄 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "预约成功",
    "data": {
      "bookingId": 1,
      "serviceId": 1,
      "date": "2024-02-01",
      "time": "10:00"
    }
  }
  ```

## 8. 通用接口

### 8.1 上传文件
- **接口路径**: `/api/upload`
- **请求方法**: POST
- **请求参数**:
  | 参数名 | 类型 | 必填 | 描述 |
  | --- | --- | --- | --- |
  | file | file | 是 | 文件 |

- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "上传成功",
    "data": {
      "url": "文件URL"
    }
  }
  ```

### 8.2 获取地址列表
- **接口路径**: `/api/addresses`
- **请求方法**: GET
- **响应数据**:
  ```json
  {
    "code": 200,
    "message": "获取成功",
    "data": {
      "list": [
        {
          "id": 1,
          "name": "张三",
          "phone": "13800138000",
          "address": "北京市朝阳区",
          "isDefault": true
        }
      ]
    }
  }
  ```

## 9. 错误码说明

| 错误码 | 描述 |
| --- | --- |
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 10. 注意事项

1. 所有需要认证的接口都需要在请求头中携带 `Authorization: Bearer token`
2. 接口返回格式统一为 JSON 格式
3. 分页接口默认返回 20 条数据
4. 时间格式统一为 `YYYY-MM-DD HH:mm:ss`
5. 金额单位为人民币元
