# BLUEPRINT — 需求蓝图 → 工作流实现核对表

来源：`G:\workflow.md`（研究思路设计蓝图 + 历次运行反馈）。每条蓝图要求对应到工作流的具体机制；状态 = 已实现（✅）/ 已实跑验证（🧪）/ 设计就绪待真实研究启用（⏳）/ 文档化补强（📘 本轮新增）。

## 一、主流程（蓝图 L1）

| 蓝图要求 | 工作流机制 | 状态 |
|---|---|---|
| 思路 → 联网判断发文条件 | S01 整理想法 → S02 可行性（真实 PubMed 检索 + GO/PIVOT/STOP） | 🧪 |
| 初步方案 + 数据源与获取方式 | S03 方案（protocol_v1、acquisition_plan、analysis_contract、governance） | 🧪 |
| 全量获取数据 | S04 全量普查（源总数=接收数=分析行数、哈希绑定、禁 LIMIT/抽样） | 🧪 |
| 方法调研 + 探索性分析（不作图） | S05（method_scan、探索分析、no_plot_calls 门禁） | 🧪 |
| 完善方案 + 二次发文判断 | S06（protocol_final/diff、go_nogo_2） | 🧪 |
| 主/补图表数量参考类似论文 | S07 对标硬门禁（3 篇真实全文，图/表逐篇计数） | 🧪 |
| figure legends + methods 参考类似论文 | S07 legends / S08 Methods（methods-structure.md 结构） | 🧪/⏳ |
| results 按表图写、注意图表引用 | S09（表图先行顺序 S10→S11→S09→S12） | ⏳ |
| 笔记.md（intro/discussion 要点） | S01 起 notes.md 全程维护 | 🧪 |
| 先表后图：三线表、标题脚注、非分析报告 | S10（threeline xlsx；主表一表一文件、补表一簿多 sheet） | ⏳ |
| 作图规范（少说明文字、标题短、参考医学论文规范） | S11（R 优先 + figure-standards + 实际渲染目检） | ⏳ |
| 参考文献库 ~50 篇、带摘要 | S13（library.json；无摘要需登记合法全文） | ⏳ 📘 |
| introduction / discussion（pandoc 标记、一次一文件） | S14 / S16（writer 分节、citekeys 门禁） | ⏳ |
| 5 篇左右精读原文参与 discussion | S15（deepread；全文瀑布获取，找不到找用户） | ⏳ |
| 作者信息后补 | S21 | ⏳ |
| 选刊（SCIE、接受概率优先） | S20（journal.py 候选清单） | ⏳ |
| 投稿指南严格遵循 + 整合包 | S20/S23（指南抓取 + 逐条合规 + 包构建） | ⏳ |

## 二、补充要求（蓝图 L3–L13）

| 蓝图要求 | 工作流机制 | 状态 |
|---|---|---|
| PubMed API 真实检索底线（禁虚构） | EFetch 原始 XML 哈希 + S13/S25 独立实时复核；伪造 DOI/verified 被门禁拦截（selftest 覆盖） | ✅ |
| 不多生成文件、迭代清理中间文件 | temp 目录纪律 + `wf clean --apply` | ✅ |
| 文件分文件夹放置 | 00_input–08_submission 固定目录 | ✅ |
| Methods 结构参考多篇论文、长内容进补充 | methods-structure.md + supplementary_methods（prose，禁表格） | ✅ |
| title 自动选；组装后独立子 agent 审发文条件 | S17 自动选题 → S18 独立只读子代理可发表性审查 | ✅ |

## 三、运行反馈（蓝图 L15–L37）

