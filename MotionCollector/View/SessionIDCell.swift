import UIKit

class SessionIDCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    
    func configureCell (id: Int){
        idLabel.text = "\(id)"
    }
    
}
