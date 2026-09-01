//
//  ContentView.swift
//  transport-disruption-app
//

import SwiftUI

struct ContentView: View {
    
    @State private var journey = Journey.empty
    @State private var startJourney = false
    
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                VStack(
                    spacing: 28
                ) {
                    
                    Spacer()
                        .frame(height: 30)
                    
                    
                    // MARK: - App Icon
                    
                    ZStack {
                        
                        Circle()
                            .fill(
                                Color.blue.opacity(0.10)
                            )
                            .frame(
                                width: 120,
                                height: 120
                            )
                        
                        Image(
                            systemName: "bus.fill"
                        )
                        .font(
                            .system(size: 58)
                        )
                        .foregroundStyle(.blue)
                    }
                    
                    
                    // MARK: - Title
                    
                    VStack(
                        spacing: 8
                    ) {
                        
                        Text(
                            "Public Transport Disruption"
                        )
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        
                        Text(
                            "Decision Support"
                        )
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    
                    
                    // MARK: - Description
                    
                    Text(
                        "Understand service disruptions, see how they affect your journey, and compare available travel options before making your decision."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    
                    
                    // MARK: - Start Journey
                    
                    Button {
                        
                        journey = Journey.empty
                        startJourney = true
                        
                    } label: {
                        
                        HStack {
                            
                            Image(
                                systemName: "location.fill"
                            )
                            
                            Text("Start Journey")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(
                                systemName: "arrow.right"
                            )
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    
                    
                    // MARK: - How It Works
                    
                    VStack(
                        alignment: .leading,
                        spacing: 20
                    ) {
                        
                        Text("How It Works")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        
                        HomeStepRow(
                            number: "1",
                            icon: "location.fill",
                            title: "Select Your Journey",
                            description:
                                "Enter your origin, destination and approximate travel time, then identify your current service."
                        )
                        
                        
                        HomeStepRow(
                            number: "2",
                            icon: "exclamationmark.triangle.fill",
                            title: "Understand the Disruption",
                            description:
                                "See what has happened and understand how the disruption affects your journey."
                        )
                        
                        
                        HomeStepRow(
                            number: "3",
                            icon: "arrow.triangle.branch",
                            title: "Compare Your Options",
                            description:
                                "Compare the current service with available alternatives using clear journey information."
                        )
                        
                        
                        HomeStepRow(
                            number: "4",
                            icon: "checkmark.circle.fill",
                            title: "Make Your Decision",
                            description:
                                "Choose the travel option that works for you and evaluate the decision-support experience."
                        )
                    }
                    .padding()
                    .background(
                        Color(
                            .secondarySystemBackground
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )
                    .padding(.horizontal)
                    
                    
                    // MARK: - Research Purpose
                    
                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {
                        
                        Label(
                            "Prototype Purpose",
                            systemImage: "info.circle.fill"
                        )
                        .font(.headline)
                        .foregroundStyle(.blue)
                        
                        Text(
                            "This prototype explores how public transport disruption information can be presented more clearly and actionably to support passenger decision-making."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        Color.blue.opacity(0.06)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                    .padding(.horizontal)
                    
                    
                    Spacer()
                        .frame(height: 30)
                }
            }
            
            // MARK: - Navigation
            
            .navigationDestination(
                isPresented: $startJourney
            ) {
                
                CurrentJourneyView(
                    journey: $journey
                )
            }
        }
    }
}


// MARK: - Home Step Row

struct HomeStepRow: View {
    
    let number: String
    let icon: String
    let title: String
    let description: String
    
    
    var body: some View {
        
        HStack(
            alignment: .top,
            spacing: 14
        ) {
            
            // Step Number
            
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(
                    width: 36,
                    height: 36
                )
                .background(
                    Color.blue
                )
                .clipShape(
                    Circle()
                )
            
            
            // Step Content
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                
                HStack(
                    spacing: 7
                ) {
                    
                    Image(
                        systemName: icon
                    )
                    .foregroundStyle(.blue)
                    
                    Text(title)
                        .font(.headline)
                }
                
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            
            
            Spacer()
        }
    }
}


// MARK: - Preview

#Preview {
    
    ContentView()
}