| 反馈 | 工作流机制 | 状态 |
|---|---|---|
| Word：纯黑字、无黑点、Times New Roman、keyword 规范、References 标题、无超链接、字体统一按指南 | build_docx 确定性构建 + docx_audit 门禁（selftest 全覆盖） | ✅ |
| 正文末尾要有 figure legend | S23 构建默认末尾图注（独立图注文件 + 正文末尾） | ✅ |
| **投稿包内 cover letter / 补充方法也要转 Word** | TEXT_ROLES 含 cover_letter/supplementary，必须产出 .docx（build_docx 校验） | ✅ |
| Word 禁 ↓ 换行符 | build_docx 明确禁 U+2193（selftest 覆盖） | ✅ |
| 缩写统一放 Declarations and Statements | AGENTS.md 规则 + central_abbreviations 检查 | ✅ |
| figure legend 不复述结果 | legend_no_results_restatement 门禁 | ✅ |
| 投稿包人工审核 → 确认 → 独立 subagent 按指南核查缺漏/对应 | S24（我确认这一版）→ S25 独立合规终审 | ✅ |
| 投稿前读者/编辑视角终检 | S25（reader + editor + compliance 三视角） | ✅ |
| **审阅包 zip 给第三方** | 按需机制：S12.5（写摘要前）预审完成后**询问用户是否需要整理第三方审阅包**；投稿准备期（S24 前后）按用户需要再决定导出。命令：`review_round.py export`（无固定导出动作） | 📘 按用户澄清调整 |
| 虚假文献/绕过门禁 | 引用四文件禁手写；门禁不可 --force；selftest 专项 | ✅ |
| 数据抽样截断 | 全量普查 + cap 扫描 + 不可豁免 | ✅ |
| 反复修改的节点与 token 优化 | S19/S24 修订轮 + rework.py 回源局部返工；token 压力禁止降质（engine invariant） | ✅ |
| S19 提示用户可审核 + 告知内容位置 | S19 卡 + 审阅轮报告路径呈现 | 📘 本轮文档化 |
| 分析 Python、作图 R | language_policy/r-first（R 默认渲染，Python 例外需理由） | ✅ |

## 四、九条细节（蓝图 L39–L47）

| # | 要求 | 状态 |
|---|---|---|
| 1 | PubMed API 全局 | ✅ User 级 + `medpaper init-env` |
| 2+3 | 每节当场去 AI 化 + 医学润色 | ✅ 写作四步法入执行纪律 |
| 4 | 全文瀑布含其他途径（scihub 等），找不到再找用户 | ✅ OA 三路由实跑 + register 外部途径；S15 找用户 |
| 5 | no-go/收益少及时告知 | ✅ S02/S06 + 任意阶段止损上报 |
| 6 | 图数量对标类似论文并执行 | 🧪 S07 实跑（3 篇对标、密封） |
| 7 | 写摘要前独立 agent 审方法与结果图表 | ⏳ S12.5 检查点（设计就绪，真实研究 S12 首次启用） |
| 8 | 浏览器抓指南 + 严格遵循 + 系统出入核对 | ⏳ playwright 抓取 + journal.py register（S20 首次启用）；系统出入核对在 S23 后 |
| 9 | 投稿包名含期刊+日期；换刊重走第 8 条 | ✅ releases/<期刊>_<日期> + 换刊流程 |

## 五、蓝图新增补强（本轮）

| 蓝图要求 | 补强内容 | 状态 |
|---|---|---|
| L49 参考文献池数量限制需遵循 | S13 执行纪律：目标池约 50 篇（benchmark ranges 35–60），S13 收尾向用户报告池数量 + 各论证角色覆盖；禁止低于论证需要凑数 | 📘 已写入 MEDPAPER-WORKFLOW.md |
| L49 pdf 精读失败要找用户 | 已在 R4/全文瀑布第 5 级；S15 显式记录缺失为证据缺口 | ✅ |
| L49 图表类型/数量调研确定 | S07 对标（已实跑） | 🧪 |
| L35 审阅包 zip 给第三方 | 按需：S12.5 预审后询问用户是否整理第三方审阅包；投稿准备期按需再导出 | 📘 已按用户澄清调整 |
| L35 S19 提示审核 + 内容位置 | S19 呈现审阅轮报告路径；第三方审阅包仅在用户确认后导出 | 📘 已按用户澄清调整 |

*状态图例：✅ 机制已实现（引擎或纪律层）｜🧪 已用真实数据实跑验证｜⏳ 设计就绪、留待真实研究首次启用｜📘 本轮按蓝图补强。*
