import Foundation
import UIKit

open class ContentViewController: ViewController {
    
    public var contentView = UIView()
    
    open override func setup() {
        super.setup()
        
        contentView.backgroundColor = UIColor.clear
        view.addSubview(contentView)
        
        contentView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
    }
}
