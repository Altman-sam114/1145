# 当前任务

## 目标与边界

- 从最新 `main` 继续 Desert Stormfront 风格 RTS 视觉与易用性重构，先交付可实际运行的统一美术基线；使用原创生成素材，不搬运商业游戏资产。
- 本轮验收：陆海空十种机动单位真实透明贴图随包加载；HUD 清晰、按钮易点且明显减少遮挡；地图/建筑与单位风格一致；精确实现 SHA 的云端双构建、HUD/资源契约和原生截图证据通过。
- 不改经济/战斗平衡，不建立平行玩法系统，不做本机编译、运行、探针或模拟器操作，不启动子智能体。

## 现场与归属

- 分支 `main`，起点 `699e172c8b48bbfdaf23868c8d67aac3c79fd32b`，2026-10-28 已 fetch / pull --ff-only，远端一致；GitHub 活跃账号 `Altman-sam114`。
- 起始已有修改：GameScene 的单位贴图/初步 HUD、Art 文件夹、工程资源项、workflow/runner 的资源检查入口与预算；本任务沿用并补齐相关半成品，不丢弃。
- 起始已有文档整理（AGENTS/README/flow/test/prompt/log）、历史未跟踪提示词/Unity 分析和签名 Team ID 均保留；不把无关内容混入提交。提交前逐块核对。
- 最新云端 run `40165304151` / v5.69 的官方原包已核验；只作为旧版基线，不冒充本轮结果。

## 步骤

1. [完成] 读取当前渲染/HUD/CI；核验 v5.69 官方 ZIP digest/CRC、身份、JUnit、24/24 原生证据；百度桌面遇跳转/验证码，移动端已返回游戏条目；已目视项目原有 Desert Stormfront 参考截图，不采用 AI 汇总或下载站宣传作为权威事实。
2. [完成基线] 已尝试内置生图 7 次，当前会话全部 503；已接续十种既有兵模，增加 384px 透明边距归一化、实际贴图 ready 元数据；v6.2 精确官方包中 source/bundle 十资源和6项直接正负例通过。新生成素材通道仍不可用。
3. [进行中] HUD 底部分类/窄资源栏/小地图、水平生命条/阵营点、四类设施与村落、材质基线已获v6.2双构建/HUD25/24图技术证据；v6.3按实际画面修正黑图标、道路底色/对角连通、沿边浅水、曲线棕榈与门窗细节，当前尚未提交/云端验收。
4. [完成v6.2复核] main精确 `99276c262481e9c8b40b37f6461e92c59be2546a` / run40706434687 / attempt1 官方ZIP摘要/CRC/身份与报告通过；不放宽gate、不以旧run替代新实现。下一步v6.3静态自查、逐块提交main并下载新SHA官方包。
5. [待办] 修复证据暴露的问题，记录长期结论；只有全部所选验收完成后清理本工作台。

## 编辑范围

- 已编辑：`DesertFrontline/GameScene.swift`、新增 `ci/check_unit_art.py` 与 `md/art/v6.0-unit-art.md`、workflow self-test/有界预算、`ci/package_results.py` 资源报告索引、本工作台；沿用未提交 Art/工程/runner 半成品。对应 README/flow/test/log 增量已补，逐块暂存，原有无关文档整理保留未暂存。
- 以实际增量为准，不批量格式化或重写历史提示词。

## 验证与证据

