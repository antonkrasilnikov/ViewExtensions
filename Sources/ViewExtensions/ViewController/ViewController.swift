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
        
    }
}
