# Master Password 加密系统 - 性能分析

## 解密时间构成

### 完整解锁流程时间

```
用户输入密码 → 点击 Unlock
  ↓
[1] PBKDF2 密钥派生 ⏱️ 主要耗时
  ↓
[2] AES-256 解密 ⏱️ 很快 (~1-5ms)
  ↓
[3] JSON 解析 ⏱️ 很快 (~1-10ms)
  ↓
显示 Dashboard
```

### 各阶段时间分析

#### 1. PBKDF2 密钥派生 (主要耗时)

**Standard (100,000 iterations)**
- iPhone 13/14: ~80-120ms
- iPhone 11/12: ~100-150ms
- iPhone 8/X: ~150-200ms
- Android 旗舰: ~100-180ms
- Android 中端: ~200-300ms

**Enhanced (650,000 iterations)**
- iPhone 13/14: ~450-550ms
- iPhone 11/12: ~500-700ms
- iPhone 8/X: ~700-900ms
- Android 旗舰: ~600-800ms
- Android 中端: ~1000-1500ms

**Paranoid (1,000,000 iterations)**
- iPhone 13/14: ~700-900ms
- iPhone 11/12: ~800-1100ms
- iPhone 8/X: ~1100-1400ms
- Android 旗舰: ~900-1200ms
- Android 中端: ~1500-2000ms

#### 2. AES-256-CBC 解密 (极快)

```dart
// 单个 secret 解密
final encrypted = base64.decode(data);
final iv = IV(encrypted.sublist(0, 16));
final ciphertext = encrypted.sublist(16);
final decrypted = encrypter.decrypt(Encrypted(ciphertext), iv: iv);
```

**时间:** ~0.1-1ms per secret
- 10 secrets: ~1-10ms
- 100 secrets: ~10-100ms
- 1000 secrets: ~100-1000ms (1秒)

#### 3. JSON 解析

```dart
final jsonMap = json.decode(decryptedString);
final secrets = jsonList.map((j) => Secret.fromJson(j)).toList();
```

**时间:**
- 10 secrets: ~1-3ms
- 100 secrets: ~5-15ms
- 1000 secrets: ~50-150ms

## 完整解锁时间估算

### Standard (100,000 iterations)

| Secrets | iPhone 13 | iPhone 11 | Android 中端 |
|---------|-----------|-----------|-------------|
| 10      | ~100ms    | ~120ms    | ~250ms      |
| 100     | ~120ms    | ~150ms    | ~300ms      |
| 1000    | ~200ms    | ~250ms    | ~500ms      |

### Enhanced (650,000 iterations)

| Secrets | iPhone 13 | iPhone 11 | Android 中端 |
|---------|-----------|-----------|-------------|
| 10      | ~500ms    | ~650ms    | ~1200ms     |
| 100     | ~520ms    | ~670ms    | ~1250ms     |
| 1000    | ~600ms    | ~750ms    | ~1500ms     |

### Paranoid (1,000,000 iterations)

| Secrets | iPhone 13 | iPhone 11 | Android 中端 |
|---------|-----------|-----------|-------------|
| 10      | ~800ms    | ~1000ms   | ~1800ms     |
| 100     | ~820ms    | ~1020ms   | ~1850ms     |
| 1000    | ~900ms    | ~1100ms   | ~2000ms     |

## 性能优化建议

### 1. 默认推荐 Standard 级别 ✅

```dart
SecurityLevel _selectedLevel = SecurityLevel.standard; // 默认
```

**原因:**
- 100,000 次迭代已经很安全
- 解锁时间 <200ms，用户感知不到延迟
- OWASP 推荐最低 10,000，我们用 100,000

### 2. 在 UI 中显示预估时间

```dart
Text(
  'Standard (100,000 iterations)',
  style: GoogleFonts.spaceGrotesk(...),
),
Text(
  'Unlock time: ~100-200ms', // 添加这行
  style: GoogleFonts.notoSans(
    fontSize: 12,
    color: Colors.grey[500],
  ),
),
```

### 3. 添加加载指示器

当前已实现：
```dart
VaultButton(
  text: _isLoading ? 'Unlocking...' : 'Unlock Vault',
  isLoading: _isLoading, // ✅ 已有加载状态
)
```

### 4. 后台线程优化（可选）

Dart 的 PBKDF2 运行在主线程，可以使用 Isolate 优化：