- 本机仅 `git diff --check`、相关 Python AST/JSON/YAML 解析、工程 plist 格式与文档链接检查。
- 云端 baseline：generic iOS device build；direct：资源随包完整性、模拟器启动、25 组 HUD 生产布局/路由/恢复契约及相关陆海空原生截图。当前入口固定 24 探针，全面视觉重构涉及全部画面，首次可复用该集合，不额外扩无关测试。
- 本轮未执行任何本机编译/测试/设备命令。
- 2026-10-28 静态检查：`git diff --check` / `git diff --cached --check`、三个相关 Python AST、资源清单/probes JSON、workflow YAML、工程 `plutil -lint`、本轮文档链接均通过；未执行新 checker 自测或任何本机回归。已在 main 提交 v6.0 `7ba2ab308d7eeff44bbc051726ff0e7ef8da77dc`，仅本轮授权24文件；用户 Team ID 与无关文档/历史资料未提交。push 前确认 origin 为 Altman-sam114/1145，待推仅此一提交，当前账号 Altman-sam114。
- v5.69 原包：`/private/tmp/desert-frontline-review-40165304151-attempt1/official-parallel.zip`，artifact `12588462536`，SHA256 `0a94649ee1df8866e37a725cb0633a942a2b18fb709dce94751ae6bba21cef43` 与 API digest 一致、全项 CRC 正常；results 下原生 PNG / JSON / JUnit。branch/main/SHA/run/attempt 一致；双构建通过、24/24、JUnit10/0fail/1准确skip。旧小屏战术页 HUD 占屏 70.7%；总 runner1055.028s、work1039.732s，仅余40.3s，generic build约40s，不是 Swift 编译卡死。

## 生图通道调查（用户追加要求）

- 当前调用 carrier 去背景 / HQ / scout / sand texture 共 4 次，均 `gpt-image-2` / team 通道 503 No available channel，没有新生成成功，不擅自改用 CLI/收费 API。
- 用户指出其他项目能生图后，只读核对相关成功调用与图片：rome / Rustwar / easytech 均用同一 `image_gen.imagegen` 内置工具，当前时段有真实 PNG；没有给其他聊天发送消息，没有启动子智能体。
- 只读会话设置发现关键差异：本线程 `01a18284-c517-7100-87ad-bb188f2cf57c` 当前 model=`boa-hb/gpt-6.1-sol`；rome 与 Rustwar 为 `boa-xu/gpt-6.1-sol`。这是观察到的路由差异，尚未证明切换即成功。
- 已向用户询问是否允许仅将本会话切到 `boa-xu/gpt-6.1-sol` 并发送续行消息；未获确认前不改设置或发消息。没有修改全局配置/数据库，没有读出或输出密钥。环境无 `OPENAI_API_KEY`；只读模型发现接口不列图像模型。官方 OpenAI 图片文档两个域名均返回403，不据此臆测可用性。
- 恢复后第5次直接生成全新透明侦察车仍503，request id `202610281422501166835938268d9d6q5Pz1DH1`，错误明确为 `gpt-image-2` / `team` / distributor无可用通道。再次只读核对Rustwar实际imageGeneration成功记录及easytech/Rustwar美术来源：都使用同一内置工具，无独立插件或CLI/API key路径。工具当前不暴露model/provider切换参数，不向prompt伪加路由参数，不擅自转收费API。两个官方文档域名再次403。
- 恢复后又以SQLite mode=ro仅取这4个线程的rollout路径、仅解析turn_context.model：本线程最新14:21:56仍boa-hb/gpt-6.1-sol；rome、Rustwar、easytech三个成功项目均boa-xu/gpt-6.1-sol，model_provider均magpie。没有读取认证值或修改数据库，路由关联再次确认但未实际切换验证，不把它写成已修复。
- 相隔约30分钟，第6次改走真实本地carrier引用图的编辑/去背景请求，仍同一gpt-image-2/team通道503，request id `202610281453440502744568268d9d6cMUGKQBv`。无新生成PNG、未修改carrier原图；直出与编辑两种内置路径都已证实当前失败，不继续只改prompt机械重试。

## 下一步

下一有限增量 v6.4：仅修复云端boot证据的浮点序列化，将deadline相对秒数与其他时间字段一致保留6位小数，原严格budget gate不放宽；增加生产boot方法的非二进制时钟原点正例与实际deadline偏移负例。本轮只改runner、该直接回归与日志/work，GameScene/美术/HUD保持v6.3原样。baseline=diff/两个Python AST；direct=云端新回归、真实启动/预算门禁以及现有完整入口的双构建/HUD25/24图，首次失败包保留，不再盲目重跑。真实触摸、完整对局和长期性能仍须后续独立证据。

