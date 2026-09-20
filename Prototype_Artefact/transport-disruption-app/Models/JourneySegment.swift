//
//  JourneySegment.swift
//  transport-disruption-app
//

import Foundation

struct JourneySegment: Identifiable, Hashable {
    
    let id: Int
    
    // MARK: - Segment Order
    
    let sequence: Int
    
    
    // MARK: - Transport Type
    
    let transportMode: String
    
    
    // MARK: - Route Information
    
    let routeID: String?
    let routeName: String
    
    
    // MARK: - Segment Journey
    
    let origin: String
    let destination: String
    
    let scheduledDeparture: String?
    let scheduledArrival: String?
    
    let expectedDeparture: String?
    let expectedArrival: String?
    
    let durationMinutes: Int
    
    
    // MARK: - Disruption Information
    
    let disruptionType: String
    let delayMinutes: Int
    
    
    // MARK: - Display Helpers
    
    var transportDisplayName: String {
        
        switch transportMode.lowercased() {
            
        case "train":
            return "Train"
            
        case "ferry":
            return "Ferry"
            
        case "walk", "walking":
            return "Walking"
            
        default:
            return "Bus"
        }
    }
    
    
    var transportIcon: String {
        
        switch transportMode.lowercased() {
            
        case "train":
            return "tram.fill"
            
        case "ferry":
            return "ferry.fill"
            
        case "walk", "walking":
            return "figure.walk"
            
        default:
            return "bus.fill"
        }
    }
    
    
    var departureText: String {
        
        expectedDeparture
        ?? scheduledDeparture
        ?? "—"
    }
    
    
    var arrivalText: String {
        
        expectedArrival
        ?? scheduledArrival
        ?? "—"
    }
    
    
    var delayText: String {
        
        if disruptionType == "Cancelled" {
            return "Cancelled"
        }
        
        if delayMinutes <= 0 {
            return "On time"
        }
        
        return "\(delayMinutes) min delay"
    }
    
    
    var isWalking: Bool {
        
        let mode = transportMode.lowercased()
        
        return mode == "walk"
            || mode == "walking"
    }
    
    
    var isCancelled: Bool {
        
        disruptionType == "Cancelled"
    }
    
    
    var routeDisplayText: String {
        
        if isWalking {
            return "Walk"
        }
        
        return routeName
    }
}
