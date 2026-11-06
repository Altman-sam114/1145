# 当前任务

## 目标与边界

- 总目标：从最新main持续推进Desert Stormfront风格RTS，统一高质量画面与易用UI，修复云端构建/验证；使用原创素材。当前有限增量为v6.5设施/环境美术与紧凑选择卡。
- 验收：十种机动单位+十种设施+三类环境真实透明图随包且挂载；小屏选择卡64pt并保留四项事实与至少44pt控件；精确实现SHA云端双构建、资源/HUD契约及24张正式原生图通过并目视复核。
- 不改经济/伤害/AI/寻路，不建平行玩法系统；不本机编译、运行、探针、模拟器操作，不启动子智能体。全方向动画、真实触摸、完整对局与长期性能不以固定截图冒充。

## 现场与归属

- main / HEAD / origin/main = a53d342798892e2b9a0a7dfbc29ffc7e3b8dc665；2026-11-06已fetch和pull --ff-only成功，origin=https://github.com/Altman-sam114/1145.git，账号Altman-sam114。提交前再次确认。
- 起始保留：AGENTS、README、flow/图、test、prompt索引、update_log、work的既有文档整理；工程Team ID两行；未跟踪历史提示词、v6归档和Unity分析。不覆盖、不stash、不混入本轮提交。
- 本任务沿用v6.0至v6.4已发布渲染/CI链路。旧临时传输已失效，v6.4官方包本轮重新取得并完成核验。版本过程已写update_log，不再把旧run作新实现证据。

## 步骤

1. [完成] 读入口/工作台/规范、Git/源码/云端核对；百度移动站搜索200，原页面和正文保存/private/tmp/desert-baidu-reference-20261106.*，不采信未核实下载站宣传。
2. [完成] v6.4原包SHA256/API digest/CRC/身份/JUnit/HUD/实际PNG核验，云端修复已有正式成功证据。
3. [完成实现，待验证] 内置image_gen生成13种新素材，工厂另编辑一次；字节原样复制项目与用户目录，提示词/来源/尺寸/hash已落盘。EntityKind全部20种实体共用解码/缓存，设施贴地anchor；三类环境替换原mapNode入口；compact选择卡92→64pt、双列四事实、队列右上。
4. [完成] diff/相关AST、JSON、8文档32本地链接/围栏通过；逐块暂存26文件，排除原有无关文档/Team ID。已再次fetch/pull main，远端一致；准备提交与推送。
5. [待办] 推送新SHA，等待云端固定完整入口，下载精确官方包核对双构建、23资源、HUD25、24原生图与实际比例/遮挡。失败依据证据定向修复，不盲目重跑或改gate。
6. [待办] 记录正式结论；完成所选验收后收口，若总目标仍有必需工作则保留精确下一步。

## 本轮编辑范围

- GameScene：artworkName/Directory/Width、共享384px解码与缓存、设施anchor、scenery入口、ready真实挂图证据、HUDLayout compact双列槽与互不重叠检查。
- Art：新增Structures十图、Scenery三图，unit-art-manifest扩为23；ci/check_unit_art.py同步精确路径集合，保留原CRC/alpha/hash门槛与现有6项PNG正负例。
- md/art/v6.5-generation-prompts.json、v6.5-production-art.md、v6.0来源说明补历史状态；README/flow/flowchart/test/log/work只提交本轮事实增量，原文档整理不提交。工程与workflow/runner预算不改。

## 证据与验证选择

- 本机仅git diff --check、相关Python AST/JSON与文档本地链接/路径检查、只读GitHub证据；未执行checker、App、Swift/Xcode或任何本机测试。
- baseline：所有改动diff；ci/check_unit_art.py AST、Art清单与提示词JSON、本轮文档链接。direct：云端generic iOS device build+simulator build、实际bundle23资源、HUD25矩阵与24正式截图。全面实体/环境/界面重构涉及完整画面；当前入口不可切分，本轮复用现有集合、不额外增加无关玩法。
- v6.4：run40819582266/attempt1/main/a53d342；artifact12874910247，53,881,516 bytes /158项未加密，SHA256=9dda0f1ffd7b5b69ab3cb6313de15772eae7ff1ece208e647442c919778ddf0a与API一致、CRC/路径正常；缓存/private/tmp/desert-frontline-review-40819582266-attempt1/official/。双BUILD SUCCEEDED、JUnit10/0failure/1准确XCTest skip、110 runner+5watchdog+6资源正负例通过；HUD25成功/恢复true，24/24完整；work798.709s/cleanup38.861s，严格boot预算gate通过。
- v6.4目视战术/Build/陆战/海岸/航母：图标、车辆/舰船贴图正常；选择卡过高、几何设施/岩石/村落不协调，构成本轮修复依据。不把CPU/资源合同当作美观、触控或完整对局证据。
- 生图本轮成功：内置image_gen，未用CLI/收费API或其他聊天。13选定原图保存DesertFrontline/Art/{Structures,Scenery}及/Users/a114514/.codex/generated_images/1/v6.5-*.png；未脚本编辑图像。预览雾光部分是alpha0的RGB值，需云端RGBA实际呈现确认。旧7次503与FLUX许可/导出调查是历史状态，未将FLUX候选并入App。

## 阻塞与精确下一步

- 当前无须用户确认的阻塞。官方artifact首次gh下载TLS超时已用官方302+4路Range获取同一原包，摘要完整匹配后才使用；不重跑旧CI。
- 下一步：完成静态和逐块审查，安全同步main，精确暂存/提交v6.5；推送后记录完整SHA/run并等官方包。不可清理工作台或标总目标完成，直到必需验收完成。

- 为让新HQ/工厂/机场有正式屏幕证据，将原build探针从重复air构图改为base焦点，仍为24项、原page/marker/等待/完整性门槛不变；GameScene仅CI分支选择原始HQ与基地相机，fixture事实要求四类初始设施实际挂图。ci/probes.json纳入本轮编辑和JSON静态检查，不新增探针或改验证器。

- 提交前自查：共享实体/环境加载、isOperational/fog/死亡/SKRM沿用原链路；全部23清单路径与Art文件夹资源引用一致。只读旧ready测算新增元数据约4471bytes，低于原8000-byte门槛（仅静态估算，真实云端仍严格校验）。未本机运行测试。
