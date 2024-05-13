//
//  Sensor+CoreDataProperties.swift
//  iOS Motion Collector
//
//  ELTE BSc Thesis "Machine Learning Based Real-time Movement Detection of Children (2024)"
//  @author Wittawin Panta
//  @version 1.50 13 May 2024


import Foundation
import CoreData


extension Sensor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sensor> {
        return NSFetchRequest<Sensor>(entityName: "Sensor")
    }

    @NSManaged public var id: Int32
    @NSManaged public var toSensorData: NSSet?

}

// MARK: Generated accessors for toSensorData
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
