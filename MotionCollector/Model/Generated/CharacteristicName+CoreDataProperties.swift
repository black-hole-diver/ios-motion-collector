//
//  CharacteristicName+CoreDataProperties.swift
//  iOS Motion Collector
//
//  ELTE BSc Thesis "Machine Learning Based Real-time Movement Detection of Children (2024)"
//  @author Wittawin Panta
//  @version 1.50 13 May 2024

import Foundation
import CoreData


extension CharacteristicName {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CharacteristicName> {
        return NSFetchRequest<CharacteristicName>(entityName: "CharacteristicName")
    }

    @NSManaged public var name: String?
    @NSManaged public var toCharacteristic: NSSet?

}

// MARK: Generated accessors for toCharacteristic
extension CharacteristicName {

    @objc(addToCharacteristicObject:)
    @NSManaged public func addToToCharacteristic(_ value: Characteristic)

    @objc(removeToCharacteristicObject:)
    @NSManaged public func removeFromToCharacteristic(_ value: Characteristic)

    @objc(addToCharacteristic:)
    @NSManaged public func addToToCharacteristic(_ values: NSSet)

    @objc(removeToCharacteristic:)
    @NSManaged public func removeFromToCharacteristic(_ values: NSSet)

}
