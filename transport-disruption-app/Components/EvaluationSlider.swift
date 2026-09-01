//
//  EvaluationSlider.swift
//  transport-disruption-app
//

import SwiftUI

struct EvaluationSlider: View {
    
    // MARK: - Question Data
    
    let title: String
    let description: String
    
    
    // MARK: - User Rating
    
    @Binding var value: Double
    
    
    // MARK: - Body
    
    var body: some View {
        
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            
            // MARK: Question Title
            
            HStack {
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(value))/5")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            
            // MARK: Question Description
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            
            
            // MARK: Slider
            
            Slider(
                value: $value,
                in: 1...5,
                step: 1
            )
            
            
            // MARK: Scale Labels
            
            HStack {
                
                Text("Strongly disagree")
                
                Spacer()
                
                Text("Strongly agree")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }
}
