# Usability Test Plan

## Test Purpose

This formative evaluation asks whether a passenger can select a planned journey, understand a simulated disruption, compare options, and make a choice in the current SwiftUI prototype. The repository states that the prototype should make disruption information clearer and more actionable, but contains no interview, synthesis, hypothesis, or Test Card files. This is therefore a team-confirmation point, not an established discovery finding.

## Objectives and Research Questions

- Can participants independently select a journey, inspect disruption information, compare options, choose an option, and submit feedback?
- Do they understand the affected segment, service status, arrival impact, and comparison information?
- Can they find the next step without being told which control to use?
- Where do they hesitate, err, backtrack, abandon, or need help?
- Does the workflow make the next step and final state clear and appear to reduce disruption uncertainty?

## DECO6500 Committed Inquiry

**Leverage point:** the moment a passenger with a disrupted planned journey reviews its impact and decides whether to continue or choose an alternative. This is the specific decision point where the prototype intervenes, rather than the whole transport system.

The following four questions are the committed A2 questions. They cover Bands 1 and 2 only and should be checked against the course's six question tests before the team locks them:

- **1.1 Interaction and interface:** Can a first-time participant complete the disruption-information and option-selection flow without direct assistance?
- **1.2 Prototype and technical:** For fixed simulated journeys, does the prototype consistently carry the selected journey and show its disruption status, impact, and selectable options correctly?
- **2.1 In-context use:** In a time-limited disrupted-trip scenario, which information do participants actually use or overlook before choosing an option?
- **2.2 Human needs:** Does the information support a participant's confidence in making a travel decision, and what uncertainty remains?

Questions about operator workflows, data governance, accessibility equity, or long-term transport outcomes are recorded for A3 rather than answered by this A2 test.

## Participants and Environment

**Group A - general public-transport users.** Include adults who used public transport in the past six months; exclude team members and people who have practised the prototype. Recruit 5-8 participants. This group can reveal usability and comprehension issues, not population prevalence.

**Group B - relevant-background participants.** If available, recruit 2-4 people with direct transport operations or passenger-information experience, and clearly distinguish them from those with only related study or work backgrounds. They assess practicality of wording and information needs, not operational approval. If unavailable, run Group A only and record the evidence gap.

The qualitative strand is 5-8 moderated think-aloud sessions. The separate quantitative strand targets about 15 measured participants: task completion, time, errors/backtracks, and post-task confidence are recorded in the session template. It describes patterns rather than proving statistical significance. The in-app ratings may be recorded, but are not the quantitative strand on their own.

Test in person on an iPhone simulator or device with one moderator and an optional observer. Screen recording requires separate consent; record participant codes only. In remote sessions participants control their device and share the screen. Standard duration: 25 minutes (2 introduction/consent, 3 pre-test, 14 tasks, 5 interview, 1 close). See the [contingency plan](testing-contingency-plan.md) for the 10-minute version.

## Core Tasks

| ID | Scenario | Completion Criteria | Do Not Reveal |
|---|---|---|---|
| T1 | You are planning a public-transport trip. Use the prototype to find a journey matching the trip you intend to take. | A complete journey is selected and the disruption page is reached. | Controls or a route. |
| T2 | A disruption has affected part of that journey. Show what you think has changed and what it means for your trip. | The participant explains the status/affected part and one impact detail in their own words. | Badge or card locations. |
| T3 | You still need to reach your destination. Use the available information to decide what you would do. | An available option is selected and the participant gives a reason. | Which option is recommended. |
| T4 | Complete the prototype's final feedback step as you normally would. | Ratings or optional feedback can be entered and submission is reached. | The submit control. |

## Metrics, Intervention, and Analysis

- **Completion (2/1/0):** 2 independent success; 1 partial success with major hesitation, wrong path, or limited help; 0 failure, abandonment, or direct instruction.
- Record time, navigation errors, backtracks, hesitation, moderator assistance, abandonment, comments, and 1-5 confidence after T2/T3. Record technical delays separately from user errors.
- Hesitation is visible or verbal uncertainty of about three seconds or more before a next action. Assistance is classified as neutral or direct.
- Intervention sequence: observe silently; ask “What are you looking for now?”; ask “What would you expect here?”; give one neutral prompt; give direct help only when necessary and record it.
- Aggregate task outcomes, timings, repeated observations, and quotations. Keep observation and interpretation separate. Assess issues by frequency, impact, persistence, and risk: Critical prevents completion or causes a serious incorrect outcome; High is major/repeated difficulty; Medium is recoverable friction; Low is minor.

Pre-test asks about public-transport use and normal disruption behaviour. Post-test asks about the easiest and most confusing parts, missing information, comparison difficulty, barriers to use, difference from normal behaviour, and one improvement. Small convenience samples, local simulated SQLite data, prototype fidelity, the test setting, self-report, and absence of Group B are limitations.

Before recruitment, prepare the standard UQ Participant Information Sheet and Consent Form. Store signed consent, recordings, and identifiable transcripts only in the team's OneDrive; keep only de-identified notes and quotes in the research notebook or repository. Run and revise a pilot before formal testing, book participants by the end of Week 6, and run sessions in Week 7. See the [inquiry and evidence plan](deco6500-inquiry-plan.md).
