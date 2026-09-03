# Technical Feasibility Review

## Requirement-to-System Audit

| Question | Technical component | Participant component | Current support | Status | A2 action |
|---|---|---|---|---|---|
| Q1: understand disruption, impact, and independently select an action | Display selected journey, segment status, impact, and selectable options. | Understanding, independent success, and decision quality. | Views and `Journey` state provide the required controls and displays. | PARTIALLY SUPPORTED | Technically verify controls; use interview testing for human outcomes. |
| Q2: simulated conditions correctly update disruption, impact, alternatives | Represent condition change and recompute all dependent values. | None required for core software correctness. | Database loads fixed disruption values; decision options are filtered/ranked from them. No runtime transition exists. | PARTIALLY SUPPORTED | Verify fixed scenarios; add deterministic transition only if needed before pilot. |
| Q3: when/why information is needed and what supports decisions | Make information available at the intended decision point. | Timing, reason, and information use. | Standalone current-journey entry establishes a test context. | NOT TECHNICALLY ESTABLISHABLE | Evaluate with participant scenarios and think-aloud. |
| Q4: features may improve confidence and reduce uncertainty | Provide disruption, impact, comparison, and selection features. | Confidence, uncertainty, perceived control, usefulness. | Features exist; evaluation ratings are local only. | NOT TECHNICALLY ESTABLISHABLE | Evaluate with participant evidence; do not infer outcomes from technical tests. |

## Q2 Audit

The local SQLite database has fixed `disruption_type` and `delay_minutes` values per journey segment. It contains Normal Service, Minor Delay, and Major Delay records, but no Cancellation records. `DatabaseManager.findDecisionOptions` excludes cancelled alternatives and ranks remaining options by expected arrival, transfers, delay, and duration; this rule is present but cancellation cannot be exercised with the bundled data. The app does not mutate journey data after selection, so it loads a pre-existing simulated condition rather than modelling a live disruption transition.

## Final Technical Verdict

| Requirement | Technical status | Verified? | Requires participant evidence? | Remaining limitation |
|---|---|---|---|---|
| Q1 | Partially supported | Build and source flow verified | Yes | Runtime touch flow still needs manual pilot. |
| Q2 | Partially supported | Fixed data loading and build verified | No for core correctness | No cancellation data and no dynamic transition. |
| Q3 | Not technically establishable | N/A | Yes | Standalone entry is research scaffolding. |
| Q4 | Not technically establishable | Feature availability only | Yes | Local ratings do not prove confidence. |

**NOT READY FOR PILOT.** The prototype can support a limited fixed-scenario pilot only after a manual end-to-end check and a deterministic cancellation scenario or an explicit removal of cancellation from the committed Q2 scope. It cannot yet test a normal-to-disruption state transition.
