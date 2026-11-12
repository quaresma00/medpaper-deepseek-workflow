# MedPaper Workflow — DeepSeek Edition

面向医学与临床研究的**门禁式论文生产工作流**（DeepSeek Harness 专用版）：把"研究思路"推进为经全量数据、真实文献、统计结果、图表、人工复核与期刊规则共同校验的 **SCIE original article 投稿包**。

- 引擎：medpaper 1.29.0（25 阶段 / 296 门禁，**与具体研究无关**）
- 执行层：为 DeepSeek Harness 适配的驱动封装（`medpaper` 一条命令）、用户级 skill、全局 AGENTS.md 入口
- 已验证：真实大规模公开数据跑通 S01–S07 核心科学链（全量普查、复现证明、写作冻结、图表对标密封）；引擎自检 231/231

> 姊妹仓库：Codex 版见 `medpaper-codex-workflow`，Kiro 版见 `medpaper-kiro-workflow`，Gemini 版见 `medpaper-pipeline-gemini`。本仓库是 **DeepSeek 版**。

## 这套工作流解决什么

医学论文真正的难点不是生成文字，而是让研究问题、数据、统计、文献、图表、正文与投稿文件**彼此一致**，并符合目标期刊要求。本工作流用分阶段门禁阻断常见失败：

- 选题高度饱和、做完无发表价值 → S02/S06 两次 go/no-go，任何阶段发现不值得立即止损上报
- 数据"全量可得却只取前 N 条" → S04 全量普查证明（源端总数=接收数=分析行数，哈希绑定，`LIMIT/head()/sample()` 被阻断且不可 `--force`）
- **虚构文献**（AI 凭记忆编 PMID/DOI、手改 verified.json）→ 正式引用只认 PubMed EFetch 原始 XML 哈希 + 独立实时复核
- 正文数字没有来源、表图与正文对不上 → 数字必须存在于代码生成的结果 JSON 并绑定人群/终点/对比/分母
- 工程化、计算机化语言（snake_case、JSON 键名、p.value、分析报告腔）→ 每个写作阶段当场去 AI 化 + 医学润色
- 图表数量与已发表同类论文相比过于单薄 → S07 硬性对标 3–5 篇真实全文后锁定图表计划
- Word 黑点/蓝色字/超链接/无 References 标题/Aptos 字体 → 确定性 Word 构建 + 渲染后视觉检查
- 投稿包缺文件、指南要求未逐条执行 → 指南逐条要求清单 + 合规矩阵 + 独立终审

## 在 DeepSeek Harness 中调用（像 `$medpaper` 一样一句话启动）

安装（一次性）：

```powershell
pwsh .\dsh\install.ps1   # 装入用户级 skill + 全局 AGENTS.md 入口
```

之后在任意 DeepSeek 会话中：

- **新建研究**：`medpaper new -Slug <研究名> -IdeaFile <思路.md> [-DataDir <数据目录>]`
- **恢复研究**：在论文工作区开新会话，直接说 **"继续 medpaper"**（skill 与 AGENTS.md 会自动生效，智能体自动驱动 `medpaper status → card → 阶段工作 → check → advance`）
- **手动驱动**：`medpaper`（状态+任务卡）/ `medpaper check` / `medpaper advance -n "…"` / `medpaper decide …`（`medpaper.ps1` 自动注入环境变量，无需手动设置）

三种入口机制与安装说明见 `dsh/README.md`。

## 快速开始（命令行方式）

```powershell
# 1) 全局环境（一次性，User 级永久生效）
pwsh .\medpaper-helpers\medpaper.ps1 init-env -key "<你的NCBI key>" -email "you@example.org"

# 2) 把 medpaper 命令装进 PATH（一次性）
Add-Content $PROFILE 'function medpaper { pwsh "F:\path\to\medpaper-deepseek-workflow\medpaper-helpers\medpaper.ps1" @args }'
. $PROFILE

# 3) 新建论文工作区（任意思路、任意研究类型、任意公开数据集）
medpaper new -Slug <研究名> -IdeaFile <思路.md> [-DataDir <数据目录>]

# 4) 在论文工作区里启动/恢复
cd <论文目录>
medpaper               # 一步显示当前阶段 + 执行卡
medpaper check         # 门禁
medpaper advance -n "本阶段完成内容与决策"   # 推进
```

