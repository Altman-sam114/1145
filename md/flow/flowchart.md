# 项目流程图

本文用 Mermaid 图把 `md/flow/flow.md` 的核心逻辑可视化。每张图前都有中文读图说明，便于人工快速检查当前项目运行链路。

## 1. 项目核心逻辑图

读图说明：从 App 启动开始，SwiftUI 只负责承载 SpriteKit；所有游戏运行态进入 `GameScene`。每帧 update 推进各系统，最后更新节点渲染、HUD、小地图和胜负状态。

```mermaid
flowchart TD
  App["DesertFrontlineApp\n创建窗口入口"] --> View["GameView\nGeometryReader + 全屏 SpriteView\n黑色背景兜底并同步视口尺寸"]
  View --> Holder["SceneHolder\n创建非零初始 GameScene\nresizeFill 并跟随窗口尺寸"]
  Holder --> Scene["GameScene.didMove\n初始化世界节点、地图、实体、HUD、相机"]
  Scene --> Init["初始化链路\n地形 -> 地图 -> 控制点 -> 初始部队 -> HUD -> 迷雾"]
  Init --> Loop["GameScene.update 每帧循环\n统一推进游戏状态"]
  Loop --> Build["施工 / 生产\n建筑进度、RAD/SON/GT/SAM/CB、AA Truck、旗点覆盖、BuildOrder、出兵、航母甲板起飞反馈、集结点与面板状态"]
  Loop --> Economy["经济 / 占领\nHQ、油井、旗点收入/视野/覆盖、旗点奖金与占领进度"]
  Loop --> Commands["移动 / 命令\nMOVE青绿落点、AMOV琥珀双环、已知目标ATK红框、海军方向航迹、空军方向投影/84间距/同阵营避让/攻击环站位、HOLD、Carrier guard wing最多2架anchor station/分配组成cue/脱离反馈、已知HQ指引和面板摘要、路径和编队"]
  Loop --> Combat["战斗 / 维修\n未完工攻击结构禁火、SAM/AA 防空与选中空军已知覆盖威胁圈/顶标/摘要、岸防反舰、目标搜索、Carrier guard wing近域威胁优先、有效伤害、空战导弹烟迹/弹体/命中环、航母 wing strike、可见水面舰炮命中水柱、已知潜艇 direct-fire ASW HIT、支援命中潜艇短暴露、击杀 XP、老兵徽章、死亡清理"]
  Loop --> AI["敌方 AI\n补建含声呐浮标、防空阵地和岸防炮、空军压力补防空、已知潜艇压力补 ASW、合法认知 SCAN 巡扫、生产机动防空、长期保留占点队、反夺旗点优先级、旗点防守响应、海岸目标权重、跳过不可生产兵种、支援、混编主攻波次、低血单位撤退回修、受损老兵保护、空闲Carrier警戒翼队、高价值海军护航门槛、attack-move 波次"]
  Loop --> Fog["战争迷雾\n单位/已完工建筑/RAD/脆弱专职 SON/GT/SAM/CB 视野、侦察、潜艇检测、支援命中暴露"]
  Loop --> Mission["任务 / 胜负\n占油、夺旗、海岸资产分项摘要、混编/破生产奖励、已知HQ情报与AMOV面板摘要、HQ 摧毁判定"]
  Build --> Render["SpriteKit 渲染\n浅滩/岸线浪花、Tank履带/炮塔/光学件细化、HEL/JET细化模型与投影、实体节点、特效、进度条"]
  Economy --> Render
  Commands --> Render
  Combat --> Render
  AI --> Render
  Fog --> Render
  Mission --> HUD["HUD / 小地图\nTACT/BUILD/AIR/SEA/SUP五页单排命令条、金钱、队列、生产来源提示、航母甲板/集结/普通翼队组成/GW组成与紧凑绑定站位/接触数类型目标交战状态/多选CV GW组成摘要/HEL-JET CV GUARD组成与距离状态/HOLD Carrier无bound wing也显示anchor范围圈、高价值海军护航状态/缺口类型/半径圈/多选摘要、Mechanic维修反馈/来源提示/范围圈、集结点pending来源摘要、选择/反潜/声呐信息、海岸资产职责/计入状态、海岸任务摘要、声呐覆盖圈、任务、跨页命令高亮、支援按钮缺资产/资金提示、目标面板资产提示、领域化小地图符号/选择外圈/相机框"]
  Render --> HUD
```

## 2. 玩家输入与命令流程图

读图说明：触摸输入会先判断 HUD 和小地图；HUD 可处理控制组保存 / 召回并清理 pending 模式。建筑放置、支援技能、集结点和 attack-move 都是互斥 pending 状态，最后才进入普通选择、攻击或移动；无效世界目标只补短暂拒绝标记，不改变命令合法性或 pending 语义。

