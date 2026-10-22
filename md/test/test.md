v5.34 目视口径：复用现有 24 张云端截图检查 HUD 视觉重构，不新增本地探针。`simulator-screenshot.png`、`simulator-hud-build.png`、`simulator-hud-air.png`、`simulator-hud-naval.png`、`simulator-hud-support.png` 核对顶部 Blue Command 资源条、金色任务卡、消息胶囊、底部深色 command dock、五页 active/armed 状态与按钮文字没有遮挡战场；`simulator-combat-ui.png`、`simulator-incoming-ui.png`、`simulator-land-combat.png` 核对选择卡、状态卡、目标血条、FOCUS / ATK / INCOMING 可读；`simulator-map-terrain.png`、`simulator-naval-salvo.png`、`simulator-carrier-strike.png` 核对小地图、海空模型、特效与 HUD 层级。代码审阅确认 `HUDPalette` 只影响渲染颜色/几何，页面动作映射、最小 44pt hit frame、inert gap、pending、updateHUD 数据流不变。固定 PNG 只能证明云端固定窗口的静态布局、构建和启动稳定性，不能外推真实触控、任意尺寸、长时间运行或真机性能。CI 对首启系统迁移导致的预热进程退出增加最多 3 次、每次间隔 20 秒的有限重试；三次都失败才判定 simulator launch failure。

# 测试规范

本文指导 Agent B 和 Agent C 为 `Desert Frontline` 选择验证层级。每次实现前必须先读本文件。

v5.10 目视口径：复用现有 24 张截图检查六格竖直耐久塔的满血初始化、HP ratio 分段颜色和可见空槽；确认塔与旗标、实体短码、选择圈、FOCUS / ATK 标记、伤害烟火及海空反馈不重叠，且迷雾不会泄露未知实体。无新增 launch。

v5.11 目视口径：复用现有 24 张截图检查选中战斗面板行色层级，不新增 launch。`simulator-combat-ui.png` 核对多选 HP/Wnd/Crit、PRIMARY、Eng/Rdy 的绿 / 琥珀 / 红橙优先级；`simulator-incoming-ui.png` 核对 Critical HP 与 `INCOMING` / `IN` 红橙状态、切换选择后无颜色残留；`simulator-target-cycle.png`、`simulator-enemy-touch-assist.png` 核对目标 HP 与 Weapon ready / Reload 颜色对应真实状态；`simulator-land-combat.png`、`simulator-damage-state.png`、`simulator-naval-salvo.png`、`simulator-coastal-battery.png`、`simulator-carrier-strike.png`、`simulator-mobile-aa.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png`、`simulator-naval-damage.png` 核对颜色不压过单位模型、六格耐久塔、FOCUS / ATK、炮击、水柱、舰载机或 ASW 反馈；BUILD / RALLY / SUPPORT / 空选择等非战斗面板行恢复中性浅色。颜色只读复用既有 HP、primaryCombatTarget、attackTimer、incomingThreatSummary 和迷雾边界，不改变文案、布局或战斗规则。

v5.12 目视口径：复用现有 24 张截图检查选中玩家作战单位选择圈低侧的四段武器就绪刻度，不新增 launch。`simulator-combat-ui.png` 核对多选中一名 partial reload 与其余 ready 的琥珀 / 青绿刻度差异，同时保留右侧颜色面板、FOCUS、八段目标血条、维修链和炮线可读；`simulator-target-cycle.png` 核对四个选中陆空单位的 ready 刻度与 TGT / ATK / FOCUS 不重叠；`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-naval-damage.png` 核对 Battleship / Carrier 选中圈的 partial ticks 不压过舰炮、航迹、水柱、ASW HIT 或战损；`simulator-mobile-aa.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 核对小型陆空选中圈仍可辨、不遮挡双弹 / 火箭、投影、旗标、耐久塔和命中反馈。`simulator-land-combat.png`、`simulator-damage-state.png`、`simulator-incoming-ui.png`、`simulator-enemy-touch-assist.png` 及其余截图核对敌军、结构、Mechanic、施工、pending / 空选择没有刻度残留，迷雾不泄露位置，24 张 PNG 尺寸 / 亮度 / 日志均正常。刻度只读 `attackTimer` 并以含 veterancy multiplier 的 `effectiveAttackCooldown` 归一化，不新增战斗状态或操作。

v5.13 目视口径：复用现有 24 张截图检查单选 Blue 陆空作战单位的 `attackRange` 射程椭圆，不新增 launch。`simulator-selection-cycle.png` 核对单 Tank 单选时范围椭圆与 SEL / 选择圈、旗标、耐久塔和模型共存；`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 核对单选 Fighter / Helicopter 的冷色低透明椭圆不遮挡机体、投影、导弹 / 火箭、命中反馈和目标信息；`simulator-mobile-aa.png`、`simulator-enemy-touch-assist.png` 核对 AA Truck 编队继续只显示既有防空威胁圈，不出现通用陆空椭圆；`simulator-target-cycle.png`、`simulator-combat-ui.png` 核对多选时新椭圆全部隐藏且 TGT / ATK / FOCUS、readiness、目标生命条和维修链不回归；`simulator-naval-salvo.png`、`simulator-coastal-battery.png`、`simulator-carrier-strike.png`、`simulator-naval-damage.png` 核对既有海军炮圈 / 护航圈 / 航迹 / 炮迹 / 水柱 / ASW HIT 不被重复绘制或改色。`simulator-incoming-ui.png`、`simulator-damage-state.png` 及其余截图核对建筑、Mechanic、SAM、敌军、迷雾、死亡、空选择和 build / rally / support / AMOV pending 没有射程圈残留；24 张 PNG 尺寸 / 亮度 / 日志正常。新节点只读 `EntityKind.attackRange`，不改变 `canAttack`、目标、攻击、AI 或迷雾。

v5.14 目视口径：复用现有 24 张截图检查 Carrier 三个固定停机位轮廓，不新增 launch 或 capture。`simulator-carrier-strike.png`、`simulator-naval-salvo.png`、`simulator-naval-damage.png` 核对三个位点沿甲板跑道错列、低透明空位和舰岛 / 跑道 / 航迹 / 战损层级不互相遮挡；`simulator-carrier-strike.png` 同时核对三机 strike、反舰弹、命中反馈仍优先可读。`simulator-hud-naval.png` 核对选中 Carrier 的 `Deck 3PAD H/J` 短文案不挤出单排面板；若探针场景存在真实 Carrier HOLD guard wing 或 HEL/JET BuildOrder，绑定位应提亮、队列位应显示琥珀条，空位保持暗色。`simulator-combat-ui.png`、`simulator-selection-cycle.png`、`simulator-map-terrain.png` 及其余截图核对非 Carrier 不出现停机位、敌方未知 Carrier 不通过甲板节点泄露迷雾位置，死亡 / 重开 / 未完工 Carrier 不留节点。节点只读现有 `boundCarrierGuardWing(for:)`、`BuildOrder` 和 `isOperational`，不新增飞机实体、队列、护航状态、攻击规则或第 25 次截图探针；24 张 PNG 尺寸 / 亮度 / 日志仍须正常。

v5.15 目视口径：复用现有 24 张截图检查潜艇局部模型与实体本地接触 cue，不新增 launch 或 capture。`simulator-naval-damage.png` 核对 Red Submarine 的艏艉层次、声呐穹顶、潜望镜、鱼雷口、尾舵/螺旋桨与低透明航迹共存，`CONTACT` cue 不遮挡 `ASW HIT`、双压力环、水沫、气泡、血条或 Battleship 战损；`simulator-naval-salvo.png` 核对潜艇细节在海战炮迹、航迹、射程圈和 HUD 之间保持低对比可读；`simulator-carrier-strike.png`、`simulator-map-terrain.png` 核对 Carrier 甲板、海岸层次、浅水和小地图没有潜艇节点或 cue 残留。代码审阅同时确认选中的 Blue Submarine 只读显示 `STEALTH` / `SONAR` / `DETECT`，玩家未知 Red Submarine 不显示模型或 cue，已知 Red Submarine 只显示 `CONTACT`；不把固定 capture 误称为真实隐身转换、长时间战斗或触控验证。节点预创建并挂在实体树，24 张 PNG 尺寸 / 亮度 / 日志和迷雾边界仍须正常。

