//
//  MinimumPlayer.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/08/10.
//  Copyright © 2016年 rodhosSoft.
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php

import Foundation
import AVFoundation
import UIKit


class RDAVPlayer : UIViewController {
    
    var playerLayer : AVPlayerLayer!
    
    
    static func sampleURL()->NSURL?
    {
        return NSBundle.mainBundle().URLForResource("samplemovie", withExtension: "mov")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerLayer.frame.size = size
    }
    
    override func viewDidLoad() {
        self.setup()
        self.play()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    }
    
    func play() {
        playerLayer.player?.play()
    }
    
    func setup() {
        self.playerLayer = setupPlayerLayer(self.dynamicType.sampleURL()!)
        view.layer.addSublayer(playerLayer)
    }

    
    func setupPlayerLayer(URL:NSURL!) -> AVPlayerLayer {
        
        let player = AVPlayer(URL:URL)
        let playerLayer : AVPlayerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        return playerLayer
    }
    

    
}



