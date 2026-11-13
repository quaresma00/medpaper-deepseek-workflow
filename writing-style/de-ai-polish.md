# 去 AI 化 + 医学润色检查清单（DeepSeek 版）

> 每个写作阶段（S08/S09/S14/S16/S17 及摘要）写完 md 后，立即按本清单执行**去 AI 化 + 医学润色**，再过语言门禁。
> 本清单综合三个外部参考的规则并对医学论文做裁剪：
> - `stephenturner/skill-deslop`（科学写作去 AI 化，MIT）
> - `theclaymethod/unslop`（AI 味检测/重写，MIT）
> - `Adkid-Zephyr/anti-defensive-writing-Skill`（学术写作原则，MIT；SKILL 与提示词见 `anti-defensive-writing/` 目录）
> - 引擎内置 `reference/medical-writing.md`（医学表达正面示例）

## 一、AI 味检查（机械层，逐条对照）

**填充与开场**
- 清嗓式开场（"值得注意的是""Here's the thing""It's worth noting"）→ 直接陈述
- 强调拐杖（"Let that sink in""这一点怎么强调都不为过"）→ 删除
- 元评论（"本节将探讨…""In this section, we'll explore…"）→ 删除
- 意义膨胀（"意义重大""landmark""pivotal""rich tapestry"）→ 换成具体事实

**结构与节奏**
- 二元对比句（"不是 X，而是 Y"）、否定列举、戏剧性碎片短句堆叠 → 改写为直接陈述
- 三连句/排比滥用 → 用两项或一项
- 连续三句以上同长度 → 打断
- 每段以"However/Moreover/此外"开头（连接脚手架）→ 让段落以自身主张开头
- 自我设问立即自答（"为什么这很重要？因为…"）→ 并入陈述
- 每段结尾都是短句结论（staccato）→ 变化
- 段落小结式收尾（总结三明治）→ 删除重复

**词汇与语法**
- 魔法副词（"quietly""significantly"空转、"delve""tapestry""nuanced"）→ 删除或换具体词
- 被动语态能找到施动者 → 换主动（科学写作中"we"用于自己的工作）
- 无生命事物做人的动作（"数据表明…""the data tells a story"）→ 改为"我们观察到…/结果支持…"
- 泛化绝对词（"every""always""never"做模糊工作）→ 换具体范围
- 模糊归因（"Experts argue""Studies show""研究表明"）→ 点名具体文献（本项目引用必须绑定已验证文献）
- 无实义范围（"from X to Y"）→ 删除

**格式**
- em dash（——）超过每段一个 → 换逗号/句号/括号；**医学稿件统一不用 em dash**
- 无 Unicode 箭头（↓→↑）替代文字
- 加粗引导的列表式段落冒充散文 → 恢复为散文
- "In conclusion/总而言之"式签名结尾 → 删除

## 二、医学语境保护（本清单与通用去 AI 工具的区别）

医学论文的**必要措辞不是 AI 味**，以下必须原样保留：

- 科学/统计限定语："does not establish causation""不能确立因果关系""报告层面关联""95% CI"
- 不确定性表达（当事实如此）："尚不明确""证据有限""需进一步验证"——**如实的不确定是医学诚信，不是防御性写作**
- 法定/安全措辞："不得""禁止""风险""不良反应"
- 领域术语是精确语言："reporting odds ratio""propensity score""time-to-event" 不是行话
- 引用/数字/单位/日期/否定词/范围：**任何重写不得改变事实**（数字与引文变化必须回源校验）

## 三、防御性写作检查（表达自信，事实完整）

来自 anti-defensive-writing：**论文是学术发布会，不是项目总结；围绕最强主张组织，不自我削弱。**

- 禁用自我削弱表达："遗憾的是…""效果有限""仍明显落后""尚需进一步研究"（当它不是事实需要时）→ 直接陈述实际结果
- 不占优的结果不说"输"：如实报告但不过度道歉；阴性结果按工作流红线如实呈现（"未观察到差异""估计不可用"是陈述，不是贬低）
- 每个实验/分析承担一个论证职责，不附录式堆结果
- 结论只强化记忆点：解决了什么、证明了什么、为什么重要
- 摘要/引言按"发布会开场"组织：问题 X 关键、现有缺 Y、本文做 Z、证据如下

> **边界（医学诚信优先）**：anti-defensive 的"自信表达"绝不覆盖工作流红线——阴性/矛盾/不可估计结果必须如实报告，局限性必须真实说明。风格层只改"怎么说"，不改"说什么"。

## 四、快速自测（交付前）

1. 任何 -ly/地/的 修饰副词能否删？能删就删
2. 被动句能找到施动者吗？找到就换主动
3. 有没有"值得注意的是/需要指出/本节将"？删除
4. 有无"不是 X 而是 Y/其一…其二…其三…"？改写
5. 有无连续三句同长？打断
6. 段末有 em dash 或 ↓？移除
7. 每个段落是否以自身主张开头（而非连接词）？
8. 阴性/局限/不确定性是否如实保留（不被"自信化"删掉）？
9. 数字/引文/单位与来源是否一致（改后必须回源核对）？
10. 读起来像一个具体研究者在写给医学读者，而不是模型在汇报？

## 参考文件

- 完整规则与示例：`anti-defensive-writing/SKILL.md`（中文）、`anti-defensive-writing-en/SKILL.md`
- 提示词版（可单独用于任何对话）：`anti-defensive-writing/prompts/精简版提示词.txt`、`quick-prompt-en.txt`
- 外部上游（如需更深目录）：`github.com/stephenturner/skill-deslop`、`github.com/theclaymethod/unslop`、`github.com/bahayonghang/academic-writing-skills`、`github.com/zczjyq/de-AIGC-skill`（中文学术）
