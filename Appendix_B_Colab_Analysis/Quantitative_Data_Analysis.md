# Quantitative Data Analysis

## 1. Dataset and Participant Context

### 1.1 Source file and preparation

The analysis used the de-identified file `quantity_data.csv`, prepared and uploaded on 13 September 2026.

The dataset contains 16 participants, and all 16 participants completed the qualitative interview component. Because there is no non-interviewed subgroup, an interviewee-versus-non-interviewee comparison is not applicable in this study.

No missing values were detected in the uploaded dataset.

Before upload, the CSV was cleaned so that:

- column names used underscores rather than spaces;
- completion time was converted to seconds and stored as numeric values;
- a standardised `Task_Outcome` column was added using `unaided`, `assisted`, and `not_completed`;
- `Public_Transport_Use_Frequency` was added as a participant-level background variable.

### 1.2 Public transport use frequency

9 of 16 participants reported **High** public transport use frequency, while 7 of 16 reported **Moderate** use. No participants were classified as low-frequency public transport users. The sample therefore mainly represents participants who already use public transport relatively regularly.

**Evidence register — demonstrates.** This demonstrates the composition of this participant sample because public transport use frequency was directly recorded for all 16 participants. However, it cannot establish the transport-use patterns of international students more generally and should not be generalised beyond this sample.

**Relevance to the evaluation.** This result does not directly answer one of the committed evaluation questions. Instead, it provides participant-context information for interpreting later findings about usability, disruption-information understanding, decision confidence, and perceived usefulness.

**What to check in the qualitative data.** Examine whether participants with different levels of public transport use describe different expectations, difficulties, or information needs during service disruptions. In particular, check whether higher-frequency users rely more on prior knowledge, familiar routes, or existing transport apps.

**Sampling limitation.** The sample contains only moderate- and high-frequency public transport users. If participants generally perform well with the prototype, part of that performance may reflect existing familiarity with public transport rather than the prototype alone.

---

## 2. Task Performance

### 2.1 Overall task outcome

15 of 16 participants (**94%**) completed the task unaided, while 1 participant (**6%**) completed it with assistance. No participant was classified as `not_completed`, and all participants reached a viable final travel action.

This bears directly on the Layer 1.1 evaluation question of whether participants can understand the disruption situation and use the prototype to make an appropriate next travel decision without assistance.

**Evidence register — suggests.** The large majority of participants were able to complete the task independently, suggesting that the prototype generally supported independent decision-making in this sample. However, this does not establish that all international students would be able to do the same, particularly because the sample contained only moderate- and high-frequency public transport users.

The assisted completion should be examined in the qualitative and observational data to identify where support was required: interpreting the disruption, understanding its impact, comparing alternatives, or selecting the final action. Participants classified as unaided should also be checked for hesitation or uncertainty, because successful task completion does not necessarily mean that the process was effortless or fully clear.

> **Classification note:** assistance Levels 0–1 were treated as `unaided`, while Levels 2–3 were treated as `assisted`. The outcome therefore reflects independent completion under the predefined assistance criteria rather than the complete absence of moderator interaction.

### 2.2 Completion time

All 16 participants completed the task.

- **Median:** 180 seconds
- **Mean:** 202.5 seconds
- **SD:** 78.6 seconds
- **Range:** 120–360 seconds

Most participants completed the task between 120 and 300 seconds, while one participant took 360 seconds.

![Figure 1. Completion time distribution](assets/figure_1.png)

This bears on the Layer 1.1 usability question by describing how efficiently participants were able to work through the prototype and reach a final travel decision.

**Evidence register — demonstrates / suggests.** The data demonstrate the completion-time distribution for these 16 participants. They suggest that most participants completed the task within a relatively short period, while the spread indicates that some participants required substantially more time than others. The result cannot establish that the same completion-time pattern would occur among international students more generally.

The qualitative data should be checked to understand why some participants took longer, especially the participant who required 360 seconds. Relevant explanations may include hesitation, difficulty interpreting disruption information, comparing alternatives, uncertainty about the final decision, or differences in prior public transport experience.

No major procedural deviation directly affects this measure. However, because the sample includes only moderate- and high-frequency public transport users, completion times may partly reflect participants' prior familiarity with public transport rather than the prototype alone.

