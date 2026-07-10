# 项目核心流程文档

`Desert Frontline` 当前核心链路是：SwiftUI 全屏承载 SpriteKit 场景，`GameScene` 在单个实时循环中驱动地图、实体、玩家输入、经济、生产、战斗、AI、战争迷雾、HUD 和胜负状态。

## 1. 当前核心数据流

```text
触摸输入 / HUD 按钮 / AI 计时器
  -> GameScene 状态字段
  -> GameEntity / EntityKind / VeterancyRank / BuildOrder / ControlPoint / SupportPower
  -> 移动、生产、经济、战斗、占领、迷雾、任务、胜负规则
  -> SKNode / SKShapeNode / SKLabelNode 渲染
  -> README、测试规范、更新日志记录当前事实
```

协作验证数据流：

```text
人工单轮目标 / Agent X 总目标
  -> Agent X（可选）拆分轮次目标并调度 Agent A/B/C
  -> Agent A 生成版本化提示词
  -> Agent B 在 main 上实现、本地轻量检查、commit、push origin/main
  -> GitHub Actions 云端 build / 静态检查 / iOS Simulator 启动探针
  -> 未加密 CI 结果包
  -> Agent C 下载并核对 manifest / JUnit / xcodebuild.log / simulator-launch.log / failure summary
  -> Agent X 或人工根据验收结果判断继续、退回、暂停或完成
```

## 2. 当前核心执行流

1. `DesertFrontlineApp` 创建 `GameView`。
2. `GameView` 用 `GeometryReader` 包住全屏 `SpriteView` 挂载 `SceneHolder.scene`，并用黑色背景兜底，避免 SpriteKit 视图尚未铺满时露出系统白屏或空黑屏。
3. `SceneHolder` 先创建非零初始尺寸 `GameScene(size: 1366x1024)`，`scaleMode = .resizeFill`，随后在 SwiftUI 提供有效容器尺寸时同步 `scene.size`，让 HUD、相机 clamp 和 SpriteKit viewport 以真实窗口尺寸布局。
4. `GameScene.didMove(to:)` 初始化 world、map、entity、effect、fog、HUD、camera 节点。
5. 初始化流程依次构建地形、绘制地图、生成控制点、生成初始单位/建筑、布局 HUD、刷新迷雾、刷新 HUD；地图绘制会只读检查水格四个正交邻格，在邻陆水格增加浅水菱形、青白冲洗带和细泡沫线，开阔水格保留稀疏方向波纹，不改变 terrain、海岸建造或寻路语义。
6. `GameScene.update(_:)` 每帧推进施工、生产、支援冷却、经济、占领、维修、移动、战斗、AI、迷雾、死亡清理、任务进度、胜负和 HUD。
7. 触摸事件在 `touchesBegan/Moved/Ended` 中分流到 HUD、迷你地图、双指平移缩放、框选、建筑预览、支援技能目标、集结点、attack-move、选中、移动和攻击。

## 3. 核心状态对象 / 模块

### `EntityKind`

单位和建筑的静态定义来源：名称、短码、域、成本、建造时间、HP、速度、射程、伤害、冷却、视野、占地、生产来源、可生产项、可攻击目标。当前建筑包含 HQ、War Factory、Airfield、Radar Outpost、Sonar Buoy、Guard Tower、SAM Site、Coastal Battery、Shipyard 和 Oil Derrick；Radar Outpost 是普通陆地结构，完工后提供较大静态视野并可作为 `SCAN` 资产；Sonar Buoy 是低成本、脆弱的海岸侦测结构，完工后提供有限静态视野和较大 sonar 检测范围，不攻击、不生产、不赚钱，也不作为 `SCAN` 资产；Guard Tower 是普通陆地防御结构，完工后自动攻击可见 land / air / structure 目标，不攻击 naval / submarine，也不提供声呐；SAM Site 是普通陆地防空结构，完工后只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供声呐；Coastal Battery 是海岸防御结构，完工后只攻击可见水面海军目标，不攻击潜艇，也不提供声呐。AA Truck 是 War Factory 生产的移动陆地防空单位，只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供声呐。

### `GameEntity`

运行态实体：id、kind、faction、hp、destination、path、attackTarget、holdPosition、`guardAnchorCarrierID`、attackMoveDestination、attackTimer、revealedUntil、captureProgress、施工进度、rallyPoint、`veterancyXP`、`killCount` 和各类 SpriteKit 节点。`guardAnchorCarrierID` 用于 HEL/JET 记录当前 Carrier HOLD guard wing 归属；当绑定 Carrier 仍 HOLD 时，移动更新会把该 HEL/JET 的 `holdPosition` 维护到 Carrier 附近稳定站位，战斗目标获取会优先考虑 Carrier 近域内该翼队已知且可攻击的威胁，Carrier HOLD HUD 会用紧凑 `GW ... Hn/Jn Cn` 格式只读显示同一口径的 HEL/JET 组成、去重接触数，并在非零时追加 Air / Sea / Sub / Ground / Mix 类型摘要、`Tgt XXX` 优先接触短码和当前合法交战翼队数 `Eng n`，选中被有效 anchor 绑定的 HEL/JET 时也会只读显示 `CV GUARD`、距 anchor Carrier 的近似距离，以及当前存在合法 Carrier guard contact 时的 `Tgt XXX Air/Sea/Sub/Ground` 优先目标摘要；选中这些 HEL/JET 时会在 anchor Carrier 上显示基于 `carrierGuardThreatRadius` 的只读范围圈，选中玩家 HOLD Carrier 时即使没有绑定翼队也显示该 Carrier 自身同一范围圈，继续复用普通 HOLD 回位、警戒、迷雾和 `canAttack` 链路，不新增巡逻、完整 CAP、截击状态机或战斗加成。

`veterancyRank` 由 XP 计算得到，不保存第二份等级状态；`veterancyNode` 作为实体节点子节点显示非 Recruit 单位的老兵徽章，并随实体迷雾隐藏。

