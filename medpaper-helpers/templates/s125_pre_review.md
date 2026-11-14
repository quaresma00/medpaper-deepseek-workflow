# S12.5 分析证据预审——独立审阅子代理简报模板

> 用途：S12 对账完成后、S13 文献库前，把本文件内容（+ 实际材料路径）交给一个**只读**独立子代理。
> 子代理只写自己的报告（.wf/review_bundle/<round>/report.md），不编辑任何论文文件。
> 主代理不代笔结论；SUPPORT/REVISE/INSUFFICIENT 由子代理给出，返修由主代理回源执行。

## 给子代理的中性简报（复制后填入）

```
你是一名独立审阅者。只读以下材料，不修改任何文件，不访问后台上下文。
目标：判定"当前的分析方法与结果、以及计划/已产出的表和图，是否足够支撑一篇
SCIE original article"，并给出返修建议（如有）。

材料（全部只读）：
- 03_analysis/method_scan.md
- 03_analysis/analysis_log.md
- 03_analysis/results/primary_ror.json（及同目录其余结果 JSON）
- 01_protocol/analysis_contract.json
- 01_protocol/study_facts.json
- 01_protocol/artifact_plan.json
- 01_protocol/prototypes/（图/表原型）与 01_protocol/display_review.json
- 02_data/acquisition_manifest.json（全量普查证明）
- 01_protocol/artifact_benchmark.md（对标：最新 5–10 篇论文的图表数量/类型）

请按下面六项判据逐项给出 PASS / REVISE（+ 具体修改建议与归属阶段），最后给出总体判定。
```

## 六项判据

| # | 判据 | 核对要点 | 判定 |
|---|---|---|---|
| 1 | 设计有效性 | 设计/分析单位/分母定义与研究问题一致；同适应证对照成立；伦理与数据范围无硬伤 | PASS / REVISE(→S03/S05) |
| 2 | 统计严谨性 | 模型选择合理；效应尺度与置信水平明确；零单元格/稀疏处理诚实（Firth/exact/描述性）；多重性说明 | PASS / REVISE(→S05) |
| 3 | 结果稳健性 | 敏感性族完整且预设；阴性/矛盾/不可估计结果如实呈现；结论强度与证据匹配 | PASS / REVISE(→S05/S09) |
| 4 | 表图充分性（vs 对标） | 表/图数量与类型对标最新 5–10 篇论文是否充分；每张图承担论证职责；无"分析报告"式产物 | PASS / REVISE(→S10/S11) |
| 5 | 医学可读性 | 表/图内文字与图注为医学语言；无工程词/代码词；图注不复述结果；医生能独立看懂 | PASS / REVISE(→S10/S11) |
| 6 | 阴性结果处理 | 零结果/不利结果/局限性是否如实报告，未被风格化隐藏或改写 | PASS / REVISE(→S05/S09) |

## 总体判定

- **SUPPORT**：六项全部 PASS（或仅有非阻断性建议）→ 继续 S13。
- **REVISE_ANALYSIS**：存在阻断项 → 主代理回源（标注归属阶段 S05/S08/S09/S10/S11）返修 → 重跑证明 → 重新预审。
- **INSUFFICIENT**：设计/证据硬伤无法通过返修解决 → 上报用户（止损），不进入写作。

## 输出格式（report.md）

```markdown
# S12.5 预审报告（round <id>）
总体判定：<SUPPORT|REVISE_ANALYSIS|INSUFFICIENT>
逐项：<判据编号> <判定> <依据（文件+位置）> <修改建议（如REVISE，注明归属阶段）>
返修清单（如REVISE）：<逐条：改什么、在哪改、验收标准>
```
