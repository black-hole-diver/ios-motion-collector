import Foundation
import CoreData

// MARK: Characteristic Extension
extension Characteristic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Characteristic> {
        return NSFetchRequest<Characteristic>(entityName: "Characteristic")
    }

    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var z: Double
    @NSManaged public var toCharacteristicName: CharacteristicName?
    @NSManaged public var toSensorData: SensorData?

}
