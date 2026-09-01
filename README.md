# Public Transport Disruption Decision Support App

## 1. Project Overview

This project is an iOS prototype designed to explore how public transport
disruption information can be presented more clearly and actionably to
support passenger decision-making.

The prototype focuses on situations where a passenger has already planned
a journey and a disruption affects part of that journey.

Instead of only showing that a service is delayed or cancelled, the system
shows:

- the passenger's complete planned journey;
- which part of the journey is affected;
- how the disruption changes the expected journey;
- available alternative journeys;
- key information for comparing the alternatives.

The prototype is developed using SwiftUI and runs natively on iOS.


## 2. Main User Flow

The application contains four main stages:

### Page 1 — Current Journey

The passenger selects:

- Origin
- Destination
- Approximate journey time

The system searches for possible journeys within approximately ±10 minutes
of the selected time.

Both direct and transfer journeys may be displayed, including combinations
such as:

- Bus
- Train
- Ferry
- Bus → Train
- Bus → Bus
- Walk → Ferry → Walk

Similar repeated journey patterns are grouped to avoid showing too many
nearly identical options.

The passenger then selects the journey that best represents their intended
current journey.


### Page 2 — Disruption Information

The system presents the passenger's complete journey and identifies which
journey segment is affected by disruption.

For example:

Route 412  
UQ Lakes → Toowong  
Normal Service

Transfer

Ipswich Line  
Toowong → Brisbane City  
Major Delay • 15 min

The page also explains the overall journey impact by comparing the scheduled
arrival time with the expected arrival time.


### Page 3 — Decision Support

The passenger's current journey is compared with available alternatives.

Options are primarily ranked using:

1. Expected arrival time
2. Number of transfers
3. Disruption delay
4. Total journey time

Up to five options are displayed.

The first ranked option is labelled "Recommended Option". This is intended
as decision support rather than an automatic decision: the passenger can
still select any available option.

The passenger may also continue with their original journey if it remains
available.


### Page 4 — Evaluation

After making a decision, the passenger evaluates the prototype.

The current evaluation considers:

- Information Clarity
- Journey Impact Understanding
- Alternatives Clarity
- Actionability
- Decision Confidence
- Reduced Uncertainty

Optional written feedback can also be provided.


## 3. Technology

The prototype uses:

- Swift
- SwiftUI
- Xcode
- SQLite
- Native iOS navigation and interface components

Transport services and simulated disruption conditions are stored in a local
SQLite database included with the application.


## 4. Project Structure

```text
transport-disruption-app
│
├── Components
│   ├── EvaluationSlider.swift
│   ├── InformationCard.swift
│   └── ServiceOption.swift
│
├── Models
│   ├── Journey.swift
│   ├── JourneyOption.swift
│   ├── JourneySegment.swift
│   └── TransportService.swift
│
├── Resources
│   └── transport_simulation.db
│
├── Services
│   ├── DatabaseManager.swift
│   └── DecisionLogic.swift
│
├── Views
│   ├── CurrentJourneyView.swift
│   ├── DisruptionInformationView.swift
│   ├── DecisionSupportView.swift
│   └── EvaluationView.swift
│
├── ContentView.swift
└── transport_disruption_appApp.swift