v5.16 目视口径：复用现有 24 张截图检查海空选择面板的确定性短码与单行宽度 fitting，不新增 launch 或 capture。`simulator-hud-naval.png` 核对 Battleship / Carrier / Submarine 的 `ASW`、`SON`、`C<n>`、`Deck 3PAD H/J`、`Q` / `W` / `GW` / `Esc` 信息仍在面板边界内；`simulator-hud-air.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 核对目标、距离、`Ready` / `Rld`、空防摘要与模型/弹体不被行文本遮挡；`simulator-naval-salvo.png`、`simulator-naval-damage.png`、`simulator-carrier-strike.png` 核对目标 HP、ASW HIT、舰炮 / 舰载机 / 航迹和 v5.15 潜艇细节保持可读。`simulator-combat-ui.png`、`simulator-incoming-ui.png`、`simulator-target-cycle.png`、`simulator-enemy-touch-assist.png` 核对多选 `PRIMARY` / `Eng` / `Rdy` / `IN` 行的颜色索引与事实文本不变；`simulator-map-terrain.png`、`simulator-screenshot.png`、`simulator-hud-build.png`、`simulator-hud-support.png` 核对非海空、pending、空选择和地图面板没有短码残留或溢出。该轮只验证固定云端 capture 的布局可读性，不能外推真实触控、任意尺寸窗口、长时间战斗或全部动态状态；短码与 fitting 只读展示，不改变原始 rows、目标血条、命令、战斗、声呐、迷雾或生产规则。

v5.17 目视口径：复用现有 24 张 PNG 检查小地图海空朝向与交战微标，不新增 launch 或 capture。`simulator-hud-naval.png`、`simulator-hud-air.png` 核对海军菱形 / 空军三角的短朝向齿与选择圈、海空 HUD 不重叠；`simulator-command-move.png`、`simulator-command-attack-move.png`、`simulator-command-attack-target.png` 核对移动 / AMOV / 已知攻击目标方向在小地图同步且不改变命令；`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 核对海空模型、航迹、弹体、目标齿层级；`simulator-incoming-ui.png`、`simulator-naval-damage.png` 核对选中海空单位的来袭齿、既有告警圈、潜艇已知边界与 ASW HIT；`simulator-stop-command.png`、`simulator-target-cycle.png` 核对 STOP / TGT 后不残留旧方向齿；`simulator-map-terrain.png`、`simulator-hud-build.png`、`simulator-hud-support.png` 核对非海空、地图与 SUP/BUILD 页面无污染。代码审阅必须确认未知敌人、未知 HQ、未侦测 Submarine 不创建目标方向齿；固定 capture 只能证明符号层级、已知目标映射和启动稳定性，不能外推真实触控、动态移动、AI、连续战斗、生产、隐身转换或性能；24 张 PNG 尺寸 / 哈希 / 日志 / PID 仍须正常。

v5.18 目视口径：复用现有 24 张 PNG 检查海岸线陆地侧湿沙唇与稀疏礁石边缘，不新增 launch 或 capture。`simulator-map-terrain.png` 核对水侧浅水 / wash / foam 与 `.sand` / `.oil` 陆地侧缩进湿边连续，湿边沿共享四方向等距边方向、不越出 tile、不形成跨 tile 接缝；同图核对水邻 `.ridge` 只有低密度短暗色礁线 / 碎片，不形成连续黑带，`.road` 岸边没有错误陆地装饰，沙丘、油污、道路、Ridge、海岸和小地图仍清晰。`simulator-coastal-battery.png` 核对湿沙唇 / 礁石不遮挡岸防炮、炮迹、炮口闪光、水柱或目标信息；`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-fighter-strike.png` 核对舰体、舰炮、航迹、舰载机、弹体、命中反馈优先于岸线细节；`simulator-naval-damage.png` 核对战损舰体、Submarine、ASW HIT、水沫、气泡和既有迷雾边界不被污染。其余 `simulator-hud-build.png`、`simulator-hud-support.png`、`simulator-screenshot.png` 及 18 张截图核对 HUD、生产、支援、陆空模型、选择标记和非海岸地图无新装饰残留。代码审阅必须确认所有新节点只挂 `mapNode`、沿用 `terrainDetailHash(for:)`、在 `drawMap()` / `SKRM` 重建时清理，且没有新增 Terrain、碰撞、路径、登陆、建造、AI、战斗、迷雾或小地图语义；固定 capture 只能证明静态岸线几何、层级、fog 覆盖、24 张 PNG、启动存活和 generic build，不能外推真实触控、动态移动、海陆通行、连续战斗、全部 seed 或长时间性能。

v5.19 目视口径：复用现有 24 张 PNG 检查既有 FOCUS / ATK 世界交战标注的确定性层级和海空 caption 分带，不新增 launch 或 capture。`simulator-land-combat.png`、`simulator-combat-ui.png`、`simulator-incoming-ui.png` 核对 FOCUS 双环、八段目标生命条、`ATK <shortCode>` 与选中面板 / 来袭标记不互相覆盖；`simulator-naval-salvo.png`、`simulator-coastal-battery.png`、`simulator-carrier-strike.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png`、`simulator-naval-damage.png` 核对海军 / 空军模型、舰炮、航迹、弹体、舰载机、ASW HIT、水沫、战损与 FOCUS / ATK 环和文字同时可读。检查 `simulator-command-attack-target.png`、`simulator-target-cycle.png`、`simulator-stop-command.png` 中直接攻击 / TGT / STOP marker 的出现与清理，`simulator-map-terrain.png`、`simulator-hud-build.png`、`simulator-hud-support.png` 中无残留标注。代码审阅必须确认 FOCUS / ATK 只改变 effects-layer z 序、label 分带或 marker 布局，继续经过玩家已知 / 存活 / `canAttack` 边界，未知敌方、未知 HQ、未侦测 Submarine 不会因 z 序提升泄露；固定 capture 只能证明静态层级、启动稳定性和 generic build，不能外推真实触控、动态移动、连续交火或真机性能，24 张 PNG 尺寸 / 哈希 / 日志 / PID 仍须正常。

v5.20 目视口径：复用现有 24 张 PNG 检查任务面板内固定六阶段进度带的层级与布局，不新增 launch 或 capture。`simulator-screenshot.png`、`simulator-map-terrain.png`、`simulator-hud-build.png`、`simulator-hud-support.png` 核对六个节点与五条连接线不遮挡标题、详情、资源面板、小地图或命令条；代码审阅确认节点状态只读取 `completedMissionStages` / `activeMissionStage()`，完成为青绿色、当前为金色、未开始为低透明度，且胜负/重开刷新路径不会残留旧色。其余 20 张 PNG 核对任务带不污染海空模型、战斗反馈、选择面板、迷雾和 pending 命令。该轮只验证固定 capture 的 HUD 几何、颜色层级、generic build 与启动稳定性，不能外推真实触控、动态任务推进或真机性能；不新增任务规则、奖励、按钮、地图目标或第 25 次截图探针。

v5.21 目视口径：复用现有 24 张 PNG 检查 Battleship / Coastal Battery 双炮齐射的方向、层级和清理，不新增 launch 或 capture。`simulator-naval-salvo.png` 核对 Blue Battleship 的两条分离炮线、第二 lane 的短暂错列、双炮口闪光 / 烟雾、炮弹和主 / 次水柱、舰体命中、目标 HP / 距离 / reload 同时可读；`simulator-coastal-battery.png` 核对岸防炮双线、recoil / 岸边尘浪、方向化水柱与舰体命中不遮挡海岸、舰体或 HUD；`simulator-naval-damage.png`、`simulator-carrier-strike.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 核对战损、Submarine / ASW HIT、Carrier strike 和其他海空命中反馈不回归。代码审阅确认 runtime 方向只来自已通过既有 `attackerKnownToPlayer` / `shouldShowNavalWaterImpact(...)` 的 `fire(...)`，`target.hp`、伤害、冷却、AI、fog、潜艇侦测不变；普通特效仍移除，persistent capture 一次创建完整静态效果，未传 attacker 位置的 CI helper 保留 entity-id fallback。其余 20 张 PNG 核对无残留炮弹 / 水柱 / smoke、HUD 溢出、未知敌方或未侦测潜艇泄漏；24 张 PNG 尺寸 / RGBA、manifest、JUnit、日志、PID 和 ZIP 完整性仍须正常。固定 capture 只能证明静态层级、方向化几何、generic build 与启动稳定性，不能外推真机、真实触控、连续交火或动态时序。

v5.22 目视口径：复用现有 24 张 PNG，不新增 launch 或 capture。`simulator-carrier-strike.png` 必须同时显示三架错列舰载机、两枚反舰弹、按航母到目标来袭方向稳定的紧凑主水溅射、较小近失回响、舰体闪光 / 火花、伤害飘字、目标 HP / 距离 / reload、Carrier 甲板 / 护航圈、航迹和 HUD；主 / 次水柱不能重复叠加、跨舰体覆盖或遮挡单排命令条 / 小地图。`simulator-naval-salvo.png`、`simulator-coastal-battery.png` 核对 v5.21 双炮线、方向化水柱和岸防尘浪不回归；`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png`、`simulator-naval-damage.png` 核对既有空袭、战损、Submarine / ASW HIT、水沫和气泡不受 Carrier 专属回响污染。代码审阅确认 Carrier 水面反馈只从 `launchCarrierWing(...) -> showCarrierStrikeImpact(...)` 统一产生，fixture 不再额外调用 `showNavalWaterImpact(...)`；`target.hp`、伤害、射程、冷却、AI、生产、fog、潜艇侦测不变，普通水柱按既有 helper 清理，persistent 立即构图。其余 18 张 PNG、manifest、JUnit、build / launch 日志、PID、ZIP 完整性和未知目标边界仍须正常；固定 capture 不能外推真实触控、连续交火或真机性能。

v5.23 目视口径：复用现有 24 张 PNG，不新增 launch 或 capture。`simulator-helicopter-salvo.png` 必须在 Blue Helicopter 投影附近同时显示低透明、垂直压缩的等距尘环、沿攻击方向稳定分开的两侧短尘流和少量固定颗粒，并继续保持机体、旋翼、双 weapon pods、四枚火箭 / 烟点 / 发射闪光、耐久塔、三点命中、伤害飘字、Red Tank 目标信息、HUD 与小地图可读；persistent capture 不能依赖等待或 fade-in 才出现。`simulator-fighter-strike.png`、`simulator-mobile-aa.png`、`simulator-damage-state.png`、`simulator-map-terrain.png` 及其余 20 张图核对 Fighter / AA / 战损 / 沙地道路油田 Ridge 水面与既有海空反馈不出现直升机尘环污染，尤其 `.water`、`.road`、`.ridge` 和无效点不创建下洗节点。代码审阅确认 rotor wash 只有 `showHelicopterRocketSalvo(...)` 一个调用点，runtime 仍受 `attackerKnownToPlayer` 约束；普通 root 在约 0.45--0.65 秒内统一 `removeFromParent()`，persistent 立即保留完整构图；不改 HP、伤害、射程、冷却、AI、移动、任务、胜负、fog、潜艇 / ASW 或 24 次探针。该轮只定义云端 generic build / 24 PNG 的复核口径，不能把静态检查代称编译、运行时或视觉已通过。

v5.24 目视口径：复用现有 24 张 PNG，不新增 launch 或 capture。`simulator-map-terrain.png` 核对移动海军静态构图中的舰艏 V 形浅水冲洗、Battleship 较窄 / Carrier 较宽的近段尾流、远段递减泡沫边和舰艉推进器扰流，不遮挡舰体、舰炮、航母甲板、舰载机、岸线、HUD 或小地图；`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-coastal-battery.png` 核对新航迹与双炮线、舰载机 strike、岸防炮、水柱和目标信息同时可读；`simulator-naval-damage.png` 核对战损 Battleship、Submarine、ASW HIT、水沫、气泡与低透明潜艇扰动共存，Submarine 不出现明亮长距离尾流。`simulator-hud-naval.png`、`simulator-screenshot.png`、`simulator-command-*.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 及其余截图核对非海军场景无航迹污染、停止 / 未知敌方实体无残留节点、24 张 PNG 尺寸 / RGBA / 哈希和日志正常。代码审阅确认几何只在 `configureNavalWakeNode(for:)` 预创建，`updateNavalWake(...)` 不分配节点，root 仍挂实体树背景层并沿用 `animateIdle`、fog、死亡和 `SKRM` 清理；固定 capture 只能证明静态层级与 generic build / 启动稳定性，不能外推真实连续航行、触控或长时间战斗。

