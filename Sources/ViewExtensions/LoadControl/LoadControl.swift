import Foundation
import UIKit

public protocol LoadView: View {
    func start()
    func stop()
    var color: UIColor? { get set }
}

open class LoadControl: View {

    public enum AnimationType {
        case system
        case square
        case line
    }

    private let animationType: AnimationType

    public var color: UIColor = .white {
        didSet {
            loadView?.color = color
        }
    }

    public init(animationType: AnimationType = .system) {
        self.animationType = animationType
        super.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var loadView: LoadView? = { [unowned self] in
        let view: LoadView
        switch animationType {
        case .system:
            view = SystemAnimatedView()
        case .square:
            view = BlocksAnimatedView()
        case .line:
            view = LineAnimatedView()
        }
        addSubview(view)
        view.color = color
        view.autoPinEdgesToSuperviewEdges()
        return view
    }()

    public override func setup() {
        super.setup()
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    public func start() {
        loadView?.start()

    }
    
    public func stop() {
        loadView?.stop()
    }
}