### `BuildOrder`

生产队列项：产品、阵营、来源建筑/航母、总时长、剩余时间。`updateBuildOrders(dt:)` 完成出兵，`productionSource(...)` 决定来源。

### `BattlefieldControlPoint`

前线旗点状态：阵营、占领进度、占领方和对应节点。已占领旗点提供持续收入、视野和有限建造覆盖，归属实际变化时给新归属方一次性占领奖金，并影响任务阶段。

### `SupportPower`

支援技能定义：侦察、区域维修、空袭、海军炮击。包含成本、冷却、半径、伤害/维修量和资产需求。`SCAN` 需要 operational HQ 或 Radar Outpost；未完工 Radar Outpost 不满足资产需求，Sonar Buoy 不计入 `SCAN` 资产。支援按钮 subtitle 的显示优先级是冷却秒数、具体缺失资产短码、资金短缺金额、价格；缺资产短码复用 `supportAssetRequirementLabel(for:)`，显示 `need HQ/RAD`、`need HQ/MECH`、`need AF/CV` 或 `need BB/CV`；资产满足但资金不足时显示 `need $shortfall`；支援 pending 选择信息面板的资产行复用 `hasOperationalSupportAsset(for:faction:)` 显示 `Asset ready` 或 `Need`，执行链路仍由 `supportIssue(for:faction:)` 约束，不改变费用、冷却、资产需求或效果。

### `HudAction`

底部命令条动作：选军、`G1` / `G2` 控制组保存与召回、`HOLD`、`AMOV` attack-move、生产、集结点、基地建造、支援技能、AI 难度、HQ 聚焦、重开 skirmish。

### `AIDifficulty`

AI 参数：指挥间隔、收入加成、每轮建造数、进攻组规模、支援技能消费保留和支援阈值。

### `MissionStage`

自动任务阶段：占油、夺旗、建立海岸据点、混合军种、摧毁 Red 生产、摧毁 Red HQ。建立海岸据点阶段由 `coastalAssetCount(for:)` 统计己方存活且已完工的 Shipyard、Sonar Buoy 和 Coastal Battery，未完工建筑不计入；任务详情用 `coastalAssetBreakdown(for:)` 显示同一 operational 口径下的 `SY` / `SON` / `CB` 分项摘要，但完成条件仍是任意 2 个 coastal assets；单选这三类海岸资产时，选择信息面板也显示职责摘要和 `Secure Coast: counted/pending/not counted` 状态，仍只把 Blue 存活且 operational 的海岸资产视为 counted，不改变任务计数；`missionReward(for:)` 当前在建立海岸据点首次完成时通过 `changeMoney(for: .player, by: 600)` 发放 `$600`，在混合军种首次完成时发放 `$800`，在摧毁 Red 生产首次完成时发放 `$900`，依赖 `completedMissionStages` 防止重复发放。终局 `Destroy Red HQ` 详情只在 Red HQ 满足 `isKnownToFaction(..., observer: .player)` 时显示 HP；同一已知边界也用于 `AMOV` 的短暂 HQ 攻击指引和 armed 选择面板摘要，未知时只提示侦察或推进，不泄露隐藏 HQ 信息。

## 4. 关键运行流程

### 输入与命令

- HUD 点击先于世界点击处理。
- 双指触摸进入相机平移/缩放。
- 单指拖动可框选玩家移动单位。
- 建筑放置、支援技能、集结点和 attack-move 都是 pending 模式；进入新模式时必须清理冲突模式。
- 底部 HUD 直接暴露 `HOLD` 和 `AMOV` 基础军队命令；`HOLD` 按钮 subtitle 会根据当前玩家移动单位选择只读显示 `guard`、选中 Carrier 时的 `CV GW` 或选中已绑定 Carrier guard HEL/JET 时的 `CV rel`，不改变点击处理；对选中 Carrier 下达 `HOLD` 时，Carrier 本身按普通 HOLD 处理，并把同阵营、存活、operational、非结构、位于 `highValueNavalEscortRadius` 内最近的最多 2 架 Helicopter / Fighter 一次性设为 HOLD guard wing，同时写入该 Carrier id 作为 guard anchor；本次 HOLD 后若某个玩家 Carrier 实际拥有绑定翼队，会在该 Carrier 甲板位置显示短暂 `GW Hn/Jn` 分配 cue，顶部成功消息会按最终绑定状态只读显示聚合 `Guard wing n Hn/Jn`，缺员时追加 `Need n`，即使没有绑定到 wing 也会对 Carrier HOLD 显示 `Guard wing 0 Need n`；该反馈只读复用现有 SpriteKit deck pulse 和消息链路，不写入命令、迷雾或战斗状态；绑定 Carrier 仍 HOLD 时，这些 HEL/JET 会把自身 `holdPosition` 维护到 Carrier 附近稳定站位，并在没有当前目标时优先选择 Carrier 近域内已知、可攻击且仍满足自身 HOLD 站位警戒半径的威胁，然后才回落到普通 HOLD 目标搜索；普通移动、AMOV、直接攻击或普通 HOLD 会清理 HEL/JET 旧 guard anchor，并在玩家成功命令消息中追加 `CV guard released n Hn/Jn.` 短反馈；ordinary HOLD 会在可能的 Carrier 重新绑定后再统计最终脱离 wing 及组成，避免把同次重新绑定的 wing 误报为 released；再次 Carrier HOLD 可改写为新 anchor；`BASE`、`RLY`、`AMOV` 和支援技能按钮的高亮由 `pendingConstructionKind`、`isSettingRallyPoint`、`isSettingAttackMove`、`pendingSupportPower` 直接推导，只提供等待地图目标的视觉反馈，不改变 pending 优先级或命令语义；`RLY` pending 时选择信息面板显示可设置来源数量、land/air/naval 类型、rally set/unset 摘要和 `Tap map to set rally`；终局 `.destroyHQ` 阶段按下 `AMOV` 时，只有玩家已知 Red HQ 才会短暂标出 HQ 并提示可向 HQ 或地图下达 attack-move，armed 选择面板也只在同一已知条件下显示 Red HQ HP 和最近选中作战单位的 approximate 距离。
- HUD 单击 `G1` / `G2` 会召回对应控制组中仍存活的玩家机动单位，并过滤死亡、移除、结构或非玩家 ID；HUD 双击 `G1` / `G2` 会把当前玩家机动单位选择保存到对应组，空选择不会覆盖旧组。
- 使用控制组会清理 pending 建筑、支援技能、集结点、attack-move 和 construction preview；召回空组不会清空当前选择；`SKRM` 重开会清空两个控制组。
- 世界点击优先处理 pending 支援、pending 建筑、pending 集结点、pending attack-move，然后才处理选中、攻击或移动。
- pending 建筑、支援、集结点、attack-move 和普通攻击 / 空地命令的无效世界目标会通过 `showDeniedMarker(at:reason:)` 在点击位置显示短暂红橙拒绝标记；该反馈只补充 `showMessage(...)`，不改变合法性、pending 清理、迷雾边界或执行优先级。
- 普通世界点击中，双击玩家己方机动单位会选择当前摄像机视野内同 `kind` 的己方存活机动单位；建筑、敌方、中立和屏幕外同类不纳入该选择。

