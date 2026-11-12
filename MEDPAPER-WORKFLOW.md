# MedPaper 工作流 —— 我的执行版（v1.0，通用）

> 本文档是**适合本智能体执行的医学论文工作流**，与任何具体研究思路无关。
> 引擎 = medpaper 1.29.0（25 阶段 / 296 门禁，通用母版）；本文定义我的执行层：
> 循环、九条长期规则、子代理角色、人工检查点、命名规范与止损纪律。
> 任何"医学公开数据集 → 发文思路 → SCIE original article"类任务均按本文执行。

---

## 0. 架构与全局配置

| 组件 | 位置 | 说明 |
|---|---|---|
| 引擎母版（只读，通用） | `F:\deepseek\工作流\medpaper-pipeline-gemini` | 纯净骨架，**永不修改**；论文差异只进论文工作区 |
| 论文工作区 | `F:\deepseek\工作流\papers\<slug>` | 每篇论文独立复制引擎骨架 + venv + 项目数据 |
| 我的辅助工具 | `F:\deepseek\工作流\medpaper-helpers\` | 启动器、浏览器抓取、后续可扩展脚本（引擎外） |
| 工作流总文档 | `F:\deepseek\工作流\MEDPAPER-WORKFLOW.md` | 本文 |
| 全局环境变量（User 级，已设） | `NCBI_API_KEY` / `NCBI_API_EMAIL` / `PYTHONUTF8=1` | 永久生效；PYTHONUTF8 修复中文系统 GBK 编码坑 |

**执行原则**：引擎门禁是权威（`pipeline/pipeline.toml` + 阶段卡）；本文只定义"我如何驱动引擎 + 九条用户长期规则"，不替代引擎、不把工作流绑定到某一篇论文。

---

## 1. 新论文启动（任何思路，3 步）

```powershell
# 1) 用通用启动器建工作区（复制骨架 → bootstrap → wf init → 思路进 00_input → 数据原地登记）
pwsh -File F:\deepseek\工作流\medpaper-helpers\new-paper.ps1 `
     -Slug <slug> -IdeaFile <思路.md> [-DataDir <数据目录>]

# 2) 恢复/查看（之后每次会话只需）
cd F:\deepseek\工作流\papers\<slug>
$env:PYTHONUTF8="1"; $env:NCBI_API_KEY=[Environment]::GetEnvironmentVariable('NCBI_API_KEY','User'); $env:NCBI_API_EMAIL=[Environment]::GetEnvironmentVariable('NCBI_API_EMAIL','User')
.\.venv\Scripts\python.exe tools\wf.py status

# 3) 已有数据/半成品论文：wf.py status 会指出从哪个阶段续；数据用 data_sources.py add 原地只读登记
```

## 2. 每阶段执行循环

```text
wf status → wf card（读当前阶段卡）→ 按需加载 reference/<专题指南> → 执行产出
        → wf check（门禁）→ wf advance --note "产出+决策+待决" → 下一阶段
```
- **表图先行**：编号不变，执行顺序 S08 → S10 表 → S11 图 → S09 Results → S12 对账。
- 门禁不是回合边界：红灯修到绿再进；绿灯连续推进。
- 上下文压缩后：`wf handoff`（≤60 行有界恢复），只读受影响来源，不重读整段历史。
- 不在阶段卡声明的 outputs 之外乱建文件；临时产物进 `project/temp/`，advance 前清理。

## 3. 九条长期规则（与具体研究无关，每篇论文都执行）

