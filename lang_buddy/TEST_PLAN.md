# LangBuddy 测试计划文档

## 1. 测试概览

| 类别 | 测试文件数 | 测试用例数 | 覆盖模块 |
|------|-----------|-----------|---------|
| 单元测试 - Domain | 3 | 35+ | Entities, Enums, copyWith |
| 单元测试 - Data | 3 | 30+ | AI Clients, Repositories, Factory |
| 单元测试 - Config | 2 | 15+ | Default Agents, System Prompts |
| 单元测试 - Core | 1 | 10+ | DateFormatter |
| Widget 测试 | 4 | 20+ | ChatBubble, CorrectionBubble, ChatInputBar, Avatar |
| 集成测试 | 1 | 5+ | 完整聊天流程 |
| **合计** | **14** | **115+** | **全层覆盖** |

## 2. 测试策略

### 2.1 单元测试
- **Entity 层**: 验证所有数据模型的构造、copyWith、enum 映射
- **AI Client 层**: Mock HTTP 请求，验证请求构造和响应解析
- **Repository 层**: Mock DAO，验证数据转换和业务逻辑
- **Config 层**: 验证预设 Agent 完整性和 System Prompt 构建
- **工具层**: 验证日期格式化的各种场景

### 2.2 Widget 测试
- **ChatBubble**: 用户/Agent 气泡样式区分
- **CorrectionBubble**: 展开/折叠、纠错详情显示
- **ChatInputBar**: 文本输入、发送按钮状态切换
- **AvatarWidget**: 颜色生成、首字母显示

### 2.3 集成测试
- 完整聊天流程: 发送消息 → AI 响应 → 纠错解析 → 消息存储

## 3. 测试矩阵

### 3.1 Domain Entities 测试矩阵

| 测试场景 | Agent | Message | Conversation | Correction | AIModelConfig |
|---------|-------|---------|--------------|------------|---------------|
| 构造函数必填字段 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 构造函数默认值 | ✅ | ✅ | ✅ | - | ✅ |
| copyWith 全字段 | ✅ | ✅ | ✅ | - | ✅ |
| copyWith 部分字段 | ✅ | ✅ | ✅ | - | ✅ |
| Enum label/instruction | ✅ | - | - | - | ✅ |

### 3.2 AI Client 测试矩阵

| 测试场景 | ClaudeClient | OpenAIClient | Factory |
|---------|-------------|-------------|---------|
| sendMessage 正常 | ✅ | ✅ | - |
| sendMessage 错误 | ✅ | ✅ | - |
| streamMessage 正常 | ✅ | ✅ | - |
| 请求头正确性 | ✅ | ✅ | - |
| 纠错 JSON 解析 | ✅ | ✅ | - |
| 工厂创建正确类型 | - | - | ✅ |

### 3.3 Widget 测试矩阵

| 测试场景 | ChatBubble | CorrectionBubble | ChatInputBar | Avatar |
|---------|-----------|-----------------|-------------|--------|
| 正常渲染 | ✅ | ✅ | ✅ | ✅ |
| 用户样式 | ✅ | - | - | - |
| Agent 样式 | ✅ | - | - | - |
| 交互操作 | - | ✅展开 | ✅发送 | - |
| 状态切换 | - | ✅折叠 | ✅按钮 | - |

## 4. 测试执行流程

```
1. flutter test test/unit/          → 运行所有单元测试
2. flutter test test/widget/        → 运行所有 Widget 测试
3. flutter test test/integration/   → 运行集成测试
4. flutter test                     → 运行全部测试
5. flutter test --coverage          → 生成覆盖率报告
```

## 5. 通过标准

- 所有测试用例 100% 通过
- 无运行时异常
- 关键路径（聊天流程）覆盖完整
- Entity 层 copyWith 行为正确
- AI Client 请求/响应格式正确
- Widget 渲染和交互符合预期