### 经济与生产

- HQ、已占领油井、已占领旗点提供持续收入；旗点归属实际变化时，新归属方通过共享 `changeMoney(for:by:)` 获得一次性占领奖金。
- 建筑覆盖由己方已完工结构和己方已占领旗点提供；旗点覆盖范围小于结构覆盖范围。玩家建造仍需要目标位置可见，SAM Site 走普通陆地结构规则，Shipyard、Sonar Buoy 和 Coastal Battery 仍需要海岸，Oil Derrick 仍需要油田，建筑不能压住旗点中心。
- 建筑只有 `isOperational` 后才能生产、赚钱、提供基地覆盖、贡献视野、提供支援技能资产或使用自身武器。
- 陆军来自 War Factory，AA Truck 作为移动防空陆军也来自 War Factory；空军来自 Airfield 或 Carrier，海军来自 Shipyard。`HMV` / `AA` / `TANK` / `ART` / `MECH` 按钮 subtitle 复用 `productionSource(for:faction:)` 显示当前 `WF` 来源或 `need WF`，`HELI` / `JET` 按钮 subtitle 同样显示当前 `AF` / `CV` 来源或 `need AF/CV`，`SHIP` / `SUB` / `CV` 按钮 subtitle 同样显示 `SY` 来源或 `need SY`；这些都是只读来源提示，不改变队列、费用或来源选择。
- Carrier 是移动空军生产平台，可生产 Helicopter/Fighter、使用空军集结点，并在甲板出机时显示短暂 launch 反馈；单选 Carrier 时，选择信息面板会显示 deck 可生产 Helicopter/Fighter、rally set/unset、当前队列状态、附近 HEL/JET 空中翼队 readiness 和附近 escort 数量 / 需求，Carrier 未 HOLD 时翼队达标显示 `Wing x/2 OK Hn/Jn`、不足显示 `Wing x/2 Need n Hn/Jn`，其中 `Hn` / `Jn` 只读显示附近 Helicopter / Fighter 组成，0 数量类型可省略；Carrier HOLD 时改为只把附近仍 HOLD 且 `guardAnchorCarrierID` 等于该 Carrier id 的 HEL/JET 计入紧凑 `GW x/2 OK Hn/Jn C0`、`GW x/2 Need n Hn/Jn C0` 或非零接触时的 `GW x/2 OK Hn/Jn Cm Air/Sea/Sub/Ground/Mix Tgt XXX Eng n` / `GW x/2 Need n Hn/Jn Cm Air/Sea/Sub/Ground/Mix Tgt XXX Eng n`，其中 `Hn` / `Jn` 只读显示当前绑定 Helicopter / Fighter 组成，0 数量类型可省略，`Eng n` 只在非零时显示并统计当前 `attackTarget` 仍满足 `isCarrierGuardContact(...)` 的绑定 HEL/JET 数量；玩家 Carrier HOLD 和 Red AI 自动 guard wing 都以每艘 Carrier 最多 2 架作为同一需求口径；多选含 HOLD Carrier 时，HOLD 状态行会用紧凑 `CV GW x/y OK/Need Hn/Jn Cn Air/Sea/Sub/Ground/Mix Tgt XXX Eng n` 聚合选中 HOLD Carrier 的绑定翼队总数、需求、HEL/JET 组成、去重合法接触数、非零接触类型、优先接触短码和非零交战翼队数，`C0` 时不追加类型或目标；Carrier HOLD 成功绑定翼队时会显示短暂 `GW Hn/Jn` 甲板 cue，顶部成功消息会显示聚合 `Guard wing n Hn/Jn.` 并在缺员时追加 `Need n`，没有绑定到 wing 时也会显示 `Guard wing 0 Need n`；绑定翼队在 Carrier 仍 HOLD 时会维护 Carrier 附近稳定站位，单选这些 HEL/JET 时显示 `CV GUARD Dn` anchor 距离并在 anchor Carrier 上显示 guard anchor 范围圈；选中玩家 HOLD Carrier 时即使没有绑定翼队也显示自身 guard anchor 范围圈；多选这些 HEL/JET 且未选中 HOLD Carrier 时显示紧凑 `CV GUARD n Hn/Jn Dm` 摘要并显示所有有效 anchor Carrier 范围圈，并优先处理 Carrier 近域内已知可攻击威胁，escort 达标时显示 `Escort x/2 OK`，不足时显示 `Escort x/2 Need n Air/Sea/Ground/Mix` 这类只读缺口类型提示；多选含 Carrier / Battleship 时会显示高价值海军护航满足摘要，不足时同样在 `Need n` 后追加 Air / Sea / Ground / Mix 缺口类型；选中玩家 Carrier / Battleship 时会显示暖色 escort radius ring，`HELI` / `JET` 按钮也会在 Carrier 是实际来源时显示 `CV`，这些不改变 `BuildOrder`、生产来源、集结点、AI、自动巡逻、完整 CAP 或截击状态机。