v5.27 目视口径：复用现有 24 张 PNG，不新增 launch 或 capture。`simulator-map-terrain.png` 核对真实水邻 `.sand` tile 上低密度、断续、短小且与岸线平行的潮痕，以及最多一个靠近湿边的小低对比漂砾；潮痕不连成边框，漂砾不变成大石，不跨 tile 接缝，不遮挡道路、沙丘、泡沫、海岸实体或小地图。`simulator-coastal-battery.png`、`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-naval-damage.png` 核对岸防炮、舰体、舰炮 / 舰载机、命中反馈、战损、Submarine / ASW HIT、水沫和迷雾边界优先可读；其余 20 张 PNG 核对 HUD、生产、支援、陆空模型、命令 marker 和非海岸地图无新装饰残留。代码审阅确认潮痕 / 漂砾只在 `addLandShorelineDetails(...)` 的 `.sand` 分支使用 `landShorelineEdges(for:)`、`terrainDetailHash(for:)` 与 `edge.index` 确定性选择，每个 tile 各自最多一条 / 一个，新节点只挂 `mapNode` 并随 `drawMap()` / `SKRM` 清理；oil / ridge / road 旧分支、Terrain / 通行 / AI / 战斗 / fog 状态 / 小地图 / CI fixture 不变。固定 PNG、generic build、launch/PID 和日志只能证明固定窗口静态层级与回归，不能外推全部 seed、动态重开、实时移动、真实触控、AI、连续战斗或真机性能。
v5.28 目视口径：复用现有 24 张 PNG，不新增 launch 或 capture。主证据 `simulator-coastal-battery.png` 核对玩家 Shipyard 既有 dock / crane 内的两条短平行内轨、三处低矮龙骨支架、一段窄内侧码头边缘和三个小系泊标记；细节必须低对比、留在既有视觉包络内，不遮挡岸防炮、舰体、舰炮线、水柱、旗标、生命塔、HUD 或小地图。`simulator-map-terrain.png` 核对 Shipyard 模型不污染海岸浅水、泡沫、道路、地形细节和小地图；`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-naval-damage.png`、`simulator-hud-build.png` 及其余 20 张 PNG 核对海战、航母、战损 / ASW、BUILD 面板和非 Shipyard 场景无无关回归。代码审阅确认新增几何只在 `addStructureBody(for:to:)` 的 `.shipyard` 分支直接挂 `base`，无新状态、helper、动画、随机、每帧节点、CI fixture 或第 25 次探针；固定 PNG、generic build、launch/PID、JUnit、manifest、日志和 ZIP 只能证明固定窗口静态构图 / 层级、构建、artifact 完整性与启动稳定性，不能外推生产 / rally、施工变化、fog 进出、死亡 / `SKRM` 动态重建、真实触控、全部 seed 或真机性能。

v5.29 目视口径：复用现有 24 张 PNG，不新增 launch、capture 或第 25 张探针。主证据为 `simulator-carrier-strike.png`，核对 Carrier 舰体、甲板、跑道、舰岛、三停机位与动态舰载机仍可读，同时能辨识两条短平行低对比作业轨和一段内缩安全/拦阻边线；`simulator-naval-salvo.png`、`simulator-naval-damage.png`、`simulator-coastal-battery.png`、`simulator-map-terrain.png`、`simulator-hud-naval.png`、`simulator-hud-build.png` 及其余截图核对海战、HUD、地图和非 Carrier 场景无污染。代码审阅确认新几何只在 `addNavalUnitBody(for:to:)` 的 `.carrier` 分支挂入实体 `base`，无新状态、动画、每帧节点、生产、战斗、fog 或 CI 入口；固定 PNG、generic build、launch/PID、JUnit、manifest、日志和 ZIP 只能证明固定构图、层级、构建、artifact 完整性与启动稳定性，不能证明真实触控、动态生产/队列、fog 进出、死亡、`SKRM` 动态重开、连续战斗或真机性能。

v5.30 目视口径：复用现有 24 张 PNG，不新增 launch、capture 或第 25 张探针。主证据 `simulator-hud-air.png`、`simulator-screenshot.png` 与三张 `simulator-command-*.png` 核对 Blue Fighter -> Red Fighter 的两个翼下发射点、两条 guided trail / 两枚弹体与既有 Fighter / Helicopter、投影、FOCUS / ATK、耐久塔、选择面板、HUD 和小地图共存，同时只保留一组 air impact、一次伤害飘字和既有单个爆炸样本。`simulator-fighter-strike.png` 核对 Fighter -> structure 仍为既有双曲线 surface strike，`simulator-mobile-aa.png`、`simulator-carrier-strike.png`、`simulator-naval-salvo.png`、`simulator-coastal-battery.png`、`simulator-naval-damage.png` 及其余截图核对 AA Truck、Carrier intercept / strike、SAM、海战、岸防、Submarine / ASW、Helicopter、陆战、HUD、地图和 fog 无额外 Fighter-air 轨迹污染。源码审阅必须确认 runtime 只在 Fighter -> `.air` 且 `attackerKnownToPlayer` 与目标玩家 / 玩家已知门槛同时成立时调用 `showFighterAirMissileSalvo(...)`，门槛失败不回落 generic；helper 只调用两次未改动的 `showGuidedMissileTrail(...)`，第二弹约延迟 0.055 秒，普通节点沿既有有限生命周期清理，persistent 只用于 air capture；`target.hp -=`、damage floater、air impact 与击杀 / XP 仍为单次统一链路。固定 persistent PNG、generic build、launch/PID、JUnit、manifest、日志和 ZIP 不能证明普通运行时清理、真实错发时序、未知 Red Fighter 动态 fog 进出、Reduce Motion、真实触控、连续密集空战或真机性能。

v5.31 目视口径：复用现有 24 张 PNG，不新增 launch、capture 或第 25 张探针。主证据 `simulator-naval-damage.png` 必须在 Battleship 既有 230pt sonar 与玩家可见 tile 的合法 `CONTACT` 条件下，同时显示 Red Submarine -> Blue Battleship 的一枚 persistent 鱼雷体、短而窄的低透明扰流 / 固定气泡、一次按来袭方向旋转的紧凑水面命中与一次舰体命中，并保留约 29% HP Blue Battleship 的两档战损、约 46% HP Red Submarine、Blue Battleship -> Red Submarine 的双压力环 / 水沫 / 气泡 / `ASW HIT`、攻击意图、耐久塔、HUD 和小地图。`simulator-naval-salvo.png`、`simulator-carrier-strike.png`、`simulator-coastal-battery.png`、`simulator-fighter-strike.png`、`simulator-helicopter-salvo.png` 及其余 18 张图核对炮击双水柱、Carrier 回响、空袭、岸防、陆战、地图与 HUD 无额外鱼雷污染。源码审阅必须确认 runtime 只在 `Submarine -> naval` 且攻击者为玩家 / 玩家已知、目标为玩家 / 玩家已知时调用 `showSubmarineTorpedoRun(...)`，门槛失败不回落 generic tracer；水面舰只经 `showSubmarineSurfaceImpact(...)` 调用一次 `showNavalWaterImpact(...)` 与一次 `showNavalHullStrike(...)`，sub-vs-sub 不进入该分支；`target.hp -=`、damage floater、impact 与 kill / XP 仍为单次统一链路，fixture 不写 `revealedUntil`，既有 sonar / CONTACT / ASW / fog 不变。固定 persistent PNG、generic build、launch/PID、JUnit、manifest、日志和 ZIP 不能证明普通运行时清理、动态声呐 / fog 进出、真实触控、连续海战或真机性能。