| # | 规则 | 执行方式 |
|---|---|---|
| 1 | PubMed API 全局 | 已存 User 级；每条 wf/pubmed 命令前注入会话变量 |
| 2+3 | **医学语言 + 当场润色** | 每个写作阶段（S08/S09/S14/S16/S17）执行**写作四步法**：起草 → 当场去 AI 化+医学润色（polish.py 事实不变校验）→ 以"临床医生读者"身份自查 → 过门禁。红线（正文/表/图/图注统一）：`snake_case`、`p.value`、JSON 键名、`factor()`、`TRUE/FALSE`、`Std. Error/z value/AIC`、`coef/se/fpr`、`y~x`、`Analysis Report Figure 1`、处理日志语言、科学计数法堆砌、参考组 1.00(1.00-1.00)、无单位连续变量 → 一律清除；S22 只做期刊层统一收尾，不背医学语言的主责任 |
| 4 | **全文获取瀑布** | S15 按序尝试：EuropePMC/PMC OA → Unpaywall → OpenAlex → **scihub 镜像等途径（用户已授权）** → 找用户。任何途径的全文一律 `fulltext.py register --access authorized --route <途径>` + 身份核验（DOI/标题/首作者），身份不过不深读 |
| 5 | **早期止损** | S02 第一次 GO/PIVOT/STOP、S06 第二次判断，**以及任何阶段发现"不值得继续/收益少"** → 立即向用户报告证据 + 成本-收益评估 + 建议，等用户拍板；绝不默默硬做或为了推进而推进 |
| 6 | **图表对标硬门禁** | S07 联网抓 3–5 篇最相近已发表论文全文，逐篇列图表清单（主/补图、主/补表、类型），生成**对标对比表**给用户过目；本计划数量/类型明显偏少 → 门禁失败并给出补图建议（亚组森林图、敏感性图、校准、DCA、剂量反应、平衡图、补充拆分），只有用户确认或明确理由才允许低于对标 |
| 7 | **S12.5 分析证据预审** | S12 对账后、S13 文献库前，**新增强制检查点**：独立只读子代理审查 methods + results + 全部表图 + 结果 JSON 摘要 + claim_bindings + 对标报告，判定 SUPPORT / REVISE_ANALYSIS（回 S05/S08/S09/S10/S11 返修重审）/ INSUFFICIENT（止损上报）；**在组装/摘要等高成本写作之前解决"证据是否撑得起 SCIE original article"** |
| 8 | **指南获取与逐条执行** | `journal.py fetch --mode auto` → 被拦时用 `capture_guidelines.py`（playwright，headful 遇验证码交用户）→ `journal.py register --url --file --why --retrieved-at` 留痕。抓到的官方指南转带行号文本 → 生成 `guideline_requirements.json`（每条：原文引文+行号+类别+执行方式）→ S23 生成**合规矩阵**（每条 PASS/FAIL/WARN+证据位置）→ S25 逐条对照原文终审。投稿时用同一浏览器流程采集**投稿系统实际要求** → 与指南 diff → 修正投稿包并给"指南 vs 系统差异清单" |
| 9 | **命名与换刊** | 投稿包目录固定 `08_submission/releases/<期刊名>_<YYYY-MM-DD>/`；拒稿换刊 `journal.py begin`（归档旧刊）→ **重走第 8 条全套**（新指南抓取+新要求清单+新合规矩阵+新命名）→ 科学母稿冻结不动，只重做期刊层 |

## 4. 子代理角色契约（我的 subagent 分工）

| 角色 | 用在哪 | 输入（只给材料包） | 输出 | 禁令 |
|---|---|---|---|---|
| `medpaper-clinical-writer` | S08/S09/S14/S16/S17 首稿与改写 | writer_bundle（临床标签、文字化结果、表图、图注、notes.md）——**不给代码/JSON 键名/日志** | 对应分节 md | 不得自造数字/引文；主代理随后过语言门禁 |
| `medpaper-deepreader` | S15 每篇全文 | 已登记全文 + citekey | `06_refs/deepread/<citekey>.md` 结构化笔记 | 一篇一次调用；无全文不得假装深读 |
| `medpaper-reviewer` | **S12.5** / S18 / S19 / S24 / S25 | `review_round.py start` 生成的 bundle 路径 + 中性简报（不含后台上下文） | 自己的 `report.md`（review_round.py close 原样读取） | **只读**：不编辑任何论文文件；逐条给文件+位置；区分必须改/轻微/偏好 |

独立审查一律"只读 + 版本绑定 + 主代理不代笔结论"。

## 5. 人工检查点（其余阶段自主执行，不打扰用户）

| 节点 | 需要用户做什么 |
|---|---|
| S01 | 仅当 `open_questions` 有会改变设计的歧义时提问一次 |
| S02 / S06 / S12.5 / 任何止损点 | 阅读证据与建议，拍板 GO/PIVOT/STOP/返修 |
| S19 | 审阅全文+表+图+独立报告；提意见批次；最终明确回复**"我确认这一版"** → 科学母稿冻结。需要给第三方审核时：`medpaper export --scope S19` 生成审阅包 ZIP（内容位置 = 审阅轮报告 + 稿件/表/图路径） |
| S20 | 从候选清单（接受概率排序+退稿梯队）选定期刊 |
| S21 | 提供作者/单位/ORCID/基金/利益冲突/伦理/数据可用性等事实（不编造） |
| S24 | 检查投稿包；修改；明确回复**"我确认这一版"** → 冻结 |
| S25 后 | 投稿系统上传由用户执行；如需 portal 采集，用户登录后交浏览器流程 |