### 移动与战斗

- 陆、空、海按 `Domain` 使用不同移动和地形规则；空军直飞，陆海需要路径点。
- 普通移动会清理攻击/hold/attack-move 意图；若本次玩家成功移动会让有效绑定的 Carrier guard HEL/JET 脱离 anchor，成功消息只读追加 release 数量和 HEL/JET 组成。
- `HOLD` 记录 `holdPosition`，单位会在警戒半径内交战并回位；当本次 HOLD 包含玩家 Carrier 时，附近己方 operational Helicopter / Fighter 也会被设置为自身当前位置的 `holdPosition`，写入 Carrier id 到 `guardAnchorCarrierID`，清理原攻击、attack-move、destination 和 path，复用同一 HOLD 警戒链路；该 anchor 会在绑定 Carrier 仍 HOLD 时把翼队 `holdPosition` 维护到 Carrier 附近稳定站位，并让无当前目标的翼队优先选择 Carrier 近域内已知、敌对、可攻击且仍在自身 HOLD 警戒半径内的威胁；后续普通移动、AMOV、直接攻击或普通 HOLD 会清理旧 anchor，玩家成功消息会报告最终释放的 bound wing 数，不新增巡逻、完整 CAP、截击状态机或战斗加成。
- `AMOV` 记录 `attackMoveDestination`，编队推进并沿途寻找可见敌人；若本次玩家成功 AMOV 会让有效绑定的 Carrier guard HEL/JET 脱离 anchor，成功消息只读追加 release 数量和 HEL/JET 组成。
- Carrier guard wing 近域威胁优先由 `carrierGuardPriorityTarget(for:)` 在 `updateCombat(dt:)` 的目标获取阶段执行；它只返回候选目标，不直接设置 destination、不改变 `fire(attacker:target:)`，并继续要求目标满足 `isKnownToFaction(...)`、`canAttack(...)`、Carrier 近域半径和翼队 HOLD 站位警戒半径；Carrier HOLD HUD 的紧凑 `Cn` 接触数、Air / Sea / Sub / Ground / Mix 类型摘要、`Tgt XXX` 优先接触短码和非零 `Eng n` 交战翼队数复用同一合法性判断，`C` 按目标 id 去重，`Eng` 按当前拥有合法 `attackTarget` 的绑定 HEL/JET 数量计数，`Tgt` 只镜像现有优先级、Carrier 距离和 entity id 排序，只读显示，不写入 `revealedUntil`、迷雾集合、攻击目标或命令状态。
- `updateCombat(dt:)` 会先跳过并清理未完工攻击型结构的攻击目标和计时器；完工结构与移动单位再选择目标、用老兵等级计算有效冷却并调用 `fire(attacker:target:)`。
- Guard Tower 共享 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击 land / air / structure，不攻击 naval / submarine。
- SAM Site 共享 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供 sonar。
- Coastal Battery 共享 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击可见水面海军目标，不攻击潜艇，不提供 sonar，也不触发潜艇暴露。
- AA Truck 共享移动单位 `canAttack(_:)`、目标搜索、迷雾合法性和 `fire(attacker:target:)` 链路，只攻击可见 air 目标，不攻击 land / naval / submarine / structure，也不提供 sonar。
- `fire(attacker:target:)` 使用有效伤害结算直接开火；Carrier 开火会显示短暂 wing-strike 视觉但仍走同一直接火力结算；直接火力命中玩家潜艇或玩家已知敌方潜艇时，只显示短暂 `ASW HIT` / 水下冲击圈反馈，不改变伤害、侦测或暴露；击杀发生时为可移动作战单位增加 `killCount` 和 XP，XP 推动 Recruit / Hardened / Veteran / Elite 等级，并更新头顶徽章。
- 支援技能伤害仍走 `applySupportDamage(...)`，没有虚拟击杀者，因此不会把支援技能击杀计入任何单位 XP；`AIRS` / `BARR` 真实命中潜艇时会短暂设置该潜艇的 `revealedUntil`。
- Mechanic 自动维修仍由 `updateRepair(dt:)` 统一执行：寻找同阵营、存活、非自身、受损的最近目标，目标距离小于 95 时按每秒 22 修复并偶发 repair spark；选择面板、受损单位维修来源提示和维修范围圈只读复用该范围，不改变目标选择、维修量、AI、支援或移动 / 战斗规则。

### 迷雾与隐身

- 玩家可见性由单位、已完工建筑有效视野、控制点视野和支援侦察共同决定；Radar Outpost 完工后提供较大静态侦察范围，Sonar Buoy 完工后提供有限普通视野但较大的 sonar 检测范围，Guard Tower、SAM Site 和 Coastal Battery 完工后提供普通建筑视野，Veteran 和 Elite 单位会在基础视野上获得轻量加成。
- 敌方实体只有满足 `isKnownToFaction(..., observer: .player)` 时才应被玩家看见或成为合法交互目标。
- 潜艇依赖 `revealedUntil` 和声呐检测；完工 Sonar Buoy 可作为静态 sonar sensor，结构类 sonar 未完工不生效，且不会写入潜艇 `revealedUntil`。开火会暴露，伤害型支援技能真实命中潜艇时也会短暂暴露。`SCAN` 仍使用 8 秒区域侦察暴露潜艇，未命中的 `AIRS` / `BARR` 不暴露潜艇。直接火力命中潜艇的 `ASW HIT` 反馈只在玩家潜艇或玩家已知敌方潜艇上显示，不能泄露隐藏敌方潜艇位置。玩家选中 active sonar sensor 时显示的 contact count 只读统计 `isKnownToFaction(..., observer: .player)` 已成立且位于该 sensor `sonarRange` 内的敌方潜艇；多选含玩家 active sonar sensor 时，编队 `Ctc n` 摘要只读统计玩家已知、位于至少一个已选玩家 sonar sensor 范围内的敌方潜艇，并按实体 id 去重；玩家单选己方潜艇时，状态行只会在临时暴露或玩家已知敌方 active sonar sensor 覆盖时提示，隐藏敌方 sensor 不会通过 HUD 泄露；这些摘要和状态不写入 `revealedUntil` 或任何迷雾集合。

