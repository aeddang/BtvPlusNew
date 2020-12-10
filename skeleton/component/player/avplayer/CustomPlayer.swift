import Foundation
import SwiftUI
import Combine
import AVKit


struct CustomPlayer: UIViewRepresentable , PlayBack,  PlayerUIViewDelegate{
    
    @ObservedObject var viewModel:PlayerModel
    private let TAG = "CustomPlayer"
    
    func makeUIView(context: UIViewRepresentableContext<CustomPlayer>) -> PlayerUIView{
        let player = PlayerUIView(frame: .zero)
        player.delegate = self
        return player
    }

    func onPlayerCompleted(){
        self.onCompleted()
    }
    
    func onPlayerError(_ error:PlayerStreamError){
        self.onError(error)
    }
    
    func updateUIView(_ player: PlayerUIView, context: UIViewRepresentableContext<CustomPlayer>) {
        if viewModel.status != .update { return }
        guard let evt = viewModel.event else { return }
        if let e = player.player?.error {
            PageLog.log("updateUIView error " + e.localizedDescription , tag: TAG)
        }
        
        switch viewModel.updateType {
        case .recovery(let t):
             recovery(player, evt: evt, recoveryTime: t)
        case .initate :
             recovery(player, evt: evt, recoveryTime: 0)
        default:
             update(player, evt: evt)
        }
        
    }
    private func recovery(_ player: PlayerUIView, evt:PlayerUIEvent, recoveryTime:Double){
        viewModel.updateType = .update
        var initTime = recoveryTime
        var isPlay = true
        switch evt {
        case .togglePlay: break
        case .resume: break
        case .seekTime(let t, let play):
            initTime = t
            isPlay = play
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            isPlay = play
            initTime = t
        default :
            self.update(player, evt: evt)
            return
        }
        viewModel.event = .load(viewModel.path, isPlay , initTime)
    }
    
    private func update(_ player: PlayerUIView, evt:PlayerUIEvent){
        func onResume(){
            if !player.resume() {
                viewModel.error = .illegalState(evt)
                return
            }
            run(player)
        }
        func onPause(){
            if !player.pause() { viewModel.error = .illegalState(evt) }
        }
        
        func onSeek(time:Double, play:Bool){
            if !player.seek(time) { viewModel.error = .illegalState(evt) }
            self.onSeek()
            if self.viewModel.isRunning {return}
            if play { onResume() }
            run(player)
        }
        
        switch evt {
        case .load(let path, let isAutoPlay, let initTime):
            viewModel.reset()
            if path == "" {viewModel.error = .connect(path)}
            viewModel.path = path
            self.onLoad()
            player.load(path, isAutoPlay: isAutoPlay, initTime: initTime)
            run(player)
        
        case .togglePlay:
            if self.viewModel.isPlay {  onPause() } else { onResume() }
        case .resume: onResume()
        case .pause: onPause()
        case .stop:
            player.stop()
        case .volume(let v):
            player.currentVolume = v
            viewModel.volume = v
        case .seekTime(let t, let play): onSeek(time:t, play: play)
        case .seekMove(let t, let play): onSeek(time:viewModel.time + t, play: play)
        case .seekProgress(let pct, let play):
            let t = viewModel.duration * Double(pct)
            onSeek(time:t, play: play)
        }
        viewModel.event = nil
        
    }
    
    private func run(_ player: PlayerUIView){
        var job:AnyCancellable? = nil
        var timeControlStatus:AVPlayer.TimeControlStatus? = nil
        var status:AVPlayer.Status? = nil
        viewModel.isRunning = true
        job = Timer.publish(every: 0.1, on:.current, in: .common)
            .autoconnect()
            .sink{_ in
                guard let currentPlayer = player.player else {
                    self.cancel(job, reason: "destory plyer")
                    self.onStoped()
                    return
                }
                let t = CMTimeGetSeconds(currentPlayer.currentTime())
                self.onTimeChange(Double(t))
                player.layer.setNeedsDisplay()
                if currentPlayer.timeControlStatus != timeControlStatus {
                    switch currentPlayer.timeControlStatus{
                    case .paused:
                        self.cancel(job, reason: "pause")
                        self.onPaused()
    
                    case .playing: self.onResumed()
                    case .waitingToPlayAtSpecifiedRate:
                        switch currentPlayer.reasonForWaitingToPlay {
                        case .some(let reason):
                            switch reason {
                            case .evaluatingBufferingRate: self.onBuffering(rate: 0.0)
                            case .noItemToPlay: self.cancel(job, reason: "noItemToPlay")
                            case .toMinimizeStalls: self.onBuffering(rate: 0.0)
                            default:break
                            }
                        default:break
                        }
                    default:break
                    }
                    timeControlStatus = currentPlayer.timeControlStatus
                }
                if(status != currentPlayer.status){
                    switch currentPlayer.status {
                    case .failed: self.cancel(job, reason: "failed")
                    case .unknown:break
                    case .readyToPlay: do {
                        if let d = currentPlayer.currentItem?.asset.duration {
                            self.onDurationChange(Double(CMTimeGetSeconds(d)))
                        }
                        self.onReadyToPlay()
                    }
                    @unknown default:break
                    }
                    status = currentPlayer.status
                }
                
        }
    }
    
