//
//  TransportService.swift
//  transport-disruption-app
//

import Foundation

struct TransportService: Identifiable, Hashable {
    
    let id: Int
    
    // MARK: - Transport Type
    
    let transportMode: String
    
    // MARK: - Route Information
    
    let routeID: String
    let routeName: String
    
    // MARK: - Journey Information
    
    let origin: String
    let destination: String
    
    let scheduledDeparture: String
    let scheduledArrival: String
    
    let journeyMinutes: Int
    let transfers: Int
    
    // MARK: - Disruption Information
    
    let disruptionType: String
    let severity: String
    
    let delayMinutes: Int
    let cause: String?
    
    // MARK: - Expected Information
    
    let expectedDeparture: String?
    let expectedArrival: String?
    let expectedRecovery: String?
    
    // MARK: - Journey Impact
    
    let journeyImpact: String?
    let recommendedAction: String?
    
    let trafficPeriod: String
    
    
    // MARK: - Display Helpers
    
    var transferText: String {
        
        if transfers == 0 {
            return "Direct"
        }
        
        if transfers == 1 {
            return "1 transfer"
        }
        
        return "\(transfers) transfers"
    }
    
    
    var delayText: String {
        
        if isCancelled {
            return "Cancelled"
        }
        
        if delayMinutes <= 0 {
            return "On time"
        }
        
        return "\(delayMinutes) min delay"
    }
    
    
    var expectedDepartureText: String {
        expectedDeparture ?? scheduledDeparture
    }
    
    
    var expectedArrivalText: String {
        expectedArrival ?? scheduledArrival
    }
    
    
    var isCancelled: Bool {
        disruptionType == "Cancelled"
    }
    
    
    var hasDisruption: Bool {
        disruptionType != "Normal Service"
    }
    
    
    // MARK: - Transport Icon
    
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
    
    
    // MARK: - Transport Display Name
    
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
}
