# 当前任务

## 总目标与本轮验收

- 持续迭代 Desert Stormfront 风格 RTS，改善美观易操作的 HUD、地图、陆海空兵模与战斗；使用原创生图，云端验证，不以有限增量冒称完整复刻或全面高档品质完成。
- v6.10 已正式复核；当前 v6.11：战斗机八方向接入，尝试并筛选直升机八方向；统一 HUD 字体与面板/按钮层次，修复固定命令截图被底栏遮挡。
- 验收：新 SHA 云端 generic + simulator 构建；新增图集 source/bundle、八向×两父镜像/几何/状态恢复与实际姿态；保留原坦克/叠层、25HUD/50详情与24正式PNG，逐张目视。固定 marker 需完整出现在可操作战场中。
- 本机只 Git/文本/diff/AST/JSON/图像元数据等静态；不编译、不运行App/模拟器/探针/回归，不开子智能体。不改战斗数值/AI/迷雾/任务/SKRM规则，不改CI预算或扩无关对局。

## 现场与归属

- main HEAD/origin/main=90aaaf93e557930510aa8a389fa618afab72649e；origin=https://github.com/Altman-sam114/1145.git，gh账户 Altman-sam114，2026-11-09再次fetch/pull --ff-only成功。
- 起始 AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/log 文档整理与未跟踪历史提示词/v6归档/Unity分析保留；不stash/覆盖/混入提交。本轮基线备份 /private/tmp/desert-v6.11-baseline/。
- v6.10 run42589790371/attempt1/artifact13662086373，ZIP身份/digest/CRC/JUnit/双构建/直接trace与26资源/25HUD/24原图已核验，证据 /private/tmp/desert-frontline-review-42589790371-attempt1/，结论已写更新日志。

## 步骤

1. [完成] 核对最新main与云端，下载并核验v6.10精确官方包，全24图逐张目视；百度搜索入口不可达，已核对NobleMaster官方itch资料，不下载商业素材。
2. [完成实现，待云端] 使用内置imagegen；沿用战斗机4次候选中干净带边距稿，直升机首稿有彩色残片且边距不足，针对性清理/缩小第二稿进行中。候选原图/提示词保留用户目录，选定逐字节复制仓库。
3. [完成实现，待云端] 复用现有方向渲染入口扩展空军，正确抵消父镜像，共享移动/已知目标朝向；新增直接资源与恢复证据，不创建平行玩法状态。
4. [完成实现，待云端] HUD统一正常宽度字体、简化重复边框、当前页底部强调；保留44pt命中/完整文字。固定命令截图调整位置并补屏内无遮挡合同。
5. [静态通过，最终审查中] 静态自查、相关文档、精确暂存本轮改动，main提交/正常push。等待精确新SHA官方包，核对双构建、原生截图与相关探针；失败按证据修复。
6. [待办] 保存正式结论。整体目标剩余海军和其他陆军方向/动画、自然地图、真实操作/完整对局与性能，不清空总目标或冒称完成。

## 本轮编辑范围

- DesertFrontline/GameScene.swift：方向纹理/姿态、HUD绘制、固定截图布局；Art/Directions与资源manifest。
- ci/check_unit_art.py、ci/scene_evidence.py、ci/check_probe_runner.py：新增资源/方向/固定标记直接证据。保留原workflow/probes/runner/设备与预算。
- md/art新增本轮图集来源和完整提示词；README/flow/图/test/log/work仅本轮相关增量。

## 当前证据与下一步

- v6.10原包 SHA256 32abd88cee00825cfcde06c04677ba1ced2286f0bbcf4e55c09a977c7bed93ec，113runner/26资源/25HUD/24图通过；generic约41s，boot156.608s，work1041.926s/cleanup14.502s。不是编译卡死。
- 战斗机候选 /Users/a114514/.codex/generated_images/1/v6.10-candidates/fighter-eight-padded.png；1774×887/604998bytes，SHA256 f7a5aef394fed9a9476bc0782460913a972a8def622c95ab8e82aa887c0bfc15，已目视，待接入。
- 下一步：检查直升机清理稿透明与格内布局，决定是否接入同一有限增量，再实现方向/HUD/标记并云端验证。

- 图集已接入：战斗机原4稿选定；直升机本轮3稿选哑光清理稿，1774×887/760365bytes/SHA256 36f5573bbeeb0cae30401853006fb1ef04be0a9ef8e06fe716b135f00b59b403。原图/提示词已保存用户目录和md/art。
- 两空军方向/两镜像/几何/恢复与实际姿态及subject协议实现；原26资源增加至28，不改workflow/probes/预算。HUD正常宽度字体和细状态线、三个固定命令实际包围框无遮挡检查实现。静态3AST/2JSON/28路径digest/5文档链接围栏/git diff --check通过；未本机运行任何测试。
- 精确下一步：最终审查本轮diff并安全同步main，精确暂存新代码资源及文档增量，提交正常push；等待精确新run官方包复核。
