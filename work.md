# 当前任务

## 总目标与当前完成范围

- 持续从最新main迭代Desert Stormfront风格RTS：美观易操作UI，精细陆海空兵模/战斗/自然地图，原创生图、云端探针。完整复刻与整体高档品质目标仍未完成，不能以局部通过冒称全部完成。
- 本轮v6.11/v6.12已实现并正式云端复核：HUD正常宽度字体/石墨面板/细状态线、三个固定命令无遮挡；战斗机/直升机/战列舰原创八向；坦克/空军/舰体共享只读朝向和镜像补偿；迷雾去重叠格边。所有24正式PNG均逐张目视。
- 本机只Git/文本/diff/AST/JSON/资源元数据/官方产物复核；未本机编译、运行App/模拟器、simctl、探针或CI回归；未开子智能体。

## 现场与归属

- main HEAD/origin/main=706c23443629243e8d095a14dd01e886a4632bb6；本轮另有38bd6ef9f14fb923568509d2169237dae67a920e，均正常push。origin=https://github.com/Altman-sam114/1145.git，gh账户Altman-sam114。
- 原有AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/log文档整理及未跟踪历史提示词/v6归档/Unity分析保留，不stash/覆盖/混入；起始备份 /private/tmp/desert-v6.11-baseline/ 与 /private/tmp/desert-v6.12-baseline/。
- 本轮源码/资源/CI协议均已提交且精确SHA验收；验收补记、README旧事实纠正和工作台留本地，不为纯文档再次触发固定完整CI。

## 已完成步骤与证据

1. [完成] 安全fetch/pull main、核对账号与原有改动；百度桌面/移动入口失败，已核对NobleMaster官方itch/公开截图。旧operationstormfront域名是无关站，不采信。不下载商业素材。
2. [完成] v6.10官方包及全部24图复核；继续两个有限增量，不重跑已验收SHA。
3. [完成] 本轮内置imagegen共6次：直升机3稿、战列舰3稿，选透明带边距的哑光稿；战斗机沿用前轮4稿中的干净稿。最终PNG在仓库Art/Directions及用户指定目录1，完整提示词/摘要见md/art/v6.11-*、v6.12-*。
4. [完成] v6.11 main38bd6ef，run42638430426/attempt1/artifact13686675379；63926872bytes/158项，SHA25631aa6f08d483e6fca0f9ec0557d5b8758f6f1bb2d84fe7c4285bf7885448beba。115runner/28资源/两空军及坦克八向/叠层/25HUD/50详情/24图通过；原包与review在/private/tmp/desert-frontline-review-42638430426-attempt1/。generic57s、work1067.846s/cleanup10.735s。
5. [完成] v6.12 main706c234，run42643835030/attempt1/artifact13688292104；63654864bytes/159项，SHA256f3a444b50e4ea393bfabc27a7e8c90fa4eb1bc84081e064afac6a53dc52352f7。双BUILD SUCCEEDED，117runner/5watchdog/7资源方法、29source/bundle、四模型八向两镜像/几何/恢复/实际姿态、720迷雾path/位置/raster/alpha、25HUD/50详情和全部24原图通过。JUnit10/0failure/1准确XCTest skip；ready7373bytes，原8000门槛不变。原包/official/review在/private/tmp/desert-frontline-review-42643835030-attempt1/。
6. [完成] v6.12启动恢复原始证据：CoreLocation迁移导致首boot监控240.746s/124，owned CLI已reap、进程组absent；既有同设备纯监控续等40.348s后exit0。没有监控间重启/换设备或加预算。generic61s，work1201.339s/cleanup24.359s在原预算内。该首阶段失败保留日志，不冒称无失败stage。
7. [完成] 24原生图逐张目视：舰体侧/斜向与原HUD/空军/坦克正常；深色迷雾格线明显减少，0.6/1.0样本未见明显内部裂缝；外缘细线与阶梯边界仍可改善。

## 当前边界与剩余步骤

- [待办] 航母/潜艇及其他陆军共6类机动单位仍是两向镜像；四类八向是2D图集，独立炮塔/旋翼/履带动画尚未完成。
- [待办] 更自然地图、地图外缘与柔和迷雾边界、动态战场构图；连续移动/缩放的渲染稳定性仍需云端直接操作证据。
- [待办] 真实物理触控、完整SKRM对局和长期性能；当前没有XCTest target，CPU合同和固定截图不能冒充这些证据。完整战役/多人及整体复刻尚未完成。
- 慢启动仍有云端CoreSimulator数据迁移风险，现有有界同设备恢复已本轮实测成功；不要因该环境阶段去盲改Swift或无限放宽超时。

## 精确下一步

恢复时先核对Git与本工作台/精确云端状态，保留原有修改。优先从当前航母甲板/潜艇渲染入口接续多方向与动画，或针对已目视的地图外缘/迷雾阶梯改善；先写有限增量验收再实现。全部编译、探针与运行仍在云端，不开子智能体；原24截图入口暂无按范围输入，不能擅自删门槛。总目标未完成，工作台保持可恢复状态。

## v6.13进行中：完整海军八向

- [完成] 原创航母/潜艇八向生图，各自4×2透明图集、固定世界尺寸与中心锚点；未通过生成物不接入。
- [完成] 将现有战列舰方向入口推广到三类海军，共享只读目的地/已知目标方向与镜像补偿；不改变舰载机、鱼雷、声呐、视野、伤害、AI和经济。
- [待办] 云端直接资源/朝向/恢复证据；海军方向证据使用逐方向bit mask保持现有8000字节单行预算，不放宽门槛。现有24原生场景包含航母、潜艇鱼雷与海军场景，编译与探针仍全部云端。
- 本轮编辑范围：GameScene海军Artwork入口、Art/Directions与manifest、生图提示词、三个直接CI验证脚本、README/flow/图/日志/work。原有修改继续保留；起点备份/private/tmp/desert-v6.13-baseline/。
- 验收：三舰8向×正负父镜像、固定尺寸/锚点/位置、状态完整恢复、29→31资源source/bundle一致、generic/device与sim双build、原始正式证据逐张验收；本机仅diff/AST/JSON与资源元数据。

- v6.13本机静态通过：3Python AST、2JSON、31资源digest、28文档链接/围栏、git diff --check；ready结构估算7115/8000。五次生图与原RGBA/提示词已保存。新增航母选中信息行，避免固定角度指示叠到转向甲板。下一步精确暂存本轮增量、main提交/push并等待下载同SHA官方结果包，未完成云端验收前不清理工作台。
