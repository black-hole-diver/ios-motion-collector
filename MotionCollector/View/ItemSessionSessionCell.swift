//
//  ItemCell.swift
//  iOS Motion Collector
//
//  ELTE BSc Thesis "Machine Learning Based Real-time Movement Detection of Children (2024)"
//  @author Wittawin Panta
//  @version 1.50 13 May 2024

//

import UIKit

class ItemSessionCell: UITableViewCell {
    
    @IBOutlet weak var idSessionLabel: UILabel!
    @IBOutlet weak var dateSessionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var isWalkingLabel: UILabel!
    @IBOutlet weak var iPhoneIcon: UIImageView!
    @IBOutlet weak var appleWatchIcon: UIImageView!
    
    
    func configureCell (session: Session){
        
        // Format dateTime
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy  HH:mm:ss"
        let myString = formatter.string(from: session.date! as Date)
        
        
        idSessionLabel.text = "\(session.id)"
        dateSessionLabel.text = myString
        durationLabel.text = session.duration
        periodLabel.text = "\(session.frequency)"
        isWalkingLabel.text = "\(session.recordID)"
        
        if session.type == SessionType.OnlyPhone.rawValue {
            iPhoneIcon.isHidden = false
        } else if session.type == SessionType.OnlyWatch.rawValue {
            appleWatchIcon.isHidden = false
        } else if session.type == SessionType.PhoneAndWatch.rawValue {
            iPhoneIcon.isHidden = false
            appleWatchIcon.isHidden = false
        }
    }
    
}
