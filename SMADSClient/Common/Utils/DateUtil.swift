//
//  DateUtil.swift
//  Smds_app
//
//  Created by Asha Jain on 7/2/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

class DateUtil{
    
    func parseDateStringForCalendar(dateString: String) -> String {
        let dateParts = dateString.split(separator: "T")
        let calendarParts = dateParts[0].split(separator: "-")
        
        let year = calendarParts[0]
        
        var day_of_month = 0
        var th = ""
        if let day = Int(calendarParts[2])
        {
            day_of_month = day
            
            switch day_of_month{
            case 1: th = "st"
            case 2: th = "nd"
            case 3: th = "rd"
            default:
                th = "st"
            }
        }
        
        
        var monthName = ""
        if let monthNum = Int(calendarParts[1]){
            monthName = DateFormatter().monthSymbols[monthNum - 1]
        }
        
        
        let constructString = "\(monthName) \(day_of_month)\(th), \(year)"
        
        return constructString
    }
    
    //"2020-07-02T23:00:52.627113Z"
    func parseDateStringForTime(dateString: String) -> String{
        let dateParts = dateString.split(separator: "T")
        let timeParts = dateParts[1].split(separator: ":")
        
        if var hour  = Int(timeParts[0]), let min = Int(timeParts[1])
        {
            var am_pm = "AM"
            if hour > 12{
                hour = hour - 12
                am_pm = "PM"
                
            }
            return "\(hour):\(min.format("02")) \(am_pm)"
        }
        return "---"
    }
}


extension Int {
    func format(_ f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
