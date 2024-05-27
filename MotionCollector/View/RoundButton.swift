import UIKit

// MARK: Set up Button UI
@IBDesignable
class CircleButton: UIButton {
    @IBInspectable var isRound: Bool = true {
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
        self.backgroundColor = .red
    }
}

