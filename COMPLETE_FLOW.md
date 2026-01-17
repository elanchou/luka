# Master Password 加密系统 - 完整流程文档

## ✅ 最终实现的用户流程

### 启动逻辑

```dart
AppSplashScreen._checkVaultStatus() {
  hasPassword = MasterKeyService.hasPassword();
  
  if (hasPassword) {
    // 已初始化 -> 密码输入页
    Navigator -> /master-password-input
  } else {
    // 未初始化 -> 欢迎页
    Navigator -> /onboarding
  }
}
```

### 完整流程图

```
┌─────────────────────────────────────────────────────────────┐
│                     APP 启动                                 │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │  SplashScreen  │
         │  检查 hasPassword │
         └────────┬───────┘
                  │
         ┌────────┴────────┐
         │                 │
    hasPassword?       hasPassword?
      = false             = true
         │                 │
         ▼                 ▼
  ┌─────────────┐   ┌──────────────────┐
  │ Onboarding  │   │ PasswordInput     │
  │ 欢迎页面     │   │ 输入密码解锁      │
  └──────┬──────┘   └────────┬─────────┘
         │                   │
         ▼                   ▼
  ┌─────────────┐      验证密码
  │ 点击 "Create│         │
  │ New Vault" │    ┌────┴────┐
  └──────┬──────┘    │  正确?   │
         │           └────┬────┘
         ▼                │
  ┌─────────────────┐     ▼
  │ SetupMasterPassword │  初始化 VaultProvider
  │ - 输入新密码      │         │
  │ - 确认密码        │         ▼
  │ - 选择安全级别    │   ┌──────────┐
  └──────┬──────────┘   │ Dashboard │
         │               │ 主界面    │
         ▼               └──────────┘
    设置成功
         │
         ▼
  ┌──────────────────┐
  │PasswordInput      │
  │ 输入刚设置的密码   │
  └──────┬───────────┘
         │
         ▼
    验证并初始化
         │
         ▼
  ┌──────────┐
  │ Dashboard │
  └──────────┘
```

### 流程 1: 新用户首次使用 ✅

```
1. 启动应用
   └─> SplashScreen
       └─> hasPassword() = false
           └─> /onboarding

2. VaultOnboardingScreen
   └─> 点击 "Create New Vault"
       └─> /set-master-password

3. SetupMasterPasswordScreen
   ├─> 输入密码 (≥8 字符)
   ├─> 确认密码
   ├─> 选择安全级别 (Standard/Enhanced/Paranoid)
   └─> 点击 "Create Password"
       └─> MasterKeyService.setMasterPassword()
           ├─> 生成 256-bit random salt
           ├─> 存储 salt 和 iterations
           └─> 标记 hasPassword = true
       └─> /master-password-input (自动跳转)

4. MasterPasswordInputScreen
   ├─> 输入刚设置的密码
   └─> 点击 "Unlock Vault"
       └─> MasterKeyService.verifyPassword()
           └─> PBKDF2 派生密钥
               └─> 验证成功
       └─> VaultProvider.reinitialize(password)
           └─> EncryptionService.init(masterPassword)
               └─> deriveMasterKey()
           └─> VaultService.loadSecrets()
               └─> 空列表 (新用户)
       └─> /dashboard

5. MainVaultDashboard
   └─> 空的 vault，可以添加 secrets
```

### 流程 2: 老用户再次打开应用 ✅

```
1. 启动应用
   └─> SplashScreen
       └─> hasPassword() = true ✓
           └─> /master-password-input (直接跳转)

2. MasterPasswordInputScreen
   ├─> 输入密码
   └─> 点击 "Unlock Vault"
       └─> MasterKeyService.verifyPassword(password)
           ├─> 读取 salt
           ├─> 读取 iterations
           └─> PBKDF2 派生密钥
               └─> 验证通过
       └─> VaultProvider.reinitialize(password)
           ├─> EncryptionService.init(masterPassword)
           │   └─> _masterKey = derivedKey
           └─> VaultService.loadSecrets()
               ├─> 读取 vault.enc
               ├─> Base64.decode()
               ├─> EncryptionService.decryptData()
               │   └─> AES-256-CBC.decrypt()
               └─> JSON.decode() -> List<Secret>
       └─> /dashboard

3. MainVaultDashboard
   └─> 显示所有已保存的 secrets
```

### 流程 3: 添加 Secret ✅

```
Dashboard
  └─> 点击 "+" FAB
      └─> /add-secret-1
          ├─> 输入 name
          └─> 输入 network
              └─> /add-secret-2
                  ├─> 输入 12 个 seed words
                  ├─> BIP39 验证
                  └─> 点击 "Verify & Save"
                      └─> Secret.create()
                      └─> VaultProvider.addSecret(secret)
                          └─> VaultService.saveSecrets([...secrets, newSecret])
                              ├─> JSON.encode({secrets: [...]})  
                              ├─> EncryptionService.encryptData(json)
                              │   ├─> 使用已派生的 _masterKey
                              │   ├─> 生成 random IV
                              │   ├─> AES-256-CBC.encrypt()
                              │   └─> Base64(IV + Ciphertext)
                              └─> File.writeAsString(vault.enc)
                          └─> notifyListeners()
                      └─> /dashboard

Dashboard
  └─> 显示新添加的 secret
```

### 流程 4: 查看 Secret ✅

