# 当前任务

## 总目标与本轮验收

- 持续从最新main迭代Desert Stormfront风格RTS，全面改善美观易用的UI、精细兵模/地图/陆海空战斗、修复云端构建并使用原创生图；不以局部通过冒称完整复刻/高档品质全部完成。
- 当前有限增量v6.10：清理粗炮线/常驻意图/集火和海军尾流；缓存渲染节点，修正父镜像导致的指令端点错误及SKRM后focus根丢失。保持玩家/AI原规则、目标认知、伤害/经济/移动/迷雾与任务/胜负，不改workflow/工程/设备/预算。
- 验收：新SHA云端generic+simulator构建，正负父镜像真实端点/3与4节点身份复用/根重挂/指令战斗选择恢复；原26资源/坦克八向/25HUD/50详情/24正式图与逐张目视保持。
- 本机仅Git、diff、AST/JSON/文档等静态；禁止本地编译/运行/模拟器/探针/回归，不开子智能体。CPU镜像/重挂证据不代替物理触控、完整SKRM对局、长期FPS或全军多向完成。

## 现场与归属

- main HEAD/origin/main=b096db605b190119cc9acc05e48b194d6ac68310；origin=https://github.com/Altman-sam114/1145.git，账号Altman-sam114。2026-11-09本轮再次fetch/pull --ff-only已成功，远端未前移，gh api user确认Altman-sam114；Git单次使用该账号helper，未改全局配置。
- 原有AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/log文档整理、未跟踪历史提示词/v6归档/Unity分析保留，不stash/覆盖、不混入提交。起始diff备份/private/tmp/desert-v6.8-starting-worktree.patch；文档只暂存本轮事实。
- v6.8 main2d3e98f及v6.9 mainb096db6均已正式云端复核，必要结论已入update_log，不重复跑已验收SHA；上一轮属有效源码/提交/证据进展。用户短暂暂停后已恢复。

## 步骤

1. [完成] v6.9官方原包身份/digest/CRC/JUnit/双构建/26资源/八向与两镜像/恢复/实际pose、25HUD/50详情/24图核验；全部24张正式PNG已逐张目视。
2. [完成实现，待云端] 三份实体指令/四份集火节点预建复用、entityLayer到本地端点转换、focus根重挂；留空括线/紧凑标签与细HP、短暖色普通炮迹、低对比断续泡沫和范围。保留防空威胁提示原强度。
3. [完成实现，待云端] 原fixture后同一生产入口检查两父镜像端点、节点身份、根重挂与原指令/战斗/选择恢复；ready和失败trace留真实样本，validator/metadata独立核对有符号坐标；12类直接负例。不修改已验收八向资源、预算或设备。
4. [静态通过，最终审查中] git diff --check、2Python AST、6文档31链接/围栏通过；本机不import/执行CI或测试。最终diff/同步/精确暂存后提交main正常push，记录SHA/run。
5. [待办] 等精确新run官方包，检查所有必需项与24实际图，重点陆战/空军集火/海军尾流和反向意图；失败根据原日志修复，不盲延时或退本机。
6. [待办] 记录结论继续完整品质目标：固定marker构图、空军/海军及其他单位方向与动画、地图更自然、真实操作与完整对局/性能。未完成总目标不清空work或标complete。

## 本轮文件与关键符号

- GameScene：GameEntity.commandIntentLine/Tip/Cross，configureFocusFireMarker/refreshFocusFireMarker/updateCommandIntentMarker/auditTacticalOverlayRendering，showProjectile、configureNavalWakeNode及相关ready。指令取消只隐藏，死亡/迷雾沿原实体；SKRM只修渲染根重挂。
- ci/scene_evidence.py、ci/check_probe_runner.py：tacticalOverlays完整性/端点数值与直接负例；未改runner/入口/资源checker/probes/workflow。
- README/flow/图/test/log/work及v6.9美术说明只提交本轮增量与v6.9正式结论，原有文档整理不混入。
- 普通弹迹0.09…0.28s视觉飞行+0.04s淡出，不新增命中回调；固定截图留55%位置。其他导弹/火箭/海军齐射保持原入口与单次伤害。

## 已核验证据

- v6.9 mainb096db605b190119cc9acc05e48b194d6ac68310 /run42584596625/attempt1/artifact13659925122；65229344bytes/158项未加密，SHA256 e50d417d9a9e327c132e769d8b3802822988293ac53a2e3dd478f1677e745a4c与API一致，CRC/身份/正式PNG和直接trace摘要一致。缓存/private/tmp/desert-frontline-review-42584596625-attempt1/{ci-results.zip,run.json,official/,review.json}。
- 双BUILD SUCCEEDED(generic31s)，112runner/5watchdog/7资源方法；JUnit10/0fail/1准确XCTest skip；26source/bundle一致，八格透明/不同alpha，24launch八向两镜像/恢复/实际pose全真，HUD25/详情50/恢复及24原图通过；work774.075s/cleanup11.548s，无失败stage。
- 全24图已看：坦克真实不同侧/斜向视图、比例/锚点可读，无整底色/邻格串入；不是八张独立方向原图或实际移动对局。粗炮/意图线、几何尾流、大范围圈与部分固定marker在HUD后仍需优化。
- 源码确认：commandIntentNode原端点减位置后未补偿父镜像，每帧removeAllChildren重建；focus根会被SKRM effectsLayer.removeAllChildren脱挂。v6.10针对这些实际问题，不借它们改玩法。
- 原坦克八向图用户目录/Users/a114514/.codex/generated_images/1/v6.9-tank-eight.png；原RGBA及提示词md/art/v6.9-*，SHA25638cb291958468016dfc7cd59735824ac96f65df4b6bd8247eccca22df9082b2c。
- 战斗机候选4次内置生成/编辑，原图/完整提示词均存用户目录v6.10-candidates；首两稿有边缘碎片，哑光石墨灰和加边距稿更干净。选定候选fighter-eight-padded.png为1774×887/604998bytes/SHA256f7a5aef394fed9a9476bc0782460913a972a8def622c95ab8e82aa887c0bfc15，alpha0…255；尚未接入/云端验证，不能称空军八向完成。
- 百度桌面/移动入口本轮失败/超时，已搜索NobleMaster官方itch参考，不采信混淆FPS的下载站宣传；不下载商业素材。

## 精确下一步

完成v6.10最终diff与静态核对，确认同步main、身份和本轮暂存范围，正常提交/push；等新SHA官方包并逐张目视。现有固定入口无可切分输入，ready协议直接覆盖所有launch，沿用原完整集合，不额外扩跑无关对局。实际8000-byte ready gate保持，新增元数据需静态估算并由真实run核实。

- 最终diff和静态检查通过（2AST/1JSON/6文档31链接），ready新元数据静态估算5245bytes，原8000-byte gate不变。只暂存本轮11文件及必要文档增量；准备main提交/正常push。
