//
//  SessionContainer.swift
//  iOS Motion Collector
//
//  ELTE BSc Thesis "Machine Learning Based Real-time Movement Detection of Children (2024)"
//  @author Wittawin Panta
//  @version 1.50 13 May 2024


import Foundation

class SessionContainer: Codable {
    
    var nextSessionid: Int?
    var currentSessionDate: Date?
    var currentFrequency: Int?
    var recordID: Int?
    var duration: String?
    var sensorOutputs = [SensorOutput]()
    
    init() {}
}
