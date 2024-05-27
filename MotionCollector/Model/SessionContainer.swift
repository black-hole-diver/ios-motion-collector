import Foundation

// MARK: Container for session data
class SessionContainer: Codable {
    var nextSessionid: Int?
    var currentSessionDate: Date?
    var currentFrequency: Int?
    var recordID: Int?
    var duration: String?
    var sensorOutputs = [SensorOutput]()
    
    init() {}
}