## 1. 默认策略

- 默认云端重验证，本机只跑轻量检查。
- 本轮固定使用 `main` 作为唯一上传、提交、推送和云端验证分支。
- Agent B 完成实现后在本机跑轻量检查，commit 后直接 `git push origin main`，由 GitHub Actions 执行 Xcode build 和结果包归档。
- Agent C 不只看 Agent B 文字汇报；必须下载 `origin/main` 最新 commit 对应的未加密 CI 结果包，核对 manifest、JUnit、日志和失败摘要。
- Agent X 循环下，每一轮仍必须遵守 Agent B 本地轻量检查、GitHub Actions artifact、Agent C 下载复判的顺序。
- Agent X 不得跳过 Agent C artifact 验收；失败时不得继续下一轮或伪装成功。
- 只有人工明确说“本机测试”“本地 build”“本地 xcodebuild”“本地跑探针”等，本机完整构建或模拟器验证才成为默认路径。
- 纯文档修改仍需本地通过 `git diff --check`。

## 2. 本地轻量检查

### Probe / Fast

触发条件：

- 纯文档修改。
- 提交前快速检查。
- Agent C 验收开始时。
- GitHub Actions workflow、Xcode project 或脚本配置修改后的本地格式检查。

命令：

```sh
git diff --check
```

Xcode 工程配置修改时补充：

```sh
plutil -lint DesertFrontline.xcodeproj/project.pbxproj
```

GitHub Actions workflow 修改时补充：

```sh
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci-results.yml"); puts "yaml ok"'
```

当前基线：

- 文档-only 任务最低要求通过 `git diff --check`。
- workflow 修改最低要求通过 YAML 解析。
- 本机轻量检查通过不等于游戏构建已通过；构建结论以云端结果包或人工要求的本机构建为准。

## 3. 云端重验证

### v5.53 调度与完整性门槛

- 本轮本机只允许 `git diff --check`、暂存 diff 检查、YAML / Python AST / shell 语法检查；禁止本机 build、Simulator、simctl、watchdog 或 scheduler 测试，也不得本机伪造 `GITHUB_ACTIONS=true`。全部回归由 Actions 执行。
- `ci/probes.json` 是唯一 24 项权威清单，包含 ID、page、marker、focus、原等待时间和 PNG basename；顺序、场景和输出名与既有 24 次探针一致。预热单独统计，正式 launch 不重试、不以替代图补数。
- `ci/simulator_probe.py` 顺序执行 simulator build、可解释设备选择、boot、install、prewarm 和 24 项 capture；本轮没有并行 boot/build 的加速承诺。共享 monotonic 工作 deadline 1080 秒，所有命令与等待都扣除同一预算，另用最多 90 秒有界收尾，合计 1170 秒 < step 1260 秒。generic build 独立 600 秒 / step 12 分钟；job 45 分钟；静态测试 / lint 最多 2 / 1 分钟，metadata / upload 最多 3 / 5 分钟。
- 模拟器编译最多 420 秒、bootstatus 每次 240 秒最多两次、launch 每次 120 秒、截图 180 秒、sips 30 秒；v5.56 的 install 独立180秒、安装恢复就绪60秒，其余 simctl 60 秒。每次命令额外在剩余预算内留 2 秒用于 TERM/KILL/reap。boot / prewarm 重试检查剩余预算，不能靠重试重置总 deadline。预热保留 90 秒通知消退、5 秒稳定等待，首次截图 8 秒、其余 4 秒，等待每 30 秒打印心跳。
- 选择策略：记录 Xcode / simulator SDK、全部已安装 runtime；仅候选 `isAvailable` 的 iOS runtime / iPhone，版本须在构建后 app `MinimumOSVersion` 与所选 SDK 之间，runtime 按新到旧、设备按 name / UDID 升序排序。未有稳定旧 runtime 的证据，因此不凭猜测选旧版本；不下载、不新建、不在重试时更换设备。
- `simulator-probe-summary.json` 每个阶段 / 探针原子落盘，记录 commit / run / attempt / version / branch、设备 / runtime / 选择理由、工作与收尾预算 / 耗时、阶段 start / end / exit、prewarm、当前阶段、失败原因、最后成功 probe、expected / completed / failed / notRun / running 计数和每项 PID / launch 次数 / launch 后与截图后存活 / PNG 大小、尺寸、SHA-256。缺失 summary 时 metadata 只能补失败记录，不能推断 success。
- 每个截图必须通过完整 PNG chunk CRC、RGB/RGBA 8-bit 非交错结构、解压 scanline / filter / 数据长度校验，竖图经有界 sips 旋转为横屏后再校验；PID 两次活跃检查、24 项一一对应、无重复 ID / path、无额外截图同时满足才允许成功。`ci/package_results.py` 在上传前重验身份、安装、prewarm、场景就绪、HUD契约、全部 24 PNG 和 summary；v5.57 的 JUnit 为8个CI testcase加1个准确skipped的XCTest，共9 case，计数与实际节点一致。
- `ci/check_watchdog.py` 仅 Actions 检查成功、非零、超时、后代清理、SIGTERM 后代清理；`ci/check_probe_runner.py` 仅 Actions 使用 fake commands 与标准库 unittest 检查 24 完整结果、缺项、重复 ID / path、空 / 坏 / 截断 PNG、缺图、dead PID、真实短命令超时、deadline 传递 / 耗尽、失败 summary、runtime 确定排序和被篡改图像证据。其日志进入 `static-checks.log`，结构化 `ci-regression-results.json` 进入 artifact；失败会阻止最终 CI 通过。
- 调度器直接持有一个子命令进程组，不套另一层 watchdog session；取消先终止所属命令组，再记录失败并按有界 finally 采集 app log / device state、仅 shutdown 选定设备。重复取消在收尾时忽略，不扩大为全局 shutdown。收尾警告不覆盖原始失败；强制销毁 runner / GitHub 硬取消仍可能阻止上传。
- artifact 增加 `probes.json`、`simulator-probe-summary.json`、`simulator-build.log`、`simulator-runtimes.json`、`simulator-boot-state.json` 和 `ci-regression-results.json`，与 manifest / JUnit / generic build / 原 24 PNG 一并验收。C 必须核对最新 SHA / run / attempt 以及全部 PNG 目视，结构通过不代表无白屏、真实触控、动态玩法、多尺寸或真机长期性能。

### v5.54 截图朝向与 HUD 遮挡门槛

- 本机仍只允许 AST/YAML/语法和 diff 等静态检查，不运行 sips、CI 回归、游戏、build 或任何模拟器操作；不伪造 `GITHUB_ACTIONS=true`。
- `Runner.normalize_screenshot(...)` 是实际 capture 和云端角点回归的共享入口：portrait 源图有界调用真实 `sips --rotate 270`，native landscape 不调用旋转并保持文件 SHA 不变，正方形明确失败。保持原 24 项、设备选择和所有预算/等待。
- summary schemaVersion 2 的每项增加 `rawImage`（旋转前 bytes/width/height/sha256）、`rotationDegrees`、`normalizationPolicy`，最终 `image` 保留规范化后同一元数据。raw PNG 不重复上传，raw hash 是原地修改前的现场记录，不得称为 artifact 内原始文件可重算证据。
- runner 与 metadata 共用校验要求原始元数据完整、portrait 角度为 270 且最终宽高互换、native landscape 角度为 0 且元数据完全一致；缺项/错角/错尺寸/最终图 SHA 不符均失败。结构校验不能自动证明 App 的真实文字朝向。
- `ci/check_probe_runner.py` 保留原 16 项调度/完整性测试并增加 raw/角度/policy/尺寸/未旋转原图一致性负路径；独立 normalization suite 使用标准库生成 2x3 不对称 RGB fixture，经真实云端 sips 后用小型 PNG 反过滤解码核对完整 3x2 像素位置（`A B / C D / E F -> B D F / A C E`），另证实 native landscape 不执行命令、SHA/像素不变和 square 被拒绝。日志及 `ci-regression-results.json` 分开记录各 suite、真实 sips fixture 元数据/期望/实际像素及真实用例结果。
- HUD 根 z=10000，超过 fogLayer 300 加每格 `1000 + zPosition(center)` 的当前约 1411.8 上界，也高于当前地图/实体/效果子树；不改 fog alpha、认知集合或潜艇链路。C 必须目视全部 24 官方 PNG 无需额外旋转、文字正向、命令栏在底部，TACT/BUILD、THEATER/minimap、选择卡不再被 fog 黑三角覆盖，战场未知区仍有迷雾。不得用本地旋转审阅副本代替官方 PNG。
- 270 策略仅由已审阅 hosted iPhone 17 / iOS 26.5 证据支持，不代表任意未来 runtime 自动识别；固定 capture 不代表多尺寸、触控或动态玩法认证。v5.53 CI 技术项通过但 C 整体不通过；v5.54 已由 C 下载 run `39802364105` attempt 1 的正式 ZIP、核对 26 项回归与全部 24 张正向 PNG 后通过（详见 update_log）。后续版本必须重新验收其最新 run，不能沿用这份通过结论。

### v5.55 战场优先布局与同源云端契约

