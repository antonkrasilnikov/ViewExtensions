import UIKit

@objc
open class ViewController: UIViewController,UserInterface {
    
    open var isCanBeClosedByGesture: Bool = true
    open var isAppeared: Bool { !appearanceQueue.isSuspended }

    let appearanceQueue: OperationQueue = {
        $0.qualityOfService = .userInteractive
        $0.isSuspended = true
        return $0
    }(OperationQueue())
    private var resetableConstraints: [NSLayoutConstraint] = []

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        #if DEBUG
        print("deinit",NSStringFromClass(type(of: self)))
        #endif
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupSizes()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearanceQueue.isSuspended = false
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appearanceQueue.isSuspended = true
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in }) { [weak self] _ in
            self?.setResetableConstraints()
            self?.viewDidTransition()
        }
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func addOperationOnAppearance(_ block: @escaping () -> Void) {
        appearanceQueue.addOperation {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    open func setup() {
        
    }
    
    open func setupSizes() {
        setResetableConstraints()
    }

    @ConstraintsBuilder
    open func buildTransitionalConstraints() -> [NSLayoutConstraint] {}

    open
    func viewDidTransition() {}

    private
    func setResetableConstraints() {
        resetableConstraints.forEach({ $0.isActive = false })
        resetableConstraints.removeAll()
        resetableConstraints.append(contentsOf: buildTransitionalConstraints())
    }
}
