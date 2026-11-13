# writing-style — 写作风格与去 AI 化参考（DeepSeek 版）

写作四步法第 2 步（去 AI 化 + 医学润色）的本地参考库。

| 内容 | 说明 | 来源 |
|---|---|---|
| `de-ai-polish.md` | **医学版去 AI 化 + 润色检查清单**：AI 味机械检查 + 医学语境保护 + 防御性写作检查 + 医学诚信边界 + 交付前自测 | 综合 deslop / unslop / anti-defensive-writing 提炼裁剪 |
| `anti-defensive-writing/` | 学术写作原则（中英 SKILL + 提示词）：论文是发布会不是项目总结，禁自我削弱表达 | [Adkid-Zephyr/anti-defensive-writing-Skill](https://github.com/Adkid-Zephyr/anti-defensive-writing-Skill)（MIT，原样收录） |
| 外部上游（按需查阅） | `stephenturner/skill-deslop`（科学写作去 AI，MIT）｜`theclaymethod/unslop`（AI 味检测/重写，MIT）｜`bahayonghang/academic-writing-skills`（学术论文后处理：格式/润色/de-AI/引用检查/审稿式审计）｜`zczjyq/de-AIGC-skill`（中文学术去 AI 味） | GitHub |

## 使用位置

- 每个写作阶段（S08/S09/S14/S16/S17 与摘要）写完 md → 按 `de-ai-polish.md` 检查清单执行 → 再过引擎语言门禁
- 摘要/引言/结论的自信表达与结构组织 → 参考 `anti-defensive-writing/SKILL.md`
- **医学诚信边界**：风格层只改"怎么说"，不改"说什么"——阴性/矛盾/不可估计结果、局限性与不确定性必须如实报告（工作流红线优先于任何风格指令）
