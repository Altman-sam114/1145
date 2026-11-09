# 当前任务

## 目标与边界

- 总目标沿用：从最新main持续改善Desert Stormfront风格RTS的UI、兵模、地图和陆海空表现，修复云端构建；使用原创生图，只云端编译/运行/探针，不启动子智能体。
- 当前有限增量v6.8：据v6.7官方失败包修复小屏pending指令被截断；保留关键全文与原布局/路由门槛，核验v6.7新特效的实际正式画面。八方向坦克图集先作候选，未达标不接入。
- 验收：新SHA云端generic+simulator构建、25资源source/bundle、25HUD/50详情状态/关键全文与24正式图，逐张核验。完整复刻、全方向动作、真实UITouch、完整对局和长期性能仍未完成，不能冒称发行品质。
- 不改伤害、AI、经济、寻路、目标/迷雾合法性或单次结算；不放宽任何失败gate/预算，不做无关重构。

## 现场与归属

- main HEAD/origin/main缓存=2a2235bad2b05b252479101de0cf11dedabb6b06；origin=https://github.com/Altman-sam114/1145.git，活跃账号Altman-sam114。
- 恢复时已有AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/log文档整理及未跟踪历史提示词/v6归档/Unity分析。全部保留，不stash或混入提交；初始diff备份/private/tmp/desert-v6.8-starting-worktree.patch。
- 2026-11-09本轮fetch/pull --ff-only均已成功，main与origin/main未前移。此前间歇TLS/HTTP2错误，用单次HTTP1.1及有界连接诊断恢复，未改全局配置。

## 步骤

1. [完成] 核对v6.7官方run/attempt/SHA、API摘要、未加密zip CRC、manifest/JUnit/构建/失败HUD原始证据，定位具体6组截断。构建成功而非编译卡死。
2. [完成实现，待云端] pending短指令、命令标题保留完整语义，pending不再拼接无关防空摘要；不修改全文gate。共享玩法/选择/路由/重置不改。
3. [静态完成/准备提交] diff检查、5文档28链接/围栏通过；安全同步完成，仅暂存本轮源码/日志/work，正常推送main。
4. [待办] 等待精确新SHA云端，下载官方未加密包并核验25资源/HUD25/详情50/24原生图，重点任务正文、四类pending与海空特效。失败据新证据修复。
5. [进行中/独立候选] 内置image_gen成功生成8向坦克草图，已存用户目录。首图RGBA但1774×887不等分、第二格朝向重复；alpha范围8…255、角点90，背景并不透明，尚未接入。第二次同工具编辑已修正重复朝向并真实去底(alpha0)，原RGBA 1774×887/1524367bytes/SHA25638cb291958468016dfc7cd59735824ac96f65df4b6bd8247eccca22df9082b2c和完整两次提示词已保存；实际加载/锚点/运动尚未验证，不声称八方向已完成。
6. [待办] 记录验收、继续总品质目标的下一个有限增量；必需证据未完成不清空工作台或标总目标完成。

## 本轮编辑与验证

- GameScene.updateHUD：pending提示文案/防空摘要呈现条件；work与update_log只提交本轮事实。
- 未编辑workflow/预算/设备策略/工程/玩法/资源清单。候选图仅存用户目录，不参与本次构建。
- baseline：git diff --check、文档本地链接与规则一致性；本机不运行CI checker/测试/Swift编译/模拟器。
- direct：现有云端固定入口不能分割；HUD小屏/多pending及v6.7海空特效仍需完整原集合。不额外扩跑其他对局或长期性能。

## 精确证据与下一步

- v6.7 main2a2235b/run42578898847/attempt1/artifact13656407685；142799bytes/33项，SHA256=ea13e9678c2ee812acec95dedb041b305ed81e6c0b5905fd28904ffdaa892007，与API一致，未加密/CRC通过。缓存/private/tmp/desert-frontline-review-42578898847-attempt1/{ci-results.zip,run.json,job.log,official/}。
- generic和simulator日志均BUILD SUCCEEDED，111runner方法通过，25资源source/bundle可查；HUD状态恢复true，375/393/402高小屏air与naval的selected全文false，其余19组合通过。JUnit10/4fail/1XCTest skip，24截图未运行，不能当作图片验证。
- 失败阶段hud-contract-read-and-validate；boot40.553s/安装成功，work194.121s/cleanup5.935s；无编译卡死证据。pending原长句又追加防空摘要是生产逻辑原因，修短句而不放宽门槛。
- GitHub API/下载遇间歇TLS超时，curl HTTP1.1有限重试成功取得身份/日志/原包；未更换账号、改全局配置或重跑CI。
- 2026-11-09尝试百度桌面/移动入口均不可访问/超时；官方NobleMaster itch页面已搜索找到用于参考定位，不采信下载站混淆FPS的宣传，不下载商业素材。
- 精确下一步：baseline并完成fetch/pull；本轮patch审查/精确暂存/正常push，记录新SHA/run后等待核验。生图候选不阻断修复。
