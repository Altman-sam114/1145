# 当前任务

## 总目标与本轮验收

- 持续迭代Desert Stormfront风格RTS，改善美观易操作的HUD、精细陆海空兵模/战斗/地图，使用原创生图与云端验证；不冒称完整复刻或整体高档品质已全部完成。
- v6.11已正式云端复核，全24图目视。当前有限增量v6.12：战列舰八方向图集与原渲染链路接入；消除迷雾重叠格边黑线，只改绘制，不改可见性集合/敌军认知/数值/碰撞/胜负。
- 验收：新SHA云端generic+simulator构建；29资源source/bundle与四个方向图集；战列舰八向×两父镜像/几何/恢复及实际姿态，原坦克/两空军/叠层/25HUD/50详情/24正式图保持，逐张目视迷雾边界和舰体锚点。
- 本机仅Git/文本/diff/AST/JSON/图像元数据，不编译/运行App/模拟器/探针/回归，不开子智能体；不改workflow、设备、预算或追加无关对局。

## 现场与归属

- main HEAD/origin/main=38bd6ef9f14fb923568509d2169237dae67a920e；origin=https://github.com/Altman-sam114/1145.git，账号Altman-sam114。
- 原有AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/log文档整理与未跟踪历史提示词/v6归档/Unity分析保留；不stash/覆盖/混入。v6.12起始备份 /private/tmp/desert-v6.12-baseline/；文档只暂存本轮增量和v6.11正式结论。
- v6.11官方包身份/digest/CRC/JUnit/双构建/28资源/两空军方向/25HUD/50详情/24图均通过，证据 /private/tmp/desert-frontline-review-42638430426-attempt1/，结论已写update_log。无需重跑旧SHA。

## 步骤

1. [完成] v6.11正式包与全部24原图目视；云端generic57s无卡死，模拟器完整入口17分59秒。
2. [完成候选，待接入] 战列舰3次内置生成/编辑：首稿白底、第二稿红边残片，第三稿石墨灰水线较干净；原图/完整提示词在用户目录v6.12-candidates。
3. [完成实现，待云端] 接入战列舰八向，复用解码/朝向选择与实体生命周期，新增直接云端姿态/恢复证据，不改海战规则。
4. [完成实现，待云端] fog tile去掉1pt重叠并关闭形状边缘抗锯齿，保留每格alpha/集合和实体过滤，云端实际图检查是否消除黑线且没有可见裂缝。
5. [静态通过，待提交/云端] 静态diff/AST/JSON/链接和资源摘要检查，更新相关文档，安全同步/精确暂存main提交push；下载新SHA正式包逐项复核与24原图目视，按证据修复。
6. [待办] 保存结果与剩余范围：航母/潜艇/其他陆军方向和动画、更自然地图、真实触控/完整对局/长期性能；总目标未完不清空work或冒称complete。

## 编辑范围与关键符号

- GameScene：方向解码/通用sprite方向选择、Battleship姿态及audit、drawMap fog绘制。
- Art/Directions/battleship-eight.png与manifest；ci/check_unit_art.py、scene_evidence.py、check_probe_runner.py直接新增合同。
- md/art来源/完整提示词，README/flow/图/test/log/work只相关增量，不混入原文档整理。

## 已有证据与精确下一步

- v6.11 main38bd6ef /run42638430426/attempt1/artifact13686675379，63926872bytes/158项，SHA25631aa6f08d483e6fca0f9ec0557d5b8758f6f1bb2d84fe7c4285bf7885448beba；115runner，28资源/25HUD/50详情/24图通过，ready6548bytes，work1067.846s/cleanup10.735s。
- 战列舰候选 /Users/a114514/.codex/generated_images/1/v6.12-candidates/battleship-eight-graphite.png，1774×887/784556bytes，SHA2569f1e6dee64733d73c5f926439d63527ee220ab774e770ba97ccdb22a368a9ad0，RGBA alpha0…255，尚未接入/云端验证。
- 百度桌面/移动搜索入口均不可达，已核对NobleMaster官方itch与公开截图；旧operationstormfront域名已为无关页面，不作为游戏依据。不下载商业素材。
- 下一步实现上述有限增量；云端必须新SHA，CPU方向样本不代替全部方向屏幕/真实触控或对局。

- 静态通过：3Python AST/2JSON、29资源路径/摘要、6文档40链接/围栏、git diff --check。ready估算7367bytes，原8000门槛保持；未本机运行CI/探针或编译。fetch/pull --ff-only成功，账号仍Altman-sam114。下一步精确暂存本轮实现与v6.11正式结论，main提交/正常push，等待精确新run。
