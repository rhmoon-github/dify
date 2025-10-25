# Dify外部知识库工作流项目

## 项目概述

本项目提供了一套完整的Dify外部知识库工作流解决方案，专注于DSL设计，包含多种工作流配置和自动化导入工具，帮助用户快速集成外部知识库到Dify平台。

## 项目结构

```
knowledge/
├── 工作流配置文件（DSL设计核心）
│   ├── external_knowledge_workflow.yaml    # 基础外部知识库工作流
│   ├── simple_workflow.yaml               # 简化版工作流配置
│   ├── advanced_workflow.yaml             # 高级工作流配置（多知识库、智能分析）
│   ├── conditional_workflow.yaml          # 条件分支工作流配置
│   └── demo_workflow.yaml                 # 演示工作流配置
│
├── 导入工具
│   └── import_workflow.py                 # 完整版导入脚本
│
└── 文档
    ├── README.md                          # 详细使用说明
    └── PROJECT_SUMMARY.md                 # 项目总结
```

## 工作流文件说明

### 1. 基础工作流
- **文件**: `external_knowledge_workflow.yaml`
- **功能**: 基础的外部知识库检索工作流
- **节点**: 开始 → 知识检索 → LLM → 结束
- **适用**: 简单应用场景

### 2. 简化工作流
- **文件**: `simple_workflow.yaml`
- **功能**: 最简化的外部知识库工作流
- **节点**: 开始 → 知识检索 → LLM → 结束
- **适用**: 快速测试

### 3. 高级工作流
- **文件**: `advanced_workflow.yaml`
- **功能**: 多知识库、智能分析、结果合并
- **节点**: 开始 → 查询分析 → 多知识库检索 → 结果合并 → 内容增强 → 答案生成 → 质量检查 → 结束
- **适用**: 企业级应用

### 4. 条件分支工作流
- **文件**: `conditional_workflow.yaml`
- **功能**: 条件路由、用户类型识别、动态处理
- **节点**: 开始 → 查询分类 → 条件路由 → 多分支处理 → 结果合并 → 质量控制 → 结束
- **适用**: 个性化服务

### 5. 演示工作流
- **文件**: `demo_workflow.yaml`
- **功能**: 演示和学习
- **节点**: 基础工作流节点
- **适用**: 学习和演示

## 使用方法

### 环境准备

```bash
# 设置环境变量
export DIFY_BASE_URL="http://localhost:5001"  # Dify API地址
export DIFY_API_TOKEN="your_api_token_here"   # API访问令牌
export EXTERNAL_API_ENDPOINT="https://your-external-api.com"  # 外部知识库API端点
export EXTERNAL_API_KEY="your_api_key_here"   # 外部知识库API密钥
export EXTERNAL_KNOWLEDGE_ID="your_knowledge_id"  # 外部知识库ID
```

### 导入工作流

```bash
# 运行导入脚本
python import_workflow.py
```

导入脚本会：
1. 自动创建外部知识库API配置
2. 自动创建数据集
3. 导入选择的工作流文件
4. 测试工作流功能

### 选择工作流

导入脚本支持选择不同的工作流文件：
- 基础工作流（推荐新手）
- 简化工作流（快速测试）
- 高级工作流（企业应用）
- 条件分支工作流（个性化服务）
- 演示工作流（学习演示）

## 工作流特性

### 基础功能
- ✅ 外部知识库检索
- ✅ LLM智能回答
- ✅ 结果重排序
- ✅ 来源引用

### 高级功能
- ✅ 多知识库支持
- ✅ 智能查询分析
- ✅ 结果智能合并
- ✅ 内容增强处理
- ✅ 答案质量检查
- ✅ 条件分支路由
- ✅ 用户类型识别

## 技术特点

### DSL设计
- 基于Dify工作流DSL规范
- 支持多种节点类型
- 灵活的参数配置
- 可扩展的架构设计

### 节点类型
- **开始节点**: 接收用户输入
- **知识检索节点**: 从外部知识库检索信息
- **LLM节点**: 智能处理和回答生成
- **代码节点**: 自定义逻辑处理
- **条件节点**: 条件分支路由
- **结束节点**: 输出最终结果

### 配置选项
- 支持多种LLM模型
- 可配置检索参数
- 支持自定义提示词
- 灵活的输出格式

## 快速开始

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd knowledge
   ```

2. **设置环境变量**
   ```bash
   export DIFY_BASE_URL="http://localhost:5001"
   export DIFY_API_TOKEN="your_api_token_here"
   # ... 其他环境变量
   ```

3. **运行导入脚本**
   ```bash
   python import_workflow.py
   ```

4. **选择工作流类型**
   - 根据需求选择合适的工作流
   - 配置相关参数
   - 开始导入

5. **测试工作流**
   - 在Dify控制台中测试
   - 验证功能是否正常
   - 根据需要调整配置

## 故障排除

### 常见问题

1. **导入失败**
   - 检查环境变量设置
   - 确认API令牌权限
   - 检查网络连接

2. **工作流运行失败**
   - 检查外部知识库API配置
   - 确认数据集状态
   - 查看错误日志

3. **检索结果为空**
   - 检查外部知识库数据
   - 调整检索参数
   - 确认知识库ID正确

### 调试建议

1. **启用详细日志**
   ```bash
   export DEBUG=1
   python import_workflow.py
   ```

2. **检查API响应**
   - 查看控制台输出
   - 检查HTTP状态码
   - 分析错误信息

3. **验证配置**
   - 确认所有环境变量
   - 检查API端点可访问性
   - 验证权限设置

## 贡献指南

欢迎贡献代码和建议！

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 发起Pull Request

## 许可证

本项目采用MIT许可证。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 提交Issue
- 发送邮件
- 参与讨论

---

**开始使用Dify外部知识库工作流，提升您的AI应用能力！** 🚀