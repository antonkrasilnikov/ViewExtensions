import Foundation
import AVFoundation

public class VideoView: View {
    private var _url: URL?
    
    private var _onFinish: (() -> Void)?
    
    private var _moviePlayer: AVPlayer?
    private var _avPlayerLayer: AVPlayerLayer?
    private var _playerItem: AVPlayerItem?
    
    public var isSoundOn: Bool = true {
        didSet {
            _moviePlayer?.volume = self.isSoundOn ? 1 : 0
        }
    }
    
    public func play(url: URL, onFinish: @escaping () -> Void) {
        _url = url
        _onFinish = onFinish
        
        _play()
    }
    
    private func _play() {
        
        guard let url = _url else { return }
        
        if let avPlayerLayer = _avPlayerLayer {
            avPlayerLayer.removeFromSuperlayer()
            _avPlayerLayer = nil
        }
        
        _playerItem = AVPlayerItem.init(url: url)
        NotificationCenter.default.addObserver(self, selector: #selector(_videoFinised(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        _moviePlayer = AVPlayer.init(playerItem: _playerItem!)
        
        _avPlayerLayer = AVPlayerLayer.init(player: _moviePlayer!)
        _avPlayerLayer?.frame = layer.bounds
        _avPlayerLayer?.videoGravity = .resizeAspectFill
        layer.addSublayer(_avPlayerLayer!)
        _moviePlayer?.volume = isSoundOn ? 1 : 0
        _moviePlayer?.play()
        
        
        
    }
    
    @objc
    private func _videoFinised(notification: NSNotification) {
        
        let playerItem = notification.object as? AVPlayerItem
        
        if playerItem === _playerItem {
            _avPlayerLayer?.removeAllAnimations()
            NotificationCenter.default.removeObserver(self)
            
            if let onFinish = _onFinish {
                _onFinish = nil
                onFinish()
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _avPlayerLayer?.frame = layer.bounds
    }
    
    public override func setup() {
        backgroundColor = .black
    }
}
