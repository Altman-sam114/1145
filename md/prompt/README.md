# Prompt 目录

本目录保存每轮 Agent A 写给 Agent B 的详细实现提示词。Agent B 只能按对应版本提示词实现，不能把本目录当成历史总结随意改写。

## 命名规则

- 阶段目录：`md/prompt/v0（项目治理）/`、`md/prompt/v1（核心玩法）/`。
- 提示词文件：`v0.1（建立迭代文档）.md`、`v1.0（实现老兵系统）.md`。
- 人工指定版本时，以人工指定为准。
- 人工未指定版本时，Agent A 根据 `update_log.md` 和本目录自动递增。
- 同一阶段的小任务、修复、优化递增小版本，例如 `v0.1` -> `v0.2`。
- 重要玩法阶段或架构阶段可新开大版本，例如 `v1.0`。

## 角色召唤

- 用户消息以 `agenta`、`a:` 或 `A:` 开头，表示召唤 Agent A。
- 用户消息以 `agentb`、`b:` 或 `B:` 开头，表示召唤 Agent B。
- 用户消息以 `agentc`、`c:` 或 `C:` 开头，表示召唤 Agent C。
- 没有这些前缀时，按普通 Codex 任务处理；若任务需要 A/B/C 边界，提醒用户指定角色或说明本轮按普通任务执行。
- Agent A / B / C 的最终回复第一行分别必须写 `我是 Agent A。`、`我是 Agent B。`、`我是 Agent C。`。

## 每份提示词必须包含

- 版本号。
- 版本分配依据。
- 背景。
- 目标。
- 非目标。
- 当前架构依据。
- 实现步骤。
- 关键文件。
- 测试要求。
- 文档更新要求。
- 验收标准。
- 风险和禁止项。

## 云端阶段要求

Agent A 给 Agent B 的提示词必须写清：

- 本轮固定使用 `main`，不引入 `smalldata_test`、`develop`、`codeb/...`、候选分支或 PR 流。
- Agent B 开始前要 `git fetch origin`、`git switch main`、`git pull --ff-only origin main`，并确认无无关工作区改动。
- Agent B 完成后默认只跑本地轻量检查，commit 并 `git push origin main` 触发 GitHub Actions；除非人工明确要求，不默认跑本机完整 Xcode build。
- GitHub Actions 必须上传未加密 CI 结果包，至少包含 `ci-artifact-manifest.json`、`junit.xml`、`xcodebuild.log`、`ci-failure-summary.md` 和项目原生结果文件。
- Agent C 必须用 `gh auth login` 后下载最新 `origin/main` run 的 artifact，默认缓存到 `/private/tmp/desert-frontline-c-review-<run_id>/`。
- Agent C 必须核对 manifest 的 `branch=main`、`commitSha`、`runId`、`runAttempt` 与 `origin/main` 最新 commit 和 GitHub run 完全一致。
- 云端失败时，Agent C 输出退回清单；Agent B 在 `main` 上追加修复 commit 后继续 push。
- 没有 `origin`、没有 push 权限、没有 GitHub 权限或 artifact 下载失败时，必须明确写出阻塞原因。

## 当前建议下一轮

建议由 Agent A 创建：

- `md/prompt/v1（核心玩法）/v1.0（实现老兵经验系统）.md`

该提示词应要求 Agent B 完成击杀 XP、等级、战斗加成、头顶徽章、选择面板显示、README 记录和 generic iOS build 验证。
