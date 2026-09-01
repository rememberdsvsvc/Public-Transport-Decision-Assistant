//
//  ServiceOption.swift
//  transport-disruption-app
//

import SwiftUI

struct ServiceOption: View {
    
    // MARK: - Service Data
    
    let service: TransportService
    
    
    // MARK: - User Action
    
    let buttonTitle: String
    let action: () -> Void
    
    
    // MARK: - Body
    
    var body: some View {
        
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            // MARK: Route Header
            
            HStack {
                
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    
                    Text(service.routeName)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(
                        "\(service.origin) → \(service.destination)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "bus.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            
            
            Divider()
            
            
            // MARK: Time Information
            
            HStack(spacing: 20) {
                
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    
                    Text("Departure")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(service.scheduledDeparture)
                        .font(.headline)
                }
                
                
                Spacer()
                
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                
                
                Spacer()
                
                
                VStack(
                    alignment: .trailing,
                    spacing: 4
                ) {
                    
                    Text("Arrival")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(service.scheduledArrival)
                        .font(.headline)
                }
            }
            
            
            // MARK: Journey Details
            
            HStack(spacing: 18) {
                
                Label(
                    "\(service.journeyMinutes) min",
                    systemImage: "clock"
                )
                
                Label(
                    service.transferText,
                    systemImage: "arrow.triangle.branch"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            
            // MARK: Disruption Status
            
            if service.hasDisruption {
                
                HStack {
                    
                    Image(
                        systemName: disruptionIcon
                    )
                    
                    Text(service.disruptionType)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(service.delayText)
                }
                .font(.subheadline)
                .foregroundStyle(disruptionColor)
            }
            
            
            // MARK: Select Button
            
            Button {
                
                action()
                
            } label: {
                
                HStack {
                    
                    Spacer()
                    
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                    
                    Image(
                        systemName: "arrow.right.circle.fill"
                    )
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
    
    
    // MARK: - Disruption Icon
    
    private var disruptionIcon: String {
        
        switch service.disruptionType {
            
        case "Cancelled":
            return "xmark.octagon.fill"
            
        case "Major Delay":
            return "exclamationmark.triangle.fill"
            
        case "Minor Delay":
            return "clock.badge.exclamationmark"
            
        default:
            return "info.circle.fill"
        }
    }
    
    
    // MARK: - Disruption Colour
    
    private var disruptionColor: Color {
        
        switch service.severity {
            
        case "High":
            return .red
            
        case "Medium":
            return .orange
            
        case "Low":
            return .yellow
            
        default:
            return .secondary
        }
    }
}