### AI

- AI 按 `AIDifficulty` 周期执行。
- AI 会赚钱、补生产建筑、Radar Outpost、Sonar Buoy、Guard Tower、SAM Site 和 Coastal Battery、生产含 AA Truck 的混合陆海空单位、占油/旗、重建、使用支援技能、基地被打时拉防守单位，并在 Red 已占旗点被玩家可感知地争夺时拉附近非 reservation 作战单位防守。空闲 Red Carrier 会在指挥周期内把附近空闲 Helicopter / Fighter 绑定为最多 2 架 guard wing，复用现有 Carrier HOLD anchor、站位保持和近域已知威胁优先链路，不新增 CAP、巡逻、截击状态机或 AI 作弊侦察。
- AI 在常规生产前会按 Red 当前认知评估玩家空军压力；该认知只来自 Red 存活单位、Red 已完工建筑和 Red 已占旗点视野内的玩家空军，不复用玩家 `visibleTiles`，也不全图作弊。若已知玩家空军达到阈值且 Red 现有 / 已排队防空不足，AI 每个指挥周期最多额外尝试排一个 AA Truck 或 Fighter。
- AI 也会按 Red 当前认知评估玩家潜艇压力；已知潜艇必须同时满足 `isKnownToFaction(..., observer: .enemy)` 和 Red 单位、已完工建筑或已占旗点视野边界。若 Red 已知玩家潜艇数量超过现有 / 已排队 ASW 覆盖，AI 每个指挥周期最多额外尝试排一个 Helicopter、Fighter、Submarine、Battleship 或 Carrier；Fighter 计为 ASW attacker 但不是 sonar sensor，Sonar Buoy 计为 sonar sensor 但不是 ASW attacker。
- AI 动态防空和动态 ASW 仍走 `canQueueBuild(...)`、`queueBuild(...)` 和 `productionSource(...)`，缺资金、缺 operational War Factory / Airfield / Carrier / Shipyard 或队列来源时自然跳过，不直接生成单位。
- AI 使用 `SCAN` 做反潜侦察时，精确目标只来自 Red 已知玩家潜艇；已知条件与动态 ASW 压力一致，需要同时满足 `isKnownToFaction(..., observer: .enemy)` 和 Red 单位 / 已完工建筑 / 已占旗点视野边界。没有已知玩家潜艇时，Red 只能从己方 operational sonar sensor 或已占旗点周边生成水域 / 海岸巡扫热点，不能读取隐藏玩家潜艇的真实坐标、距离或数量来决定 `SCAN` 落点。
- AI 常规生产按难度 build pattern 轮转；每个生产槽从 `aiBuildCursor` 开始扫描当前有 operational 生产来源且资金足够的单位，跳过暂时缺 War Factory / Airfield / Shipyard / Carrier 或资金不足的项，成功后仍通过 `queueBuild` / `productionSource` 排队，未完工建筑不能生产。该轮转会穿插陆军核心、AA、空军和海军支援，以配合后续混编主攻波次。
- AI 占点分配只使用当前空闲陆地单位；被派去油井或旗点的 runner 会登记为占点 reservation，直到目标归 Red、目标消失、单位死亡、单位不再有效或被外部战斗状态打断才释放。有效 reservation 会让该 runner 即使到达占领半径且 `destination` 已清空，也不会被再次分配为其他占点队或被常规主攻 attack-move 波次抢走；`SKRM` 重开会清空所有 reservation。
- AI 选择旗点目标时会按玩家已占、玩家正在占领和距离 Red 基地的组合评分排序；玩家控制或争夺中的旗点优先于中立扩张，Red 已占但正在被玩家夺取的旗点也会进入候选，距离仍作为次级排序。占旗 runner 的 `excludingReserved` 调用仍会跳过已有 reservation 的旗点目标。
- 玩家单位开始夺取 Red 已占旗点时，AI 会先用 Red 自己的单位、已完工建筑或已占旗点视野确认抢点单位；确认后最多调附近少量可攻击该单位的非 reservation 作战单位防守，并用独立 cooldown 节流，`SKRM` 重开会重置该 cooldown。
- AI 建造选点可把已占领旗点作为前线 anchor，但最终仍走 `constructionIssue(...)`，不能绕过 Sonar Buoy / Shipyard / Coastal Battery 的海岸要求、油田、陆地、碰撞或覆盖规则。
- AI 进攻使用 attack-move 波次，目标包括旗点、油田、生产建筑、侦测结构、防御结构、海岸基础设施和 HQ；Sonar Buoy、Radar Outpost、SAM Site 会作为有价值结构参与战略目标排序。Red 拥有可攻击结构的 operational 海军压力时，会提高已知玩家 Shipyard、Sonar Buoy 和 Coastal Battery 的战略目标权重，Red 海军单位也会更重视这些已知且可攻击的海岸目标；该权重不绕过 `isKnownToFaction(...)` 或 `canAttack(...)`。Red routine assault wave 会先尝试把前排、防空、远程、空军和海军支援混入 provisional wave；在此之前空闲 Red Carrier 可绑定附近空闲 HEL/JET 作为 guard wing，已绑定 Red Carrier guard wing 的 HEL/JET 平时会保留护航职责并被排除出 ordinary routine assault candidates。若 anchor Carrier 自身进入 provisional wave，本轮 assault candidates 会追加该 Carrier 当前有效、同 anchor、无 attack target、无 attack-move 且未撤退的 bound HEL/JET，即使这些 wing 正在返回 guard station，让它们可作为 escort 参与高价值海军门槛；最终只有 anchor Carrier 也保留在 accepted wave 内时，这些 bound wing 才会随同 `issueFormationMove(... attackMove: true)` 出击，否则继续留在 guard anchor。Red AI 再把低血作战单位撤向最近 Mechanic 或 Red 基地锚点回修，把低血 Veteran / Elite 机动战斗单位以及缺少本轮 escort 或足够混合波次规模的 Battleship / Carrier 留在主攻外，避免高价值单位孤立或带伤出击；满足 HP 与护航门槛时它们仍会随后续波次推进。玩家单选 Battleship / Carrier 时也会显示只读 `Escort x/y OK` 或 `Escort x/y Need n` 护航状态，但不改变 Red AI 门槛或玩家命令。Red `REPR` 支援评分会偏向低血 Veteran / Elite 和正在撤退回修的作战单位，但不改变实际维修量、费用、冷却或玩家手动支援。
- Red routine assault wave 成功下发后，会先按 `isKnownToFaction(..., observer: .player)` 过滤出玩家已知的 wave 子集；若该子集非空，则记录 `lastEnemyAssaultWaveSummary` 和时间戳，HUD 的 Red 状态行用 `R# F# Seen n Lx/Ax/Nx` 显示最近可感知主攻波子集的宏观构成，并在非零时追加 `CVc`、`Hh`、`Jj`；`n` 是玩家已知子集数量，不是完整 wave 总规模；该摘要约 12 秒后过期，过期后恢复显示 AI 难度。该摘要只来自已经下发且玩家已知的 wave 单位，不包含目标坐标、隐藏单位位置、隐藏单位组成、完整 wave 数量或额外侦察信息，`SKRM` 重开会清空。

