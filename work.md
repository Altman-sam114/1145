# 当前任务

## 目标与边界

- 从最新main持续迭代Desert Stormfront风格iOS RTS，重点为美观易操作HUD、精细陆海空/地图/战斗和稳定云端。完整复刻/整体高档品质尚未完成。
- 本机只Git/文本/AST/JSON/资源元数据/官方结果包复核；不编译、不运行App/模拟器/simctl/探针或CI回归；不启动子智能体。删除使用trash。
- 百度桌面/移动均无法访问；已核对NobleMaster官方itch与公开参考截图，仅参考设计，不复制商用素材。

## Git现场与归属

- main/origin/main=40be549283a9057c4ebdbf78ff359aa88e6bc842，前序2afc543为本次HUD/截图增量，3a0fa18为航母潜艇八向。origin=https://github.com/Altman-sam114/1145.git；gh为Altman-sam114。
- 原有AGENTS/工程Team ID两行/README/flow/图/test/prompt索引/日志整理及未跟踪历史提示词、v6归档、Unity分析保留，不stash/覆盖/混入。本轮文档用index仅追加方式暂存，保留原有工作区差异。
- 备份/private/tmp/desert-v6.14-baseline、desert-v6.15-baseline、desert-v6.16-baseline；此前v6.13备份仍保留。

## 当前完成与失败证据

1. [已实现，待完整云端] 截图首次45秒，只有owned CLI超时且完整回收才在原180秒总预算内同设备/PID/nonce/ready重读一次；独立候选隔离迟到输出，metadata复核日志/身份/时限/回收/rawImage，失败候选留证。原work1440/cleanup90和24图门槛不变。
2. [已实现，待完整云端] HUD柔化面板、放大命令字、分类单标题、突出Advance/可用Target；沙地与海面细纹烘焙到原材质缓存，不改变玩法/路由/44pt。
3. [失败已定位] v6.13 run42651313363：双build成功，MOVE截图180s超时，仅5/24图；证据/private/tmp/desert-frontline-review-42651313363-attempt1。
4. [失败已定位] v6.14 run42687256502/2afc543：159283bytes，digest924520411a108386b78df5c260007a79332e6ae758d26021b21424076b6fbaea；双build/121runner/31source=bundle，0/24。分类空subtitle导致原两行ready检查hud=false；HUD producer成功/恢复但报告未采集。review.json已保存；不是编译卡死。
5. [失败已定位] v6.15 run42689909487/40be549：160855bytes，digestbaac3cd41dcf71887ce3d40aa09f541de28986fdedca2e868fa266f32d9736de；双build/122runner/31source=bundle，0/24。原生hud=true，但Swift审计另有旧subtitle清单，producer恢复失败；源码确认必败条件。证据/private/tmp/desert-frontline-review-42689909487-attempt1（含review.json）；不能冒称25契约/画面通过。
6. [完成代码/待云端] v6.16将ready与Swift审计统一到hudControlTextIDs/expectedHUDControlTextIDs，保留严格单标题/命令两行和所有原恢复门槛；额外有界失败诊断给首条文字问题及前三失败case，非gate。源代码检索已无page subtitle要求；Python侧相应required IDs/负例于v6.15已改。

## 生图

- 内置imagegen8次（侦察车5稿，火炮/防空/维修各1稿），候选保存在/Users/a114514/.codex/generated_images/1/v6.14-*-eight-candidate.png；原始默认目录01a1c1cf-750e-7181-8c1f-9d2f1d724e98。
- 斜向已修正，但前三类有彩边，维修白底，均不接入。md/art/v6.14-generation-prompts.json与v6.14-ground-candidates.md记录完整提示词、源文件和质量状态。
- 已异步询问是否允许工具外图像处理清理，尚无明确回答；内置生图工具编辑规则要求用户明确指定其他方式，故未做代码/CLI抠图。不因此停止独立代码/云端工作。

## 本轮编辑与验证计划

- v6.16只改GameScene HUD规则/失败诊断与相关flow/图/log/work；此前截图CI、Python文字协议和美术候选文档已在main。
- [完成] diff检查；本地只静态，未运行测试。
- [待办] 安全fetch/pull main，精确暂存本次代码和文档追加、main正常提交/push；现workflow无选择输入，固定24原生场景用于本次跨陆海空/HUD验证。
- [待办] 同一模型等待精确SHA云端，下载未加密结果包，核对branch/SHA/run/attempt/digest/manifest/JUnit/双build/31source-bundle、文字/方向/叠层/迷雾合同及全部24正式PNG逐张目视。CPU/固定图不等于物理触控、完整对局或长期性能。
- 若仍失败，只根据新增诊断修复；同因连续失败无新证据即停止，不重复盲推或改预算，不切回本机测试。

## 总目标剩余

- 四类陆军八向素材清理与正式接入；独立炮塔/旋翼/履带/舰体动画。
- 更自然地图/海岸与迷雾外缘、连续移动缩放稳定性、真实触控/完整SKRM对局/长期性能、完整战役/多人及整体复刻。
- 总目标及必需云端未完成，不清空工作台。
