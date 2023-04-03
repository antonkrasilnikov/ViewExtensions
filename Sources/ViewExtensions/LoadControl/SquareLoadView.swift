import Foundation
import UIKit

open class SquareLoadView: View {

    let loadControl = LoadControl(animationType: .square)

    public override func setup() {

        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        layer.cornerRadius = 10

        addSubview(loadControl)
        loadControl.start()
    }

    public override func setupSizes() {
        loadControl.autoCenterInSuperview()

        if Interface.sizeType == .pad {
            autoSetDimensions(to: .init(width: 64, height: 64))
        }else{
            autoSetDimensions(to: .init(width: 48, height: 48))
        }
    }
}
