import UIKit

// MARK: A custom UITableViewCell to display label id
class SessionIDCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    
    func configureCell (id: Int){
        idLabel.text = "\(id)"
    }
    
}
