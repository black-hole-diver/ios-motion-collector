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
    @objc(addToSensorDataObject:)
    @NSManaged public func addToToSensorData(_ value: SensorData)
    
    @objc(removeToSensorDataObject:)
    @NSManaged public func removeFromToSensorData(_ value: SensorData)

    @objc(addToSensorData:)
    @NSManaged public func addToToSensorData(_ values: NSSet)

    @objc(removeToSensorData:)
    @NSManaged public func removeFromToSensorData(_ values: NSSet)

}
