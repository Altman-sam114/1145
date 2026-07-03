# 项目流程图

本文用 Mermaid 图把 `md/flow/flow.md` 的核心逻辑可视化。每张图前都有中文读图说明，便于人工快速检查当前项目运行链路。

## 1. 项目核心逻辑图

读图说明：从 App 启动开始，SwiftUI 只负责承载 SpriteKit；所有游戏运行态进入 `GameScene`。每帧 update 推进各系统，最后更新节点渲染、HUD、小地图和胜负状态。

```mermaid
flowchart TD
  App["DesertFrontlineApp\n创建窗口入口"] --> View["GameView\nSwiftUI SpriteView 承载场景"]
  View --> Holder["SceneHolder\n创建 GameScene 1366x1024"]
  Holder --> Scene["GameScene.didMove\n初始化世界节点、地图、实体、HUD、相机"]
  Scene --> Init["初始化链路\n地形 -> 地图 -> 控制点 -> 初始部队 -> HUD -> 迷雾"]
  Init --> Loop["GameScene.update 每帧循环\n统一推进游戏状态"]
  Loop --> Build["施工 / 生产\n建筑进度、BuildOrder、出兵、集结点"]
  Loop --> Economy["经济 / 占领\nHQ、油井、旗点收入与占领进度"]
  Loop --> Commands["移动 / 命令\n普通移动、HOLD、AMOV、路径和编队"]
  Loop --> Combat["战斗 / 维修\n目标搜索、有效伤害、击杀 XP、老兵徽章、死亡清理"]
  Loop --> AI["敌方 AI\n建造、占点、支援技能、attack-move 波次"]
  Loop --> Fog["战争迷雾\n可见格、已探索格、侦察、潜艇检测"]
  Loop --> Mission["任务 / 胜负\n阶段目标与 HQ 摧毁判定"]
  Build --> Render["SpriteKit 渲染\n实体节点、特效、进度条"]
  Economy --> Render
  Commands --> Render
  Combat --> Render
  AI --> Render
  Fog --> Render
  Mission --> HUD["HUD / 小地图\n金钱、队列、选择信息、任务、相机框"]
  Render --> HUD
```

## 2. 玩家输入与命令流程图

读图说明：触摸输入会先判断 HUD 和小地图，再处理 pending 模式。建筑放置、支援技能、集结点和 attack-move 都是互斥 pending 状态，最后才进入普通选择、攻击或移动。

```mermaid
flowchart TD
  Touch["玩家触摸输入\nBegan / Moved / Ended"] --> HUDCheck{"是否点到 HUD 按钮"}
  HUDCheck -- "是" --> HudAction["handleHudAction\n切换命令、生产、支援、AI、重开"]
  HUDCheck -- "否" --> MiniMap{"是否点到小地图"}
  MiniMap -- "是" --> Camera["移动相机到小地图位置"]
  MiniMap -- "否" --> MultiTouch{"是否双指触摸"}
  MultiTouch -- "是" --> PanZoom["相机平移 / 缩放"]
  MultiTouch -- "否" --> Pending{"是否存在 pending 模式"}
  Pending -- "建筑" --> Place["放置预览 / placeStructure\n检查视野、基地覆盖、地形和资金"]
  Pending -- "支援技能" --> Support["executeSupportPower\n检查资金、冷却、资产需求、效果"]
  Pending -- "集结点" --> Rally["setRallyPoint\n生产来源设置出兵目标"]
  Pending -- "AMOV" --> AttackMove["issueAttackMoveOrder\n编队推进并沿途交战"]
  Pending -- "无" --> WorldTap{"世界点击目标"}
  WorldTap -- "己方实体" --> Select["选中实体 / refreshSelection"]
  WorldTap -- "可见敌人" --> Attack["设置 attackTarget\n进入攻击链路"]
  WorldTap -- "地面" --> Move["issueFormationMove\n按陆空海分组移动"]
  Touch --> Drag{"单指拖动空地"}
  Drag -- "超过阈值" --> Box["框选玩家移动单位"]
```

## 3. Agent 迭代与云端验证流程图

读图说明：人工提出目标和最终复核结论；Agent A 负责设计版本化提示词，Agent B 必须基于最新 `origin/main` 在 `main` 上实现、提交并直推，GitHub Actions 生成未加密结果包。Agent C 下载并核对最新 `main` run 的 manifest、JUnit、日志和失败摘要；验收不通过则退回 Agent B 在 `main` 上追加修复 commit 并重新 push，验收通过后再回到人工复核。

```mermaid
flowchart TD
  Human["人工提出目标\n功能、禁止项、验收标准、测试要求"] --> AgentA["Agent A\n分析目标并写实现提示词"]
  AgentA --> Prompt["md/prompt/vX（阶段）/vX.Y（任务）.md\n版本化实现提示词"]
  Prompt --> Sync["Agent B\nfetch origin、切到 main、pull --ff-only origin main"]
  Sync --> Implement["Agent B\n小步实现、更新必要文档、本地轻量检查"]
  Implement --> Commit["main commit\nsubject: 版本号: 简要说明"]
  Commit --> Push["git push origin main\n触发云端验证"]
  Push --> Actions["GitHub Actions ci-results\n静态检查、plutil、generic iOS build"]
  Actions --> Artifact["未加密 CI 结果包\nmanifest、JUnit、xcodebuild.log、failure summary、xcresult"]
  Artifact --> AgentC["Agent C\ngh auth login 后下载最新 run 结果包"]
  AgentC --> Verify["核对 origin/main 最新 commit\nrun id、run attempt、artifact、日志"]
  Verify --> Gate{"验收是否通过"}
  Gate -- "不通过" --> BackB["退回 Agent B\n列出阻塞问题和修复要求"]
  BackB --> Fix["main 追加修复 commit\n再次 push origin main"]
  Fix --> Actions
  Gate -- "通过" --> Docs{"是否需补齐核心文档"}
  Docs -- "需要" --> DocCommit["Agent C 在 main 追加文档 commit\npush 后重新触发 Actions"]
  DocCommit --> Actions
  Docs -- "不需要" --> Review["人工复核\n决定继续下一轮或补充返工"]
  Review --> Human
```
