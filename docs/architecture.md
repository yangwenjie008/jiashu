# jiashu 家族家谱应用 - 架构设计文档

## 1. 项目概述

### 1.1 项目简介
jiashu是一个家族家谱电子化应用，旨在帮助家族成员记录、管理和传承家族历史与族谱信息。

### 1.2 核心价值
- 数字化保存家族历史
- 便于家族成员联系与互动
- 传承家族文化与传统
- 支持多代家族成员管理

## 2. 系统架构

### 2.1 整体架构
```
┌─────────────────────────────────────────────────────────┐
│                    客户端层                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Android App │  │  iOS App    │  │  Web App    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    API网关层                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  负载均衡   │  │  认证授权   │  │  限流熔断   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    服务层                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ 家谱服务    │  │ 成员服务    │  │ 关系服务    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ 媒体服务    │  │ 通知服务    │  │ 搜索服务    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    数据层                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ PostgreSQL  │  │   Redis     │  │   MinIO     │     │
│  │ (关系数据)  │  │  (缓存)     │  │ (对象存储)  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### 2.2 技术选型

| 层级 | 技术选择 | 说明 |
|------|----------|------|
| 移动端 | GoMobile | Go语言开发Android/iOS应用 |
| 后端 | Go + Gin | 高性能Web框架 |
| 数据库 | PostgreSQL | 关系型数据库，支持复杂查询 |
| 缓存 | Redis | 内存缓存，提升性能 |
| 对象存储 | MinIO | 存储图片、文档等文件 |
| 认证 | JWT | JSON Web Token认证 |
| API文档 | Swagger | API接口文档 |

## 3. 数据库设计

### 3.1 ER关系图
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   families   │     │   members    │     │  relations   │
│──────────────│     │──────────────│     │──────────────│
│ id (PK)      │◄────│ family_id    │     │ id (PK)      │
│ name         │     │ id (PK)      │────►│ member_id_1  │
│ description  │     │ name         │     │ member_id_2  │
│ created_at   │     │ gender       │     │ relation_type│
│ updated_at   │     │ birth_date   │     │ created_at   │
└──────────────┘     │ death_date   │     └──────────────┘
                     │ avatar       │
                     │ bio          │
                     │ created_at   │
                     │ updated_at   │
                     └──────────────┘
                            │
                            ▼
┌──────────────┐     ┌──────────────┐
│   media      │     │   users      │
│──────────────│     │──────────────│
│ id (PK)      │     │ id (PK)      │
│ member_id    │     │ username     │
│ file_url     │     │ email        │
│ file_type    │     │ password_hash│
│ description  │     │ avatar       │
│ created_at   │     │ created_at   │
└──────────────┘     └──────────────┘
```

### 3.2 数据表设计

#### 3.2.1 家谱表 (families)
```sql
CREATE TABLE families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    founder_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### 3.2.2 成员表 (members)
```sql
CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other')),
    birth_date DATE,
    death_date DATE,
    avatar VARCHAR(500),
    bio TEXT,
    generation INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### 3.2.3 关系表 (relations)
```sql
CREATE TABLE relations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id_1 UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    member_id_2 UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    relation_type VARCHAR(50) NOT NULL CHECK (relation_type IN (
        'parent-child', 'spouse', 'sibling', 'grandparent-grandchild'
    )),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(member_id_1, member_id_2, relation_type)
);
```

#### 3.2.4 媒体表 (media)
```sql
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID REFERENCES members(id) ON DELETE SET NULL,
    family_id UUID NOT NULL REFERENCES families(id) ON DELETE CASCADE,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL CHECK (file_type IN ('image', 'video', 'document')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### 3.2.5 用户表 (users)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## 4. API设计

### 4.1 API接口列表

#### 认证相关
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/auth/register | 用户注册 |
| POST | /api/v1/auth/login | 用户登录 |
| POST | /api/v1/auth/refresh | 刷新Token |
| GET | /api/v1/auth/profile | 获取用户信息 |

#### 家谱相关
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/families | 创建家谱 |
| GET | /api/v1/families | 获取家谱列表 |
| GET | /api/v1/families/:id | 获取家谱详情 |
| PUT | /api/v1/families/:id | 更新家谱信息 |
| DELETE | /api/v1/families/:id | 删除家谱 |

#### 成员相关
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/families/:familyId/members | 添加成员 |
| GET | /api/v1/families/:familyId/members | 获取成员列表 |
| GET | /api/v1/members/:id | 获取成员详情 |
| PUT | /api/v1/members/:id | 更新成员信息 |
| DELETE | /api/v1/members/:id | 删除成员 |

#### 关系相关
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/relations | 添加关系 |
| GET | /api/v1/families/:familyId/relations | 获取家谱关系 |
| DELETE | /api/v1/relations/:id | 删除关系 |

#### 媒体相关
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/media/upload | 上传媒体文件 |
| GET | /api/v1/families/:familyId/media | 获取家谱媒体 |
| DELETE | /api/v1/media/:id | 删除媒体文件 |

### 4.2 数据模型

#### 请求模型
```go
// 创建家谱请求
type CreateFamilyRequest struct {
    Name        string `json:"name" binding:"required"`
    Description string `json:"description"`
}

