# MedPaper Workflow — DeepSeek Edition

面向医学与临床研究的**门禁式论文生产工作流**：把"研究思路"推进为经全量数据、真实文献、统计结果、图表、人工复核与期刊规则共同校验的 **SCIE original article 投稿包**。

- **引擎**：medpaper 1.29.0（25 阶段 / 296 门禁，与具体研究无关）
- **执行层**：为 DeepSeek Harness 适配——用户级 skill、全局 AGENTS.md 入口、`medpaper` 一条命令驱动
- **已验证**：真实大规模公开数据跑通 S01–S07 核心科学链；引擎自检 231/231

> 姊妹仓库：Codex 版 `medpaper-codex-workflow` ｜ Kiro 版 `medpaper-kiro-workflow` ｜ Gemini 版 `medpaper-pipeline-gemini`。本仓库为 **DeepSeek 版**。

---

## 目录

1. [解决什么问题](#解决什么问题)
2. [快速开始](#快速开始)
3. [在 DeepSeek Harness 中调用](#在-deepseek-harness-中调用)
4. [工作流怎么跑](#工作流怎么跑)
5. [九条细节约束（运行反馈沉淀）](#九条细节约束运行反馈沉淀)
6. [人工检查点](#人工检查点)
7. [需求蓝图核对](#需求蓝图核对)
8. [验证记录](#验证记录)
9. [目录结构](#目录结构)
10. [常见命令](#常见命令)
11. [边界](#边界)

---

## 解决什么问题

医学论文真正的难点不是生成文字，而是让研究问题、数据、统计、文献、图表、正文与投稿文件**彼此一致**，并符合目标期刊要求。本工作流用分阶段门禁阻断常见失败：

- **选题饱和、做完无发表价值** → S02/S06 两次 go/no-go；任何阶段发现不值得继续，立即上报止损
- **数据"全量可得却只取前 N 条"** → S04 全量普查证明（源总数=接收数=分析行数，哈希绑定；`LIMIT/head()/sample()` 被阻断且不可豁免）
- **虚构文献**（凭记忆编 PMID/DOI、手改校验文件）→ 正式引用只认 PubMed EFetch 原始 XML 哈希 + 独立实时复核
- **数字无来源、表图与正文对不上** → 数字必须存在于代码生成的结果 JSON 并绑定人群/终点/对比/分母
- **工程化、计算机化语言**（snake_case、p.value、JSON 键名、分析报告腔）→ 每个写作阶段当场去 AI 化 + 医学润色
- **图表数量比同类论文单薄** → S07 硬性对标 3–5 篇真实全文后锁定图表计划
- **Word 黑点/蓝色字/超链接/Aptos 字体/keyword 错乱/缺 References 标题** → 确定性 Word 构建 + 渲染后视觉检查
- **投稿包缺文件、指南要求未逐条执行** → 指南逐条要求清单 + 合规矩阵 + 独立终审

## 快速开始

```powershell
# 1) 全局环境（一次性；NCBI key 提升 PubMed 限速至 10 req/s）
pwsh .\medpaper-helpers\medpaper.ps1 init-env -key "<NCBI_API_KEY>" -email "you@example.org"

# 2) 安装 DeepSeek Harness 入口（一次性：用户级 skill + 全局 AGENTS.md）
pwsh .\dsh\install.ps1

# 3) 新建论文工作区（任意思路、任意研究类型、任意公开数据集）
medpaper new -Slug <研究名> -IdeaFile <思路.md> [-DataDir <数据目录>]

# 4) 在论文工作区里启动/恢复
cd <论文目录>
medpaper               # 状态 + 当前阶段执行卡（一条命令）
medpaper check         # 运行当前阶段门禁
medpaper advance -n "本阶段完成内容与决策"   # 关闭阶段并推进
```

环境要求：Windows + pwsh；uv + Python 3.13（论文 venv 自动创建）；R 4.3+（新医学图默认 R）；Pandoc；网络（PubMed/Crossref/Unpaywall/期刊官网）。

## 在 DeepSeek Harness 中调用

三个入口（与 Codex 的 `$medpaper`、Kiro/Gemini 的 skill 对等）：

| 入口 | 位置 | 效果 |
|---|---|---|
| 用户级 skill | `$DSH_HOME/skills/medpaper/SKILL.md` | 会话技能目录自动出现 `medpaper`，任务匹配时自动加载 |
| 全局 AGENTS.md | `$DSH_HOME/AGENTS.md` | 每个会话注入 medpaper 入口与硬性底线 |
| 项目 AGENTS.md | 论文工作区（`new-paper.ps1` 自动放置） | 在论文工作区开会话时自动注入执行策略 |

安装后（`pwsh .\dsh\install.ps1`，重启会话生效）：

- **新研究**：对 DeepSeek 说"启动 medpaper 工作流，思路在 <路径>"，或 `medpaper new -Slug ...`
- **恢复研究**：在论文工作区开新会话，直接说 **"继续 medpaper"**
- 驱动命令无需手动设置环境变量（自动注入 `PYTHONUTF8` / `NCBI_API_KEY` / `NCBI_API_EMAIL`）

## 工作流怎么跑

```text
S01 整理想法 → S02 可行性(go/no-go#1) → S03 方案 → S04 全量数据 → S05 探索分析
→ S06 冻结方案(go/no-go#2) → S07 图表对标 → S08 Methods → S10 表 → S11 图 → S09 Results → S12 对账
→ ★S12.5 分析证据预审(独立子代理：方法+结果+图表能否撑起 SCIE OA；完成后询问是否需要第三方审阅包)
→ S13 文献库(实时核验) → S14 Introduction → S15 深读 → S16 Discussion → S17 组装
→ S18 独立审查 → S19 人工审核("我确认这一版") → S20 选刊(SCIE，接受概率优先)
→ S21 作者信息 → S22 润色 → S23 投稿包 → S24 人工确认 → S25 独立终审 → PASS 交付
```

- **表图先行**：S08 之后先表后图再 Results——Results 是看着成品表图写的
- **换刊**：归档旧刊 → 新刊重新抓指南、重建合规矩阵 → 新投稿包（`releases/<期刊名>_<日期>/`）
- 完整阶段细节：`MEDPAPER-WORKFLOW.md`（智能体执行细则）

## 九条细节约束（运行反馈沉淀）

> 这九条不是先验规则——是你在**运行工作流过程中发现并反馈的问题**，逐条沉淀为约束。完整映射（反馈原话 → 约束 → 机制 → 版本出处）见 **`CONSTRAINTS.md`**。

1. **PubMed API 全局**：`medpaper init-env` 写入 User 级；所有文献调用真实核验（反馈：API 要存全局）
2+3. **医学语言、每节当场润色**：每个写作阶段当场去 AI 化 + 医学润色，S22 只做期刊层收尾（反馈：产物工程化医生看不懂；润色要每节写完就做）
4. **全文获取瀑布**：OA API → 聚合源 → 其他可用途径 → 找不到再找用户；获取后一律身份核验（反馈：不仅仅合法 OA，自己尽量获取）
5. **早期止损**：任何阶段发现不值得继续，立即上报 GO/PIVOT/STOP 由用户拍板（反馈：no-go/收益少要及时告知，避免浪费）
6. **图表对标硬门禁**：S07 抓 3–5 篇相近已发表全文，逐篇列图表清单后锁定计划（反馈：图太少、参考类似论文的要求没执行）
7. **S12.5 分析证据预审**：写摘要/组装前，独立只读子代理判定方法+结果+图表能否撑起 SCIE original article；预审后询问是否整理第三方审阅包（反馈：组装后再审返工量大）
8. **投稿指南**：浏览器抓官方指南 → 逐条要求清单 → 合规矩阵 → 投稿系统实际要求核对（反馈：指南获取不全、没严格遵循、系统与指南有出入）
9. **投稿包命名与换刊**：`releases/<期刊名>_<日期>/`；拒稿换刊重走第 8 条（反馈：文件夹名要含期刊与时间）

更早的运行反馈（Word 格式问题、虚假文献、数据偷懒、反复改稿耗 token、R 与 Python 分工等）同样逐条沉淀在 `CONSTRAINTS.md` 第二、三节。

## 人工检查点

| 节点 | 需要用户做什么 |
|---|---|
| S02 / S06 / S12.5 / 任何止损点 | 阅读证据与建议，拍板 GO/PIVOT/STOP/返修 |
| S19 | 审阅全文+表+图+独立报告；提意见批次；明确回复 **"我确认这一版"** → 科学母稿冻结 |
| S20 | 从候选清单（接受概率排序+退稿梯队）选定期刊 |
| S21 | 提供作者/单位/ORCID/基金/利益冲突/伦理等事实 |
| S24 | 检查投稿包；修改；明确回复 **"我确认这一版"** → 冻结 |

口令纪律：`我确认这一版` 绑定实际文件哈希；沉默、OK、继续都不算确认。其余阶段由智能体自主执行，不打扰。

## 需求蓝图核对

原始需求蓝图（`G:\workflow.md`：主流程 + 补充要求 + 历次运行反馈 + 九条细节）逐条映射到工作流机制，见 **`BLUEPRINT.md`**。关键结论：

- 引擎已拦截：虚构文献（伪造 DOI/verified 被门禁挡下）、数据抽样截断、Word 格式问题（纯黑/无黑点/Times New Roman/无超链接/禁 ↓）、图注复述结果
- 投稿包全部转 Word（正文、cover letter、补充方法均强制 .docx）
- 审阅包 ZIP：**按需**——S12.5 预审后询问用户、投稿准备期按用户需要再导出
- 参考文献池纪律：S13 目标约 50 篇（容许带 35–60），收尾报告池数量与各论证角色覆盖

## 验证记录

- 引擎离线回归：**231/231 通过**
- 真实大规模公开数据实跑 S01–S07：全量普查证明、字典锁定、双生产者复现证明、写作冻结、三篇对标全文密封
- 实测发现并修复 16 项适配层问题（gzip 确定性、声明输入、依赖顺序、pandas dtype 陷阱等）→ 清单见 `MEDPAPER-WORKFLOW.md` 第 11 节

## 目录结构

```text
medpaper-deepseek-workflow/
├── pipeline/            # 25 阶段与门禁的唯一机器配置（引擎，只读）
├── tools/               # 状态机、文献核验、表图、Word 构建等工具（引擎，只读）
├── reference/           # 专题执行规范（引擎，只读）
├── project/             # 单篇论文模板骨架（00_input~08_submission）
├── medpaper-helpers/    # 执行层：new-paper.ps1、medpaper.ps1（驱动）、capture_guidelines.py（浏览器抓指南）
├── dsh/                 # DeepSeek Harness 集成：skill + 全局入口 + install.ps1
├── AGENTS.md            # 引擎执行策略（话题路由表）
├── MEDPAPER-WORKFLOW.md # 智能体执行细则（阶段循环、红线、修复清单）
├── CONSTRAINTS.md       # 约束与细节清单（运行反馈 → 约束 → 机制 → 版本出处）
└── BLUEPRINT.md         # 需求蓝图 → 机制核对表
```

## 常见命令

```powershell
medpaper                       # 状态 + 阶段卡（在论文工作区内）
medpaper new -Slug <名> -IdeaFile <思路.md> [-DataDir <目录>]   # 新建论文
medpaper check / card [--details] / handoff / tree -v / doctor / clean [--apply]
medpaper advance -n "<完成内容与决策>"
medpaper decide <名称> <值> -w "<理由>"
medpaper init-env -key <NCBI key> -email <邮箱>
medpaper export --scope S12_5|S24   # 按需导出第三方审阅包（仅在你要求时）
```

## 边界

- 工作流辅助研究组织、分析、写作与质量检查；**不代替**研究者的伦理责任、临床判断与署名确认
- 不把数据不支持的结论"包装"成可发表结果；关键硬伤会给出 `PIVOT` 或 `STOP`
- 患者级/私密数据仅限本地；未经明确授权不外发
- 引擎母版只读：论文级差异写入论文工作区，不修改共享引擎
