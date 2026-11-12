# User-global agent instructions (DeepSeek Harness)

## medpaper research-paper workflow

当用户的任务涉及"医学/临床研究论文、发文思路、SCIE original article、公开数据集挖掘、药物警戒、PubMed 文献、期刊投稿"且提到 medpaper 时：

1. 若当前/最近工作目录是论文工作区（含 `pipeline/pipeline.toml` 与 `.venv`）：按 medpaper 工作流驱动，入口命令
   `pwsh <workflow-root>/medpaper-helpers/medpaper.ps1 <command>`（或 PATH 中的 `medpaper`）：
   `medpaper`（状态+阶段卡）→ 执行阶段工作 → `medpaper check` → `medpaper advance -n "<完成内容>"`。
2. 若是新研究：`medpaper new -Slug <名称> -IdeaFile <思路.md> [-DataDir <数据目录>]`。
3. 完整执行纪律见 `MEDPAPER-WORKFLOW.md`（workflow 根目录）与 medpaper skill。
4. 硬性底线：全量数据普查（禁抽样截断）、文献只认 PubMed EFetch 实时核验（禁手写/伪造引用文件）、
   数字只来自执行的结果 JSON、每节当场医学润色、S19/S24 需用户明确"我确认这一版"、任何阶段发现不值得继续立即上报止损。
