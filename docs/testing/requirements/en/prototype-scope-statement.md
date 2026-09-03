# Prototype Scope Statement

## Must Be Real

| Capability | Required by Question |
|---|---|
| Select an origin, destination, time, and planned journey. | 1.1, 1.2 |
| Carry the selected journey to a disruption-information view. | 1.1, 1.2 |
| Display a simulated affected segment, status, and arrival impact. | 1.2, 2.1 |
| Compare and select an available journey option. | 1.1, 2.1, 2.2 |

## Can Be Simulated

- Local SQLite journey and disruption data.
- Fixed journey scenarios and hardcoded disruption states.
- Local evaluation submission with manually captured scores.

## Not Building for A2

- Live network feeds, real-time alerts, accounts, authentication, payment, or ticketing.
- Operator workflows, dispatch tools, passenger support, and service recovery.
- Claims about long-term behaviour, equity, governance, or environmental outcomes.

## Build Sequence

Confirm the four must-be-real flows, run the fixed-scenario technical check, prepare the test instruments, conduct a pilot, revise, then freeze the evaluation build before Week 7. Assign an owner and end-of-Week-6 completion date to each dependency.
