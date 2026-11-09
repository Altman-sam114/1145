# 当前任务

## 总目标与当前完成范围

- 持续从最新main迭代Desert Stormfront风格RTS：美观易操作UI，精细陆海空兵模/战斗/自然地图，原创生图、云端探针。完整复刻与整体高档品质目标仍未完成，不能以局部通过冒称全部完成。
- 本轮v6.11/v6.12已实现并正式云端复核：HUD正常宽度字体/石墨面板/细状态线、三个固定命令无遮挡；战斗机/直升机/战列舰原创八向；坦克/空军/舰体共享只读朝向和镜像补偿；迷雾去重叠格边。所有24正式PNG均逐张目视。
- 本机只Git/文本/diff/AST/JSON/资源元数据/官方产物复核；未本机编译、运行App/模拟器、simctl、探针或CI回归；未开子智能体。

## 现场与归属

- main HEAD/origin/main=3a0fa1808bb85a3f8e760faa024dbfee3f8cb972；前序增量706c234与38bd6ef9f14fb923568509d2169237dae67a920e，均正常push。origin=https://github.com/Altman-sam114/1145.git，gh账户Altman-sam114。
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

- v6.13实现已正常提交/push：main 3a0fa1808bb85a3f8e760faa024dbfee3f8cb972，15个逐文件/逐块授权文件，原工程Team ID/文档整理/归档未混入。现有workflow所有main push自动跑固定完整链路；等待同SHA run出现并复核双build、原包身份/摘要与24正式图。本轮未修改workflow、未放宽预算、未本机测试。

- 云端run42651313363/attempt1已启动，head=3a0fa1808bb85a3f8e760faa024dbfee3f8cb972。只读取状态，不再重复dispatch；下载/复核脚本已准备/private/tmp/desert-review-v6.13.py，最终证据目标/private/tmp/desert-frontline-review-42651313363-attempt1/。原24原生探针不裁剪。

- 云端进度：Static checks于16:08:41UTC通过（141s），Project lint通过；generic iOS build已启动，尚未收到模拟器/截图验收。等待同run，不运行本机测试或重复触发。

- 云端generic iOS设备编译已通过；当前进入iOS simulator launch probe。未拿到原包前不推断31bundle、方向/原图通过。

- v6.13云端失败已下载原包并核对：run42651313363/attempt1/artifact13691641823，16,129,981bytes，SHA256 f975b8b490add65721753dba3d887b628afef9027a18d6e75026662ee3f2e724。双BUILD SUCCEEDED、静态117runner/31source=bundle、25HUD通过；仅5/24正式PNG，MOVE已ready/三舰masks255，但simctl io screenshot卡180s/124，后18未运行。work781.685/cleanup47.081。不能宣称全验收，失败证据保留/private/tmp/desert-frontline-review-42651313363-attempt1/。
- [进行中] v6.14截图有界恢复：只读simctl io screenshot最多2次，同设备/同PID/同nonce/同ready，前次owned CLI确认reap+group cleanup后才能重试，独立输出文件避免迟到旧结果；原每截图180s总体和work1440/cleanup90不变。编辑范围ci/simulator_probe.py/check_probe_runner.py、直接测试规范/flow/图/log/work，游戏源码与资源不再改动。精确下一步实现直接负例与独立metadata验收后云端验证，不本机运行测试。

## 本次继续执行（2026-11-10）

- 已重新核对main/远端、最新失败run和原生PNG；fetch/pull安全完成，原有文档/Team ID/归档保留，无子智能体。
- 本轮收敛为同一批可验收增量：[进行中] 完成已有截图恢复与独立metadata负例；[待办] 原创侦察车/火炮/防空车/维修车八向素材与共享方向入口；[待办] HUD层次及地形材质打磨；[待办] 同SHA云端双build、资源/方向/HUD/截图恢复合同与24正式PNG逐张复核。
- 百度实际入口不可访问，官方NobleMaster itch页面可访问；只借鉴玩法/易操作目标，不下载原作商用美术。使用已读取的imagegen技能与内置工具，最终素材另存用户指定generated_images/1和项目Art目录。
- 新增编辑范围：GameScene（仅HUD/材质/方向渲染）、Art/Directions/manifest、ci/check_unit_art.py/scene_evidence.py及直接合同、ci/package_results.py证据清单，相关README/flow/test/log/work。baseline仍保留已有修改归属；CI现无选择输入，固定24截图链路用于本次跨陆海空视觉验收。
- 验收不会把CPU合同当真实触控或长期性能，完整复刻/多人/战役/全动画仍是持续目标，不能宣称本轮全部完成。

- [完成代码/待云端] 截图恢复和独立metadata负例、manifest日志/失败候选、HUD文字/主命令层次与缓存地形细纹。本机3Python AST与diff通过，不运行任何本地测试。
- [素材质量阻塞] 内置imagegen共8次：四类八向候选已出图，侦察车斜向修正；透明输出存在彩边，维修车仍白底，均未接入。候选路径为generated_images/1/v6.14-*-eight-candidate.png，提示词已落盘。已异步询问是否允许图像处理清理，未收到明确回答前不做工具外图片编辑；独立代码验证继续。
- 本次先提交截图/HUD/材质可验收增量，云端固定24链路将一并复核前轮完整海军八向。不将素材待办混成已完成内容。

- 已精确暂存并正常提交/push main `2afc543`（截图恢复/HUD/材质/提示词与本轮文档追加共11文件）。原有文档整理、Team ID和历史归档未混入；先前append文档patch因index上下文不同失败，改为仅将本轮追加内容写入index，工作区原改动完整保留。现等待该SHA云端，不重复dispatch。
- 精确云端run已出现：42687256502 / attempt1 / SHA 2afc543899625e705850c0618f236d9deeb67164，进行中。证据目标/private/tmp/desert-frontline-review-42687256502-attempt1/；本机只读取运行状态。生图记录已补每次source与未接入状态（本地文档，不为此另触发CI）。
- run42687256502：Static checks成功（19:51:03→19:53:20 UTC，137s），Project lint成功，generic iOS device build进行中；尚无运行/截图验收结论。
- run42687256502：generic iOS设备编译成功（19:53:20→19:54:09 UTC，49s）；当前进入模拟器构建/启动/24图流程。尚未取得完整原包，不提前声称HUD或海军验收通过。

- [失败已定位] v6.14 run42687256502原包159283bytes/33项，digest924520411a108386b78df5c260007a79332e6ae758d26021b21424076b6fbaea已核对；双build/121runner/31source=bundle成功，0/24正式图。prewarm因为分类空subtitle不满足原两行controlsHaveText而hud=false，模型/地图/迷雾/文字事实/投影全true、HUD producer成功并恢复。work464.096/cleanup21.302；没有进入截图恢复。
- [完成代码/待云端] v6.15移除空分类subtitle并同步实际节点/精确文字ID与可见性验证、hudText实际数量证据、parser与HUD审计及对应负例。本机3AST/JSON/diff；下一步精确暂存追加文档和4个直接代码文件，main正常提交/push，下载新SHA官方包逐张复核24图。失败证据继续保留，不盲加时间。
