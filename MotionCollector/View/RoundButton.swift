//
//  RoundButton.swift
//  iOS Motion Collector
//
//  ELTE BSc Thesis "Machine Learning Based Real-time Movement Detection of Children (2024)"
//  @author Wittawin Panta
//  @version 1.50 13 May 2024

//

import UIKit


@IBDesignable
class CircleButton: UIButton {
    
    @IBInspectable var isRound: Bool = false {
        
        didSet {
            if isRound {
                setupView()
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        if isRound {
            setupView()
        }
    }
    
    func setupView() {
        self.layer.cornerRadius = self.bounds.size.width / 2.0
        self.clipsToBounds = true
    }
    
}

