//
//  StopCoordinates.swift
//  transport-disruption-app
//
//  Created by 杨炎坤 on 2026/9/5.
//

import Foundation
import CoreLocation

struct StopCoordinates {

    static let coordinates: [String: CLLocationCoordinate2D] = [

        "UQ Lakes": CLLocationCoordinate2D(
            latitude: -27.4975,
            longitude: 153.0170
        ),

        "Toowong": CLLocationCoordinate2D(
            latitude: -27.4854,
            longitude: 152.9924
        ),

        "Brisbane City": CLLocationCoordinate2D(
            latitude: -27.4698,
            longitude: 153.0251
        ),

        "Indooroopilly": CLLocationCoordinate2D(
            latitude: -27.4992,
            longitude: 152.9734
        ),

        "South Bank": CLLocationCoordinate2D(
            latitude: -27.4810,
            longitude: 153.0234
        )
    ]

    static func coordinate(for stopName: String) -> CLLocationCoordinate2D? {
        return coordinates[stopName]
    }
}