口令纪律：`我确认这一版`（或 I confirm this version）绑定实际文件哈希；沉默、OK、继续都不算确认。

## 6. 红线纪律（引擎门禁 + 我的执行纪律，不可豁免）

1. **全量数据普查**：S03 定义的数据范围全部获取；`LIMIT/TOP/head()/sample()/固定页数` 阻断；源端总数=接收数=分析行数，逐层证明；pilot 不用于分析且必须随后补全量。
2. **文献真实性**：正式引用只认 `pubmed/verify.py` 新鲜 EFetch + 原始 XML 哈希；**禁手写/篡改 library.json、verified.json、refs.bib、refs.ris、伪造 DOI**；S13/S25 强制独立实时核验。
3. **数字溯源**：本研究数字只来自已执行 `03_analysis/results/*.json`，绑定人群/终点/对比/效应尺度/分母/时间窗（claim_bindings）；引用他人数字必须绑定原文段落；禁正文心算。
4. **实际目检**：图 → `read_image` 逐张看渲染结果；表/Word → office 渲染检查实际页面；工具输出≠已目检。
5. **不编造**：伦理/基金/利益冲突/作者/AI 使用声明一律由用户提供；AI 声明只在用户明确要求时写入。
6. **引擎纯净**：不修改引擎母版；论文级差异走论文 `.wf/config.toml` 或 overrides；`--force` 不能豁免完整性门禁。
7. **隐私**：患者级/私密数据不上传外部服务；本地数据原地只读登记。
8. **参考文献池纪律（用户明确要求）**：S13 文献库目标规模约 **50 篇**（含 benchmark ranges 35–60 的容许带），按论证角色覆盖（临床问题/背景/前作/方法学/比较/机制）；**S13 收尾必须向用户报告池内文献数与各角色覆盖情况**；不足时先补检索再收尾，禁止"池子凑不满就带病推进"；引用数量不得低于论证实际需要（不为省额度删引用，也不为凑数加引用）。

## 7. 命名与目录规范（通用）

```text
papers/<slug>/
  00_input/       用户思路、原始材料、author_info.json
  01_protocol/    方案、决策、分析契约、图表计划、治理评估
  02_data/        raw/(不可变) acquisition/(取数代码) derived/(代码生成) manifest/codebook/provenance
  03_analysis/    code/ results/*.json analysis_log notes.md
  04_tables/      main/(每表一 xlsx) supplementary/(一簿多 sheet 三线表)
  05_figures/     out/(代码+矢量PDF+PNG) qc/ legends.md
  06_refs/        library.json verified.json refs.bib refs.ris fulltext/ deepread/
  07_manuscript/  分节 md、full_manuscript.md、审阅轮次、scientific_master_freeze.json
  08_submission/  期刊层：guideline_requirements.json、compliance_matrix、
                  integration/、releases/<期刊名>_<YYYY-MM-DD>/、journal_archives/
```
补充文件：`Supplemental_File_<N>_<描述>.<ext>`（不用 ESM1）；Word 默认 Times New Roman/12pt/双倍行距/纯黑/无黑点/无超链接/每表一页/末尾图注。

## 8. 命令速查（引擎通用，在论文工作区运行）

```powershell
# 状态与推进
wf.py status | handoff | card [--details] | check | advance --note "..." | decide NAME VALUE --why "..."
wf.py loop --to <stage>     # 显式回退（局部返工禁用，仅换设计等兜底）
wf.py tree -v | clean [--apply] | doctor | migrate --yes | rebuild --wait
# 数据
tools/data_sources.py add --path <绝对路径> --name <名> --why "..."
tools/data_manifest.py init|sync|verify          # 全量普查证明
# 文献
tools/pubmed/build_library.py --add-query "..." | --add-ids ... | --export
tools/pubmed/verify.py [--check]                 # 新鲜 EFetch 核验（S13/S25 实时）
tools/pubmed/fulltext.py fetch|register          # 全文（OA 路由 / 外部获取登记）
# 表图
tools/tables/（三线表生成）、tools/figures/render_r.py --figure "..."、tools/figures/qc.py
# 审阅与返工
tools/review_round.py start|ingest|close|decide
tools/review_round.py export --scope S19      # 导出审阅包 ZIP 供第三方审核（用户明确要求时）
tools/rework.py batch|status|check|close
# 期刊层
tools/journal.py begin|fetch|register|show|csl|seal|status|check
F:\deepseek\工作流\medpaper-helpers\capture_guidelines.py --url <URL> --out <目录> [--headed --manual-minutes 3]
# 自检
tools/selftest.py
```

