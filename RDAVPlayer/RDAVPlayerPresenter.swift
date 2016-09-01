//
//  RDAVPlayerPresenter.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/09/01.
//  Copyright © 2016年 rodhosSoft.
//  This software is released under the MIT License.
//

import Foundation
import AVFoundation

protocol RDAVPlayerAPI {
    func setupPlayer(url:NSURL)
    func addObserver(observer:RDAVPlayerEventReceiver)
    func play()
    func pause()
    func seek(value:Float)
}

protocol RDAVPlayerInfo {
    func isPlaying()->Bool
}

protocol RDAVPlayerViewAPI {
    func setup()
    func updatePlay()
    func updatePause()
    func updateSeekValue(item:AVPlayerItem)
}

enum RDAVPlayerPresenterEvent {
    case NotifyPlayButtonPushed
    case NotifySeekValueChanged(value:Float)
    case NotifyUpdateTime(item:AVPlayerItem)
}

protocol RDAVPlayerEventReceiver {
    func notify(event:RDAVPlayerPresenterEvent)
}

// State manager
class RDAVPlayerPresenter : RDAVPlayerEventReceiver {
    let playerAPI : RDAVPlayerAPI = RDAVPlayer.shareInstance
    let playerInfo : RDAVPlayerInfo = RDAVPlayer.shareInstance
    let playerView : RDAVPlayerViewAPI
    
    let sampleURL = NSBundle.mainBundle().URLForResource("samplemovie", withExtension: "mov")!
    
    
    init(view:RDAVPlayerViewAPI){
        playerView = view
        setup()
    }
    
    func setup() {
        playerAPI.setupPlayer(sampleURL)
        playerView.setup()
        playerAPI.addObserver(self)
    }

    func notify(event:RDAVPlayerPresenterEvent) {
        switch event {
        case .NotifyPlayButtonPushed:
            if (self.playerInfo.isPlaying()) {
                playerAPI.pause()
                playerView.updatePause()
            } else {
                playerAPI.play()
                playerView.updatePlay()
            }
        case .NotifySeekValueChanged(value: let value):
            playerAPI.seek(value)
        case .NotifyUpdateTime(item: let item):
            playerView.updateSeekValue(item);
        }
    }
    
}
