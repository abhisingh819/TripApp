//
//  Trip.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import Foundation

struct Trip : Codable {
    var start_time: String
    var trip_id: String
    var end_time: String
    
    struct Path : Codable {
        var latitude: Double
        var longitude: Double
        var timestamp: String
        var time_millis: Double
    }
    
    var simple_path: [Path]
}
