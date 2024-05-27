import Foundation

// MARK: Sensor output containing gyroscope x,y,z and accelerometer x,y,z
class SensorOutput: Codable {
    
    var timeStamp: Date?
    
    var gyroX: Double?
    var gyroY: Double?
    var gyroZ: Double?
    
    var accX: Double?
    var accY: Double?
    var accZ: Double?
    
    init() {}
}