- 本轮仅云端编译/运行/测试，本机只允许 git diff、AST/YAML/文本静态检查。保留 24 项权威探针、等待、270/0 规范化、单一 hosted 设备和 1080s work / 90s cleanup / 1260s step hard limit，不增 launch/capture/device。
- 成功 prewarm launch 通过环境传递 run/SHA/attempt/version 并仅开启一次 Swift 契约；场景确认真实 UIWindow inset、实际 SpriteView 尺寸和横屏后，用生产 `HUDLayout` 与 `consumeHUDTouch/handleHudPage` 检查五尺寸乘五页：667×375 零 inset；852×393 左右59、底21；874×402 使用实际设备 inset；1024×768、1366×1024 零 inset。
- 每组合九类检查：`controls` 最少44pt/安全框/互斥；`containers` 顶层互斥和子槽归属；`bands` 小地图三带/44pt缩放；`routing` page/action/zoom/map/inert/world；`pending` 静态卡/rail与dock gap不改状态及模式互斥；`pageState` 实际切页保留选择/队列/pending；`roundTrip` 生产地图正逆投影；`labels` 长文字与实际行有界；`rebuild` 节点数稳定且无旧页命中。四类 pending 模式及空态分布在每个尺寸的五页场景，不执行生产/战斗动作。
- 输出 App `Documents/DesertCI/<nonce>/hud-layout-contract.json`，含 schema1、producer=GameScene.HUDLayout、run/SHA/attempt/version/PID/probe/nonce、实际尺寸/inset、25个组合的生产框/检查/失败/面板面积与视口比例、实际场景恢复结果。检查后恢复尺寸/inset、页、选择、队列、pending、相机、消息和触摸起点；正式 24 launch 禁用契约，不带合成状态。
- v5.57替代原15s `get_app_container` 依赖：prewarm90秒后从绑定当前launch的直接ready描述符安全读取最多1MiB报告，根来自所选设备dataPath，并核对该容器自身metadata的bundleId、普通文件/非symlink、固定Documents nonce路径及bytes/SHA。Python不复算几何，只复核生产来源、完整25组合/九类断言、fixture元数据、身份/PID/nonce、恢复和hash；报告或场景就绪失败留证早停，不继续整轮坏图，不能以截图覆盖红门槛。
- runner与metadata分别复核，报告进入 manifest 的 hudLayoutContractPath/outcome、projectSpecificReports、JUnit和失败摘要。JUnit新增 hud-layout-contract，正常结构为7 case / 0 failure / 1 skipped XCTest；失败缺报仍留证。新增11个schema/身份/缺报/篡改/漏断言/未恢复/未完成采集负例，保留26项既有回归，实际结果以云端 ci-regression-results.json 为准；schema单测使用明确标记的synthetic fixture，不是另一个布局或真实模拟器证据。
- C独立检查最新未加密ZIP、全部24张正式PNG和契约身份/25组合：左五页轨和当前动作dock、36pt资源条、任务/消息、限宽选择队列、分带地图、费用/来源与armed/disabled状态可读，原陆海空/迷雾无回退。用panelAreaFraction客观复核占屏，不因无重叠就宣称战场面积已改善。几何路由契约不等于真实触摸、多尺寸截图、动态战斗或真机性能认证。
- 性能风险继续保留：v5.54 work 1065.448/1080s仅余14.552s；慢点在hosted boot与截图I/O，不能说编译已持续快速稳定。本轮不放宽超时掩盖问题。

### v5.56 安装限时、预算与实际CLI回执

- 失败基线：v5.55 run `39814471623` attempt1 的两类build、37项回归和独立5项watchdog检查成功，但install在60.619s返回124，开始/结束余量683.339/622.720s；prewarm空、24项not_run、0正式PNG、无HUD JSON。C不通过，不是HUD断言失败；API绿色continue-on-error step不能替代真实outcome或最终gate。
- install专属requested cap180s，最多两次且同一UDID/App。首尝试准入为 `180+2+95+sum(24 wait)+180=557s`；恢复前为617s，恢复使用同UDID `bootstatus -b` cap60s，再检查557s。95s保留原90s通知等待与5ssettle，100s保留全部原24 wait，180s是后续命令运行保留，不保证最坏24次I/O。1080/90/1260/2700s总预算、原设备选择、prewarm和24项门槛均不改变。
- 只有本watchdog真实124且CLI终止/reap回执完整，或明确device busy/resource temporarily unavailable/connection interrupted，才允许一次就绪恢复和重试。文件/bundle/签名/架构/参数等永久诊断优先拒绝；未知非零、信号/取消、TERM/KILL/reap错误、就绪失败、第二次失败均停止。预算不足不发命令；不新增boot/shutdown、切换设备/runtime、清空App或全局CoreSimulator重置。
- `run_bounded(..., receipt=...)` 向后兼容记录真实pid/pgid、trigger、requested/effective limit、exit/returncode、TERM/KILL sent/already_gone/error、leader reap、cleanup耗时。scope仅为owned CLI组，发送成功及leader回收不等于所有后代或系统安装服务已清理。正常exit0同样来自实际wait，不能合成成功。
- summary的installation schema1/policy带UDID、bundle/App、admissions、1至2条attempt及可选recovery，每项保存cap、elapsed、remaining、分类/决策、CLI回执与独立输出文件bytes/SHA。失败/取消finally原子落盘；未记录真实成功不进入prewarm。runner和metadata分别验证同设备身份、时序/预算/分类/回执/输出完整性；缺失、失败或跨设备记录即使HUD/24PNG完整也为红，manifest有simulatorInstallOutcome，JUnit新增simulator-install。
- 云端回归保留原37项，新增12个安装策略/负例方法（含恢复后再次预算不足、TERM/KILL/reap错误、取消和metadata红等subtests）、2个真实短CLI exit/timeout回执方法，AST声明总数51（34调度/HUD/image、12安装、2回执、3真实sips规范化）。独立5项watchdog检查保持；所有实际执行数量/结果必须以最新run日志和ci-regression-results.json为准，未在本机运行。fake clock/command与synthetic installation/HUD fixture仅为schema单测，不是正式模拟器证据。
- C必须下载最新main/SHA/run/attempt的官方未加密ZIP，核对安装attempt/recovery原始输出、实际receipt、manifest/JUnit/日志、所有回归、prewarm绑定PID的HUD25矩阵及全部24张正向PNG；继续按实际panelAreaFraction和图像判断占屏与可读性。安装门槛通过本身不代表v5.55视觉通过、完全复刻或真实触摸/连续战斗/真机性能认证。

### v5.57 场景就绪、直接trace与早停

- v5.56真实C结论不通过：两build成功且install一次exit0耗时38.339s，prewarm90.203s后PID活跃；`get_app_container`超时，18/24完成，14张无HUD且前8图同SHA。不能由PID/有效PNG推断语义就绪，也不能断言所有probe或整个App冻结。真实timeout回归TERM后退出并遇KILL EPERM而失败，不吞掉收尾错误。
- SwiftUI尺寸/真实UIWindow inset去重合并后排队，仅在初始化完整后的update入口应用；layoutHUD局部非重入，HUD25内部尺寸不入外部队列，真实外部变化保留到恢复。仅CI的直接beacon包含schema1、SHA/run/attempt/version、真实PID/probe/独立32hex nonce/UDID、递增sequence及实际uptime/elapsed；常规游戏无CI输出。
- terrain/map/control-points/units/HUD/fog/fixture/initialization阶段确已结束，实际map树、live实体、七面板/五页/当前全部动作和文本、fog、分支关键实体/命令与相机、HUD25恢复满足后，至少两个不同didFinishUpdate帧共享稳定geometry revision才可ready。后续真实几何/HUD重建立即失效旧ready；缺初始化、缺一帧、失败fixture或旧帧不能冒充通过。该CPU证据不证明GPU画面正确。
- 每次launch用独立stdout/stderr重定向文件，云端共享deadline内cap10s保存help核对选项；beacon行最多8KiB、每通道trace最多256KiB，超限/损坏/错误身份拒绝，不静默截断成功。prewarm沿用90s窗口，随后5ssettle；正式保留8s/4s最小等待，从launch返回起最多30s就绪窗口，全部仍扣1080s，不因beacon重置deadline。
- prewarm终止后、正式截图及PID检查后冻结实际已读trace snapshot（`scene-<nonce>-stdout/stderr.log`），保留直接活文件（`.live.log`）诊断。冻结前latest ready须仍等于取证时ready，后续几何失效/新ready不能被偷偷接受；snapshot有bytes/SHA，后续正常live stderr追加不改变其证据边界，snapshot自身篡改仍失败。runner与metadata分别要求一个成功prewarm、恰好24项与期望probeID、唯一nonce、稳定两帧、生产事实、快照完整性和HUD25描述符/正式JSON一致。
- 前五项是五个不同HUD页；保存PNG及final SHA后如与已完成前五页重复，当前图/trace保留、当前失败、后项not_run，metadata独立红。只检查前五页，不要求24全unique，不把唯一hash当视觉通过。不额外launch、截图或放宽预算，原24定义/顺序/全部最小等待/安装策略/PID/raw270/final和HUD25九类门槛保持。
- 保留原51个测试方法名和独立5项watchdog；真实timeout子进程显式忽略SIGTERM并flush `armed`，cap2s后要求真实TERM/KILL sent、leader return=-SIGKILL且reaped/receipt完整，未arm或EPERM不跳过、不伪绿。新增13个synthetic协议/路径/hash/早停/fake-clock方法，AST声明总64；不复制Swift布局，不是设备证据。所有实际数量/结果待Actions的`ci-regression-results.json`与日志，本机未运行。
- manifest新增`sceneReadinessOutcome`，正常JUnit9case含1个skipped XCTest；失败摘要列probe/nonce/PID/lastStage和trace路径/hash。C必须下载本轮最新SHA/run/attempt未加密artifact并核对全部64声明方法的实际结果、独立5项watchdog、安装/直接trace/两帧/HUD25/24独立PNG与全部图像；若早停，只能结论失败与具体最后阶段，不借旧artifact补数或声称根因已证实。

