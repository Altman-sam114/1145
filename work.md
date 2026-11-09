# 当前任务

## 目标与边界

- 总目标：从最新main持续推进Desert Stormfront风格RTS，重构美术和易用UI、修复云端构建；用户要求原创生图、只云端测试、不启动子智能体。
- 当前有限增量v6.6：默认选择卡44pt、可点44pt详情控件查看全部五项事实；缩短下方命令区与小地图边带、顶部目标卡；短提示完全淡出且隐形时不吞战场触摸。
- 验收：所有26动作、5页、经济/生产/战斗/迷雾/AI逻辑沿用；5尺寸×5页维持原九类HUD门槛，并补展开/收起的布局、文字、pending与状态恢复证据；一张既有selection-cycle原生图展示展开状态。精确SHA云端双构建、资源合同、HUD与24张官方原图核对。
- 本轮不改实体美术/伤害/寻路/经济/AI，不以固定截图冒充真实触摸、全方向动画、完整对局或长期性能。完整复刻与高品质原型总目标仍进行中。

## 现场与归属

- main / HEAD / origin/main=d2a339633d0e6a1609a860b85466853ff1835232；2026-11-09已fetch，远端未前移。origin=https://github.com/Altman-sam114/1145.git，活动账号Altman-sam114。
- 保留起始既有AGENTS/README/flow/图/test/prompt索引/log文档整理、工程Team ID两行、未跟踪历史提示词/v6归档/Unity分析；不覆盖、不stash、不混入本轮提交。需要提交前再次安全同步main。
- v6.0至v6.5实现与生图均已在main。13张本轮新生成图、提示词与用户指定目录副本均已落盘；不再把旧503当当前不可用结论。

## 步骤

1. [完成] 恢复入口/Git/云端；下载精确v6.5官方包，核对摘要/CRC/身份/JUnit/23资源/25HUD/24图与trace，逐张目视24图。结论已写update_log。
2. [完成实现，待云端] 选择卡44pt/详情100pt（平板52/156）、命令/任务/小地图紧凑边带、提示期限/背景同步淡出与隐形路由；沿用原输入和实体状态，SKRM收起详情。
3. [完成静态，待云端执行] 25组合各新增两次生产路由、五事实框/文字/恢复/隐形提示；runner/metadata严格校验两态，1个synthetic方法含14负例并重绑真实fixture摘要，避免因旧hash提前报错；selection-cycle固定图实际经Info路由展开。diff/2Python AST/2JSON/8文档39本地链接与围栏通过，未执行本机测试。
4. [进行中] 自查调用链与实际diff，逐块暂存本轮内容；2026-11-09 fetch/pull --ff-only已完成且main未前移。准备main提交/正常push，等待精确新run。
5. [待办] 下载新SHA官方结果包，核对双构建/相关合同与全部正式图；有证据才修复，不盲目重跑。
6. [待办] 根据实图继续有限改进或收口；必需验收未完成不清理工作台、不标总目标完成。

## 本轮编辑范围

- 计划：DesertFrontline/GameScene.swift（HUDLayout/HUDRoute/选择详情/提示/重置/现有CI fixture与契约），ci/simulator_probe.py（详情证据协议校验）、ci/check_probe_runner.py（相应fixture与直接负例）。必要README/flow/图/test/log/work只提交本轮事实，不提交原有整理。
- 不改workflow/runner预算、设备策略、工程Team ID，不增加无关玩法/完整回归。

## 证据与验证

- v6.5 run42168783661/attempt1/main/d2a3396，artifact13480423270；62,752,584bytes/158项未加密，SHA256=7bc066814158f02aabf6c083dfa8197b01221eacca203f6e49bc511793e62c99，与官方一致，CRC正常。
- 缓存/private/tmp/desert-frontline-review-42168783661-attempt1/{ci-results.zip,official/,review.json}；两份BUILD SUCCEEDED、JUnit10/0fail/1准确XCTest skip、110runner+5watchdog+6资源方法通过，23source/bundle一致、HUD25成功/恢复true、24/24独立原图且20实体/3环境挂载。work636.890s/cleanup10.764s。
- 目视：新设施/环境与兵模统一，但常驻说明、两排底部区和小地图冗余边带仍遮挡；据此做v6.6。当前静态HUD纹理不是全方向动画；真实触控、完整对局与长期性能尚无本轮证据。
- v6.6所选baseline=git diff --check、相关Python AST/JSON、文档链接。direct=新UI状态/隐形提示路由和五尺寸25组合、云端双构建/资源/原24图；因全面HUD涉及全部页面并使用现有固定入口，无新增无关回归。本机不import或执行CI脚本、不运行Swift/Xcode/App/simctl。

## 阻塞与精确下一步

- 当前无须用户确认的阻塞；官方ZIP本次gh api成功，未重跑旧CI。
- 下一步实现默认44pt/详情披露、提示淡出并同步生产路由；保留原失败gate，补直接有界状态证据，目视新图后再决定后续美术增量。
