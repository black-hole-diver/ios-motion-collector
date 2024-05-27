import Foundation
import CoreData

// MARK: SensorData Extension
extension SensorData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SensorData> {
        return NSFetchRequest<SensorData>(entityName: "SensorData")
    }

    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var toCharacteristic: NSSet?
    @NSManaged public var toSensor: Sensor?
    @NSManaged public var toSession: Session?

}

// MARK: Methods to create accessors for toCharacteristic
extension SensorData {

    @objc(addToCharacteristicObject:)
    @NSManaged public func addToToCharacteristic(_ value: Characteristic)

    @objc(removeToCharacteristicObject:)
    @NSManaged public func removeFromToCharacteristic(_ value: Characteristic)

    @objc(addToCharacteristic:)
    @NSManaged public func addToToCharacteristic(_ values: NSSet)

    @objc(removeToCharacteristic:)
    @NSManaged public func removeFromToCharacteristic(_ values: NSSet)

}