    private func cancel(_ job:AnyCancellable?, reason:String? = nil){
        viewModel.isRunning = false
        if let msg = reason {
            PageLog.log("cancel reason " + msg , tag: TAG)
        }
        job?.cancel()
    }
}

protocol PlayerUIViewDelegate{
    func onPlayerError(_ error:PlayerStreamError)
    func onPlayerCompleted()
}
class PlayerUIView: UIView, AVPlayerViewControllerDelegate {
    private let TAG = "PlayerUIView"
    var currentVolume:Float = 1.0
    {
        didSet{
            player?.volume = currentVolume
        }
    }
    
    var delegate:PlayerUIViewDelegate?
    var player:AVPlayer? = nil
    private var recoveryTime:Double = -1
    let playerLayer = AVPlayerLayer()
    private let playerController = AVPlayerViewController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
    }
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    deinit {
        destoryPlayer()
        delegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    private func createPlayer(_ url:URL, buffer:Double = 2.0) -> AVPlayer?{
        destoryPlayer()
        player = AVPlayer(url: url)
        player?.volume = currentVolume
        playerLayer.player = player
        player?.currentItem?.preferredForwardBufferDuration = TimeInterval(buffer)
        PageLog.log("createPlayer " + playerLayer.isReadyForDisplay.description , tag: TAG)
        
        playerController.player = player
        playerController.delegate = self
        //player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new, .initial], context: nil)
        //player?.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .initial], context: nil)

        let center = NotificationCenter.default
        center.addObserver(self, selector:#selector(newErrorLogEntry), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        center.addObserver(self, selector:#selector(failedToPlayToEndTime), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        return player
    }
    
    private func destoryPlayer(){
        guard let prevPlayer = player else { return }
        prevPlayer.pause()
        playerLayer.player = nil
        playerController.player = nil
        playerController.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    private func onError(_ e:PlayerStreamError){
         delegate?.onPlayerError(e)
         destoryPlayer()
    }
    
    @objc func newErrorLogEntry(_ notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return}
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        PageLog.log("errorLog " + errorLog.description , tag: TAG)
        
    }

    @objc func failedToPlayToEndTime(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let e = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]
        if let error = e as? Error {
            onError(.playback(error.localizedDescription))
        }else{
            onError(.unknown("failedToPlayToEndTime"))
        }
        
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        delegate?.onPlayerCompleted()
    }
    
    @discardableResult
    func load(_ path:String, isAutoPlay:Bool = false , initTime:Double = 0, buffer:Double = 2.0) -> AVPlayer? {
        guard let url = URL(string: path) else {
           return nil
        }
        let player = createPlayer(url, buffer:buffer)
        if isAutoPlay { resume() }
        if initTime > 0 { seek(initTime) }
        return player
    }
    func stop() {
        destoryPlayer()
    }
    
    @discardableResult
    func resume() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.play()
        return true
    }
    
    @discardableResult
    func pause() -> Bool {
        guard let currentPlayer = player else { return false }
        currentPlayer.pause()
        return true
    }
    
    @discardableResult
    func seek(_ t:Double) -> Bool {
        guard let currentPlayer = player else { return false }
        let cmt = CMTime(
            value: CMTimeValue(t * PlayerModel.TIME_SCALE),
            timescale: CMTimeScale(PlayerModel.TIME_SCALE))
        currentPlayer.seek(to: cmt)
        return true
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator){
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator){
    }

    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController){
       
    }

    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController){

    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error){
        onError(.pip(error.localizedDescription))
    }

    func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController){
        
    }

    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController){
        
    }

    func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool{
        return false
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void){
    }
    
    
}

