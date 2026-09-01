//
//  InformationCard.swift
//  transport-disruption-app
//

import SwiftUI

struct InformationCard: View {
    
    // MARK: - Card Data
    
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        
        HStack(
            alignment: .top,
            spacing: 14
        ) {
            
            // MARK: Icon
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(
                    width: 32,
                    height: 32
                )
            
            
            // MARK: Text Content
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            
            
            Spacer()
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
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
