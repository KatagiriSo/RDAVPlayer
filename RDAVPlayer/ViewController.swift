//
//  ViewController.swift
//  RDAVPlayer
//
//  Created by 片桐奏羽 on 2016/08/10.
//  Copyright © 2016年 rodhosSoft.
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit
import AVFoundation

class RDPlayerView : UIView, RDAVPlayerViewAPI
{
    @IBOutlet weak var consol: UITextView!
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var screenView: UIView!
    
    func setup()
    {
        
    }
    
    func updatePlay()
    {
        print("updatePlay")
    }
    
    func updatePause()
    {
        print("updatePause")
    }
    
    func updateSeekValue()
    {
        print("updateSeekValue")
    }
}



class RDAVPlayerViewController : UIViewController {
    
    @IBOutlet weak var playerView: RDPlayerView!
    
    
    var playerPresenter : RDAVPlayerPresenter!
    var playerLayer : AVPlayerLayer!
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerLayer.frame.size = size
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
    }
    
    override func viewDidLoad() {
        self.playerPresenter = RDAVPlayerPresenter(view: self.playerView)
        self.setup()
    }
    
    func setup() {
        playerLayer = RDAVPlayer.shareInstance.playerLayer
        playerLayer.frame = self.view.bounds
        playerView.screenView.layer.addSublayer(playerLayer)
    }
    
    @IBAction func playButtonPushed(sender: UIButton) {
        playerPresenter.notify(RDAVPlayerPresenterEvent.NotifyPlayButtonPushed)
    }
    
    @IBAction func seekValueChanged(sender: UISlider) {
        playerPresenter.notify(RDAVPlayerPresenterEvent.NotifySeekValueChanged(value: sender.value))
    }
}

