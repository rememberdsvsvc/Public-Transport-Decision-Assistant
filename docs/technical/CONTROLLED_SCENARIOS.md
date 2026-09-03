# Controlled Scenarios

## Current Scenario Evidence

| ID | Initial journey | Trigger | Expected post-trigger state | Q support | Status |
|---|---|---|---|---|---|
| A | Indooroopilly -> Brisbane City, option 424, Route 430, expected arrival 09:09. | No trigger: this row is already a Major Delay of 12 minutes. | Impact is loaded from the database; non-cancelled options in the selected-time window are ranked. | Q1, Q2 | Existing fixed state, reproducible only while database stays unchanged. |
| B | Cancellation journey with a viable alternative. | Controlled cancellation. | Current journey unavailable; at least one non-cancelled option offered. | Q2 | NOT AVAILABLE: bundled database has no Cancellation segment. |
| C | Normal journey -> Major Delay on the same selected journey. | Controlled state transition. | Status, impact, and alternatives change after selection. | Q2 | NOT AVAILABLE: architecture loads static rows and has no transition mechanism. |

Scenario A is suitable for a limited participant pilot. Scenario B must be added as deterministic fixture data before cancellation behaviour is claimed. Scenario C needs a small explicit scenario-state layer; static scenario loading must not be described as real-time updating.
