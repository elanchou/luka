# Vault App - User Flow with Master Password

## 完整用户流程设计

### 流程 1: 新用户首次使用

```
启动应用
  ↓
AppSplashScreen (检查状态)
  ↓
没有 master password → 没有 vault
  ↓
VaultOnboardingScreen
  - 欢迎页面
  - 介绍 master password 加密
  - "Create New Vault" 按钮
  ↓
点击 "Create New Vault"
  ↓
SetMasterPasswordScreen (初始化模式)
  - 输入新密码 (至少8位)
  - 确认密码
  - 选择安全级别 (Standard/Enhanced/Paranoid)
  - 显示安全提示
  ↓
密码设置成功
  ↓
MasterPasswordInputScreen
  - 要求输入刚设置的密码
  - 验证密码
  - 初始化 vault provider
  ↓
密码正确
  ↓
MainVaultDashboard
  - 空的 vault
  - 可以添加 secrets
```

### 流程 2: 老用户解锁

```
启动应用
  ↓
AppSplashScreen (检查状态)
  ↓
有 master password + 有 vault
  ↓
MasterPasswordInputScreen
  - 显示 "Enter Master Password"
  - 输入密码
  - 显示/隐藏密码选项
  - "Forgot Password?" (重置选项)
  ↓
密码正确
  ↓
初始化 VaultProvider (用密码)
  ↓
MainVaultDashboard
  - 显示所有 secrets
  - 正常使用
```

### 流程 3: 修改 Master Password

```
MainVaultDashboard
  ↓
点击 Settings 标签
  ↓
SystemSettingsScreen
  ↓
点击 "Change Master Password"
  ↓
ChangeMasterPasswordScreen (新建独立页面)
  - 输入当前密码
  - 输入新密码
  - 确认新密码
  - 选择安全级别
  ↓
验证成功
  ↓
重新加密所有数据
  ↓
返回 Settings
  - 显示成功提示
```

### 流程 4: 修改安全级别

```
SystemSettingsScreen
  ↓
点击 "Security Level" → 显示当前级别
  ↓
弹出选择对话框
  - Standard (100,000 iterations)
  - Enhanced (650,000 iterations)
  - Paranoid (1,000,000 iterations)
  ↓
选择新级别
  ↓
要求输入密码验证
  ↓
验证成功
  ↓
更新迭代次数
  - 下次解锁使用新级别
```

### 流程 5: 忘记密码 (重置 Vault)

```
MasterPasswordInputScreen
  ↓
点击 "Forgot Password?"
  ↓
显示警告对话框
  - "重置将删除所有数据"
  - "无法恢复"
  - 确认/取消按钮
  ↓
确认重置
  ↓
清除所有数据
  - 删除 vault.enc
  - 删除 master password salt
  - 删除所有设置
  ↓
VaultOnboardingScreen
  - 重新开始
```

## 关键改进点

### 1. 移除 Biometric Auth Screen (暂时)
- Master password 是主要认证方式
- 生物识别作为未来增强功能
- 简化初始流程

### 2. 新建专用页面
- `ChangeMasterPasswordScreen`: 独立的修改密码页面
- 不在 Settings 页面内嵌套复杂逻辑

### 3. 明确的状态检查
```dart
if (!hasPassword && !vaultExists) {
  // 全新用户 → Onboarding
} else if (hasPassword && vaultExists) {
  // 正常用户 → Password Input
} else {
  // 异常状态 → Onboarding
}
```

### 4. 清晰的数据流
```
Master Password (用户输入)
  ↓
PBKDF2 + Salt + Iterations
  ↓
Derived Key (32 bytes)
  ↓
AES-256-CBC Encryption
  ↓
Encrypted Vault Data
```

## UX 优化

### 密码输入体验
- ✅ 显示/隐藏密码切换
- ✅ 密码强度指示器 (未来)
- ✅ 错误提示清晰
- ✅ 加载状态显示

### 安全级别说明
- ✅ 每个级别的迭代次数
- ✅ 预估解锁时间
- ✅ 安全性说明
- ⚠️ 警告：级别越高越慢

### 错误处理
- ✅ 密码错误次数限制 (未来)
- ✅ 密码为空提示
- ✅ 密码不匹配提示
- ✅ 网络异常处理

## 代码结构

```
lib/screens/
├── app_splash_screen.dart              # 启动检查
├── vault_onboarding_screen.dart        # 欢迎页
├── set_master_password_screen.dart     # 设置密码 (首次)
├── master_password_input_screen.dart   # 输入密码 (解锁)
├── change_master_password_screen.dart  # 修改密码 (新建)
├── main_vault_dashboard.dart           # 主界面
└── system_settings_screen.dart         # 设置页

lib/services/
├── master_key_service.dart             # 密码管理
├── encryption_service.dart             # 加密服务
└── vault_service.dart                  # 数据存储

lib/providers/
└── vault_provider.dart                 # 状态管理
```