### HUD / 小地图

- HUD 每帧由 `updateHUD()` 汇总金钱、收入、队列、任务、兵力、AI 状态、选择信息和按钮状态。
- AI 状态行默认用 `R# F# AI ...` 显示 Red 兵力、旗点和难度；Red routine 主攻波成功下发且至少一个 wave 单位对玩家已知后，难度位置会临时替换为最近可感知 wave 子集的 `Seen n Lx/Ax/Nx` 短构成摘要，用于提示玩家 Red 已暴露推进部队的混编规模和 CV / HEL / JET 参与情况，约 12 秒后恢复难度显示；`Seen n` 只代表玩家已知子集数量，不代表完整主攻波规模。
- 任务面板在 `Secure Coast` 阶段显示 operational coastal asset 总进度，并用 `SY` / `SON` / `CB` 摘要显示玩家已完工 Shipyard、Sonar Buoy 和 Coastal Battery 数量；该摘要只来自玩家己方已完工存活建筑，不改变任务条件、奖励或 AI。
- `G1` / `G2` subtitle 显示 `empty` 或当前 live 玩家机动单位数量；控制组只保存实体 ID，不保存单位快照、命令、位置或状态。
- `layoutHUD()` 重建按钮后、`updateHUD()` 刷新 subtitle 后都会按当前 pending 字段刷新按钮 stroke/glow 高亮，`HOLD` subtitle 按当前玩家移动单位选择显示 `guard` / `CV GW` / `CV rel`，`AMOV` subtitle 默认为 `push`，但当前可战斗移动单位选择包含已绑定有效 Carrier guard anchor 的 HEL/JET，或包含有 bound guard wing 的玩家 HOLD Carrier 时只读显示 `CV rel`，预告 attack-move 会释放相关 Carrier guard 关系而不改变实际 AMOV 执行、release feedback 或 guard anchor 清理语义，陆军生产按钮显示 `WF` 来源或 `need WF`，空军生产按钮显示 `AF` / `CV` 来源或 `need AF/CV`，海军生产按钮显示 `SY` 来源或 `need SY`，支援技能按钮在冷却中显示秒数，未冷却但缺少 operational asset 时显示具体缺失资产短码，资产满足但资金不足时显示短缺金额，资产和资金都满足时显示价格，按钮命中区域保持原逻辑。
- 选择信息来自 `singleSelectionInfo(...)`、`groupSelectionInfo(...)` 或 pending 命令摘要，会显示有效攻击/视野、ASW attack capability、active sonar range、玩家 active sonar sensor 范围内已知敌方潜艇 contacts、Mechanic repair range 和范围内受损友方目标数、受损玩家非 Mechanic 机动单位的最近 Mechanic 来源提示、玩家潜艇 temporary detected / known sonar contact / no known contact 状态、老兵等级、XP、击杀数、多选 ASW 数量、sonar asset 数量 / 最大范围、玩家多选 active sonar sensor 的去重已知敌方潜艇 `Ctc n` 摘要和多选等级分布；单选受损玩家机动单位的维修来源提示只在没有 Submarine、Mechanic、Carrier、AMOV 或 HOLD 等更高优先级状态时显示，并只读报告 `MECH in range`、`Need MECH` 或最近 Mechanic 距离；单选 Carrier 会用专用行显示 deck 可生产 Helicopter/Fighter、rally set/unset、当前队列状态、未 HOLD 时的 `Wing x/2 OK Hn/Jn` 或 `Wing x/2 Need n Hn/Jn` 空中翼队 readiness，`Hn` / `Jn` 只读显示附近 Helicopter / Fighter 组成，0 数量类型可省略；HOLD 时的真实紧凑 `GW x/2 OK Hn/Jn C0`、`GW x/2 OK Hn/Jn Cm Air/Sea/Sub/Ground/Mix Tgt XXX Eng n`、`GW x/2 Need n Hn/Jn C0` 或 `GW x/2 Need n Hn/Jn Cm Air/Sea/Sub/Ground/Mix Tgt XXX Eng n`，其中 `Hn` / `Jn` 只读显示当前绑定 Helicopter / Fighter 组成，0 数量类型可省略，`Eng n` 只在非零时显示，以及 `Escort x/2 OK` 或 `Escort x/2 Need n Air/Sea/Ground/Mix`，单选 Battleship 会显示 `Escort x/1 OK` 或 `Escort x/1 Need n Air/Sea/Ground/Mix`；单选已被有效 Carrier guard anchor 绑定的 HEL/JET 会在普通 HOLD 行位置显示 `CV GUARD Dn`，当前有合法 Carrier guard contact 时追加 `Tgt XXX Air/Sea/Sub/Ground`，随后显示 `Guard ...`，并在 anchor Carrier 上显示 guard anchor 范围圈；单选玩家 HOLD Carrier 时即使没有绑定翼队也显示自身 guard anchor 范围圈；多选这些 HEL/JET 且未选中 HOLD Carrier 时会在 HOLD 行显示 `CV GUARD n Hn/Jn Dm` 紧凑摘要，当前选中 guard wing 存在合法 Carrier guard contact 时追加 `Tgt XXX Air/Sea/Sub/Ground`，并显示所有有效 anchor Carrier 范围圈；多选含 HOLD Carrier 时会在 HOLD 行显示 `CV GW x/y OK/Need Hn/Jn Cn Air/Sea/Sub/Ground/Mix Tgt XXX Eng n` 紧凑聚合摘要，`Hn` / `Jn` 聚合绑定翼队组成，`C` 按目标 id 跨选中 HOLD Carrier 去重，非零接触会追加 Air / Sea / Sub / Ground / Mix 类型摘要和现有优先规则下的 `Tgt XXX` 目标短码，非零 `Eng` 统计当前 `attackTarget` 仍满足 `isCarrierGuardContact(...)` 的绑定 HEL/JET 数量；玩家对这些有效绑定 wing 成功下达移动、AMOV、直接攻击或 ordinary HOLD 且最终脱离 anchor 时，顶部成功消息只读追加 `CV guard released n Hn/Jn.`；多选含 Carrier / Battleship 且未显示 HOLD / AMOV 状态时，会显示高价值海军护航满足摘要，不足时显示 `HV Navy x/y escorted  Need n Air/Sea/Ground/Mix`；escort 状态只读统计同阵营、存活、operational、非结构、可攻击、非 Battleship / Carrier 的附近单位，并用同一合法 escort 集合生成 Air / Sea / Ground / Mix 缺口类型提示；Carrier wing readiness / guard wing 统计同阵营、存活、operational、非结构、Helicopter / Fighter、位于 `highValueNavalEscortRadius` 内的附近空军，其中 guard wing 还要求该空军当前 `holdPosition != nil` 且 `guardAnchorCarrierID` 等于当前 Carrier id，`C` 只读统计这些绑定翼队可处理且玩家/阵营已知的去重近域威胁，并在非零时按同一去重集合显示 Air / Sea / Sub / Ground / Mix 类型摘要和现有优先规则下的 `Tgt XXX` 目标短码，非零 `Eng` 只读统计这些绑定翼队中当前 `attackTarget` 仍满足 `isCarrierGuardContact(...)` 的 HEL/JET 数量，单选和多选 bound HEL/JET 的 `Tgt` 都通过 `carrierGuardPriorityTarget(for:)` 重新计算当前合法优先 contact，不读取 stale `attackTarget`，绑定 guard wing 会在 Carrier 仍 HOLD 时维护附近稳定站位，选中玩家 Carrier / Battleship 时额外显示独立暖色 escort radius ring，不改变 AI 护航门槛、生产、集结点、自动巡逻、拦截或迷雾合法性；单选 Shipyard、Sonar Buoy 或 Coastal Battery 会显示海岸资产职责和 `Secure Coast: counted/pending/not counted` 状态；支援 armed 时会显示 cost/cooldown、ready 秒数、半径效果和 `Asset ready` / `Need` 资产状态，该状态只读并复用 `hasOperationalSupportAsset`，不改变 `supportIssue` 或执行效果；`RLY` armed 时会按 `selectedPlayerRallyFactories()` 和 `rallyPoint` 只读显示来源数量、land/air/naval 类型、set/unset 摘要和地图点击提示，不改变 rally 执行、生产来源、出兵、AI 或移动路径；`AMOV` armed 且处于终局 `.destroyHQ` 时，多选信息只会在 `playerKnownEnemyHQ()` 成功时显示 Red HQ HP 和 nearest approximate 距离；这些 HUD 文案用 `canAttack(.submarine)` 表达反潜攻击能力，用 `EntityKind.hasSonar` 与 `sonarRange(for:)` 表达 sonar sensor，不改变声呐检测、潜艇暴露或迷雾合法性。
- 玩家选中的 active sonar sensor 会按 `sonarRange(for:)` 在战场上显示声呐覆盖圈；玩家选中的 Carrier / Battleship 会按 `highValueNavalEscortRadius` 显示护航半径圈；玩家选中的 Mechanic 会按 95 自动维修范围显示维修范围圈；玩家选中的 bound Carrier guard HEL/JET 会在有效 anchor Carrier 上按 `carrierGuardThreatRadius` 显示 guard anchor 范围圈；玩家选中的 HOLD Carrier 即使没有绑定翼队也会显示自身 guard anchor 范围圈；多选显示多个，未完工 Sonar Buoy、敌方 sensor、敌方高价值海军、敌方 Mechanic、未绑定或 anchor 无效的飞机、非 HOLD Carrier 和未选中单位不显示 guard anchor 范围圈。覆盖圈只是 selection-derived visual，位于 fog 语义之下，不改变 `visibleTiles`、`exploredTiles`、`supportRevealTiles`、潜艇检测、escort 统计、guard contact 统计、维修目标选择、AI 或目标合法性。
- 小地图显示地形、控制点、可见单位和相机框，点击可跳转相机；实体符号按领域区分为结构方块、陆军圆点、空军三角和海军菱形，潜艇使用低填充空心菱形，Battleship / Carrier 使用更醒目的描边，当前 `selectedIDs` 实体增加高对比外圈。敌方符号仍先经过 `isKnownToFaction(..., observer: .player)`，不会借小地图泄露迷雾单位或未侦测潜艇。

