import Foundation
import UIKit

extension LoadControl {

    final class SystemAnimatedView: View, LoadView {

        private let activityIndicator = UIActivityIndicatorView()

        var color: UIColor? {
            didSet {
                activityIndicator.color = color
            }
        }

        override func setup() {
            super.setup()
            addSubview(activityIndicator)
            activityIndicator.hidesWhenStopped = true
        }

        override func setupSizes() {
            super.setupSizes()
            activityIndicator.autoCenterInSuperview()
        }

        func start() {
            isHidden = false
            activityIndicator.startAnimating()
        }

        func stop() {
            isHidden = true
            activityIndicator.stopAnimating()
        }
    }
}