## 9. 止损规则（用户明确要求，优先级最高）

- S02 检出主题饱和/无空白 → `STOP` 或 `PIVOT` + 检索证据，等用户拍板。
- S05/S06 探索后判断后期收益少（效应弱/样本不足/结果不收敛/竞争已完成）→ 成本-收益评估上报。
- S12.5 预审 `INSUFFICIENT` → 上报，不进入写作。
- 任何阶段发现"继续只是重复已知结论/为阳性而阳性" → 立即停下说明，绝不包装。
- 用户任何时候可叫停；流程状态在磁盘上，随时可恢复。

## 10. 交付物（一篇论文的终点）

- `08_submission/releases/<期刊名>_<日期>/`：manuscript.docx、title_page、cover letter、三线表 xlsx、图（PDF/PNG/TIFF）、补充文件、checklist、manifest、compliance_matrix
- `guideline_requirements.json` + 指南 vs 投稿系统差异清单
- S25 独立读者/编辑/合规终审 PASS 报告
- 科学母稿冻结 + 全部门禁证据（哈希绑定，可追溯）

---

## 11. 实测发现与修复（2026-11-11/12 工作流验证实录）

对测试实例（大规模公开药物警戒数据库全量普查）实测时发现并修复的问题（全部已固化进执行纪律）：

| # | 问题 | 修复 |
|---|---|---|
| 1 | 中文 Windows 下 Python 默认 GBK 解码，引擎 UTF-8 JSON 读取乱码、反斜杠吞并 → JSONDecodeError | 全局 `PYTHONUTF8=1`（User 级） |
| 2 | **gzip 头内嵌 mtime** → 分析文件每次重写字节不同 → 复现证明永不绿（replay differs） | 所有项目 gzip 写入改 `gzip.GzipFile(..., mtime=0)`（注意 `gzip.open` 不支持 mtime）；pandas `to_csv` 可直接写二进制句柄 |
| 3 | 按 chunk 去重（`drop_duplicates(keep="last")`）跨块边界漏去重 → 369 例重复 → 重写非幂等 | 全局"最后出现位置"两遍式去重（确定性 + 幂等） |
| 4 | spotcheck 把 `source_record_check` 写进结果 JSON → 沙箱重放产出不同 → replay differs | 把 spotcheck 并入 dataset_summary 生产者（自产自销），时间戳用 census 固定值 |
| 5 | 生产者读取未声明 inputs（派生表、中间文件…）→ 沙箱缺文件 → Producer failed | `write_results(inputs=...)` 必须声明**每个**实际输入（含跨生产者的下游表）；数据源经 `data:` 引用（沙箱内 registry 自动复制、外部数据零复制） |
| 6 | 依赖顺序：dataset_summary 生产者同时消费 02 的输出 → 顺序必须 02 标记 → build 摘要 → 03 分析 → replay | 固定为依赖序执行；生产者幂等后可任意重跑 |
| 7 | `replay` 默认复制预算 200MB → 大输入报 budget exceeded | `reproduce.py replay --copy-limit-mb 16384`（run 与 replay 都要传） |
| 8 | 分析改动后 reproduce 拒绝执行（"Execute analysis only at S05"） | 用 `wf loop --to S05_analysis` 回源重放，再重进（引擎纪律，不是缺陷） |
| 9 | 结果 payload 含 `built_at`/`checked_at` 时间戳 → 非确定 | 从 payload 移除或取固定值（census generated_at） |
| 10 | 决策（analysis_converged/go_nogo_2）随 loop 回退被清 | 重进 S06 后重录决策（自动绑定 scientific_inputs 证据指纹） |
| 11 | 大表逐行 python 循环（18M 行）耗时 60+ 分钟 | 唯一值映射（1M 唯一药名做正则 → pandas map 查表）+ groupby/merge 全向量化，13 分钟完成 |
| 12 | 药名 `^...$` 锚定漏掉带剂量后缀行（且别名可能只记录在另一字段） | 包含式匹配 + 完整别名表 + 多字段（通用名+商品名）计数 |数 |
| 13 | cap 扫描把表头嗅探 `[:40]` 切片误判为截断 | 取数代码避免任何 `[:N]` 切片（用整行检测） |
| 14 | 数据源注册名必须小写 | `data_sources.py add --name <小写名>`（稳定小写标识） |
| 15 | `wf clean --apply` 会删掉 temp 里的调试脚本 | 调试脚本放 `03_analysis/code/`（freeform 允许、不清理） |
| 16 | **pandas object dtype 上 `~` 是整数按位取反**：`~True == -2`（真值！）而非 `False`——`.apply(lambda...)` 产物、`fillna(False)` 后的列若为 object dtype，逻辑非静默变成真 → 整类错误分类（warfarin 全部被标成 doac，且只在全量运行出现、小样本复现正常） | 布尔列一律 `.astype(bool)` 后再用 `~`；或只用正向条件（`col == True`）避免 `~`；门禁（分层计数 vs 词典计数不一致）暴露了该损坏 |
| 17 | `astype(bool)` 对字符串列 "True"/"False" 会把非空串全转 True | 字符串布尔用 `.eq("True")` 判定 |