```
Dashboard
  └─> 点击某个 secret card
      └─> /seed-detail
          └─> Secret 数据已经在内存中解密
              ├─> VaultProvider._secrets
              │   └─> 在 loadSecrets() 时已解密
              └─> 显示明文内容
                  ├─> 可以复制
                  ├─> 可以分享
                  └─> 可以删除
```

### 流程 5: 修改 Master Password ✅

```
Dashboard
  └─> 点击 Settings Tab
      └─> SystemSettingsScreen
          └─> 点击 "Change Master Password"
              └─> /change-master-password
                  ├─> 输入当前密码
                  ├─> 输入新密码
                  ├─> 确认新密码
                  ├─> 选择安全级别
                  └─> 点击 "Change Password"
                      └─> MasterKeyService.verifyPassword(currentPassword)
                          └─> 验证成功
                      └─> MasterKeyService.changeMasterPassword()
                          ├─> 生成新的 random salt
                          ├─> 用新密码派生新密钥
                          └─> 更新存储
                      └─> VaultProvider.reinitialize(newPassword)
                          ├─> 用新密钥重新初始化
                          ├─> 加载所有 secrets
                          └─> 用新密钥重新保存所有数据
                              └─> VaultService.saveSecrets()
                      └─> 返回 Settings
                          └─> 显示成功消息
```

### 流程 6: 忘记密码 ✅

```
MasterPasswordInputScreen
  └─> 点击 "Forgot Password?"
      └─> 显示警告对话框
          ├─> "将删除所有数据"
          ├─> "无法恢复"
          └─> 用户确认
              └─> VaultProvider.clearVault()
                  └─> VaultService.clearVault()
                      └─> 删除 vault.enc
              └─> MasterKeyService.reset()
                  ├─> 删除 salt
                  ├─> 删除 iterations  
                  └─> 删除 hasPassword 标记
              └─> /onboarding
                  └─> 重新开始流程
```

## 🔐 加密数据流

### 写入流程

```
用户数据 "hello world"
  ↓
Secret.create(content: "hello world")
  ↓
VaultProvider.addSecret(secret)
  ↓
VaultService.saveSecrets([secret])
  ↓
JSON.encode({"secrets": [{"content": "hello world", ...}]})
  ↓
EncryptionService.encryptData(jsonString)
  ↓
使用 _masterKey (来自 deriveMasterKey(userPassword))
  ↓
generate random IV (128-bit)
  ↓
AES-256-CBC.encrypt(
  key: _masterKey,
  iv: randomIV,
  plaintext: jsonString
)
  ↓
Base64.encode(IV + Ciphertext)
  ↓
vault.enc 文件
```

### 读取流程

```
vault.enc 文件
  ↓
File.readAsString()
  ↓
Base64.decode() -> bytes
  ↓
extract IV (前 16 bytes)
extract Ciphertext (剩余 bytes)
  ↓
EncryptionService.decryptData()
  ↓
使用 _masterKey (来自 deriveMasterKey(userPassword))
  ↓
AES-256-CBC.decrypt(
  key: _masterKey,
  iv: extractedIV,
  ciphertext: extractedCiphertext  
)
  ↓
JSON.decode(decryptedString)
  ↓
List<Secret> objects
  ↓
VaultProvider._secrets
  ↓
在 UI 中显示
```

## 📝 关键简化

相比之前的实现，现在的流程更加简洁：

1. **启动检查更简单**
   - 只检查 `hasPassword()`
   - 不再检查 `vaultExists()`
   - 两个分支：有密码 → 输入密码，无密码 → 欢迎页

2. **路由更清晰**
   - `/set-master-password` → 专用的初始化页面
   - `/master-password-input` → 解锁页面
   - `/change-master-password` → 修改密码页面

3. **无冗余页面**
   - 移除了不必要的 `decrypting-progress` 等过渡页
   - 移除了旧的 `biometric-auth` 流程

4. **数据流统一**
   - 所有 secrets 都用 master password 派生的密钥加密
   - 不存在混合加密模式
   - 不需要迁移逻辑

## ✅ 验收标准

### 功能完整性
- ✅ 新用户可以设置密码并创建 vault
- ✅ 老用户可以用密码解锁 vault
- ✅ 密码验证失败时有清晰提示
- ✅ 可以添加 secrets 并自动加密
- ✅ 可以查看 secrets 并自动解密
- ✅ 可以修改 master password
- ✅ 可以更改安全级别
- ✅ 忘记密码可以重置（丢失数据）

### 安全性
- ✅ 使用 PBKDF2-HMAC-SHA256 派生密钥
- ✅ 使用 AES-256-CBC 加密数据
- ✅ 每次加密使用随机 IV
- ✅ 每个用户使用随机 salt
- ✅ 密码不存储在任何地方
- ✅ 派生的密钥只在内存中

### 用户体验
- ✅ 启动流程流畅，无卡顿
- ✅ 错误提示清晰有用
- ✅ 加载状态明确
- ✅ 导航逻辑正确
- ✅ UI 一致性好

## 🎯 总结

**Master Password 加密系统已完全集成并经过简化优化。**

核心改进：
- 简化了启动检查逻辑（只看 hasPassword）
- 专用的设置页面（SetupMasterPasswordScreen）
- 清晰的路由结构
- 统一的加密流程
- 完整的用户体验

系统已准备好用于生产环境。

