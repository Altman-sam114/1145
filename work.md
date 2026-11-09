# 当前任务

## 目标与边界

- 总目标：从最新main继续Desert Stormfront风格RTS，全面改善UI/兵模/地图与陆海空战斗，修复云端构建；原创生图、只云端测试、不启动子智能体。
- 当前有限增量v6.7：修正v6.6实图任务正文/默认摘要被过度截断的问题，补正常关键文本完整显示门槛；接入两张新生成水柱/火焰烟尘，细化海空特效、复用飞机贴图取代舰载机箭头，降低粗弹道光晕。
- 验收：原26动作/5页/44pt控件/详情50态/25HUD/24原生图保留；关键任务和默认指令可完整读；25资源source/bundle与20实体+3环境+2效果实际加载/相关固定图挂载；新SHA云端双构建、JUnit/日志/manifest及逐张目视通过。
- 不改伤害、AI、经济、寻路、目标合法性、单次伤害/可见性链路；不本机构建/运行/探针/测试，不开子智能体。完整复刻、全方向动画、真实UITouch、完整对局和长期性能不冒称已完成。

## 现场与归属

- main / HEAD / origin/main=f7c9b54b8a2dd97f0889632e343278e2f6c13d95。2026-11-09已fetch，提交前再次确认和pull --ff-only。origin=https://github.com/Altman-sam114/1145.git，账号Altman-sam114。
- 起始既有AGENTS/README/flow/图/test/prompt索引/log文档整理、工程Team ID两行、未跟踪历史提示词/v6归档/Unity分析保留；文档只暂存本轮事实，不混入原有整理；不stash/覆盖。
- v6.0至v6.6均在main；v6.5美术/64pt卡正式验收，v6.6技术成功但目视发现任务正文与少数摘要高度问题，本轮必须修复。

## 步骤

1. [完成] v6.6原包核验与24图逐张目视，技术通过/真实一次查询恢复/文字问题已写update_log。
2. [完成实现，待云端] 任务卡36pt、关键字槽12pt、正常源文完整显示门槛；两图接原效果入口、原飞机纹理替换舰载机箭头、细化六类弹道；潜艇接触字抵消镜像。共享状态/伤害/延迟/目标门槛未改。
3. [完成静态，待云端] 25资源清单/checker/来源和17项直接协议负例同步；source/bundle的原alpha/CRC门槛保留，相关fixture要求水柱/火焰/三机贴图/接触字实际挂载。diff、3Python AST、3JSON、8文档41链接/围栏通过；资源图原字节复制用户目录/项目。ready新增元数据静态估算4291bytes，真实8000-byte gate不变。
4. [进行中] 2026-11-09已fetch/pull --ff-only，main未前移。准备精确暂存/提交/正常push，等待新SHA云端现有固定入口。
5. [待办] 下载官方结果包核对摘要/CRC/身份、双构建、25资源、25HUD+50详情、24原图与新效果挂载；不以旧包/绿状态代替。失败依据证据修复，不盲目重跑。
6. [待办] 记录正式结论，根据仍需完成的原型品质目标继续有限迭代；必需验收未完成不清空工作台或标总目标完成。

## 本轮编辑范围

- GameScene：HUDLayout关键字槽/关键源文完整性；Effects共享384px解码缓存及effectsLayer原入口；舰载机用原飞机纹理、相关弹道样式；CI ready/fixture加入实际挂载与文本事实。
- Art/Effects、水柱与火焰两图、unit-art-manifest、ci/check_unit_art.py；必要ci/simulator_probe.py、ci/check_probe_runner.py协议/负例。来源md/art/v6.7-*与README/flow/图/test/log/work只提交本轮增量。
- 不改workflow/预算、设备策略、工程文件与玩法数据。

## 证据与候选

- v6.6：run42574668725/attempt1/main/f7c9b54，artifact13655636333，65,045,228bytes/159项未加密；SHA256=772c83bb55ac89ee8dc7f733b0f3828c665c8de2263ad5a6d9bc5d5cb6e601a8，与官方一致、CRC/身份/PNG/trace正确。缓存/private/tmp/desert-frontline-review-42574668725-attempt1/{ci-results.zip,official/,review.json}。
- 双BUILD SUCCEEDED，111runner+5watchdog+6资源方法通过；JUnit10/0fail/1准确XCTest skip、23source/bundle一致、HUD25/详情50态/恢复true、24/24原图。首次launch help超时124后原有一次重试0.805s成功（真实恢复）；boot138.475s，work789.309s/cleanup15.084s。
- 目视全部24：默认44pt卡/Info/Close和提示消失正确，Orders小屏HUD面积44.75%/35.11%/33.68%；任务详情Ho…及少数Read…/帮助短文不完整。合法ellipsis不代表易读，需字槽高度和关键全文门槛。水柱柱体/霓虹弹道/舰载机箭头是下一美术问题。
- 内置image_gen两次成功；原RGBA未脚本编辑。/Users/a114514/.codex/generated_images/1/v6.7-candidates/{water-impact.png,impact-burst.png,generation-prompts.json}。
- water SHA256=b3223cd9929fbb664f81ae687f206cb07a62175d123bc121ab625c576497cff4（1312×1199/1,377,613bytes）；impact SHA256=9026d7bcb55511611a3becf7014222f22a5ab4b94c78eae735d7705f04e2ef71（1536×1024/1,696,917bytes）。原始生成路径和完整提示词在JSON；待复制项目并经云端真实alpha/随包/画面验证，不先宣称接入。
- 下一render helper草案/private/tmp/desert-v6.7-effect-helper.swift（未入源码）；复核辅助/private/tmp/desert-review-current-artifact.py只读云端包，不执行App/CI脚本。失败stage记录允许原有成功恢复，不能误把synthetic日志或可恢复一次超时当整体失败。

## 验证选择与下一步

- baseline：git diff --check、相关Python AST/JSON、文档本地链接/围栏；本机不执行checker或测试。
- direct：云端generic+simulator构建，25资源source/bundle检查，关键全文/25HUD/详情50态/24正式截图，重点陆战/海战/航母/飞机与展开详情。现有固定入口不能切分，UI与多种战斗画面均改变，复用原集合；不加无关玩法或全量对局。
- 当前无须用户确认的阻塞。下一步先落实HUD36pt任务卡/12pt必要文字槽与关键正常源文门槛，再复制新素材并接入原特效入口；任何失败以精确新包为准。
