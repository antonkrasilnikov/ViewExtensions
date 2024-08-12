import Foundation
import UIKit
import PureLayout

open class AlertPopover: View {

    public var text: String? {
        didSet {
            label.text = text
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 15) {
        didSet {
            label.font = font
        }
    }
    
    public var textColor: UIColor = .white {
        didSet {
            label.textColor = textColor
        }
    }

    fileprivate let label = UILabel()

    open override func setup() {

        backgroundColor = .black
        layer.masksToBounds = true
        layer.cornerRadius = 5

        addSubview(label)
        label.numberOfLines = 0
        label.textColor = textColor
        label.font = font
    }

    open override func setupSizes() {
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }

    open class func showMessage(message: String, above view: UIView) {

        if let view = view.window {
            let pasteView = AlertPopover()
            pasteView.label.text = message
            view.addSubview(pasteView)
            pasteView.autoAlignAxis(toSuperviewAxis: .vertical)
            pasteView.autoPinEdge(.top, to: .bottom, of: view)
            pasteView.alpha = 0

            pasteView.transform = CGAffineTransform(translationX: 0, y: -100)

            UIView.animateKeyframes(withDuration: 2, delay: 0, options: .calculationModeLinear, animations: {

                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.1) {
                        pasteView.alpha = 1
                }

                UIView.addKeyframe(
                    withRelativeStartTime: 0.9,
                    relativeDuration: 0.1) {
                        pasteView.transform = .identity
                        pasteView.alpha = 0
                }

            }) { _ in
                pasteView.removeFromSuperview()
            }
        }

    }
}
