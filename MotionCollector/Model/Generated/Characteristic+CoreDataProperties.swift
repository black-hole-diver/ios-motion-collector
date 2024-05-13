//
//  Characteristic+CoreDataProperties.swift
//  iOS Motion Collector
//
//  ELTE BSc Thesis "Machine Learning Based Real-time Movement Detection of Children (2024)"
//  @author Wittawin Panta
//  @version 1.50 13 May 2024

import Foundation
import CoreData


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