```mermaid
flowchart TD
  Touch["玩家触摸输入\nBegan / Moved / Ended"] --> PageCheck{"是否点到 TACT/BUILD/AIR/SEA/SUP 页签"}
  PageCheck -- "是" --> PageSwitch["handleHudPage\n只切换单排动作页并重建HUD\n保留选择/队列/pending状态"]
  PageCheck -- "否" --> HUDCheck{"是否点到当前页 HUD 按钮"}
  HUDCheck -- "是" --> HudAction["handleHudAction\nG1/G2 保存或召回控制组\nHOLD/Carrier guard wing anchor station/分配cue/脱离反馈/近域威胁优先状态、AMOV、生产、支援、AI、重开\n终局AMOV提示已知HQ并刷新面板摘要\npending按钮及所属隐藏页签高亮由状态刷新"]
  HUDCheck -- "否" --> MiniMap{"是否点到小地图"}
  MiniMap -- "是" --> Camera["移动相机到小地图位置"]
  MiniMap -- "否" --> MultiTouch{"是否双指触摸"}
  MultiTouch -- "是" --> PanZoom["相机平移 / 缩放"]
  MultiTouch -- "否" --> Pending{"是否存在 pending 模式"}
  Pending -- "建筑" --> Place["放置预览 / placeStructure\n检查视野、基地/旗点覆盖、地形规则和资金"]
  Pending -- "支援技能" --> Support["executeSupportPower\n检查资金、冷却、资产需求、效果"]
  Pending -- "集结点" --> Rally["setRallyPoint\npending面板显示来源摘要\n生产来源设置出兵目标"]
  Pending -- "AMOV" --> AttackMove["issueAttackMoveOrder\n编队推进并沿途交战\n琥珀AMOV双环落点"]
  Place -- "无效目标" --> Denied["showDeniedMarker\n点击位置短暂红橙拒绝反馈"]
  Support -- "无效目标" --> Denied
  Rally -- "无有效来源" --> Denied
  AttackMove -- "无作战单位" --> Denied
  Pending -- "无" --> WorldTap{"世界点击目标"}
  WorldTap -- "双击己方机动单位" --> TypeSelect["选择当前视野内同 kind 玩家机动单位"]
  WorldTap -- "单击己方实体/建筑" --> Select["选中实体 / refreshSelection"]
  WorldTap -- "可见敌人" --> Attack["至少一个合法攻击者设置attackTarget\n红色footprint-aware ATK框\n必要时提示CV guard released"]
  WorldTap -- "地面" --> Move["issueFormationMove\n按陆空海分组移动\n青绿色MOVE落点\n必要时提示CV guard released"]
  Attack -- "选中单位都不能攻击" --> Denied
  Move -- "无移动单位或集结来源" --> Denied
  Touch --> Drag{"单指拖动空地"}
  Drag -- "超过阈值" --> Box["框选玩家移动单位"]
```

## 3. Agent X 主控迭代与云端验证流程图

读图说明：人工可以用 `agentx:` 给出总目标。Agent X 只负责拆分轮次和判断循环状态，不替代 Agent A/B/C。每个轮次仍由 Agent A 写提示词、Agent B 在 `main` 上实现并 push、GitHub Actions 生成未加密 artifact、Agent C 下载核对最新 `origin/main` run；之后 Agent X 才能判断继续、退回、暂停或完成。

```mermaid
flowchart TD
  Human["人工给 Agent X 总目标\n范围、禁止项、验收标准"] --> AgentX["Agent X\n拆分小轮次并设定停止条件"]
  AgentX --> RoundGoal["本轮目标\n清晰、有限、可验证"]
  RoundGoal --> AgentA["Agent A\n分析本轮目标并写提示词"]
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
  Gate -- "通过" --> XJudge["Agent X 判断\n继续、退回、暂停、完成"]
  XJudge -- "继续下一轮" --> AgentX
  XJudge -- "退回补充" --> BackB
  XJudge -- "暂停等待人工" --> Pause["暂停\n权限、决策、冲突或同因失败"]
  Pause --> Human
  XJudge -- "总目标完成" --> Done["完成\n输出总目标闭环结果"]
```

- v4.81：选中玩家机动单位显示分色命令意图线（攻/移/AMOV/HOLD），只读刷新。

- v4.82：可见命中显示短促伤害飘字，只读、不改结算。

- v4.83：多选共用攻击目标显示 `FOCUS n` 集火标，只读。

- v4.84：选中战列舰/岸防炮显示舰炮射程圈，只读。

- v4.85：分层爆炸特效；多选面板 `FOCUS n Tgt` 摘要。

- v4.86：Tank 分层履带 / 炮塔 / 光学件模型；CI 新增独立 land focus 截图探针。