**执行纪律固化**：任何"结果 JSON 生产者"都必须 (a) 声明全部实际输入；(b) payload 无时间戳；(c) 输出字节级幂等；(d) 通过 `reproduce.py run + replay` 建立证明后才能进入写作冻结。

---

## 12. 验证完成度与收敛结论（2026-11-12）

**测试方式**：引擎母版保持纯净只读（一行未改）；用测试实例 + 真实大规模公开数据（数千万条报告级记录）从 S01 驱动到 S07；每阶段真实产出 + 门禁红绿 + 对抗性验证；发现的问题只修适配层/文档/项目脚本，再走 loop→reproduce→replay 证明链。

**已验证（真实数据实跑）**：

| 机制 | 证据 |
|---|---|
| 选题/可行性（S01-S02） | idea.json、3 组真实 PubMed 检索缓存、GO 决策 |
| 方案/治理（S03） | protocol、acquisition_plan、analysis_contract、官方政策证据（FDA/PMDA/Health Canada 哈希绑定） |
| 全量普查（S04） | 大规模公开数据全量解析、版本消解、删除记录、千万级记录/百级文件哈希绑定、manifest verify |
| 字典/标记/分析（S05） | 术语锁定、分析层定义、主分析+完整敏感性族、10 例源↔派生核对、**双生产者复现证明全绿** |
| 写作冻结（S06） | writing_readiness + 决策绑定证据指纹 |
| 图表对标（S07） | 3 篇 OA 对标全文（图 3/3/6、表 2/6/3 实测）、benchmark 密封、原型评审 13 项 PASS |

**机制已由引擎回归覆盖、留待真实研究执行时验证**：S08-S25 的写作/文献/图表/Word/期刊层门禁——引擎 selftest 231/231 覆盖（no_ai_boilerplate、citekeys_resolve、reference_provenance、build_docx 全套、reviewrounds、journalrules）；本实例已实跑其关键子机制：`verify.py` 8/8 实时核验、全文 OA 瀑布抓取与身份确认、`capture_guidelines.py` 冒烟、`review_round`/`rework` CLI 可用。

**收敛声明**：工作流核心科学链（选题→数据→分析→冻结→对标）已被真实数据证明可用；16 项实测问题修复固化（第 11 节）。测试实例**停在 S07**，不再继续跑论文——剩余阶段属于"真实研究执行"范畴，机制证据已具备，继续执行只验证重复性流程、不增加工作流认知。

**后续使用**：任意新研究 `new-paper.ps1` 启动 → 按本文档驱动；S08-S25 执行中若暴露新问题，按第 11 节流程定位→修复（只动适配层）→回源重放。用户 9 条需求中 R7（S12.5 预审）为新增检查点，需在真实研究到达 S12 时首次启用并验证；R8 浏览器指南抓取在 S20 首次启用。

---
