# Technical Test Report

## Purpose

Record reproducible technical checks for Q2 and the technical preconditions for Q1, Q3, and Q4. Human outcomes are excluded; see [Technical vs Participant Evidence](TECHNICAL_VS_PARTICIPANT_EVIDENCE.md).

## Environment and Command

Run from the repository root:

```bash
bash tests/technical_verification.sh
```

The script builds the iOS Simulator target with code signing disabled, then checks the bundled SQLite fixture and source-level state hand-off rules. It is not a substitute for XCTest UI automation.

## Tests Executed

| Test ID | Related question | Component | Expected result | Actual result | Status |
|---|---|---|---|---|---|
| T-01 | Q1, Q2 | Simulator build | App bundle builds. | Build completed successfully. | PASS |
| T-02a | Q2 | Fixed disruption fixture | Normal Service record exists. | Present in SQLite. | PASS |
| T-02b | Q2 | Fixed disruption fixture | Minor Delay record exists. | Present in SQLite. | PASS |
| T-02c | Q2 | Fixed disruption fixture | Major Delay record exists. | Present in SQLite. | PASS |
| T-03 | Q2 | Cancellation fixture | At least one cancellation scenario exists. | No Cancellation rows exist. | SKIP: known limitation |
| T-04 | Q2 | Alternative filtering | Cancelled alternatives are filtered by source rule. | `findDecisionOptions` contains the cancellation exclusion rule. | PASS: source rule |
| T-05 | Q1, Q2 | State hand-off | Journey, alternatives, and selected option are handed between pages. | Required `setSelectedJourney`, `setAlternativeOptions`, and `toggleOption` calls are present. | PASS: source rule |
| T-06 | Q2 | Controlled transition | A normal-to-disruption mechanism exists. | No scenario/event transition mechanism found. | SKIP: known limitation |

**Execution summary:** 8 collected, 6 passed, 0 failed, 2 skipped. The build also emitted a non-blocking warning that `InformationCard.swift` is incorrectly included in Copy Bundle Resources.

## Manual Verification Procedure

1. Launch the app in an iPhone simulator.
2. Select a reproducible fixed-delay journey from [Controlled Scenarios](CONTROLLED_SCENARIOS.md).
3. Confirm the disruption card, impact text, option list, selection, and evaluation summary match the selected data.
4. Repeat when a cancellation fixture and controlled transition are implemented.

## Interpretation Boundary

A passing script demonstrates only the checked build, database, and source rules. It does not prove real-time transport behaviour or participant comprehension, confidence, or decision quality.