## 5. 用户入口

- App 入口：`DesertFrontlineApp`
- 游戏视图：`GameView`
- 游戏场景：`GameScene`
- 玩家主要操作：点击选择、双击视野内同类机动单位、拖框、点击移动/攻击、HUD 命令、双指移动缩放、点击小地图、`SKRM` 重开。

## 6. 前端 / 数据层 / 模型层 / 测试层关系

- 前端显示：SpriteKit 节点和 SwiftUI `SpriteView`。
- 数据/状态层：`GameScene` 字段、`GameEntity`、`BuildOrder`、`BattlefieldControlPoint`。
- 模型层：`EntityKind`、`VeterancyRank`、`SupportPower`、`HudAction`、`AIDifficulty`、`MissionStage`。
- 规则层：`GameScene` 内的 update、command、build、combat、AI、fog、victory 系列函数。
- 测试层：默认本地轻量检查加 GitHub Actions 云端 generic iOS build 结果包；人工明确要求时补本机 `xcodebuild` 和设备/模拟器检查，规范见 `md/test/test.md`。

## 7. 云端协作验证流

- 角色召唤：`agenta` / `a:` / `A:` 召唤 Agent A，`agentb` / `b:` / `B:` 召唤 Agent B，`agentc` / `c:` / `C:` 召唤 Agent C，`agentx` / `x:` / `X:` 召唤 Agent X；无前缀时按普通 Codex 任务处理。
- Agent X 是主控调度角色，接收人工总目标后拆分小轮次，但不直接替代 Agent A、Agent B 或 Agent C。
- Agent X 的标准闭环是：拆分本轮目标 -> 要求 Agent A 写版本化提示词 -> Agent B 实现并 push -> GitHub Actions 生成 artifact -> Agent C 下载验收 artifact -> Agent X 判断继续、退回、暂停或完成。
- Agent X 每轮都必须以 Agent C 对最新 `origin/main` artifact 的结论为门槛；不能跳过 Agent C，也不能用旧 run、本地输出或文字汇报代替 artifact 验收。
- Agent X 遇到连续阻塞、连续无有效 diff、同因 CI 连续失败、权限/账号/密钥/付费服务需求、冲突归属不明或用户要求停止时，必须暂停或结束循环并说明原因。
- Agent A 只写版本化实现提示词，提示词必须包含 `main` 同步、commit、push、GitHub Actions、artifact 和 Agent C 下载核对要求。
- Agent B 每轮从最新 `origin/main` 开始，在 `main` 上小步实现，先跑本地轻量检查，再 commit 并 `git push origin main`。
- GitHub Actions 在 `main` push 或手动触发时运行 `ci-results.yml`，生成 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和 `.xcresult`；simulator launch 通过 `DESERT_CI_CAMERA_FOCUS=coast` 只在云端截图时把镜头聚焦玩家 Shipyard 海岸，并通过 `DESERT_CI_CAPTURE_MODE=1` 保持 HUD 渲染但暂停经济、AI、战斗和胜负推进，让 runner 延迟期间的截图仍稳定对应初始战场。普通玩家启动不设置这些变量，默认镜头和实时循环不变。
- Agent C 必须用 `gh auth login` 后下载最新 run 的未加密结果包，默认放在 `/private/tmp/desert-frontline-c-review-<run_id>/`。
- Agent C 只验收 `origin/main` 最新 commit 对应的 run id、run attempt 和 artifact；不能验收旧 run 或只看文字说明。
- 验收失败时不默认回滚，退回 Agent B 在 `main` 上追加修复 commit，再 push 触发新 run。
- 本轮制度不引入 `smalldata_test`、`develop`、`codeb/...`、候选分支或 PR 合并流。

