import Foundation

open class HalfHeightCorneredView: View {
    open override func setup() {
        layer.masksToBounds = true
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0 && bounds.height > 0 else {
            return
        }
        layer.cornerRadius = bounds.height/2
    }
}
