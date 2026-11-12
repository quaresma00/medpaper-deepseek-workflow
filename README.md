# MedPaper Workflow — DeepSeek Edition

面向医学与临床研究的**门禁式论文生产工作流**：把"研究思路"推进为经全量数据、真实文献、统计结果、图表、人工复核与期刊规则共同校验的 **SCIE original article 投稿包**。

> **总纲**：工作流由来（三库迭代史）、完整阶段细节、贯穿全程的质量约束、防伪与止损机制、反馈→机制对照，全部整合在 **[MEDPAPER-FRAMEWORK.md](MEDPAPER-FRAMEWORK.md)** —— 从这里开始读。
>
> 姊妹仓库：Codex 版 `medpaper-codex-workflow` ｜ Kiro 版 `medpaper-kiro-workflow` ｜ Gemini 版 `medpaper-pipeline-gemini`。本仓库为 **DeepSeek 版**。

## 快速开始

```powershell
# 1) 全局环境（一次性；NCBI key 提升 PubMed 限速）
pwsh .\medpaper-helpers\medpaper.ps1 init-env -key "<NCBI_API_KEY>" -email "you@example.org"

# 2) 安装 DeepSeek Harness 入口（一次性：用户级 skill + 全局 AGENTS.md）
pwsh .\dsh\install.ps1

# 3) 新建论文工作区（任意思路、任意研究类型、任意公开数据集）
medpaper new -Slug <研究名> -IdeaFile <思路.md> [-DataDir <数据目录>]

# 4) 启动/恢复（在论文工作区内）
medpaper               # 状态 + 当前阶段执行卡（一条命令）
medpaper check         # 门禁
medpaper advance -n "本阶段完成内容与决策"
```

## 在 DeepSeek Harness 中调用

- 任意会话直接说 **"启动 medpaper 工作流" / "继续 medpaper"**（用户级 skill + 全局 AGENTS.md 自动生效）
- 新研究：`medpaper new -Slug ... -IdeaFile ...`；驱动命令自动注入环境变量
- 装到别的机器：克隆后 `pwsh .\dsh\install.ps1`，重启会话生效

## 文档

| 文档 | 内容 |
|---|---|
| `MEDPAPER-FRAMEWORK.md` | **总纲**：三库迭代史 + 25 阶段细节 + 质量约束体系 + 防伪止损 + 反馈对照 |
| `MEDPAPER-WORKFLOW.md` | 智能体执行细则：阶段循环、红线纪律、子代理契约、修复清单 |
| `README.md` | 本主页：入口与快速开始 |
| `dsh/` | DeepSeek Harness 集成（skill + 全局入口 + install.ps1） |

## 目录结构

```text
medpaper-deepseek-workflow/
├── pipeline/ tools/ reference/ project/ AGENTS.md bootstrap.py …  # 引擎母版（只读、通用）
├── medpaper-helpers/    # 执行层：new-paper.ps1、medpaper.ps1（驱动）、capture_guidelines.py
├── dsh/                 # DeepSeek Harness 集成
├── MEDPAPER-FRAMEWORK.md  # 工作流总纲
├── MEDPAPER-WORKFLOW.md  # 智能体执行细则
└── README.md
```

## 边界

- 工作流辅助研究组织、分析、写作与质量检查；**不代替**研究者的伦理责任、临床判断与署名确认
- 不把数据不支持的结论"包装"成可发表结果；关键硬伤会给出 `PIVOT` 或 `STOP`
- 患者级/私密数据仅限本地；未经明确授权不外发；引擎母版只读
