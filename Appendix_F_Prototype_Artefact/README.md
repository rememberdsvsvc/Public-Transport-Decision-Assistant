# Public Transport Disruption Decision Support App

## 1. Project Overview

This project is an iOS research prototype designed to explore how public transport disruption information can be presented more clearly and actionably to support passenger decision-making.

The prototype focuses on situations where a passenger has already planned a journey and a disruption affects part of that journey.

Rather than acting as a general journey planner, the application provides disruption-specific comparative decision support. It helps passengers understand:

- their original planned journey;
- which part of the journey is affected;
- how the disruption changes the expected journey;
- what realistic alternative journeys are available;
- the benefits and trade-offs of staying with the current journey or switching to another option.

The prototype is developed using SwiftUI and runs natively on iOS.

---

## 2. Main User Flow

The application contains four main stages.

### Page 1 — Current Journey

The passenger selects:

- Origin
- Destination
- Approximate journey time

The system searches for possible journeys within approximately ±10 minutes of the selected time.

Both direct and transfer journeys may be displayed, including combinations such as:

- Bus
- Train
- Ferry
- Bus → Train
- Bus → Bus
- Walk → Ferry → Walk

Similar repeated journey patterns are grouped to avoid displaying too many nearly identical options.

The passenger then selects the journey that best represents their intended current journey.

A lightweight **Route Preview** is available for the selected option to provide spatial context for the journey without turning the prototype into a full navigation application.

### Page 2 — Disruption Information

The system presents the passenger's complete journey and identifies which journey segment is affected by a disruption.

The page also explains the overall journey impact by comparing the scheduled journey with the updated expected journey.

A route map helps the passenger understand where the affected journey sits spatially and supports interpretation of the disruption.

### Page 3 — Decision Support

The passenger's current journey is compared with available alternatives.

The page supports comparison using practical journey attributes such as:

- expected arrival time;
- disruption risk or delay;
- number of transfers;
- walking time.

The passenger can select a decision priority:

- Arrive sooner
- Avoid disruption
- Fewer transfers
- Less walking

The displayed options are reordered according to the selected priority. The interface also explains why an option may be worth considering and, where relevant, presents its trade-offs.

The original/current journey remains available as an option when it is still usable.

When an option is selected, a lightweight route preview can be displayed to help the passenger understand the spatial differences between journey alternatives.

The purpose of this page is to support the passenger's decision rather than make the decision automatically.

### Page 4 — Post-Task Evaluation

After making a travel decision, the participant completes a post-task evaluation.

#### Section A — Immediate Post-Task Ratings

Participants rate four statements from 1 (Strongly disagree) to 5 (Strongly agree):

1. The disruption information was clear enough for me to understand its impact on my journey.
2. It was easy to compare the available travel options.
3. The prototype made the next step clear.
4. The information helped me feel more confident about making a travel decision.

#### Section B — Decision Confidence

Participants rate how confident they are that they chose an appropriate travel option, from 1 (Not confident at all) to 5 (Very confident).

#### Section C — Short Answers

Participants are asked:

1. What was the most confusing part, or what information was missing?
2. If you could change one thing, what would you improve?
3. Was there anything you were still unsure about when making your decision? What was it?

#### Section D — When Is This Support Useful?

Participants can select:

- Early service
- Delayed service
- Cancelled or changed service
- On-time service
- Other

Moderator follow-up questions are conducted separately during the interview and are not included in the participant-facing application interface.

---

## 3. Online Evaluation Data Collection

Post-task evaluation responses are submitted directly from the iOS application to a Supabase online database.

```text
Participant
    ↓
EvaluationView
    ↓
EvaluationAPIService
    ↓
Supabase REST API
    ↓
evaluation_responses
```

This allows responses collected on different iPhones to be stored centrally and reviewed through the Supabase dashboard.

The participant-facing client submits evaluation responses using the Supabase client configuration and database Row Level Security (RLS). The client is intended to submit responses without general permission to read, update, or delete other participants' responses.

The collected data can later be exported from Supabase for analysis.

---

## 4. Technology

The prototype uses:

- Swift
- SwiftUI
- MapKit
- Xcode
- SQLite
- Supabase
- Supabase REST API
- Native iOS navigation and interface components

SQLite is used for the application's simulated public transport data.

Supabase is used for centralised online collection of participant evaluation responses.

---

## 5. Project Structure

A simplified project structure is:

```text
transport-disruption-app
│
├── Components
│
├── Models
│   ├── Journey.swift
│   ├── JourneyOption.swift
│   ├── JourneySegment.swift
│   ├── TransportService.swift
│   └── Helpers
│       ├── StopCoordinates.swift
│       └── RouteWaypoints.swift
│
├── Resources
│   └── transport_simulation.db
│
├── Services
│   ├── DatabaseManager.swift
│   ├── DecisionLogic.swift
│   └── EvaluationAPIService.swift
│
├── Config
│   └── SupabaseConfig.swift
│
├── Views
│   ├── CurrentJourneyView.swift
│   ├── DisruptionInformationView.swift
│   ├── DecisionSupportView.swift
│   ├── EvaluationView.swift
│   └── JourneyMapView.swift
│
├── ContentView.swift
└── transport_disruption_appApp.swift
```

The exact Xcode group structure may differ slightly from this simplified structure.

---

## 6. Evaluation Database

Participant evaluation responses are stored online in the Supabase table:

```text
evaluation_responses
```

The table contains journey context, post-task ratings, decision confidence, written feedback, selected use cases, and the submission timestamp.

When the participant taps **Submit Evaluation**, the application sends the response to Supabase. An internet connection is therefore required for submission.

---

## 7. Running the Prototype

### Requirements

- macOS
- Xcode
- A compatible iOS Simulator or physical iPhone
- Internet connection for online evaluation submission

### Run in Xcode

1. Open the project in Xcode.
2. Select an iOS Simulator or connected iPhone.
3. Build and run the application.
4. Complete the journey and disruption decision-support flow.
5. Complete the Post-Task Evaluation.
6. Tap **Submit Evaluation**.
7. During testing, verify the response in the Supabase `evaluation_responses` table.

---

## 8. Supabase Configuration and Security

The project uses:

```text
SupabaseConfig.swift
EvaluationAPIService.swift
```

`SupabaseConfig.swift` provides the Supabase project URL and the client credential required for submission.

Never place the following credentials in the iOS application or GitHub repository:

- Supabase secret key
- `service_role` key
- Database password

Database access should remain restricted using Supabase Row Level Security policies.

---

## 9. Research Prototype Notice

This application is a research prototype.

The public transport services, schedules, and disruption conditions used by the prototype are simulated for evaluation purposes and should not be treated as live operational transport information.

Route previews provide simplified spatial visualisations for the research prototype and should not be interpreted as live or authoritative public transport navigation. Route geometry is used to support journey understanding and may approximate real-world service corridors.

The prototype is intended to evaluate how disruption information and comparative decision support may influence passenger understanding and decision-making.
