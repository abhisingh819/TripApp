//
//  String.swift
//  TripApp
//
//  Created by Abhinav Singh on 5/6/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import Foundation

extension String {
    
    mutating func convertInputDateFormatToOutput(inputFormat:String,alternateFormat:String ,outputFormat:String){
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        var showDate = inputFormatter.date(from: self)
        if(showDate == nil){
            inputFormatter.dateFormat = alternateFormat
            showDate = inputFormatter.date(from: self)
        }
        inputFormatter.dateFormat = outputFormat
        if let convertedDate = showDate {
            self = inputFormatter.string(from: convertedDate)
        }
    }
    
    func getDateFromString(inputFormat:String, alternateFormat:String) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        var showDate = inputFormatter.date(from: self)
        if(showDate == nil){
            inputFormatter.dateFormat = alternateFormat
            showDate = inputFormatter.date(from: self)
        }
        
        return showDate
    }
    
}
