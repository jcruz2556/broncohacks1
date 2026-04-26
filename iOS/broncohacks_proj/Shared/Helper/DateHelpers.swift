//
//  DateHelpers.swift
//  broncohacks_proj
//
//  Created by Kenneth Sieu on 4/25/26.
//

import Foundation

func hourLabel(from hour: Int) -> String {
    switch hour {
    case 0:  return "12 AM"
    case 6:  return "6 AM"
    case 12: return "12 PM"
    case 18: return "6 PM"
    case 23: return "11 PM"
    default: return ""
    }
}

func hourLabel(from date: Date) -> String {
    let hour = Calendar.current.component(.hour, from: date)
    return hourLabel(from: hour)
}

func timeString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: date)
}

func greetingText() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 5..<12: return "Good Morning"
    case 12..<17: return "Good Afternoon"
    default:      return "Good Evening"
    }
}

func formattedDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: Date())
}