### 触发条件

`.github/workflows/ci-results.yml` 在以下情况运行：

```yaml
on:
  push:
    branches:
      - main
  workflow_dispatch:
```

### 云端检查内容

GitHub Actions 负责运行：

- `git diff --check`，检查最新提交的空白和补丁残留。
- `plutil -lint DesertFrontline.xcodeproj/project.pbxproj`。
- generic iOS device build。
- iOS Simulator 完成 boot、安装并取得 bundle ID 后，先用与正式探针一致的 `DESERT_CI_CAPTURE_MODE=1` 稳定环境启动一次 tactical / air / none 预热；workflow 必须解析并检查预热 PID，等待约 90 秒让首次启动的系统通知自然出现并消退，确认进程仍存活后终止 App，再等待 5 秒才开始正式截图。预热不截图、不计入正式 probe；artifact 仍须保留未经裁剪、滤像素或删除通知区域的原始 24 张 PNG，Agent C 必须逐张人工核对是否有系统通知或其他遮挡。
- iOS Simulator launch probe：额外构建 simulator app、安装到可用 iPhone simulator，并用 `DESERT_CI_HUD_PAGE=tactical/build/air/naval/support` 依次重启 App；五页截图分别为 `simulator-screenshot.png`、`simulator-hud-build.png`、`simulator-hud-air.png`、`simulator-hud-naval.png`、`simulator-hud-support.png`。随后以 tactical 页和 `DESERT_CI_COMMAND_MARKER=move/attack-move/attack-target` 再启动三次，生成 `simulator-command-move.png`、`simulator-command-attack-move.png`、`simulator-command-attack-target.png`；前八次均使用 `DESERT_CI_CAMERA_FOCUS=air`。第九次使用 tactical 页与 `DESERT_CI_CAMERA_FOCUS=land`，生成 `simulator-land-combat.png`，验证 Blue / Red Mechanic / Humvee / Tank / Artillery、双方维修链路、方向化扬尘、炮口 / 炮线和爆炸样本，以及单位阵营旗标（旗杆 + 飘旗，旗布按阵营着色）不遮挡血条 / label。第十次使用 tactical 页与 `DESERT_CI_CAMERA_FOCUS=coast`，生成 `simulator-map-terrain.png`，验证确定性沙地色差与低密度沙丘等高线 / 风纹、按正交邻格连续的道路肩 / 路床 / 标记、ridge 落影 / 亮暗面 / 碎石、oil 污环 / 裂纹、海岸两级浅水渐变 / 泡沫线 / 岸线泡点、开阔水面长度与角度有变化的波纹、玩家海军航迹与水面命中样本。前十次正式截图启动都在等待后截图并用宿主机 `kill -0` 确认该次 PID 仍存活，最后统一抓取 App 日志；用于捕捉启动闪退 / 白屏黑屏、页签或动作丢失、单排溢出、HUD 遮挡、既有空战 / 命令 / 战斗证据缺失，以及工程模型 / 维修链路 / 地面模型 / 地貌层次 / 海岸与海军反馈探针缺失。任一截图或 PID 检查失败都会令 simulator launch probe 失败。所有 launch 都通过 `DESERT_CI_CAPTURE_MODE=1` 暂停经济、AI、战斗和胜负推进；air capture scene 保留既有空战证据，land capture scene 只在 CI 中编排地面单位和持久视觉样本，coast/default capture scene 复用既有玩家海军方向航迹与水面命中样本。普通 App 启动不设置这些变量，默认 `TACT`，三类 marker 使用短动画，初始单位、镜头和实时玩法不变。
- 第十一次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=combat-ui` 生成 `simulator-combat-ui.png`：四个玩家作战单位共享攻击约 43% HP 的敌方 Tank，其中一个处于 reload，用于核对右侧 `Combat / Engaged / Ready / Wounded / Critical / PRIMARY` 四行摘要、面板底部左对齐目标生命条、世界 `FOCUS n TNK 43%` 和八段耐久，同时保留 Mechanic 维修链路、炮线、爆炸与单排命令条。只有 combat-ui capture 会临时写共享目标、目标 HP 和 reload，普通 App 与原 land / coast / air capture 状态不变。
- 第十二次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=incoming-ui` 生成 `simulator-incoming-ui.png`：两个 Red Tank、Artillery 和 Humvee 共四个玩家已知攻击者分别锁定两个选中 Blue 目标，一个 Blue Tank 冻结在约 31% Critical HP，并冻结敌方炮线，用于核对标题与第四行 `IN` 数量、至少两个目标的红橙方向箭头 / `IN n` 标签、小地图告警外圈、Wounded / Critical 计数和镜像方向。正式截图 probe 累计十二次独立启动 / PID 存活检查；只有 incoming-ui capture 会临时写这些敌方目标、Blue Tank HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十三次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=naval-salvo` 生成 `simulator-naval-salvo.png`：单选 Blue Battleship 锁定约 47% HP Red Battleship 并冻结一个 reload，画面同时保留背景 Carrier、双方航迹、舰炮射程圈、两条分离炮迹 / 弹体 / 炮口闪光、Red 舰体闪光 / 火花和主 / 副水柱，用于核对分层舰体、两座双联装主炮、舰桥 / 舷窗 / 桅杆 / 雷达 / 二级火炮 / 救生艇、单选目标 HP / 距离 / reload 和单排命令条。正式截图 probe 累计十三次独立启动 / PID 存活检查；只有 naval-salvo capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十四次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=coastal-battery` 生成 `simulator-coastal-battery.png`：单选 operational Blue Coastal Battery 锁定约 54% HP Red Battleship 并冻结一个 reload，画面同时保留海岸地貌、背景海军、舰炮射程圈、两条分离炮迹 / 弹体 / 炮口闪光、双炮后坐轨迹、炮床冲击环、岸边尘浪、Red 舰体闪光 / 火花和主 / 副水柱，用于核对分层炮床 / 护坡 / 沙袋、炮盾 / 双炮管 / 后膛 / 测距仪 / 阵营光学件、掩体 / 弹药箱、单选目标 HP / 距离 / reload 和单排命令条。正式截图 probe 累计十四次独立启动 / PID 存活检查；只有 coastal-battery capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十五次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=carrier-strike` 生成 `simulator-carrier-strike.png`：单选 Blue Carrier 锁定约 42% HP Red Battleship 并冻结一个 reload，画面同时保留双方航迹、Carrier 护航圈、Carrier 甲板细节（斜角跑道 / 中线虚线 / 舰岛）、三条错列二次曲线进场线、三架有朝向 / 尾焰的舰载机、两枚反舰弹体及尾焰 / 烟迹、Red 舰体闪光 / 火花、水面命中、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。正式截图 probe 累计十五次独立启动 / PID 存活检查；只有 carrier-strike capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十六次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=mobile-aa` 生成 `simulator-mobile-aa.png`：单选 Blue AA Truck 锁定约 46% HP Red Fighter 并冻结一个 reload，画面同时保留六轮装甲底盘、阵营风挡、设备舱、雷达盘、双轨四弹发射架、两枚错列拦截弹与烟迹 / 发射闪光、雷达跟踪 cue、Red Fighter 投影、命中环、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。正式截图 probe 累计十六次独立启动 / PID 存活检查；只有 mobile-aa capture 会临时写双方位置 / 目标、Red Fighter HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十七次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=fighter-strike` 生成 `simulator-fighter-strike.png`：单选 Blue Fighter 锁定约 48% HP Red Coastal Battery 并冻结一个 reload，画面同时保留 Fighter 模型 / 投影、两个翼下发射点、两条分离二次曲线、两枚错发弹体 / 尾焰、短白烟迹、双发射闪光、紧凑结构命中、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。正式截图 probe 累计十七次独立启动 / PID 存活检查；只有 fighter-strike capture 会临时写双方位置 / 目标、Red Coastal Battery HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十八次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=helicopter-salvo` 生成 `simulator-helicopter-salvo.png`：单选 Blue Helicopter 锁定约 45% HP Red Tank 并冻结一个 reload，画面同时保留 Helicopter 模型 / 投影 / 双 weapon pods、四条分离短曲线、四枚不同进度弹体 / 尾焰、阵营细亮线、离散白色烟点、双 pod 发射闪光、紧凑三点命中 / 尘环 / 碎屑、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。正式截图 probe 累计十八次独立启动 / PID 存活检查；只有 helicopter-salvo capture 会临时写双方位置 / 目标、Red Tank HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十九次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=damage-state` 生成 `simulator-damage-state.png`：同屏选择 29% HP Blue Tank、32% HP Blue Fighter 与 56% HP Blue Battleship，前两者冻结 `CRIT` 级第三段浓烟 / 紧凑火点 / 强焦痕，Battleship 冻结 `DMG` 级短烟 / 轻焦痕，同时保留 land / air / naval 不同挂点、模型 / 投影 / 航迹、生命条、选择圈、多选 `Wounded 3 / Critical 2` 摘要、小地图和单排命令条。正式截图 probe 累计十九次独立启动 / PID 存活检查；只有 damage-state capture 会临时写三单位位置与 HP，普通 App 与其他 capture 状态不变。
- 第二十次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=stop-command` 生成 `simulator-stop-command.png`：先为四个选中 Blue 跨域单位分别冻结 direct attack、move、AMOV 与 Carrier HOLD，并给未选中 Helicopter 写入该 Carrier guard anchor，再调用真实 `issueStopOrder(...)`。截图用于核对四单位选择仍保留、命令意图线全部消失、STOP subtitle 回到 `idle`、持久 `STOP 4` marker、依附 guard anchor 已释放，以及模型、HUD、选择面板和小地图无遮挡。正式截图 probe 累计二十次独立启动 / PID 存活检查；只有 stop-command capture 会临时写上述命令、位置和选择，普通 App 与其他 capture 状态不变。
- 第二十一次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=target-cycle` 生成 `simulator-target-cycle.png`：四个选中 Blue 作战单位先共享攻击最近的 Red Tank，再调用真实 `issueCycleTargetOrder(...)` 切换到第二候选 Red Artillery；第三候选为更远的 Red Humvee，其余 Red 实体移出视野。截图用于核对九动作单排、`TGT ART 2/3`、持久 `ATK 2/3 ART`、`FOCUS 4 ART 57%`、目标生命条、四条攻击意图线、选择摘要和小地图无遮挡。正式截图 probe 累计二十一次独立启动 / PID 存活检查；只有 target-cycle capture 会临时写上述位置、目标、HP 和选择，普通 App 与其他 capture 状态不变。
- 第二十二次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=selection-cycle` 生成 `simulator-selection-cycle.png`：紧邻 Blue Humvee / Tank / Artillery 对同一点真实调用两次友军选择 helper，截图核对 `SEL 2/3 TNK`、唯一 Tank 选择圈、Tank 单选面板、三个模型、九动作 TACT 与小地图无遮挡。正式截图 probe 累计二十二次独立启动 / PID 存活检查；普通 App 不进入 capture-only 写入。
- 第二十三次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=enemy-touch-assist` 生成 `simulator-enemy-touch-assist.png`：镜头缩远到 1.58，两个 Blue AA Truck 选择一个玩家已知 Red Fighter，并用确定性 precondition 证明点击点严格位于 Fighter 精确 footprint 外、26pt 屏幕辅助范围内，再真实调用普通敌军辅助攻击 helper。截图核对两个 AA Truck、Red Fighter / 投影、两条红色攻击意图线、持久 `ATK TAP JET`、完整可读且不被机身遮挡的 `FOCUS 2 JET 64%` 世界标注与八段目标血条、完整九动作 TACT、选择摘要和小地图无遮挡。正式截图 probe 累计二十三次独立启动 / PID 存活检查；普通 App 不进入 capture-only 写入。
- 第二十四次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=naval-damage` 生成 `simulator-naval-damage.png`：约 29% HP Blue Battleship 与约 46% HP Red Submarine 的距离保持在 Battleship 既有 230pt 声呐范围内，并经 `updateFog(force: true)` / `isKnownToFaction(...)` 校验为合法已知目标；截图核对 Red Submarine -> Blue Battleship 的 persistent 单鱼雷、短扰流 / 气泡、一次方向化水面命中与舰体命中，同时保留 Battleship 甲板破口 / 撕裂、Critical 第二热点与既有烟火、Submarine 模型 / 血条、Blue Battleship -> Red Submarine 的持久双层压力环 / 浅青水沫 / 气泡 / `ASW HIT`、舰炮射程圈、攻击意图和目标 HP / 距离 / reload。正式截图 probe 累计二十四次独立启动 / PID 存活检查；场景禁止直接写 `revealedUntil`，不新增第 25 次正式截图 launch，普通 App 不进入 capture-only 写入。
- v5.9 复用既有 `simulator-command-attack-target.png`、`simulator-target-cycle.png` 和 `simulator-enemy-touch-assist.png` 做攻击 marker 目视验收：三张图分别核对红色虚线 footprint-aware 目标环、环上缘内侧橙色双 V、环下方 `ATK JET` / `ATK 2/3 ART` / `ATK TAP JET`，并确认 FOCUS、目标血条、攻击意图线、空中 / 地面模型和 HUD 不遮挡；不新增 launch，workflow 总数仍为二十四次。
- v5.10 复用全部二十四张截图做实体耐久塔目视验收：`land-combat` / `combat-ui` / `target-cycle` / `enemy-touch-assist` 核对小型 HMV / AA / Fighter / Tank 的旗杆、燕尾旗、六格竖塔、短码、FOCUS / ATK 文本不重叠；`naval-salvo` / `carrier-strike` / `fighter-strike` / `helicopter-salvo` / `naval-damage` 核对舰机旗标与竖塔不遮挡模型、航迹、炮击、水柱或 ASW 反馈；`damage-state` 核对约 29% / 32% / 56% HP 的填充格数量、绿 / 红阈值、空槽可见和维修后的刷新。旧水平实体生命条不得与竖塔重复，未知敌军 / 未侦测 Submarine 不得通过塔泄露；不新增 launch，workflow 总数仍为二十四次。
- 结果包生成和上传。