## 8. 已确认铁律

- README 只能记录已完成、可验证的当前功能。
- 改 Swift 代码后最低要求云端 generic iOS device build 结果包通过；人工明确要求本机构建时再运行本机 generic iOS device build。
- Pending 模式必须互斥清理，避免建筑、支援、集结点、attack-move 状态交叉。
- 新增单位/建筑必须同步考虑生产、AI、HUD、迷雾、支援资产、死亡清理、重开重置。
- 新增 HUD action 必须同步 `HudAction`、标题/副标题、按钮颜色、处理逻辑、HUD 更新和 README 控制说明。
- 新增战斗行为必须同步可攻击规则、射程、伤害、冷却、目标搜索、AI 选择、施工禁火边界和视觉反馈。

## 9. 未来扩展点

- 老兵/经验深化：等级平衡、更多战场反馈、AI 保护高价值老兵、战役持久化等。
- AI 战术增强：守军、占点队、主攻波次、针对玩家构成调整生产。
- 海军/航母深化：舰载机巡逻、截击、反潜、海岸争夺、Sonar Buoy 平衡和升级。
- 建筑科技层：科技中心、防御塔、SAM / 岸防炮后续平衡、升级解锁和 Radar Outpost 后续平衡。
- 单位克制层：AA Truck 平衡、更多机动反制单位、AI 编队比例和高价值单位保护。
- 地图与任务：更多地图变体、战役式目标、阶段奖励。
- 操作体验：更多移动端手感优化、命令队列反馈和编队管理深化。

## 10. 不允许破坏的行为

- HQ 被摧毁决定胜负。
- 建筑施工未完成前不得生产、赚钱、提供视野、提供支援资产、扩展基地覆盖或开火。
- 玩家不能可靠攻击迷雾中不可见敌人。
- AI 和玩家必须共享核心战斗/移动/生产规则。
- `SKRM` 必须重置比赛状态、实体、任务、迷雾、经济和 pending 模式。
- 潜艇隐身和声呐检测不得被新海战逻辑绕过。
