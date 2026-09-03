# Technical Resolution

## Static Rather Than Dynamic Disruption State

**Why it matters:** Q2 asks whether changed conditions update disruption, impact, and alternatives.

**Initial status:** Partially supported. The app reads a fixed state from SQLite.

**Investigation:** `JourneySegment` values are immutable and `DatabaseManager` only loads rows; no event or scenario-state transition exists.

**Can it be technically resolved?** PARTIALLY.

**Action taken:** No production change was made. The limitation and controlled-scenario requirement are documented because adding a transition needs an agreed deterministic fixture design.

**What remains:** The current app cannot prove updates after a disruption occurs. This must be added before Q2 is tested as a transition, or Q2 must be narrowed to fixed-state correctness.

## Cancellation Coverage

**Why it matters:** Q2 requires cancellation behaviour and alternative filtering.

**Initial status:** Not supported by bundled data.

**Investigation:** The database has 0 Cancellation segments. Source excludes cancelled alternatives, but no data exercises that path.

**Can it be technically resolved?** YES, with deterministic cancellation fixture data and a manual/automated scenario check.

**Action taken:** Not changed in this review to avoid inventing route values without team agreement.

**What remains:** Do not claim cancellation handling is verified until the fixture exists and passes.

## Human Outcomes

**Can it be technically resolved?** NO.

Comprehension, need, confidence, and uncertainty require participant evidence. See [Technical vs Participant Evidence](TECHNICAL_VS_PARTICIPANT_EVIDENCE.md).
