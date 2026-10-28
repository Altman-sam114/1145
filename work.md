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
2. [进行中] 已尝试内置生图 4 次，当前会话全部 503；已接续十种既有兵模，增加 384px 透明边距归一化、实际贴图 ready 元数据；新增云端资源校验器及 6 项直接正负例，尚未运行。
3. [进行中] HUD 已改为底部横向分类、窄资源栏、小地图/任务卡收缩；重做水平生命条/小阵营点与四类等距建筑/村落，基础地形新增最多25种一次性细粒材质缓存并弱化岸线泡沫；25组契约新增中心留白及小屏占屏上限。尚未编译/云端验收。
4. [待办] 根据真实 CI 证据修复执行缺口；静态检查、按范围暂存到 main 并推送；等待/下载精确 SHA 的未加密结果包，逐项复核。
5. [待办] 修复证据暴露的问题，记录长期结论；只有全部所选验收完成后清理本工作台。

## 编辑范围

- 已编辑：`DesertFrontline/GameScene.swift`、新增 `ci/check_unit_art.py` 与 `md/art/v6.0-unit-art.md`、workflow self-test/有界预算、`ci/package_results.py` 资源报告索引、本工作台；沿用未提交 Art/工程/runner 半成品。对应 README/flow/test/log 增量已补，逐块暂存，原有无关文档整理保留未暂存。
- 以实际增量为准，不批量格式化或重写历史提示词。

## 验证与证据

- 本机仅 `git diff --check`、相关 Python AST/JSON/YAML 解析、工程 plist 格式与文档链接检查。
- 云端 baseline：generic iOS device build；direct：资源随包完整性、模拟器启动、25 组 HUD 生产布局/路由/恢复契约及相关陆海空原生截图。当前入口固定 24 探针，全面视觉重构涉及全部画面，首次可复用该集合，不额外扩无关测试。
- 本轮未执行任何本机编译/测试/设备命令。
- 2026-10-28 静态检查：`git diff --check`、三个相关 Python AST、资源清单/probes JSON、workflow YAML、工程 `plutil -lint` 均通过；未执行新 checker 自测或任何本机回归。当前仍 main、HEAD 与 origin/main 均为起点 SHA，未提交/推送。
- v5.69 原包：`/private/tmp/desert-frontline-review-40165304151-attempt1/official-parallel.zip`，artifact `12588462536`，SHA256 `0a94649ee1df8866e37a725cb0633a942a2b18fb709dce94751ae6bba21cef43` 与 API digest 一致、全项 CRC 正常；results 下原生 PNG / JSON / JUnit。branch/main/SHA/run/attempt 一致；双构建通过、24/24、JUnit10/0fail/1准确skip。旧小屏战术页 HUD 占屏 70.7%；总 runner1055.028s、work1039.732s，仅余40.3s，generic build约40s，不是 Swift 编译卡死。

## 生图通道调查（用户追加要求）

- 当前调用 carrier 去背景 / HQ / scout / sand texture 共 4 次，均 `gpt-image-2` / team 通道 503 No available channel，没有新生成成功，不擅自改用 CLI/收费 API。
- 用户指出其他项目能生图后，只读核对相关成功调用与图片：rome / Rustwar / easytech 均用同一 `image_gen.imagegen` 内置工具，当前时段有真实 PNG；没有给其他聊天发送消息，没有启动子智能体。
- 只读会话设置发现关键差异：本线程 `01a18284-c517-7100-87ad-bb188f2cf57c` 当前 model=`boa-hb/gpt-6.1-sol`；rome 与 Rustwar 为 `boa-xu/gpt-6.1-sol`。这是观察到的路由差异，尚未证明切换即成功。
- 已向用户询问是否允许仅将本会话切到 `boa-xu/gpt-6.1-sol` 并发送续行消息；未获确认前不改设置或发消息。没有修改全局配置/数据库，没有读出或输出密钥。环境无 `OPENAI_API_KEY`；只读模型发现接口不列图像模型。官方 OpenAI 图片文档两个域名均返回403，不据此臆测可用性。

## 下一步

生图路由调整尚未获得用户明确确认，不切换、不发续行消息；这只限制新增生图，不阻塞现有素材重构。完成本轮最终静态/暂存审查后提交并推送 main，等待/下载精确SHA的云端双构建、资源和24张原生图。后续仍需围绕参考图继续降低HUD干扰、完善地图/单位方向与动态海空表现、真实操作及完整对局验证，不把本轮基线等同总目标完成。
