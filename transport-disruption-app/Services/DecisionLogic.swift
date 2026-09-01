//
//  DecisionLogic.swift
//  transport-disruption-app
//

import Foundation

struct DecisionLogic {
    
    // MARK: - Journey Impact
    
    static func journeyImpact(
        for service: TransportService
    ) -> String {
        
        if service.isCancelled {
            
            return """
            This service is cancelled and cannot be used for the planned journey. You should compare the available alternatives.
            """
        }
        
        if let impact = service.journeyImpact,
           !impact.isEmpty {
            
            return impact
        }
        
        if service.delayMinutes >= 15 {
            
            return """
            Your journey may be significantly affected. The expected arrival time is approximately \(service.delayMinutes) minutes later than scheduled.
            """
        }
        
        if service.delayMinutes > 0 {
            
            return """
            Your journey is delayed by approximately \(service.delayMinutes) minutes.
            """
        }
        
        return """
        No major disruption is currently expected to affect this journey.
        """
    }
    
    
    // MARK: - Severity Description
    
    static func severityDescription(
        for service: TransportService
    ) -> String {
        
        switch service.severity {
            
        case "High":
            
            return "This disruption may have a significant impact on your journey."
            
        case "Medium":
            
            return "This disruption may moderately affect your journey."
            
        case "Low":
            
            return "This disruption is expected to have a relatively small impact."
            
        default:
            
            return "No significant disruption is currently reported."
        }
    }
    
    
    // MARK: - Expected Arrival Difference
    
    static func arrivalDelayText(
        for service: TransportService
    ) -> String {
        
        if service.isCancelled {
            return "Service cancelled"
        }
        
        if service.delayMinutes <= 0 {
            return "No additional delay"
        }
        
        return "\(service.delayMinutes) minutes later than scheduled"
    }
    
    
    // MARK: - Wait Time
    
    static func waitTime(
        for service: TransportService,
        referenceTime: Date
    ) -> Int {
        
        let departureTime =
            service.expectedDeparture
            ?? service.scheduledDeparture
        
        guard let departureDate =
                dateFromTime(
                    departureTime,
                    referenceDate: referenceTime
                ) else {
            
            return 0
        }
        
        let difference =
            departureDate.timeIntervalSince(
                referenceTime
            )
        
        let minutes =
            Int(
                difference / 60
            )
        
        return max(
            minutes,
            0
        )
    }
    
    
    static func waitTimeText(
        for service: TransportService,
        referenceTime: Date
    ) -> String {
        
        let minutes =
            waitTime(
                for: service,
                referenceTime: referenceTime
            )
        
        if minutes == 0 {
            return "Now"
        }
        
        if minutes == 1 {
            return "1 min"
        }
        
        return "\(minutes) min"
    }
    
    
    // MARK: - Comparison Summary
    
    static func comparisonSummary(
        for service: TransportService,
        referenceTime: Date
    ) -> String {
        
        let wait =
            waitTimeText(
                for: service,
                referenceTime: referenceTime
            )
        
        let arrival =
            service.expectedArrivalText
        
        let transfer =
            service.transferText
        
        let delay =
            service.delayText
        
        return """
        Depart in \(wait) • Arrive \(arrival) • \(transfer) • \(delay)
        """
    }
    
    
    // MARK: - Current Service Status
    
    static func currentServiceStatus(
        for service: TransportService
    ) -> String {
        
        if service.isCancelled {
            return "Unavailable"
        }
        
        if service.delayMinutes >= 15 {
            return "Significantly Delayed"
        }
        
        if service.delayMinutes > 0 {
            return "Delayed"
        }
        
        return "Running Normally"
    }
    
    
    // MARK: - Option Ranking
    
    static func sortedOptions(
        currentService: TransportService,
        alternatives: [TransportService]
    ) -> [TransportService] {
        
        let allOptions =
            [currentService]
            +
            alternatives
        
        return allOptions
            .filter {
                !$0.isCancelled
            }
            .sorted {
                
                let firstArrival =
                    timeValue(
                        $0.expectedArrival
                        ?? $0.scheduledArrival
                    )
                
                let secondArrival =
                    timeValue(
                        $1.expectedArrival
                        ?? $1.scheduledArrival
                    )
                
                
                // 1. Expected arrival
                
                if firstArrival != secondArrival {
                    
                    return firstArrival
                        <
                        secondArrival
                }
                
                
                // 2. Transfers
                
                if $0.transfers
                    !=
                    $1.transfers {
                    
                    return $0.transfers
                        <
                        $1.transfers
                }
                
                
                // 3. Delay
                
                return $0.delayMinutes
                    <
                    $1.delayMinutes
            }
    }
    
    
    // MARK: - Option Description
    
    static func optionDescription(
        for service: TransportService
    ) -> String {
        
        if service.isCancelled {
            
            return """
            This service is currently unavailable because it has been cancelled.
            """
        }
        
        if service.delayMinutes >= 15 {
            
            return """
            This option is experiencing a significant delay. Compare its expected arrival time with the other available services.
            """
        }
        
        if service.transfers > 0 {
            
            return """
            This option requires \(service.transferText), but it may still provide a useful alternative depending on the expected arrival time.
            """
        }
        
        if service.delayMinutes > 0 {
            
            return """
            This service is delayed, but it remains available for your journey.
            """
        }
        
        return """
        This service is currently operating without a major reported disruption.
        """
    }
    
    
    // MARK: - Time Helpers
    
    private static func dateFromTime(
        _ timeString: String,
        referenceDate: Date
    ) -> Date? {
        
        let components =
            timeString.split(
                separator: ":"
            )
        
        guard components.count == 2,
              let hour = Int(
                components[0]
              ),
              let minute = Int(
                components[1]
              ) else {
            
            return nil
        }
        
        var dateComponents =
            Calendar.current.dateComponents(
                [
                    .year,
                    .month,
                    .day
                ],
                from: referenceDate
            )
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(
            from: dateComponents
        )
    }
    
    
    private static func timeValue(
        _ timeString: String
    ) -> Int {
        
        let components =
            timeString.split(
                separator: ":"
            )
        
        guard components.count == 2,
              let hour = Int(
                components[0]
              ),
              let minute = Int(
                components[1]
              ) else {
            
            return Int.max
        }
        
        return hour * 60 + minute
    }
}