## 推送链路与云端证据

- 原 push exec session42134已终止，exit128，原始错误 SSL connection timeout；HTTP/1.1只读ls-remote session40649也已终止，exit128/30s low-speed。不是只因观察超时就重启命令。
- 原进程存活期间查看过socket与远端ref，彼时远端保持699e172；GitHub API仍能访问同一repo。本机现有公钥/agent无Altman-sam114匹配，不尝试其他账号SSH、不生成新身份。
- 官方API发布助手 `/private/tmp/desert-v6-git-api-publish/publish.py` / session83103 已真实退出0；receipt.json保留24个blob、根tree `e147a234c3822a01e7f0891cb018b04b5dcdd9c7`、精确commit和force=false更新回执。先重建既有parent证明API保留Git对象字节身份，再上传已提交对象，不读取未提交工作树作为发布内容。
- 后续独立GitHub API重新核对main=7ba2ab3、parent=699e172、24文件和tree均一致；再以旧值比较保护同步本地origin/main跟踪ref。没有改本地main历史、远端URL、全局配置或证书校验；不把失败的git push宣称为成功命令。
- GitHub真实触发push事件 run40699552229/attempt1，2026-10-28T13:46:39Z创建，head精确7ba2ab3，已in_progress；watch session38212负责现有run，不能用旧40165304151替代。

## v6.0 云端复核与直接修复

- run40699552229/attempt1/main7ba2ab3 completed/failure；artifact12821393791，153519bytes，SHA256 `09b7b672f3e0bf77a34a63d6f8283b521b45cb52fffe245070e0fd5fea4e34a3` 与API digest一致，全项CRC正常。缓存 `/private/tmp/desert-frontline-review-40699552229-attempt1/`。
- generic与simulator日志均真实 BUILD SUCCEEDED；5 watchdog、100 runner方法、6资源正负例通过；source/bundle各10资产事实逐项完全相同，alpha/digest/尺寸均通过。boot、install和实际ready生产阶段正常，不是编译挂死。
- 失败准确在hud-contract-read-and-validate：25矩阵中15个小屏case仅selection rows超框；其余8类均true，actualLabelAudit零失败，stateRestored=true。0正式截图完成、24not_run，JUnit10/4fail/1准确skip，不作视觉通过。
- 最小375高战术页panelAreaFraction=0.543824（旧0.707），实际874x402战术页0.406230；这是布局CPU证据，不是GPU图片或手感认证。
- 原row fitter仅按宽度缩放，不按字体真实glyph高度/偏移归位。当前直接修复从HUDLayout同源slot重置位置与scale、按宽高拟合并以真实ink bounds左对齐/垂直居中；原0.5pt containment gate保持。矩阵新增selectionRows实际slot/bounds/font/scale证据，便于后续精确复核。
- 本次只改GameScene行拟合与该直接证据，未改经济/AI/战斗、shader贴图、预算、boot策略、24集合或失败阈值。需新实现SHA的云端验收。

- v6.1修复前已重新以单命令HTTP/1.1+low-speed限时执行真实 `git fetch origin` / `git pull --ff-only origin main`，均成功（session35266退出0）；main/HEAD/origin均7ba2ab3。未改全局Git配置，优先恢复正常Git传输。

