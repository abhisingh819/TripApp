//
//  TripPresenter.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import Foundation
import MapKit

class TripViewPresenter {
    private weak var tripView: TripView?
    
    init(view: TripView){
        self.tripView = view
    }
    
    func updateModalToView(){
        guard let tripV = self.tripView else {
            return
        }
        
        tripV.update(trip: self.parseTrip())
        
    }
    
    func getTripDuration(path:[Trip.Path])->[Double]{
        var totalTime = 0.0
        var timeOfEachSegment = [Double]()
        if path.count > 1 {
            totalTime = path[path.count-1].time_millis - path[0].time_millis
            totalTime = totalTime/1000
        }
        let timeFactorForEachFrame = 15/totalTime
        for i in 1..<path.count {
                let timeIntervalinSec = (path[i].time_millis-path[i-1].time_millis)/1000
                timeOfEachSegment.append(timeIntervalinSec * timeFactorForEachFrame)
        }
        return timeOfEachSegment
    }
    
    
    func createCoordinates(paths: [Trip.Path]) -> [CLLocationCoordinate2D] {
        var location = [CLLocationCoordinate2D]()
        
        for path in paths {
            let coordinate = CLLocationCoordinate2D(latitude: path.latitude, longitude: path.longitude)
            location.append(coordinate)
        }
        
        return location
    }
    
}

private extension TripViewPresenter {
    
    func parseTrip()->[Trip] {
        var tripArray = [Trip]()
        if let path = Bundle.main.path(forResource: "Data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let trips = try! JSONDecoder().decode([Trip].self, from: data)
                var count = 0;
                for var trip in trips {
                    updatetripDateFormat(trip: &trip)
                    tripArray.append(trip)
                    count += 1
                }
                
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
        return tripArray;
    }
    
    func updatetripDateFormat(trip:inout Trip){
        
        trip.start_time.convertInputDateFormatToOutput(inputFormat: Constant.DateFormat_WithMs, alternateFormat: Constant.DateFormat_WithoutMs, outputFormat: Constant.NormalDateFormat)
        trip.end_time.convertInputDateFormatToOutput(inputFormat: Constant.DateFormat_WithMs, alternateFormat: Constant.DateFormat_WithoutMs, outputFormat: Constant.NormalDateFormat)
        
    }
    
}
