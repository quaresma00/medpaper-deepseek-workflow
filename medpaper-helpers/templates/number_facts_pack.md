# S09 数字事实包（Number Facts Pack）模板

> 用途：写 Results/摘要前，从已执行的结果 JSON 生成事实清单；**Results 正文只写包里有的数字**；正文出现的新数字必须先导出到结果 JSON 再写。杜绝"正文心算/补造/张冠李戴"。
> 生成方式：读取 `03_analysis/results/*.json`（引擎 `readiness.facts` 或直接按本表提取），本文件是填表模板。

## 事实表

| 事实 ID | 数值（全精度） | 人群 | 终点 | 对比 | 效应尺度 | 分母 | 时间窗 | 来源（JSON 指针） | 将出现在 |
|---|---|---|---|---|---|---|---|---|---|
| F-001 | 17,993,398 | FAERS 最终报告 | — | — | 计数 | 报告 | 2004Q1–2026Q3 | dataset_summary.json → n_rows | Figure 1 / Methods |
| F-002 | 107,913 | 严格房颤层 | — | — | 计数 | 报告 | 2015Q1–2026Q2 | dataset_summary.json → stratum_counts | Figure 1 / Table 1 |
| F-003 | 40 / 104,021 / 8 / 11,238 | 严格房颤层 | 胆道/胆囊出血复合 | DOAC vs 华法林 | 2×2 报告数 | 层内报告 | 2015Q1–2026Q2 | primary_ror.json → analyses.primary…raw_cells | Table 2 / Figure 2 / Results |
| F-004 | ROR 0.54 (0.25–1.15) | 严格房颤层 | 复合终点 | DOAC vs 华法林 | ROR (95%CI) | 层内报告 | 2015Q1–2026Q2 | primary_ror.json → analyses.primary…ror/ci | Table 2 / Figure 2 / Results |
| … | … | … | … | … | … | … | … | … | … |

> 示例行仅为字段演示（示例数字来自工作流验证实例，不构成任何研究结论）。

## 使用规则

1. Results/摘要/表格/图注中出现的每个数字，必须能在本表找到（同一数值+绑定字段）；找不到 → 先导出再写。
2. 绑定字段必须逐项一致：人群、终点、对比、尺度（HR/RR/OR/ROR 不可混）、置信水平、分母、时间窗。
3. 引用既往文献的数字不在本表（走 source_claims：原文段落+位置+版本）。
4. 表格从结果 JSON 生成后，本表与表格数字必须一致（S12 对账兜底）。
5. 图内显式统计标注同样只来自结果 JSON（figure_annotations 绑定）。
