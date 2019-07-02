//
//  PlayerDetailView.swift
//  PodcastLearn
//
//  Created by Chen Kelvin on 2019/5/22.
//  Copyright © 2019 Chen Kelvin. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailView: UIView {
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            miniTitleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            
            setupAudioSession()
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl ?? "") else {
                return
            }
            episodeImageView.sd_setImage(with: url, completed: nil)
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                guard let image = image else { return }
                
                //Lockscreen artwork setup code
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                
                let artWork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                    return image
                })
                
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artWork
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func playEpisode() {
        if episode.fileUrl != nil {
            playEpisodeLocal()
        } else {
            print("Trying to play episdoe at:", episode.streamUrl)
            
            guard let url = URL(string: episode.streamUrl) else {
                return
            }
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        }
    }
    
    fileprivate func playEpisodeLocal() {
        print("Attempt to play episode with file url:", episode.fileUrl ?? "")
        
        //Get the true URL to play
        guard let fileURL = URL(string: episode.fileUrl ?? "") else { return }
        let fileName = fileURL.lastPathComponent
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        trueLocation.appendPathComponent(fileName)
        
        let playerItem = AVPlayerItem(url: trueLocation)
        player.replaceCurrentItem(with: playerItem)
        
        player.play()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        enlargeEpisodeImageView()
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    fileprivate func setupGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTabMaximize)))
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = .identity
            
            if translation.y > 50 {
                UIApplication.mainTabBarController()?.minimizePlayerDetail()
            }
        }
    }
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .init())
        } catch let sessionErr {
            print("Failed to activate session:", sessionErr)
        }
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let cmdCenter = MPRemoteCommandCenter.shared()
        
        cmdCenter.playCommand.isEnabled = true
        cmdCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        cmdCenter.pauseCommand.isEnabled = true
        cmdCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        cmdCenter.togglePlayPauseCommand.isEnabled = true
        cmdCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        cmdCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        
        cmdCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
//        cmdCenter.skipForwardCommand.addTarget(self, action: #selector(handleSkip))
//        let interval = NSNumber.init(value: 30)
//        cmdCenter.skipForwardCommand.preferredIntervals = [interval]
    }
    
    @objc fileprivate func handleSkip() {
        print("Skip")
    }
    
    var playlistEpisodes = [Episode]()
    
    @objc fileprivate func handlePreviousTrack() {
        changeTrack(moveforward: false)
    }
    
    @objc fileprivate func handleNextTrack() {
        changeTrack(moveforward: true)
        print("Double Tap")
    }
    
    fileprivate func changeTrack(moveforward: Bool) {
        let offSet = moveforward ? 1 : playlistEpisodes.count - 1
        if playlistEpisodes.count == 0 { return }
        let currentEpisodeIndex = playlistEpisodes.lastIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        guard let index = currentEpisodeIndex else { return }
        self.episode = playlistEpisodes[(index + offSet)%playlistEpisodes.count]
    } //modulo operator
    
    fileprivate func setupElapsedTime(playbackRate: Float) {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main)
        { [weak self] in
            print("Episode start to playing.")
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupLockScreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        print("Interruption Observe")
        
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("Interruption began")
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        } else {
            print("Interruption ended")
            guard let option = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if option == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                handlePlayPause()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
        setupGesture()
        setupInterruptionObserver()
        observePlayerCurrentTime()
        observeBoundaryTime()
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }
    
    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                UIApplication.mainTabBarController()?.maximizePlayerDetail(with: nil)
//                gesture.isEnabled = false
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        })
    }
    
    @objc func handleTabMaximize() {
        UIApplication.mainTabBarController()?.maximizePlayerDetail(with: nil)
//        panGesture.isEnabled = false
    }
    
    static func initFromNib() -> PlayerDetailView {
        return Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    //MARK:- IB Action and Outlets
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(miniFastForward), for: .touchUpInside)
        }
    }
    
    @objc func miniFastForward() {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        print("Slider value:", currentTimeSlider.value)
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {
            return
        }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
        player.seek(to: seekTime)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    @IBAction func handleDismiss(_ sender: Any) {
//        self.removeFromSuperview()
        UIApplication.mainTabBarController()?.minimizePlayerDetail()
//        panGesture.isEnabled = true
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate let shrumkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrumkenTransform
        })
    }
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrumkenTransform
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPause() {
        print("Trying to play and pause")
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            setupElapsedTime(playbackRate: 0)
        }
    }
    
}
