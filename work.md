# 当前任务

## 总目标与验收边界

- 持续朝Desert Stormfront风格RTS迭代，全面重构美观易用的UI、精细地图/兵模/陆海空战斗，修复云端构建，尝试并实际使用原创生图。只云端编译/运行/探针，不启动子智能体，不引入未授权付费/商业素材。
- 当前有限增量v6.9：坦克八方向原创图集进入同一实体渲染链，统一格尺度/地面pivot与父镜像补偿，补资源和生产函数八向证据。不是把总目标缩成一辆坦克；其余单位方向/整体视觉、真实触控、完整对局与长期性能仍需继续。
- 本轮验收：精确新SHA的云端generic+simulator构建、26资源source/bundle（逐格alpha）、8向×2父镜像/恢复/实际pose、原25HUD/50详情/24正式原图及逐张目视。缺图/错误/未恢复不放宽gate或退回本机。
- 不改伤害、AI、经济、寻路、合法目标/迷雾、单次结算与SKRM玩法；不改workflow/预算/设备策略/工程。

## 现场与归属

- main HEAD/origin/main=2d3e98f776c5bf5f59c5a0e49e6264f86fc0892f；origin=https://github.com/Altman-sam114/1145.git，账号Altman-sam114。2026-11-09再次fetch/pull --ff-only成功，远端未前移。
- 原有AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/log文档整理、未跟踪历史提示词/v6归档/Unity分析仍保留；不stash/覆盖、不混入提交。起始diff备份/private/tmp/desert-v6.8-starting-worktree.patch；本轮文档只暂存增量。
- 上一轮属于有效进展：v6.8修复提交/推送、官方失败定位、新生图与v6.9接入均落盘。用户暂停后已恢复，未把观察超时当作CI停止，没有重复dispatch。

## 进度

1. [完成] v6.7原包定位6组pending全文失败：两次构建成功，非编译卡死；v6.8缩短四类指令、pending不拼防空摘要，保留全文gate，已main提交/推送。
2. [完成] v6.8官方包身份/digest/CRC/JUnit/双构建/25资源/HUD25/50详情/24图原始证据核验，全部24正式图逐张目视；必要结论已追加update_log。
3. [完成实现，待最终自查] 两次生图修正，原RGBA复制项目/用户目录；GameScene八格加载、生产方向函数与精确恢复，source/bundle逐格检查、ready/validator/直接负例与必要来源/架构/测试/README已同步。
4. [静态通过，待审查提交] diff、3Python AST/2JSON、7文档33本地链接/围栏、原字节SHA一致已通过；未运行本机checker、测试、Swift编译或设备。最终diff/文档增量审查后，精确暂存main提交/正常push，记录SHA/run。
5. [待办] 等待新SHA云端官方未加密包，检查26资源、8向/两镜像/恢复/pose、25HUD/50详情/24原图，重点基地/陆战/战损/选择。失败据原始证据修复。
6. [待办] 记录正式验收后继续下一有限增量：降低陆战粗炮线/命令与几何尾流遮挡，并处理固定marker在HUD下的问题；完整品质总目标尚未完成，工作台保持活动。

## 本轮编辑范围

- GameScene：GameEntity.artworkHeading（纯视觉）、tankDirectionTextures、loadTankDirectionArtwork/updateTankArtworkFacing/refreshTankArtworkFacings、auditTankDirectionArtwork及ready单位门槛；同一artworkNode、fog/血条/尘/战损/死亡生命周期。
- Art/Directions/tank-eight.png、unit-art-manifest，ci/check_unit_art.py逐格非空/透明/不同alpha；ci/scene_evidence.py与check_probe_runner.py新增直接方向协议负例，未改runner预算/模拟器入口或workflow。
- md/art/v6.9-*、v6.0单位方向说明、README/flow/图/test/log/work只提交本轮事实，原有文档整理不混入。

## 精确证据

- v6.8 main2d3e98f/run42581147286/attempt1/artifact13657901898，65241140bytes/158项未加密；SHA25685ce88236614f60b94b25ff659871fdd79b65212bbaf217e0998b7c1d3132d45与API一致、CRC/身份/PNG和trace摘要正确。缓存/private/tmp/desert-frontline-review-42581147286-attempt1/{ci-results.zip,run.json,official/,review.json}。
- 双BUILD SUCCEEDED，111runner/5watchdog/6资源方法；JUnit10/0fail/1准确XCTest skip；25source/bundle一致，HUD25关键全文/详情50/恢复true、24独立正式图、无失败stage。work711.025s/cleanup10.082s，首次generic约29s，总job13m49s，不存在本次编译卡死。
- 已看24图：全文、自然水柱/火焰烟尘、三机纹理、正向CONTACT正确；粗炮线/常驻命令虚线、几何尾流/大范围圈和部分被HUD遮挡的固定marker留待下一视觉轮，不能冒称真实触控验收。
- v6.9八向图原图1774×887/1524367bytes/SHA25638cb291958468016dfc7cd59735824ac96f65df4b6bd8247eccca22df9082b2c；两次内置image_gen及完整提示词保存在md/art/v6.9-generation-prompts.json和用户目录v6.8-candidates，选定图另存/Users/a114514/.codex/generated_images/1/v6.9-tank-eight.png。
- 现有云端固定入口不可分割，ready协议覆盖每个launch，因此沿用完整原集合；不增加无关对局/长期性能。ready新增元数据静态估算约5KB，实际8000-byte gate保留。
- 百度桌面/移动入口本轮失败/超时，已搜索到NobleMaster官方itch参考，不采信下载站混淆FPS宣传；历史当前参考边界见md/art/v6.0-unit-art.md。

## 精确下一步

最终审查v6.9 Swift与直接协议，baseline复核文档增量；确认main/origin与本轮暂存范围，提交/正常push并等待精确新run。v6.8已正式复核，不需再重跑同SHA。