云端 Xcode build 命令：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
  -project DesertFrontline.xcodeproj \
  -scheme DesertFrontline \
  -configuration Debug \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -derivedDataPath .derivedData-ci \
  -resultBundlePath ci-results/DesertFrontline.xcresult \
  CODE_SIGNING_ALLOWED=NO \
  build
```

本机历史命令使用 `build/DerivedDataDevice`；云端为了避免污染工作区固定使用 `.derivedData-ci`。

### CI 结果包

结果包必须未加密，供 Agent C 下载复核，不复用任何带密码发布包。

最低内容：

- `ci-artifact-manifest.json`
- `ci-failure-summary.md`
- `junit.xml`
- `xcodebuild.log`
- `static-checks.log`
- `project-lint.log`
- `simulator-launch.log`
- `simulator-app.log`
- `simulator-screenshot.png`
- `simulator-hud-build.png`
- `simulator-hud-air.png`
- `simulator-hud-naval.png`
- `simulator-hud-support.png`
- `simulator-command-move.png`
- `simulator-command-attack-move.png`
- `simulator-command-attack-target.png`
- `simulator-land-combat.png`
- `simulator-map-terrain.png`
- `simulator-combat-ui.png`
- `simulator-incoming-ui.png`
- `simulator-naval-salvo.png`
- `simulator-coastal-battery.png`
- `simulator-carrier-strike.png`
- `simulator-mobile-aa.png`
- `simulator-fighter-strike.png`
- `simulator-helicopter-salvo.png`
- `simulator-damage-state.png`
- `simulator-stop-command.png`
- `simulator-target-cycle.png`
- `simulator-selection-cycle.png`
- `simulator-enemy-touch-assist.png`
- `simulator-naval-damage.png`
- `DesertFrontline.xcresult`

artifact 命名规则：

```text
desert-frontline-ci-${version}-${branch_slug}-${short_sha}-run${run_id}-attempt${run_attempt}
```

`ci-artifact-manifest.json` 至少记录：

- version
- branch
- commitSha / shortSha
- runId / runAttempt
- workflowName
- createdAt
- projectName
- scheme
- destination
- resultBundlePath
- junitPath
- buildLogPath
- failureSummaryPath
- staticChecksOutcome
- buildOutcome
- simulatorLaunchOutcome
- sceneReadinessOutcome / simulatorInstallOutcome / hudLayoutContractOutcome / probeIntegrityOutcome
- testOutcome
- projectSpecificReports

当前项目没有独立 XCTest target，所以 `testOutcome` 默认为 `skipped`；不要把没有运行的 XCTest 说成通过。

## 4. Agent B main 直推验证步骤

Agent B 默认步骤：

```sh
git fetch origin
git switch main
git pull --ff-only origin main
git status --short
```

实现并本地轻量检查后：

```sh
git add 相关文件
git commit -m "vX.Y: 简要说明本轮做了什么"
git push origin main
```

push 前必须确认：

- 当前分支是 `main`。
- 目标远端是 `origin/main`。
- `git status --short` 只包含本轮相关文件。
- 提交范围没有混入用户或其他 Agent 的无关改动。

如果没有 `origin`、没有网络、没有 push 权限或 GitHub Actions 不可用，必须明确写出阻塞点，不得伪装已完成云端验证。

## 5. Agent C 结果包验收步骤

Agent C 必须先有 GitHub 权限：

```sh
gh auth login
```

下载缓存位置：

```text
/private/tmp/desert-frontline-c-review-<run_id>/
```

下载并核对示例：

```sh
gh run view <run_id> --json headSha,headBranch,status,conclusion,runAttempt,workflowName
gh run download <run_id> --dir /private/tmp/desert-frontline-c-review-<run_id>/
```

必须核对：

- `headBranch` 是 `main`。
- `headSha` 等于 `origin/main` 最新 commit。
- manifest 的 `branch`、`commitSha`、`runId`、`runAttempt` 与 GitHub run 完全一致。
- `junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 可以打开并对应同一次 run。
- `buildOutcome=success`、`simulatorLaunchOutcome=success` 且 workflow conclusion 成功，才可把云端构建与启动探针视为通过。

CI 失败时，Agent C 输出退回清单；默认由 Agent B 在 `main` 上追加修复 commit 后再次 push。不要回滚式处理远端 `main`，除非人工明确要求。