---

## 3. Questionnaire and Likert Evidence

### 3.1 Information clarity and decision support

14 of 16 participants rated the ease of comparing travel options as **4 or 5**, and 13 of 16 rated next-step clarity as **4 or 5**. Both measures had a median of **4**.

**Evidence register — suggests.** Most participants rated the decision-support process positively, but the ratings alone cannot show which specific information or interface element made the process clear. The interview data should therefore identify which parts of the information supported comparison and action selection, and where participants still experienced hesitation or confusion.

### 3.2 Perceived usefulness

The strongest usefulness result concerned deciding whether the current travel plan needed to change: **9 of 16** participants selected the highest rating of 5, with a median of **5**.

Understanding how the disruption affected the participant's own journey was also rated strongly: **8 of 16** selected 5, with a median of **4.5**. The broader usefulness measures remained positive, with medians of **4**.

**Evidence register — suggests.** The prototype appears particularly useful for helping participants judge whether action is necessary rather than simply presenting disruption information. The interviews should explain what information participants relied on when deciding whether to continue their current journey or change plans.

### 3.3 Decision confidence

13 of 16 participants rated their overall decision confidence as **4 or 5**, with a median of **4**. Ratings specifically concerning whether the prototype information increased confidence were more dispersed, despite also having a median of 4.

**Evidence register — suggests.** Participants were generally confident in their final decisions, but the quantitative results do not establish that this confidence came entirely from the prototype. Interviews should examine whether confidence came from the presented information, prior public transport experience, route familiarity, or other transport tools.

### 3.4 Perceived ease of use

All four ease-of-use measures had a median of **4**, and most responses were concentrated at 4 or 5.

**Evidence register — suggests.** Participants generally perceived the prototype as learnable, understandable, and manageable to navigate. However, some of the perceived ease may reflect prior familiarity with public transport rather than the interface alone. The qualitative data should be checked for usability difficulties that were not visible in the positive ratings.

### 3.5 Measurement note

SUS and NASA-TLX were not used in this study. Evidence in this section instead comes from project-specific quick-evaluation items and adapted TAM measures and should be interpreted descriptively for this participant sample.

---

## 4. Exploratory Association

### 4.1 Pre-analysis decision

No formal Section 8 association was run using the available participant-level background variable because `Public_Transport_Use_Frequency` is categorical (`Moderate` / `High`) and is more appropriate for the two-group comparison in Section 5.

An exploratory association was examined between perceived usefulness and decision confidence to see whether participants who perceived the prototype as more useful also tended to report higher decision confidence. This was not pre-specified as a formal association because both variables are outcome measures rather than participant characteristics.

### 4.2 Perceived usefulness and decision confidence

![Figure 2. Decision confidence against perceived usefulness](assets/figure_2.png)

The scatterplot shows a moderate positive pattern between perceived usefulness and decision confidence.

- **Spearman's ρ:** 0.46
- **n:** 16
- **p:** .071

This does not reach the conventional p < .05 threshold, but it suggests that participants who perceived the prototype as more useful also tended to report higher decision confidence.

Because this analysis was exploratory rather than pre-specified, it should not be treated as a confirmatory finding. The association also does not establish causation. The interview data should be used to examine whether higher confidence was related to prototype usefulness, prior public transport experience, route familiarity, or other sources of information.

---

## 5. Differences by Public Transport Use Frequency

### 5.1 Pre-analysis comparisons

Two comparisons were decided in advance:

1. **Completion time:** High vs Moderate public transport use frequency, because prior transport familiarity may affect how quickly participants interpret disruption information and reach a travel decision.
2. **Decision confidence:** High vs Moderate public transport use frequency, because prior transport familiarity may influence confidence when responding to disruption information.

### 5.2 Completion time by public transport use frequency

![Figure 3. Completion time by public transport use frequency](assets/figure_3.png)

Participants with High public transport use frequency (**n = 9**) had a median completion time of **240 seconds**, while participants with Moderate use frequency (**n = 7**) had a median of **120 seconds**. The dot plot shows considerable spread within both groups, particularly among high-frequency users.

- **Mann–Whitney U:** 49.0
- **p:** .063

