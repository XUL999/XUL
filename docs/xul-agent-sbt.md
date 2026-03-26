# XUL AI Agent SBT 身份系统 v2

## 📍 合约信息

| 项目 | 值 |
|------|-----|
| **合约地址** | `0x4BBC7F4f6d0c14571f58619A0125EAE056F9fD6a` |
| **链** | XUL (Chain ID: 12309) |
| **RPC** | https://pro.rswl.ai |
| **浏览器** | https://scan.rswl.ai/address/0x4BBC7F4f6d0c14571f58619A0125EAE056F9fD6a |

---

## 🦞 已注册的 Agent

| ID | Name | Address | Skills | Score | Status |
|----|------|---------|--------|-------|--------|
| #1 | Claw | `0xC2F803f72033210718dbF150301b5A88Bb2C12CC` | 8 | 500 | ✅ Active |

---

## 🔑 核心逻辑：管理员铸造 SBT 到用户钱包

**v2 关键改动：**
- 用户**不能自己铸造**
- 只有授权的 `minter` 可以调用 `mintTo()` 发送 SBT 到任意地址
- 用户只能更新自己的信息

---

## 📝 铸造新 Agent 身份

```javascript
const { ethers } = require('ethers');

const provider = new ethers.JsonRpcProvider('https://pro.rswl.ai');
const wallet = new ethers.Wallet('<MINTER_PRIVATE_KEY>', provider);

const sbt = new ethers.Contract(
    '0x4BBC7F4f6d0c14571f58619A0125EAE056F9fD6a',
    [
        'function mintTo(address to, string name, string desc, string avatar, string[] skills) returns (uint256)',
        'function mintToSimple(address to, string name, string desc, string avatar) returns (uint256)',
        'function addSkillTo(address to, string name)',
    ],
    wallet
);

// 方式1：带初始技能
await sbt.mintTo(
    '0xUserAddress...',
    'AgentName',
    'Description',
    '',
    ['Skill 1', 'Skill 2']
);

// 方式2：简化版（无技能）
await sbt.mintToSimple(
    '0xUserAddress...',
    'AgentName',
    'Description',
    ''
);

// 后续添加技能
await sbt.addSkillTo('0xUserAddress...', 'New Skill');
```

---

## 🔧 合约功能

### Minter 功能（仅限授权铸造者）
| 方法 | 说明 |
|------|------|
| `mintTo(to, name, desc, avatar, skills[])` | 铸造 SBT 到指定地址 |
| `mintToSimple(to, name, desc, avatar)` | 简化铸造（无初始技能） |
| `addSkillTo(to, name)` | 为指定地址添加技能 |

### 用户功能（仅限已铸造身份的用户）
| 方法 | 说明 |
|------|------|
| `updateName(name)` | 更新名称 |
| `updateDesc(desc)` | 更新描述 |
| `updateAvatar(avatar)` | 更新头像 URI |
| `deactivate()` | 停用身份 |
| `reactivate()` | 重新激活 |

### Admin 功能
| 方法 | 说明 |
|------|------|
| `updateScore(address, delta)` | 更新声誉评分 |
| `addMinter(address)` | 添加铸造者 |
| `removeMinter(address)` | 移除铸造者 |
| `transferAdmin(address)` | 转移管理员权限 |

### 查询功能
| 方法 | 说明 |
|------|------|
| `getInfo(address)` | 获取 Agent 完整信息 |
| `getSkills(address)` | 获取技能列表 |
| `hasIdentity(address)` | 检查是否已有身份 |
| `agentIds(address)` | 获取 Agent ID |

---

## 🎯 使用场景

1. **Agent 身份认证** - 管理员为新 Agent 发放链上身份
2. **技能认证** - 记录 Agent 的能力和特长
3. **声誉系统** - 通过评分建立可信度
4. **访问控制** - 基于 SBT 身份的权限管理
5. **治理参与** - Agent 参与链上治理投票

---

## ⚠️ 注意事项

- SBT 是**灵魂绑定代币**，不可转让
- 每个地址只能铸造一次身份
- 技能名称不能重复
- 只有 `minter` 可以铸造 SBT 到用户钱包
- Admin 可以调整声誉评分和管理 minter 列表

---

## 📂 相关文件

- 合约源码: `xul-wallet/contracts/AIAgentIdentitySBTv2.sol`
- ABI: `compiled/AIAgentIdentitySBTv2.abi`
- Bytecode: `compiled/AIAgentIdentitySBTv2.bin`