## 6. Agent X 循环验证规则

Agent X 只负责调度和判断，不新增绕过验证的捷径。

每轮必须满足：

- Agent A 生成版本化提示词，明确本轮目标、非目标、关键文件、验证、CI、artifact 和 Agent C 验收要求。
- Agent B 从最新 `origin/main` 开始，在 `main` 上实现，先跑本地轻量检查，再 commit 并 push 到 `origin/main`。
- GitHub Actions 为本轮最新 commit 生成未加密 artifact。
- Agent C 下载并核对最新 `origin/main` run 的 artifact，确认 manifest、JUnit、日志、失败摘要和 run 元数据一致。
- Agent X 只能在 Agent C 明确验收通过后继续下一轮或宣布总目标完成。

失败处理：

- Agent C 验收失败时，Agent X 必须退回 Agent B 修复或暂停等待人工确认。
- 同一原因 CI 连续失败时，Agent X 必须暂停并说明失败原因，不得继续消耗轮次。
- 连续 2 轮无有效 diff 或连续 3 轮遇到同一阻塞时，Agent X 必须暂停或结束循环。
- 需要账号、权限、密钥、付费服务、人工产品决策或冲突归属判断时，Agent X 必须暂停等待人工。

## 7. 测试数据与下载容量限制

本项目默认采用小数据量验证策略，避免下载过大 artifact、模型、数据集、缓存或结果包，把本机、CI runner 或临时目录容量撑爆。

规则：

- 测试数据必须尽量小，只覆盖必要边界。
- CI artifact 只上传必要文件：manifest、JUnit 或测试摘要、关键日志、失败摘要、必要结果包。
- 不上传大体积 DerivedData、完整 build cache、无关截图、视频、模型文件、历史 artifact 或重复压缩包。
- Agent C 下载 artifact 前优先确认只下载最新 run 对应的必要结果包。
- 下载缓存默认放在 `/private/tmp/desert-frontline-c-review-<run_id>/`。
- 下载后应检查目录大小：

```sh
du -sh /private/tmp/desert-frontline-c-review-<run_id>/
```

- 禁止使用非 `Altman-sam114` 的 GitHub 账号伪装完成 push、CI 或 artifact 验收。
- 禁止默认下载大体积测试数据、模型、历史 artifact 或无关产物，导致本机或 CI 容量被撑爆。

## 8. 人工明确要求时的本机构建

项目是 iOS SwiftUI + SpriteKit app，当前没有独立 XCTest target。命令行验证以 Xcode build 为主。

推荐使用完整 Xcode 路径，避免命令行工具路径不一致：

```sh
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
```

本机 generic iOS device build：

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

成功标准：输出包含 `** BUILD SUCCEEDED **`。

当前环境历史上 CoreSimulatorService 多次不可用；模拟器失败不能直接判定为源码回归。能启动模拟器时，UI、HUD、触摸交互改动需要补充人工交互检查。

## 9. 回归层级

### v5.32 选中海军艏向箭头

复用现有 24 次 CI launch 与 PNG，不新增入口或截图。静态核对 `navalHeadingCueNode` 只预创建一次，`updateNavalWake(for:direction:)` 与既有 `localWakeDirection` / `xScale` 同步 rotation；仅玩家选中、存活、可见的 Battleship / Carrier / Submarine 显示，停止保留最后 rotation，取消选择、死亡、重开、fog 隐藏及未知敌方潜艇不显示。不得改变移动、尾流、声呐、迷雾或战斗规则。

### Smoke

触发条件：

- 任意 Swift 源码修改。
- Xcode 工程配置修改。
- 影响资源、入口、Scene 初始化或 build setting 的修改。

默认执行方式：

- Agent B 本机跑轻量检查后 push 到 `origin/main`。
- GitHub Actions 跑 generic iOS device build 并上传结果包。
- Agent C 下载结果包复核。

人工要求本机验证时，补充运行第 8 节本机构建命令。

### Stage Regression

触发条件：

- 修改战斗、移动、生产、经济、AI、迷雾、HUD、支援技能、任务或胜负逻辑。
- Agent A 提示词要求验证某条玩法链路。
- Smoke 通过但存在高风险行为变化。

默认执行方式：

- 云端 build 结果包是最低门槛。
- 能启动模拟器或真机时，补充人工检查。

人工检查清单：

- 启动 skirmish 后地图、HUD、小地图、迷雾显示正常。
- 选择、框选、移动、攻击、`HOLD`、`STOP`、`TGT`、`AMOV` 不互相破坏；STOP 后选择保留且当前命令意图线消失；TGT 只循环当前视野内玩家已知且合法可攻击的目标，混编中不能攻击新目标的单位保持旧命令。
- 同一拥挤己方邻域的连续单击稳定循环单位；精确敌军点击仍攻击，双击己方机动单位仍选择视野内同型单位，换点击位置、候选集合、框选或控制组后不沿用旧 cursor。
- 普通世界点击保持 pending > 精确实体 > 合法敌军 26pt 辅助 > 友军 26pt 辅助 > 空地处理；敌军辅助只取玩家已知且至少一个选中 operational 作战单位可攻击的首个严格排序候选，不循环、不泄露迷雾或未侦测潜艇，精确不可攻击敌军不会穿透到附近目标。
- 生产队列、建筑施工、集结点和经济收入仍工作。
- AI 能生产、占点、进攻并使用相关新能力。
- 若修改海战，检查潜艇隐身、声呐和海军路径。

### Full

触发条件：

- 大版本合并。
- 多系统联动修改。
- 发布前、人工要求或 Agent C 判断需要。

默认执行方式：

- 云端结果包通过。
- 有可用设备/模拟器时至少跑一局从开局到明显胜负趋势的 skirmish。

人工检查清单：

- 检查三类军种、支援技能、建造、生产、AI 进攻、任务阶段、HQ 胜负。
- 尝试 `SKRM` 重开，确认状态重置。

当前基线：

- 暂无自动化 Stage Regression 或 Full；依赖云端 generic build 加可用 iOS target 的人工检查。

## 10. 规则

- 每次实现前先读本文件。
- 默认从本地轻量检查开始，再由云端 Actions 重验证。
- 文档-only 修改可以不跑 Xcode build，但必须说明原因。
- 改 Swift 代码后必须至少获得云端 Smoke 结果包；人工明确要求时再补本机 Smoke。
- UI、HUD、触摸交互改动在构建外还应尽量做设备/模拟器检查；如果 CoreSimulatorService 不可用，要明确记录。
- 不得伪造测试结果。
- Agent X 循环不得跳过 Agent C 对最新 artifact 的复判。
- 新增测试方式、脚本、XCTest target 或验证流程时，必须更新本文、`README.md` 和必要的 `update_log.md`。

## v5.39 云端超时与失败留证

云端 generic build 由 `ci/run_bounded.py` 限制 600 秒；模拟器由 `ci/simulator_probe.py` 共享 1080 秒 monotonic 工作预算，另预留至多 90 秒诊断 / 同设备 shutdown，内层 1170 秒小于 step 21 分钟硬限时。generic build step 12 分钟、job 45 分钟，metadata / upload 各预留 3 / 5 分钟。单命令保持 simulator build 420 秒、bootstatus 240 秒最多两次、launch 120 秒、截图 180 秒、其他 simctl 60 秒，实际限时还会受剩余总预算约束并预留进程组终止时间。所有等待每 30 秒输出心跳。失败 / SIGTERM / SIGINT 后尽力原子保存进度、采集有界诊断、只关闭本 run 选定的唯一设备；metadata / upload 使用 always，runner 强制销毁仍可能无法上传。保留首次成功预热 90 秒通知消退、5 秒稳定等待和全部 24 次原场景独立截图 / PID 探针，不把静态截图当作动态玩法测试。

## v5.41 云端目视口径

小地图截图需显示右上北向箭头/N 标识与左下 `TACTICAL / TAP TO FOCUS` 提示；提示不遮挡地图 blip、camera box、缩放按钮或战区状态条。该节点仅为静态 HUD 视觉，不改变镜头和命令语义。

## v5.42 云端目视口径

小地图底部应显示与 `cameraRig.xScale` 同源的倍率读数，并与北向标记、camera box、缩放按钮和地图 blip 保持可读。读数为静态 HUD 状态映射，不改变缩放或输入。

## v5.43 云端探针限时

模拟器截图 `simctl io` 使用 180 秒 watchdog，应用 launch 使用 120 秒，其他 simctl 命令保持 60 秒；用于区分慢 runner I/O 与应用启动失败。

## v5.44 云端目视口径

小地图标题下显示 L/A/S 彩色域图例，不能遮挡地图、北向标识、camera box、缩放按钮或缩放读数。图例为静态 HUD 说明，不新增玩法状态。

## v5.45 云端目视口径

小地图图例显示 `LAND / AIR / SEA`，文字保持在地图标题区域内，不遮挡北向标记、camera box、缩放按钮或倍率读数。

## v5.46 云端目视口径

小地图倍率栏显示 `PINCH • TAP FOCUS`，文字不溢出 minimap、不遮挡缩放按钮或 camera box；仅为操作提示。

## v5.47 云端目视口径

小地图 `−/+` 按钮上方显示 `ZOOM`，不遮挡按钮、倍率读数、camera box 或地图内容。

## v5.48 云端目视口径

THEATER 状态卡右侧显示绿色 LIVE 指示点，与状态文字同层级，不遮挡小地图、标题或战区信息。
