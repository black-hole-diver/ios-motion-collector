import Foundation
import CoreData

// MARK: Sensor Extension
extension Sensor {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sensor> {
        return NSFetchRequest<Sensor>(entityName: "Sensor")
    }

    @NSManaged public var id: Int32
    @NSManaged public var toSensorData: NSSet?

}

// MARK: Methods to add and remove
extension Sensor {
    // MARK: Adds a single SensorData object to the set of sensor data associated with a specific Sensor.
    @objc(addToSensorDataObject:)
    @NSManaged public func addToToSensorData(_ value: SensorData)
    
    // MARK: Removes a single SensorData object from the set of sensor data associated with a specific Sensor.
    @objc(removeToSensorDataObject:)
    @NSManaged public func removeFromToSensorData(_ value: SensorData)

    // MARK: Adds multiple SensorData objects to the sensor's data set at once.
    @objc(addToSensorData:)
    @NSManaged public func addToToSensorData(_ values: NSSet)

    // MARK: Removes multiple SensorData objects from the sensor's data set at once.
    @objc(removeToSensorData:)
    @NSManaged public func removeFromToSensorData(_ values: NSSet)

}
