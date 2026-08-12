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
- iOS Simulator launch probe：额外构建 simulator app、安装到可用 iPhone simulator，并用 `DESERT_CI_HUD_PAGE=tactical/build/air/naval/support` 依次重启 App；五页截图分别为 `simulator-screenshot.png`、`simulator-hud-build.png`、`simulator-hud-air.png`、`simulator-hud-naval.png`、`simulator-hud-support.png`。随后以 tactical 页和 `DESERT_CI_COMMAND_MARKER=move/attack-move/attack-target` 再启动三次，生成 `simulator-command-move.png`、`simulator-command-attack-move.png`、`simulator-command-attack-target.png`；前八次均使用 `DESERT_CI_CAMERA_FOCUS=air`。第九次使用 tactical 页与 `DESERT_CI_CAMERA_FOCUS=land`，生成 `simulator-land-combat.png`，验证 Blue / Red Mechanic / Humvee / Tank / Artillery、双方维修链路、方向化扬尘、炮口 / 炮线和爆炸样本，以及单位阵营旗标（旗杆 + 飘旗，旗布按阵营着色）不遮挡血条 / label。第十次使用 tactical 页与 `DESERT_CI_CAMERA_FOCUS=coast`，生成 `simulator-map-terrain.png`，验证确定性沙地色差与低密度沙丘等高线 / 风纹、按正交邻格连续的道路肩 / 路床 / 标记、ridge 落影 / 亮暗面 / 碎石、oil 污环 / 裂纹、海岸两级浅水渐变 / 泡沫线 / 岸线泡点、开阔水面长度与角度有变化的波纹、玩家海军航迹与水面命中样本。前十次启动都在等待后截图并用宿主机 `kill -0` 确认该次 PID 仍存活，最后统一抓取 App 日志；用于捕捉启动闪退 / 白屏黑屏、页签或动作丢失、单排溢出、HUD 遮挡、既有空战 / 命令 / 战斗证据缺失，以及工程模型 / 维修链路 / 地面模型 / 地貌层次 / 海岸与海军反馈探针缺失。任一截图或 PID 检查失败都会令 simulator launch probe 失败。所有 launch 都通过 `DESERT_CI_CAPTURE_MODE=1` 暂停经济、AI、战斗和胜负推进；air capture scene 保留既有空战证据，land capture scene 只在 CI 中编排地面单位和持久视觉样本，coast/default capture scene 复用既有玩家海军方向航迹与水面命中样本。普通 App 启动不设置这些变量，默认 `TACT`，三类 marker 使用短动画，初始单位、镜头和实时玩法不变。
- 第十一次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=combat-ui` 生成 `simulator-combat-ui.png`：四个玩家作战单位共享攻击约 43% HP 的敌方 Tank，其中一个处于 reload，用于核对右侧 `Combat / Engaged / Ready / Wounded / Critical / PRIMARY` 四行摘要、面板底部左对齐目标生命条、世界 `FOCUS n TNK 43%` 和八段耐久，同时保留 Mechanic 维修链路、炮线、爆炸与单排命令条。只有 combat-ui capture 会临时写共享目标、目标 HP 和 reload，普通 App 与原 land / coast / air capture 状态不变。
- 第十二次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=incoming-ui` 生成 `simulator-incoming-ui.png`：两个 Red Tank、Artillery 和 Humvee 共四个玩家已知攻击者分别锁定两个选中 Blue 目标，一个 Blue Tank 冻结在约 31% Critical HP，并冻结敌方炮线，用于核对标题与第四行 `IN` 数量、至少两个目标的红橙方向箭头 / `IN n` 标签、小地图告警外圈、Wounded / Critical 计数和镜像方向。workflow 总计十二次独立启动 / PID 存活检查；只有 incoming-ui capture 会临时写这些敌方目标、Blue Tank HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十三次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=naval-salvo` 生成 `simulator-naval-salvo.png`：单选 Blue Battleship 锁定约 47% HP Red Battleship 并冻结一个 reload，画面同时保留背景 Carrier、双方航迹、舰炮射程圈、两条分离炮迹 / 弹体 / 炮口闪光、Red 舰体闪光 / 火花和主 / 副水柱，用于核对分层舰体、两座双联装主炮、舰桥 / 舷窗 / 桅杆 / 雷达 / 二级火炮 / 救生艇、单选目标 HP / 距离 / reload 和单排命令条。workflow 总计十三次独立启动 / PID 存活检查；只有 naval-salvo capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十四次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=coastal-battery` 生成 `simulator-coastal-battery.png`：单选 operational Blue Coastal Battery 锁定约 54% HP Red Battleship 并冻结一个 reload，画面同时保留海岸地貌、背景海军、舰炮射程圈、两条分离炮迹 / 弹体 / 炮口闪光、双炮后坐轨迹、炮床冲击环、岸边尘浪、Red 舰体闪光 / 火花和主 / 副水柱，用于核对分层炮床 / 护坡 / 沙袋、炮盾 / 双炮管 / 后膛 / 测距仪 / 阵营光学件、掩体 / 弹药箱、单选目标 HP / 距离 / reload 和单排命令条。workflow 总计十四次独立启动 / PID 存活检查；只有 coastal-battery capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十五次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=carrier-strike` 生成 `simulator-carrier-strike.png`：单选 Blue Carrier 锁定约 42% HP Red Battleship 并冻结一个 reload，画面同时保留双方航迹、Carrier 护航圈、Carrier 甲板细节（斜角跑道 / 中线虚线 / 舰岛）、三条错列二次曲线进场线、三架有朝向 / 尾焰的舰载机、两枚反舰弹体及尾焰 / 烟迹、Red 舰体闪光 / 火花、水面命中、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。workflow 总计十五次独立启动 / PID 存活检查；只有 carrier-strike capture 会临时写双方位置 / 目标、Red Battleship HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十六次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=mobile-aa` 生成 `simulator-mobile-aa.png`：单选 Blue AA Truck 锁定约 46% HP Red Fighter 并冻结一个 reload，画面同时保留六轮装甲底盘、阵营风挡、设备舱、雷达盘、双轨四弹发射架、两枚错列拦截弹与烟迹 / 发射闪光、雷达跟踪 cue、Red Fighter 投影、命中环、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。workflow 总计十六次独立启动 / PID 存活检查；只有 mobile-aa capture 会临时写双方位置 / 目标、Red Fighter HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十七次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=fighter-strike` 生成 `simulator-fighter-strike.png`：单选 Blue Fighter 锁定约 48% HP Red Coastal Battery 并冻结一个 reload，画面同时保留 Fighter 模型 / 投影、两个翼下发射点、两条分离二次曲线、两枚错发弹体 / 尾焰、短白烟迹、双发射闪光、紧凑结构命中、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。workflow 总计十七次独立启动 / PID 存活检查；只有 fighter-strike capture 会临时写双方位置 / 目标、Red Coastal Battery HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十八次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=helicopter-salvo` 生成 `simulator-helicopter-salvo.png`：单选 Blue Helicopter 锁定约 45% HP Red Tank 并冻结一个 reload，画面同时保留 Helicopter 模型 / 投影 / 双 weapon pods、四条分离短曲线、四枚不同进度弹体 / 尾焰、阵营细亮线、离散白色烟点、双 pod 发射闪光、紧凑三点命中 / 尘环 / 碎屑、伤害飘字、目标 HP / 距离 / reload、小地图和单排命令条。workflow 总计十八次独立启动 / PID 存活检查；只有 helicopter-salvo capture 会临时写双方位置 / 目标、Red Tank HP 和 reload，普通 App 与其他 capture 状态不变。
- 第十九次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=damage-state` 生成 `simulator-damage-state.png`：同屏选择 29% HP Blue Tank、32% HP Blue Fighter 与 56% HP Blue Battleship，前两者冻结 `CRIT` 级第三段浓烟 / 紧凑火点 / 强焦痕，Battleship 冻结 `DMG` 级短烟 / 轻焦痕，同时保留 land / air / naval 不同挂点、模型 / 投影 / 航迹、生命条、选择圈、多选 `Wounded 3 / Critical 2` 摘要、小地图和单排命令条。workflow 总计十九次独立启动 / PID 存活检查；只有 damage-state capture 会临时写三单位位置与 HP，普通 App 与其他 capture 状态不变。
- 第二十次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=stop-command` 生成 `simulator-stop-command.png`：先为四个选中 Blue 跨域单位分别冻结 direct attack、move、AMOV 与 Carrier HOLD，并给未选中 Helicopter 写入该 Carrier guard anchor，再调用真实 `issueStopOrder(...)`。截图用于核对四单位选择仍保留、命令意图线全部消失、STOP subtitle 回到 `idle`、持久 `STOP 4` marker、依附 guard anchor 已释放，以及模型、HUD、选择面板和小地图无遮挡。workflow 总计二十次独立启动 / PID 存活检查；只有 stop-command capture 会临时写上述命令、位置和选择，普通 App 与其他 capture 状态不变。
- 第二十一次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=target-cycle` 生成 `simulator-target-cycle.png`：四个选中 Blue 作战单位先共享攻击最近的 Red Tank，再调用真实 `issueCycleTargetOrder(...)` 切换到第二候选 Red Artillery；第三候选为更远的 Red Humvee，其余 Red 实体移出视野。截图用于核对九动作单排、`TGT ART 2/3`、持久 `ATK 2/3 ART`、`FOCUS 4 ART 57%`、目标生命条、四条攻击意图线、选择摘要和小地图无遮挡。workflow 总计二十一次独立启动 / PID 存活检查；只有 target-cycle capture 会临时写上述位置、目标、HP 和选择，普通 App 与其他 capture 状态不变。
- 第二十二次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=selection-cycle` 生成 `simulator-selection-cycle.png`：紧邻 Blue Humvee / Tank / Artillery 对同一点真实调用两次友军选择 helper，截图核对 `SEL 2/3 TNK`、唯一 Tank 选择圈、Tank 单选面板、三个模型、九动作 TACT 与小地图无遮挡。workflow 总计二十二次独立启动 / PID 存活检查；普通 App 不进入 capture-only 写入。
- 第二十三次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=land` 和 capture-only `DESERT_CI_COMMAND_MARKER=enemy-touch-assist` 生成 `simulator-enemy-touch-assist.png`：镜头缩远到 1.58，两个 Blue AA Truck 选择一个玩家已知 Red Fighter，并用确定性 precondition 证明点击点严格位于 Fighter 精确 footprint 外、26pt 屏幕辅助范围内，再真实调用普通敌军辅助攻击 helper。截图核对两个 AA Truck、Red Fighter / 投影、两条红色攻击意图线、持久 `ATK TAP JET`、完整可读且不被机身遮挡的 `FOCUS 2 JET 64%` 世界标注与八段目标血条、完整九动作 TACT、选择摘要和小地图无遮挡。workflow 总计二十三次独立启动 / PID 存活检查；普通 App 不进入 capture-only 写入。
- 第二十四次使用 tactical 页、`DESERT_CI_CAMERA_FOCUS=coast` 和 capture-only `DESERT_CI_COMMAND_MARKER=naval-damage` 生成 `simulator-naval-damage.png`：约 29% HP Blue Battleship 与约 46% HP Red Submarine 的距离保持在 Battleship 既有 230pt 声呐范围内，并经 `updateFog(force: true)` / `isKnownToFaction(...)` 校验为合法已知目标；截图核对 Battleship 甲板破口 / 撕裂、Critical 第二热点与既有烟火、Submarine 模型 / 血条、持久双层压力环 / 浅青水沫 / 气泡 / `ASW HIT`、舰炮射程圈、攻击意图和目标 HP / 距离 / reload。workflow 总计二十四次独立启动 / PID 存活检查；场景禁止直接写 `revealedUntil`，普通 App 不进入 capture-only 写入。
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