// 创建成员请求
type CreateMemberRequest struct {
    Name      string  `json:"name" binding:"required"`
    Gender    string  `json:"gender" binding:"required"`
    BirthDate *string `json:"birth_date"`
    DeathDate *string `json:"death_date"`
    Bio       string  `json:"bio"`
}

// 创建关系请求
type CreateRelationRequest struct {
    MemberID1     string `json:"member_id_1" binding:"required"`
    MemberID2     string `json:"member_id_2" binding:"required"`
    RelationType string `json:"relation_type" binding:"required"`
}
```

#### 响应模型
```go
// 通用响应
type Response struct {
    Code    int         `json:"code"`
    Message string      `json:"message"`
    Data    interface{} `json:"data"`
}

// 家谱响应
type FamilyResponse struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Description string    `json:"description"`
    MemberCount int       `json:"member_count"`
    CreatedAt   time.Time `json:"created_at"`
}

// 成员响应
type MemberResponse struct {
    ID         string    `json:"id"`
    Name       string    `json:"name"`
    Gender     string    `json:"gender"`
    BirthDate  *string   `json:"birth_date"`
    Avatar     string    `json:"avatar"`
    Generation int       `json:"generation"`
    CreatedAt  time.Time `json:"created_at"`
}
```

## 5. 核心功能设计

### 5.1 家谱树管理
- **树形结构展示**：支持多层级家谱树可视化
- **成员添加**：支持添加直系亲属和旁系亲属
- **关系维护**：支持父子、夫妻、兄弟等关系
- **世代计算**：自动计算成员所在世代

### 5.2 成员信息管理
- **基本信息**：姓名、性别、出生日期、死亡日期
- **扩展信息**：头像、简介、职业等
- **多媒体**：支持上传照片、视频、文档

### 5.3 家族互动
- **家族动态**：发布家族新闻、活动
- **成员联系**：家族成员联系方式管理
- **隐私控制**：不同信息的可见性设置

### 5.4 数据安全
- **数据加密**：敏感信息加密存储
- **访问控制**：基于角色的权限管理
- **数据备份**：定期自动备份

## 6. 移动端设计

### 6.1 页面结构
```
┌─────────────────────────────────┐
│           首页                  │
│  ┌─────────┐  ┌─────────┐      │
│  │ 家谱树  │  │ 成员列表│      │
│  └─────────┘  └─────────┘      │
│  ┌─────────┐  ┌─────────┐      │
│  │ 家族动态│  │ 我的    │      │
│  └─────────┘  └─────────┘      │
└─────────────────────────────────┘
```

### 6.2 主要页面
1. **登录/注册页**：用户认证
2. **家谱树页**：可视化展示家谱
3. **成员详情页**：查看和编辑成员信息
4. **添加成员页**：添加新成员
5. **关系管理页**：管理成员关系
6. **媒体库页**：查看和上传媒体文件
7. **设置页**：应用设置和个人信息

## 7. 开发计划

### 7.1 第一阶段：基础框架（2周）
- [x] 项目初始化
- [ ] 后端基础架构搭建
- [ ] 数据库设计和实现
- [ ] 基础API开发

### 7.2 第二阶段：核心功能（4周）
- [ ] 用户认证系统
- [ ] 家谱管理功能
- [ ] 成员管理功能
- [ ] 关系管理功能

### 7.3 第三阶段：移动端开发（4周）
- [ ] 移动端UI设计
- [ ] 家谱树可视化
- [ ] 成员信息展示
- [ ] 媒体上传功能

### 7.4 第四阶段：优化完善（2周）
- [ ] 性能优化
- [ ] 安全加固
- [ ] 测试和调试
- [ ] 文档完善

## 8. 部署架构

### 8.1 开发环境
- 本地开发环境
- Docker Compose本地部署

### 8.2 生产环境
- 云服务器部署（阿里云/腾讯云）
- 数据库托管服务
- 对象存储服务
- CDN加速

## 9. 附录

### 9.1 技术参考
- [Go Mobile文档](https://github.com/golang/mobile)
- [Gin框架文档](https://gin-gonic.com/docs/)
- [PostgreSQL文档](https://www.postgresql.org/docs/)
- [Redis文档](https://redis.io/docs/)

### 9.2 相关工具
- GoLand/VS Code：IDE
- DBeaver：数据库管理
- Postman：API测试
- Git：版本控制