- v6.1修复已提交并以正常Git push发布 main `8898d790e430cdd56f3cd98d87626f0218b41b99`（3文件，原有无关改动继续保留）；恢复时HEAD/origin/main均为该SHA。新push run `40704352161` / attempt1 / main / 精确SHA已启动，当前in_progress；不重复dispatch。继续调查本会话可用的生图路径，不改全局配置、不向其他会话发送任务、不读取或外传密钥。
- v6.1 run40704352161已completed/failure（watch session52301退出1）；generic build真实step43s，模拟器step4m39s，不能将绿色continue-on-error步骤当作验收。官方artifact12822649332 /121271bytes /SHA256 `1e39b3bc7c794845446fff1ac4a38c2ecba4abfe19d12fd7659ba09c61bb27d8`，下载session88039，待精确包核对失败点；不在未读报告前盲改或重跑。
- v6.1官方ZIP已下载，字节数/API digest/全项CRC、main/完整SHA/run/attempt一致。双构建真实BUILD SUCCEEDED，脚本及十种source/bundle资产成功；boot成功167s、install成功35s，之后只读 `xcrun simctl help launch` 10s空输出超时退出124（launch-output-options）。App尚未启动，HUD缺报告、0完成/24not_run，JUnit10/4fail/1skip；不能判断v6.1行拟合效果，更不能误归因为Swift编译或新UI断言。缓存 `/private/tmp/desert-frontline-review-40704352161-attempt1/`。
- v6.2已编辑：`ci/simulator_probe.py` 局部launch help、`ci/check_probe_runner.py` 对应真实生产方法的9项synthetic边界、`ci/package_results.py` 第二次help日志索引及本日志/工作台。所选验证baseline=diff/AST；direct=新增help正负路径、实际云端launch→HUD25→24PNG（现有完整入口不可切分，不增加别的游戏探针）。不改App玩法、行拟合、资源、boot/install策略、共享预算或正式失败gate。下一步静态审查、fetch/pull、精确暂存本轮5文件并发布新SHA，不运行本机测试。
- v6.2静态审查完成：`git diff --check`及3个Python文件AST解析通过；未import或执行测试。再次正常HTTP/1.1 fetch / pull --ff-only成功，main/origin仍8898d79；本轮5文件按范围暂存，原Team ID与文档整理继续排除。原workflow仍main push固定整条链路，新增9方法只属当前help故障直接边界。
- v6.2已正常commit/push main `99276c262481e9c8b40b37f6461e92c59be2546a`（5个本轮文件）；HEAD/origin一致，账号Altman-sam114。精确push run `40706434687` / attempt1 / main /99276c2 已in_progress，接下来等待这一次，不重复dispatch；成功或失败均下载官方精确包复核，不能以新query自测替代实际App/HUD/截图。
- 当前远端watch exec session54862，日志 `/private/tmp/desert-watch-40706434687.log`；14:50Z静态step、lint、generic build均结束，模拟器step仍在执行（run约20min）。未据持续时间猜测卡死、未重启/追加run，继续等原有27min有界step及上传。原生截图/HUD结果尚未可读，不提前宣称通过。
- v6.2 watch session54862已真实退出0，run40706434687/attempt1/main/99276c2 completed/success，job21m1s；双构建/模拟器/metadata/upload/final gate均success。官方artifact12825476491，55117259bytes，digest `c706d16f002db28b68a56be7f86c203458b54fe19403320ac5506baf6db59d6c`；正在session50248下载官方ZIP至 `/private/tmp/desert-frontline-review-40706434687-attempt1/`。待digest/CRC/身份/实际命令/报告/24张原生图目视复核，不能仅凭绿色交付或完成总目标。
- 原gh artifact传输持续低速，仅2653114bytes，已核对owned PID85229的精确argv后TERM结束（session50248退出143），保留前缀，不冒充下载完成。官方302同一签名blob已验证支持206/Content-Range，另保留末尾262144bytes；当前session40492以4并发HTTP Range续传25块并组装 `official-complete.zip`，需完整官方digest/CRC匹配才解包和采用。没有重跑CI或换artifact，不输出/持久化认证值与签名URL。

## 2026-10-29 恢复与 v6.3 画面收敛

