# Test Execution Report - 2026-09-02

## 1. Purpose

Verify that the current iOS prototype builds, installs, and launches, and confirm that the core workflow state transitions exist in the source. This is evidence for DECO6500 layer 1.2, Prototype and Technical; it does not replace participant usability testing.

## 2. Scope

This run covered:

1. Building an iOS Simulator app.
2. Installing, launching, and checking home-screen rendering.
3. Checking the state flow from journey selection to disruption information.
4. Checking the state flow from disruption information to decision support.
5. Checking the state flow from option selection to evaluation.
6. Checking submission to the confirmation state.

It did not cover live transport data, external submission, real-time alerts, physical-device compatibility, or participant understanding and decisions.

## 3. Environment

| Item | Value |
|---|---|
| Project commit | `d576fcd` |
| Build configuration | Debug, code signing disabled |
| SDK | iOS Simulator SDK 26.5 |
| Test device | iPhone 17 Pro Simulator, iOS 26.5 |
| Data | Bundled local SQLite simulation data |
| Test date | 2026-09-02 |

## 4. Procedure

1. Build the project with `xcodebuild` to a temporary derived-data directory.
2. Boot an iPhone 17 Pro Simulator.
3. Install and launch the app using its Bundle ID.
4. Capture the home screen and check whether the interface renders.
5. Inspect core Views, the Journey state model, and the database service to verify navigation conditions and state hand-off.
6. Record pass, fail, source-only verification, and manual-retest status.

## 5. Test Items and Results

| ID | Test Item | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| T-01 | Simulator build | The project compiles and creates an app bundle. | `xcodebuild build` succeeded. | Pass |
| T-02 | App install and launch | The app installs and opens at the home screen. | Installed and launched. The first immediate screenshot was blank; after relaunching and waiting 5 seconds, the home screen, icon, and Start Journey button rendered normally. | Pass; monitor launch timing |
| T-03 | Journey selection to disruption page | The selected JourneyOption is stored and the disruption page opens. | `CurrentJourneyView.selectJourney` calls `journey.setSelectedJourney` before presenting `DisruptionInformationView`. | Source pass; manual retest required |
| T-04 | Disruption page to decision page | Decision options are generated, stored, and shown on the decision page. | `DisruptionInformationView` finds options, calls `journey.setAlternativeOptions`, then presents `DecisionSupportView`. | Source pass; manual retest required |
| T-05 | Option selection to evaluation page | The option is stored and evaluation opens only after a selection. | `Journey.toggleOption` stores the selection; `DecisionSupportView` opens `EvaluationView` only when an option is selected. | Source pass; manual retest required |
| T-06 | Evaluation submission | Submission shows a confirmation state. | `submitEvaluation()` sets `submitted = true`; the page switches to confirmation. Data is only printed locally to the console. | Source pass; manual retest required |

## 6. Findings and Recommendations

| Priority | Finding or Risk | Impact | Recommendation |
|---|---|---|---|
| Medium | `InformationCard.swift` is in Xcode Copy Bundle Resources. | It does not block the build, but it is an incorrect resource configuration and produces a warning. | Remove the Swift file from Target -> Build Phases -> Copy Bundle Resources. |
| Medium | A short blank screen occurred on the first launch. | It may affect a participant's first impression of stability. | Retest on a reset simulator and a physical device; record time to first rendered screen. If repeatable, inspect main-thread initialisation work. |
| High | T-03 to T-06 have not received touch-driven end-to-end verification. | Source navigation exists, but runtime interaction may still fail. | Use the [technical verification template](technical-verification-template.md) to manually run all four scenarios in the simulator and retain de-identified screenshots/observations. |
| Low | Evaluation submission is not persistent. | Appropriate for a prototype, but it cannot automatically collect participant ratings. | Record ratings in the [session template](../testing/interview/en/test-session-template.md); add local export or an approved collection method only if later required. |

## 7. Conclusion and Next Steps

This run demonstrates that the prototype builds and its home screen launches in the simulator. Core page state and navigation logic exists in source, but later screens have not yet had touch-driven runtime verification; the full end-to-end flow must not be claimed as passed.

The development owner should manually verify T-03 to T-06, resolve or confirm the build warning, and complete a pilot before participant sessions. Collect usability, comprehension, in-context use, and decision-confidence evidence separately under the [usability test plan](../testing/interview/en/usability-test-plan.md).