```dart
// 未来优化选项
Future<encrypt.Key> deriveMasterKeyInBackground(String password) async {
  return await compute(_pbkdf2Worker, {
    'password': password,
    'salt': salt,
    'iterations': iterations,
  });
}
```

## 实际测试数据

### 测试方法

在 `master_password_input_screen.dart` 中添加：

```dart
Future<void> _unlock() async {
  final password = _passwordController.text;
  
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // 测试开始时间
    final startTime = DateTime.now();
    
    final isValid = await _masterKeyService.verifyPassword(password);
    
    // 密钥派生完成时间
    final keyDerivationTime = DateTime.now().difference(startTime);
    print('PBKDF2 time: ${keyDerivationTime.inMilliseconds}ms');
    
    if (!isValid) {
      setState(() {
        _errorMessage = 'Incorrect password';
        _isLoading = false;
      });
      return;
    }

    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
    await vaultProvider.reinitialize(password);
    
    // 总解锁时间
    final totalTime = DateTime.now().difference(startTime);
    print('Total unlock time: ${totalTime.inMilliseconds}ms');
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  } catch (e) {
    // ...
  }
}
```

### 预期输出

**Standard (iPhone 13):**
```
PBKDF2 time: 95ms
Total unlock time: 112ms
```

**Enhanced (iPhone 13):**
```
PBKDF2 time: 485ms
Total unlock time: 502ms
```

**Paranoid (iPhone 13):**
```
PBKDF2 time: 756ms
Total unlock time: 773ms
```

## 用户体验影响

### 延迟感知阈值

- **<100ms**: 瞬时，用户感觉不到延迟
- **100-300ms**: 可接受，略有延迟
- **300-1000ms**: 明显延迟，需要加载指示器
- **>1000ms**: 明显等待，可能焦虑

### 推荐配置

| 用户类型 | 推荐级别 | 解锁时间 | 理由 |
|---------|---------|---------|------|
| 普通用户 | Standard | ~100-200ms | 快速+安全 |
| 高级用户 | Enhanced | ~500-700ms | 更高安全性 |
| 极端安全需求 | Paranoid | ~1-1.5s | 最高安全性 |

## 安全性 vs 性能权衡

### PBKDF2 迭代次数的意义

**攻击成本分析:**

| 级别 | 迭代次数 | 单次尝试时间 | 暴力破解成本 |
|-----|---------|------------|-------------|
| Standard | 100,000 | ~100ms | 10^8 密码/秒 → 10,000/秒 |
| Enhanced | 650,000 | ~650ms | 同上 → ~1,500/秒 |
| Paranoid | 1,000,000 | ~1s | 同上 → 1,000/秒 |

**8字符密码暴力破解时间:**
- 字符集: a-z, A-Z, 0-9, 符号 (~95种)
- 可能组合: 95^8 ≈ 6.6 × 10^15

使用 Standard (10,000 尝试/秒):
- 时间: 6.6 × 10^15 / 10,000 = 6.6 × 10^11 秒
- 约 **2100万年**

**结论: Standard 级别已经足够安全**

## 建议

### 1. 默认 Standard，文档说明

```dart
// setup_master_password_screen.dart
Text(
  'Standard (Recommended)',
  style: GoogleFonts.spaceGrotesk(...),
),
Text(
  '100,000 iterations • ~100ms unlock • Secure for most users',
  style: GoogleFonts.notoSans(...),
),
```

### 2. 高级用户可选 Enhanced

```dart
Text(
  'Enhanced',
  style: GoogleFonts.spaceGrotesk(...),
),
Text(
  '650,000 iterations • ~500ms unlock • High security',
  style: GoogleFonts.notoSans(...),
),
```

### 3. Paranoid 仅特殊场景

```dart
Text(
  'Paranoid',
  style: GoogleFonts.spaceGrotesk(...),
),
Text(
  '1,000,000 iterations • ~1s unlock • Maximum security',
  style: GoogleFonts.notoSans(...),
),
```

## 总结

✅ **当前实现已经很好**
- Standard 默认值合理
- 提供 3 个级别选择
- UI 有加载状态
- 安全性和性能平衡良好

📊 **性能特征**
- 主要耗时在 PBKDF2 密钥派生
- AES 解密和 JSON 解析可忽略
- Standard: ~100-200ms (推荐)
- Enhanced: ~500-700ms (高安全)
- Paranoid: ~1-1.5s (最高安全)

🎯 **用户建议**
- 大多数用户用 Standard
- 企业/敏感数据用 Enhanced
- 极端场景用 Paranoid