**Evidence register — suggests.** In this sample, high-frequency users tended to take longer rather than complete the task faster. However, the test could not distinguish this observed difference from chance at the conventional p < .05 level, and the groups are small. It therefore cannot establish that public transport use frequency is associated with completion speed.

The qualitative and observational data should be checked to explain why some high-frequency users took longer. One possibility to examine is whether more experienced users considered more alternatives, compared the prototype against existing knowledge, or questioned the information more carefully rather than simply completing the task faster. Interviews should also help determine whether longer times reflected difficulty or more deliberate decision-making.

### 5.3 Decision confidence by public transport use frequency

![Figure 4. Decision confidence by public transport use frequency](assets/figure_4.png)

Both groups had a median decision-confidence rating of **4**. High-frequency users (**n = 9**) and moderate-frequency users (**n = 7**) showed substantial overlap in their ratings, with scores in both groups ranging from 3 to 5.

- **Mann–Whitney U:** 37.5
- **p:** .526

**Evidence register — cannot establish.** The current sample provides no clear quantitative evidence that decision confidence differed according to public transport use frequency. This should not be interpreted as evidence that the groups are identical; with only 9 and 7 participants, the study is too small to detect anything other than a relatively large difference.

The interview data should therefore be used to examine where participants said their confidence came from — for example, prototype information, familiarity with the route, prior public transport experience, or other transport tools.

---

## 6. Interviewee Typicality

This comparison is not applicable because all 16 participants completed the qualitative interview component. There is therefore no non-interviewed subgroup against which the interview participants can be compared.

Because the qualitative and quantitative data were collected from the same participant sample, the qualitative findings are not based on a smaller selected subgroup. However, the limitations of the overall participant sample still apply, including the absence of low-frequency public transport users.

---

## 7. Summary of Quantitative Findings

### Committed question 1 — Independent task completion

The quantitative results suggest that the prototype generally supported independent task completion in this sample. **15 of 16 participants (94%)** completed the task unaided, all participants reached a viable final action, and the median completion time was **180 seconds**, although times ranged from 120 to 360 seconds.

### Committed question 2 — Clarity and ease of use

The ratings suggest that participants generally found the prototype clear and usable for comparing options and identifying what to do next. Option comparison and next-step clarity both had a median of **4**, while all four ease-of-use measures also had a median of **4**. The quantitative data alone cannot explain where any remaining confusion or hesitation occurred.

### Committed question 3 — Usefulness and decision confidence

The results suggest that the prototype provided useful decision support and was associated with generally positive decision confidence. The strongest usefulness evidence concerned helping participants decide whether their travel plan needed to change, with a median of **5**, while overall decision confidence had a median of **4**.