> `medpaper.ps1` 自动注入 `PYTHONUTF8/NCBI_API_KEY/NCBI_API_EMAIL`，无需手动设置。将 `medpaper-helpers` 加入 `$PROFILE` 的 PATH 后，任何目录下 `medpaper` 均可用。

## 工作流怎么跑

```text
S01 整理想法 → S02 可行性(go/no-go#1) → S03 方案 → S04 全量数据 → S05 探索分析
→ S06 冻结方案(go/no-go#2) → S07 图表对标 → S08 Methods → S10 表 → S11 图 → S09 Results → S12 对账
→ S13 文献库(实时核验) → S14 Introduction → S15 深读 → S16 Discussion → S17 组装
→ S18 独立审查 → S19 人工审核("我确认这一版") → S20 选刊(SCIE) → S21 作者信息 → S22 润色
→ S23 投稿包 → S24 人工确认 → S25 独立终审 → PASS 交付
```

- **表图先行**：S08 之后先表后图再 Results，Results 是看着成品表图写的
- **人工检查点**：S19/S24 必须明确回复 `我确认这一版`（绑定文件哈希）；S20 选刊、S21 作者信息由你提供
- **任何阶段发现不值得继续** → 立即上报 GO/PIVOT/STOP 建议，由你拍板
- **换刊**：归档旧刊 → 新刊重新抓指南、重新建合规矩阵 → 新投稿包（`releases/<期刊名>_<日期>/`）

## 完整执行文档

- **`MEDPAPER-WORKFLOW.md`** —— 智能体执行版总文档（12 章）：阶段循环、九条长期规则、子代理角色契约、人工检查点、红线纪律、命名规范、实测问题修复清单、验证完成度
- 引擎规范（只读、不修改）：`AGENTS.md`、`pipeline/pipeline.toml`、`pipeline/stages/`、`reference/`

## 九条长期规则（已固化）

1. PubMed API 全局配置，所有文献调用真实核验
2+3. 医学语言：每个写作阶段当场去 AI 化 + 医学润色（工程词/代码词零容忍）
4. 全文获取瀑布：OA API → 聚合源 → 其他可用途径（含用户授权渠道）→ 找不到再问用户；获取后一律身份核验
5. 早期止损：任何阶段发现不值得继续，立即上报建议、由用户拍板
6. 图表对标硬门禁：S07 抓 3–5 篇相近已发表论文全文，逐篇列图表清单后锁定计划
7. S12.5 分析证据预审：组装/摘要前由独立只读子代理判定"方法+结果+图表是否撑得起 SCIE original article"
8. 投稿指南：浏览器抓取官方指南（验证码时交用户）→ 逐条要求清单 → 合规矩阵 → 投稿系统实际要求核对
9. 投稿包命名 `releases/<期刊名>_<日期>/`；拒稿换刊重走第 8 条

## 目录结构

```text
medpaper-deepseek-workflow/
├── pipeline/            # 25 阶段与门禁的唯一机器配置（引擎，只读）
├── tools/               # 状态机、文献核验、表图、Word 构建等工具（引擎，只读）
├── reference/           # 专题执行规范（引擎，只读）
├── project/             # 单篇论文模板骨架（00_input~08_submission）
├── medpaper-helpers/    # DeepSeek 执行层：new-paper.ps1（建论文）、medpaper.ps1（一条命令驱动）、capture_guidelines.py（浏览器抓指南）
├── dsh/                 # DeepSeek Harness 集成：用户级 skill、全局 AGENTS.md 入口、install.ps1
├── AGENTS.md            # 引擎执行策略（话题路由表）
└── MEDPAPER-WORKFLOW.md # 智能体执行版总文档（本仓库的"怎么用"）
```

## 验证记录（与具体研究无关）

- 引擎离线回归：231/231 通过
- 真实大规模公开药物警戒数据（91 个季度档案 + 辅助数据库）实跑 S01–S07：全量普查证明、字典锁定、双生产者复现证明、写作冻结、三篇对标全文密封
- 实测发现并修复 16 项适配层问题（gzip 确定性、声明输入、依赖顺序、pandas dtype 陷阱等），清单见 `MEDPAPER-WORKFLOW.md` 第 11 节

## 边界

- 工作流辅助研究组织、分析、写作与质量检查；**不代替**研究者的伦理责任、临床判断与署名确认
- 不把数据不支持的结论"包装"成可发表结果；关键硬伤会给出 `PIVOT` 或 `STOP`
- 患者级/私密数据仅限本地；未经明确授权不外发
