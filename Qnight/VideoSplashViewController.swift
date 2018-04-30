//
//  VideoSplashViewController.swift
//  VideoSplash
//
//  Created by David Choi on 2017-06-16.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

public enum ScalingMode {
    case resize
    case resizeAspect
    case resizeAspectFill
}

open class VideoSplashViewController: UIViewController {
    
    // MARK: Properties
    fileprivate let moviePlayer = AVPlayerViewController()
    var avPlayer : AVPlayer?
    
    fileprivate var moviePlayerSoundLevel: Float = 1.0
    
    open var contentURL: URL = NSURL() as URL {
        didSet {
            setMoviePlayer(contentURL)
        }
    }
    
    open var videoFrame: CGRect = CGRect()
    open var startTime: CGFloat = 0.0
    open var duration: CGFloat = 0.0
    open var backgroundColor: UIColor = UIColor.black {
        didSet {
            view.backgroundColor = backgroundColor
        }
    }
    open var sound: Bool = true {
        didSet {
            if sound {
                moviePlayerSoundLevel = 1.0
            }else{
                moviePlayerSoundLevel = 0.0
            }
        }
    }
    open var alpha: CGFloat = CGFloat() {
        didSet {
            moviePlayer.view.alpha = alpha
        }
    }
    open var alwaysRepeat: Bool = true {
        didSet {
            if alwaysRepeat {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(VideoSplashViewController.playerItemDidReachEnd),
                                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: moviePlayer.player?.currentItem)
            }
        }
    }
    open var fillMode: ScalingMode = .resizeAspectFill {
        didSet {
            switch fillMode {
            case .resize:
                moviePlayer.videoGravity = AVLayerVideoGravityResize
            case .resizeAspect:
                moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect
            case .resizeAspectFill:
                moviePlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
        }
    }
    
    // MARK: VIEW DID LOAD
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.present(self.moviePlayer, animated: true, completion: nil)
        playVideo()
    }
    
    func playVideo(){
        let avPlayerItem = AVPlayerItem.init(url: contentURL)
        self.avPlayer = AVPlayer.init(playerItem: avPlayerItem)
        self.moviePlayer.player?.play()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        moviePlayer.view.frame = videoFrame
        moviePlayer.showsPlaybackControls = false
        view.addSubview(moviePlayer.view)
        view.sendSubview(toBack: moviePlayer.view)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        stopPlayer()
    }
    
    fileprivate func setMoviePlayer(_ url: URL){
        let videoCutter = VideoCutter()
        videoCutter.cropVideoWithUrl(videoUrl: url, startTime: startTime, duration: duration) { (videoPath, error) -> Void in
            if let path = videoPath as URL? {
                self.moviePlayer.player = AVPlayer(url: path)
                self.moviePlayer.player?.play()
                self.moviePlayer.player?.volume = self.moviePlayerSoundLevel
            }
        }
    }
    
    
    func playerItemDidReachEnd() {
        moviePlayer.player?.seek(to: kCMTimeZero)
        moviePlayer.player?.play()
    }
    
    
    func stopPlayer() {
        if let play = avPlayer{
            play.pause()
            avPlayer = nil
        }
    }
    
    // MARK: VIDEO SETUP
    func setupVideoBackground(name: String, type: String){
        
        let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: name, ofType: type)!)
        contentURL = (url as NSURL) as URL
        videoFrame = self.view.frame
        
        fillMode = .resizeAspectFill
        alwaysRepeat = false
        sound = true
        startTime = 0.0
        duration = 30
        
        alpha = 1
        
    }
    
    func soundOff(){
        self.sound = false
    }
}