The exploratory association between perceived usefulness and decision confidence showed a moderate positive pattern (**Spearman's ρ = 0.46, n = 16, p = .071**), but this did not reach the conventional p < .05 threshold.

### Limitations visible in the quantitative data

- The sample included only **16 participants**.
- Only **Moderate** and **High** public transport users were represented; no low-frequency users were included.
- All participants completed the interview, so there was no separate interview subgroup for typicality analysis.
- Participant characteristics such as age, prior experience with public transport applications, and general device or digital-interface experience were not included in the quantitative dataset.
- These unmeasured characteristics may have influenced completion time, perceived ease of use, perceived usefulness, and decision confidence.
- Public transport use frequency showed an observed completion-time difference (High median = 240 seconds; Moderate median = 120 seconds), but the sample was too small to distinguish this difference from chance (**U = 49.0, p = .063**).

> Overall, the quantitative findings should be treated as **descriptive evidence from this sample** and interpreted together with the qualitative and observational data.

---

# Appendix A. Coding and Classification Criteria for Quantitative Data

The following criteria were used consistently when converting observation records, participant responses, and test outcomes into categorical variables for quantitative analysis. These definitions were established to ensure that the same interpretation was applied across all participants.

## A1. Task checkpoint variables

Variables:

- `Task_Start_Completed`
- `Task_Understand_Disruption`
- `Task_Identify_Impact`
- `Task_Judge_Action`
- `Task_Compare_Options`
- `Task_Select_Action`

| Code | Criterion |
|---|---|
| `Yes` | The participant demonstrated the expected understanding or completed the required action correctly without substantive researcher assistance. |
| `Partial` | The participant demonstrated some correct understanding or progress, but the response was incomplete, uncertain, or required clarification before reaching the expected result. |
| `No` | The participant did not demonstrate the required understanding or action, made an incorrect judgement that was not independently corrected, or was unable to complete the checkpoint. |

Hesitation alone was not classified as `Partial` or `No` if the participant ultimately completed the checkpoint correctly without substantive assistance.

## A2. Maximum assistance level

| Level | Label | Criterion |
|---|---|---|
| 0 | No assistance | The participant completed the task without researcher intervention. |
| 1 | Neutral prompt | The researcher provided a neutral prompt that did not indicate the correct answer, required action, or location of information. |
| 2 | Procedural hint | The researcher provided guidance that helped the participant identify how or where to proceed. |
| 3 | Direct instruction | The researcher explicitly told the participant what action to take or provided the information required to continue. |

For quantitative analysis, Levels **0–1** were treated as independent completion, while Levels **2–3** were treated as assisted completion.

## A3. Overall task outcome

| Outcome | Criterion |
|---|---|
| `Unaided` | The participant reached a viable final travel action with a maximum assistance level of 0 or 1. |
| `Assisted` | The participant reached a viable final travel action but required assistance at Level 2 or 3. |
| `Not completed` | The participant did not reach a viable final action, abandoned the task, or required the researcher to provide the final decision or answer. |

This variable represents overall independence of task completion rather than whether every intermediate checkpoint was completed perfectly.

## A4. Final action viability

| Code | Criterion |
|---|---|
| `Viable` | The participant selected a travel action that could reasonably be carried out and appropriately responded to the disruption scenario. |
| `Not viable` | The selected action did not adequately respond to the disruption or would not allow the participant to continue the journey as required. |

A viable final action does not necessarily mean that the participant completed the process without difficulty or assistance.

## A5. Useful disruption contexts

Variables:

- `Useful_Early_Service`
- `Useful_Delayed_Service`
- `Useful_Cancelled_Changed`
- `Useful_On_Time`
- `Useful_Other`

| Code | Criterion |
|---|---|
| `Yes` | The participant selected that situation as one in which they would want this type of information or decision support. |
| `No` | The participant did not select that situation. |

These variables represent participant preferences and should not be interpreted as task-performance measures.

## A6. Public transport use frequency

`Public_Transport_Use_Frequency` was based directly on participants' self-reported public transport use frequency during data collection.

| Category | Criterion |
|---|---|
| `High` | The participant self-reported public transport use frequency as High. |
| `Moderate` | The participant self-reported public transport use frequency as Moderate. |

These categories were retained exactly as reported by participants and were used as categorical participant-background variables. No additional threshold, numerical conversion, or post-hoc reclassification was introduced.

## A7. Completion time

`Completion_Time` represents the time required for the participant to complete the task and reach a final travel decision.

All completion times were converted to and recorded in seconds before quantitative analysis to ensure consistent measurement across participants.

Completion time was treated as a numeric measure. It was interpreted alongside task outcome and qualitative observations, because a longer completion time does not necessarily indicate poorer performance; it may also reflect more extensive comparison, hesitation, or deliberation.

## A8. Likert-scale ratings

Quick-evaluation and TAM questionnaire items used a five-point Likert scale:

1. Strongly disagree
2. Disagree
3. Neutral
4. Agree
5. Strongly agree

Individual Likert items were treated as ordinal variables and were primarily described using response counts and medians.

The adapted TAM questionnaire contained two constructs:

- **Perceived Usefulness (PU):** calculated from `PU1`–`PU4`.
- **Perceived Ease of Use (PEOU):** calculated from `PEOU1`–`PEOU4`.

For each participant, `PU_Mean` and `PEOU_Mean` were calculated as the mean of the four corresponding items. The supplementary decision-confidence item was analysed separately and was not included in either TAM construct.

## A9. General coding rules

- All categorical values were derived from the original observation sheets, participant responses, and test records rather than inferred retrospectively from later interview interpretation.
- Prototype malfunctions or technical failures were not classified as participant errors or failures.
- Where available evidence was insufficient to support a classification, the value should be treated as missing rather than inferred.
- The same definitions and coding rules were applied consistently across all participants to maintain comparability within the quantitative dataset.
