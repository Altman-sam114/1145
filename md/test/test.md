# 测试规范

本文指导 Agent B 和 Agent C 为 `Desert Frontline` 选择验证层级。每次实现前必须先读本文件。

## 固定前缀 / 环境要求

项目是 iOS SwiftUI + SpriteKit app，当前没有独立 XCTest target。命令行验证以 Xcode build 为主。

推荐使用完整 Xcode 路径，避免命令行工具路径不一致：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
```

当前可靠构建目标：

- `-project DesertFrontline.xcodeproj`
- `-scheme DesertFrontline`
- `-configuration Debug`
- `-sdk iphoneos`
- `-destination generic/platform=iOS`
- `-derivedDataPath build/DerivedDataDevice`
- `CODE_SIGNING_ALLOWED=NO`

当前环境历史上 CoreSimulatorService 多次不可用；模拟器失败不能直接判定为源码回归。能启动模拟器时，UI/触摸改动需要补充人工交互检查。

## 测试分层

### 1. Probe / Fast

最快发现文档格式、补丁残留和明显构建配置问题。

触发条件：

- 纯文档修改。
- 提交前快速检查。
- Agent C 验收开始时。

命令：

```sh
git diff --check
```

当前基线：

- 文档-only 任务最低要求通过 `git diff --check`。

### 2. Smoke

验证 Swift 代码能在当前工程配置下编译。

触发条件：

- 任意 Swift 源码修改。
- Xcode 工程配置修改。
- 影响资源、入口、Scene 初始化或 build setting 的修改。

命令：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath build/DerivedDataDevice \
  CODE_SIGNING_ALLOWED=NO \
  build
```

当前基线：

- README 记录该 generic iOS device build 可成功。
- 成功标准：输出包含 `** BUILD SUCCEEDED **`。

### 3. Stage Regression

覆盖当前阶段核心模块的人工/半人工回归。

触发条件：

- 修改战斗、移动、生产、经济、AI、迷雾、HUD、支援技能、任务或胜负逻辑。
- Agent A 提示词要求验证某条玩法链路。
- Smoke 通过但存在高风险行为变化。

命令：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath build/DerivedDataDevice \
  CODE_SIGNING_ALLOWED=NO \
  build
```

人工检查清单：

- 启动 skirmish 后地图、HUD、小地图、迷雾显示正常。
- 选择、框选、移动、攻击、`HOLD`、`AMOV` 不互相破坏。
- 生产队列、建筑施工、集结点和经济收入仍工作。
- AI 能生产、占点、进攻并使用相关新能力。
- 若修改海战，检查潜艇隐身、声呐和海军路径。

当前基线：

- 暂无自动化 Stage Regression；以 generic build + 可用设备/模拟器人工检查为准。

### 4. Full

全量验证当前可运行游戏体验。

触发条件：

- 大版本合并。
- 多系统联动修改。
- 发布前、人工要求或 Agent C 判断需要。

命令：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath build/DerivedDataDevice \
  CODE_SIGNING_ALLOWED=NO \
  build
```

人工检查清单：

- 至少跑一局从开局到明显胜负趋势的 skirmish。
- 检查三类军种、支援技能、建造、生产、AI 进攻、任务阶段、HQ 胜负。
- 尝试 `SKRM` 重开，确认状态重置。

当前基线：

- 暂无自动化 Full；依赖可用 iOS target 或模拟器人工验证。

## 静态检查

当前固定静态检查：

```sh
git diff --check
```

可选辅助检查：

```sh
git status --short
git log --oneline -n 12
```

当前没有 markdown lint、SwiftLint、格式化脚本或 XCTest 目标；不要声称跑过不存在的工具。

## 规则

- 每次实现前先读本文件。
- 默认从最小测试开始，根据改动范围扩大测试。
- 文档-only 修改可以不跑 Xcode build，但必须说明原因。
- 改 Swift 代码后必须至少跑 Smoke。
- UI、HUD、触摸交互改动在构建外还应尽量做设备/模拟器检查；如果 CoreSimulatorService 不可用，要明确记录。
- 不得伪造测试结果。
- 新增测试方式、脚本、XCTest target 或验证流程时，必须更新本文、`README.md` 和必要的 `update_log.md`。