- 恢复时 HEAD/origin/main=`99276c262481e9c8b40b37f6461e92c59be2546a`，已重新 fetch / pull --ff-only，安全同步且无新增他人源码改动；原有文档整理/Team ID/未跟踪历史资料继续保留。没有启动子智能体或本机运行游戏。
- 旧临时传输目录已不在本执行环境，原session不能恢复；改用官方同一 artifact 单次重新下载成功。`/private/tmp/desert-frontline-review-40706434687-attempt1/official-complete.zip` 为55117259bytes，SHA256=`c706d16f002db28b68a56be7f86c203458b54fe19403320ac5506baf6db59d6c`，与GitHub API完全一致，159项未加密、路径安全、CRC正常；原样解包至 `official/`。
- 身份main/99276c2/run40706434687/attempt1一致；generic 与 simulator 均真实 BUILD SUCCEEDED；JUnit10/0failure/1准确XCTest skip；109 runner方法、5watchdog和6资源正负例零失败。HUD25×9全部true，actualLabelAudit零失败、stateRestored=true，正式24/24，独立nonce/PID/原生图完整性通过；work1088.252s/cleanup20.968s。launch-help本run首查正常退出，不能说已动态执行真实timeout重试。
- 已实际查看战术、Build/Support、陆战、地形、战列舰齐射、航母打击等原生PNG：单位真实贴图与HUD均呈现，无黑屏/缺层；但SF Symbol呈黑色、道路灰色整格/浅水菱形明显、植被简单。这是下轮修复依据，不宣称商业品质/完整复刻或全部视觉验收完成。
- 本轮第7次内置 `image_gen` 请求原创HQ仍503，request=`202610290113373220444658268d9d63GV85HId`，gpt-image-2/team 无可用通道；未生成或接入新图，不擅自切路由、付费API或借用其他聊天。百度本轮桌面查询已正常返回Desert Stormfront游戏条目；下载站/百科的宣传细节不作为已核实玩法。
- v6.3 编辑范围预定：GameScene 的 hudSymbol / terrainSurfaceTexture / addTerrainDetail / addPalm / addVillageScenery 及相关README、flow、日志、工作台；不动单位PNG、工程签名、CI脚本或workflow。
- v6.3有限实现已落盘：SF Symbol经UIKit真实绘制后缓存；道路/岩脊复用沙地表面（最多15材质），保留孤立道路小段并补只在无正交中介时连到对角道路，避免去除灰格后隐去真实路网；浅水只沿邻陆边、减弱泡沫/波纹；棕榈曲线叶/树干/叶脉/软影、共享建筑增加门洞/屋顶内沿/通风/窗框。README/flow与图示已同步，未引入外部素材或新依赖。下一步diff/链接/范围审查，提交与云端验证。
- v6.3静态审查：`git diff --check`、`git diff --cached --check`、6份本轮文档17个本地链接/围栏均通过；人工检查CGPoint投影/对角路与共享缓存、fog/实体生命周期。本轮只暂存7文件的实现/当前功能/架构增量与新证据，既有文档流程整理和工程Team ID继续排除。远端API与HEAD仍精确99276c2，无待推旧提交；即将按原main push完整入口执行，不重复dispatch、不本机测试。
- v6.3已正常commit/push `a0f41ccfb9044428262cb6a481faaa2dca293622`（仅7文件）；HEAD/origin/main一致，push事件触发 run `40805991371` / attempt1 / main / 精确SHA，当前in_progress。watch session72978，30s间隔、日志 `/private/tmp/desert-watch-40805991371.log`；不重复dispatch。等待期间仅检查可用的远程生图通道/旧版证据，不改待验实现。
- v6.3 attempt1已completed/failure；官方artifact12868697108 /532409bytes /SHA256=`e3c42c45ab5c5f8cd43a93166e1f470bd96c58c7ea07f6767bd66ad5795d64d0` 与API digest一致、36项未加密/CRC正常，缓存 `/private/tmp/desert-frontline-review-40805991371-attempt1/official/`。双构建/资源/HUD25真实通过，App已ready并导出非gate离屏图；失败精确在prewarm-terminate原60s上限(64.261s,exit124)，后续app log/list/shutdown亦超时。0正式图/24not_run，JUnit与manifest均保留失败，不能误说nonce真实重复或美术已验收。
- 选择一次同SHA受限重跑（attempt2）：已有App-ready/HUD成功及整个simctl服务后续命令超时证据，先验证是否瞬时runner故障，不改源码/限时/失败gate，不新建或切换云端设备；同因再失败即停止机械重跑并继续有证据的调查。原attempt1官方包保留，不用attempt2覆盖。
- 生图替代调查：通过Hugging Face仓库工具找到官方 `black-forest-labs/flux-3-image-klein` 公开ZERO Space，在浏览器匿名提交原创沙地prompt，页面真实返回1024x1024 /Distilled16steps /seed55337666与原图下载链接；未上传项目图/密钥、未付费、未下载/运行模型、未借用其他聊天。原图CLI下载403、首次浏览器downloadMedia超时，已保存成功页面截图 `/private/tmp/desert-image-candidates-20261029/flux-space-proof.png`；正在用浏览器已加载资产导出。模型API license=other，许可条款与原图质量尚未核对，不将候选并入App或宣称素材ready。
- 同一run attempt2已实际queued，仍main/a0f41cc；watch session94380，日志 `/private/tmp/desert-watch-40805991371-attempt2.log`。本机待验源码未改；attempt1非gate HUD离屏图确认图标已由黑变青，但不能替代本轮0正式图的缺口。
- FLUX候选页面与exact prompt/seed/来源回执保存至 `/private/tmp/desert-image-candidates-20261029/generation.json`；DOM自然尺寸实际2048x2048，而页面标注1024x1024，准确保留两者，不冒充原图已拿到。浏览器下载事件未触发，top-level资产导出不包含跨域iframe中的生成图；不通过截屏裁切伪造原图。官方模型元数据许可名flux-kommunity-license，LICENSE.md读取得401；不登录/接受新权限/下载模型来绕过。当前仅证明远程页面生成成功，原图导出和许可是待办，仍不接入项目。
- v6.3 attempt2已completed/failure，不再重跑：官方artifact12872633543 /53879938bytes /SHA256=`6cf22410d7a1de38abd4ccd01344426922e82480fac6082e45127a1f79f62af9` 与API digest一致，159项未加密/CRC正常；身份main/a0f41cc/run40805991371/attempt2一致，缓存 `/private/tmp/desert-frontline-review-40805991371-attempt2/official/`。双构建/资源/脚本/HUD25/scene ready与24/24实际截图通过，真实boot命令正常退出0，但integrity-gate报boot evidence invalid，JUnit10/3failure/1skip，不能报总CI通过。
- 已定位不同于attempt1的精确原因：boot.deadlineAfterSeconds=`1440.0000000000002`（由monotonic绝对时间相减），workBudgetSeconds=1440，validate_boot开头严格`!=`导致拒绝；其余时间字段已round(...,6)，此字段漏了。真实boot wait106.17559s正常退出，正式海岸/兵模/图标清晰呈现，不应修改App或放宽预算来掩盖。v6.4只将生产字段统一微秒精度；新增直接时钟边界保证旧实现可失败、真实deadline偏移仍拒绝，保留原验证器与门槛。
- v6.4已落盘：runner单行round(...,6)，新增1项生产boot/JSON保存/metadata synthetic方法，math.nextafter时钟原点正例与真实deadline±1ms负例；验证器无改动。已安全fetch/pull，HEAD/origin仍a0f41cc；`git diff --check`、两个Python AST、当前两份证据文档链接/围栏通过，没有本机import/运行测试。逐块暂存本轮4文件，既有所有无关文档/Team ID继续排除，随后提交main等待新SHA官方完整包。
