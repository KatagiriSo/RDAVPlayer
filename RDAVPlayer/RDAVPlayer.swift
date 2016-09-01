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



protocol RDAVPlayerAPI {
    func setupPlayer(url:NSURL)
    func addObserver(observer:RDAVPlayerEventReceiver)
    func play()
    func seek(value:Float)
}

private var kCurrentItemContext : Int = 0


/// control to AVPlayer
class RDAVPlayer : NSObject, RDAVPlayerAPI, AVAssetResourceLoaderDelegate {
    
    var eventReceiver : RDAVPlayerEventReceiver? = nil
    var playerLayer:AVPlayerLayer!
    var player:AVPlayer! {
        didSet(oldplayer) {
            if let o = oldplayer {
                o.removeObserver(self, forKeyPath: "status")
                o.removeObserver(self, forKeyPath: "rate")
            }
            
            self.player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
            self.player.addObserver(self, forKeyPath: "rate", options: .New, context: nil)
            // self.player.addObserver(self, forKeyPath: "timeControlStatus", options: .New, context: nil) new Paused,WaitingToPlayAtSpecifiedRate,Playing
            // self.player.reasonForWaitingToPlay
            // AVPlayer.automaticallyWaitsToMinimizeStalling = true ios 10-

        }
    }
    
    var boundTimeObserverToken : AnyObject?
    var periodTimeObserverToken : AnyObject?
    
    static let shareInstance:RDAVPlayer = RDAVPlayer()
    
    override init() {
        super.init()
        setupObserver()
    }
    
    func setupObserver() {
        
        func setupObserver(name:String,selector:Selector) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
        }
        
        setupObserver(AVPlayerItemTimeJumpedNotification, selector: #selector(RDAVPlayer.notify(_:)));
        setupObserver(AVPlayerItemDidPlayToEndTimeNotification, selector: #selector(RDAVPlayer.notify(_:)));
        setupObserver(AVPlayerItemFailedToPlayToEndTimeNotification, selector: #selector(RDAVPlayer.notify(_:)));
        setupObserver(AVPlayerItemPlaybackStalledNotification, selector: #selector(RDAVPlayer.notify(_:)));
        setupObserver(AVPlayerItemNewAccessLogEntryNotification, selector: #selector(RDAVPlayer.notify(_:)));
        setupObserver(AVPlayerItemNewErrorLogEntryNotification, selector: #selector(RDAVPlayer.notify(_:)));
    }
    
    func addObserver(observer: RDAVPlayerEventReceiver) {
        self.eventReceiver = observer
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //        print("observeValueForKeyPath:\(keyPath) ofObject \(object) change:\(change), context:\(context)")
        
        guard let key:String = keyPath else {
            return
        }
        
        if context == &kCurrentItemContext {
            switch key {
            case "rate":
                print("item rate = \(change?[NSKeyValueChangeOldKey]) -> \(change?[NSKeyValueChangeNewKey])")
                print("duration = \(self.player.currentItem?.duration.seconds)")
                print("currentTime = \(self.player.currentItem?.currentTime().seconds)")
            default:
                print("\(key)")
            }
        } else {
            switch key {
            case "status":
                print("status = \(self.player.status.rawValue)")
            case "rate":
                print("player rate = \(change?[NSKeyValueChangeOldKey]) -> \(change?[NSKeyValueChangeNewKey])")
                print("duration = \(self.player.currentItem?.duration.seconds)")
                print("currentTime = \(self.player.currentItem?.currentTime().seconds)")
            default:
                print("\(key)")
            }
        }
    }
    

    func notify(notification:NSNotification)->() {
        print("\(notification.name)")
    }
    
    var periodCount = 0
    
    func setTimeObserver() -> Bool {
        print("setTimeObserver")
        
        
        let periodblock = {(time:CMTime) in
            
            print("period \(time.seconds)")            
            
            if let item:AVPlayerItem = self.player.currentItem {
                self.eventReceiver?.notify(RDAVPlayerPresenterEvent.NotifyUpdateTime(item: item))
            }
            
            if self.periodCount % 5 == 0{
            
                self.showLog()
            }
            
            self.periodCount = self.periodCount + 1
            
        }
        
        let boundaryBlock = {() in
            print("boundary observed")
        }
        
        self.periodTimeObserverToken =  player.addPeriodicTimeObserverForInterval(CMTimeMake(100, 100),
                                                                                  queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                                  usingBlock: periodblock)
        
        let duration = self.player.currentItem!.duration
        
        func getTime(percent:Float64)->NSValue {
            let t =  CMTimeMultiplyByFloat64(duration, percent)
            let v = NSValue(CMTime:t)
            return v
        }
        
        let times = [getTime(0), getTime(0.5), getTime(1)]
        
        self.boundTimeObserverToken =  player.addBoundaryTimeObserverForTimes(times,
                                                                              queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                                                              usingBlock:boundaryBlock)
        
        return true
    }
    
    
    func play() {
        player.play()
    }
    
    func seek(value:Float) {
        
        guard value >= 0 && value < 1 else {
            return
        }
        
        let duration_ : CMTime? = self.player.currentItem!.duration
        guard let duration : CMTime = duration_ else {
            return
        }
        
        let time : CMTime = CMTimeMultiplyByFloat64(duration, Float64(value))
        let t10 : CMTime = CMTimeMake(10, 1)
        
        
        player.seekToTime(time, toleranceBefore: t10, toleranceAfter: t10, completionHandler: { isS in
            print("seekTo\(isS)")
        })
    }
    
    func setupPlayer(url:NSURL) {
        let asset : AVURLAsset = AVURLAsset(URL: url)
        asset.loadValuesAsynchronouslyForKeys(["duration"], completionHandler: nil)
        if #available(iOS 9.0, *) {
            asset.resourceLoader.preloadsEligibleContentKeys = true
        } else {
            // Fallback on earlier versions
        }
        
        asset.resourceLoader.setDelegate(self, queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        
        let item : AVPlayerItem = AVPlayerItem(asset: asset)
//        item.preferredPeakBitRate = 2000
        
        if #available(iOS 9.0, *) {
            item.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        } else {
            // Fallback on earlier versions
        };
        
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: &kCurrentItemContext)
        item.addObserver(self, forKeyPath: "playbackBufferFull", options: .New, context: &kCurrentItemContext)
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: &kCurrentItemContext)
        item.addObserver(self, forKeyPath: "rate", options: .New, context: &kCurrentItemContext)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
        
        setTimeObserver()

        
        // player.rate app request rate
        // item.timebase.rate the rate at which playback is acturally occuring
    }
    
    
    func removeTimeObserver() {
        if let ob = self.periodTimeObserverToken {
            self.player.removeTimeObserver(ob)
        }
        if let ob = self.boundTimeObserverToken {
            self.player.removeTimeObserver(ob)
        }
    }
    
    func removeObserver() {
        
        self.player.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.player.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        self.player.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func showLog() {
        print("= REPORT =")

        if let item = self.player.currentItem {
            if let log = item.accessLog() {
                if let lastevent = log.events.last {
                    let lastObservedBitrate = lastevent.observedBitrate
                    print("lastObservedBitrate \(lastObservedBitrate)")
                }
            }
        }
        
        // loaded time ranges
        if let loadedTimeRanges : [NSValue]  = self.player.currentItem?.loadedTimeRanges {
            var str = ""
            for v : NSValue in loadedTimeRanges {
                let timeRange : CMTimeRange = v.CMTimeRangeValue
                str = str + "(s:\(timeRange.start.seconds), du:\(timeRange.duration.seconds))"
            }
            print("loadedTimeRange:\(str)")
        }
        print("=====")
    }
    
// MARK: Delegate AVAssetResourceLoaderDelegate
    
    func resourceLoader(resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        /*
         Delegates receive this message when assistance is required of the application to load a resource. For example, this method is invoked to load decryption keys that have been specified using custom URL schemes.
         If the result is YES, the resource loader expects invocation, either subsequently or immediately, of either -[AVAssetResourceLoadingRequest finishLoading] or -[AVAssetResourceLoadingRequest finishLoadingWithError:]. If you intend to finish loading the resource after your handling of this message returns, you must retain the instance of AVAssetResourceLoadingRequest until after loading is finished.
         If the result is NO, the resource loader treats the loading of the resource as having failed.
         Note that if the delegate's implementation of -resourceLoader:shouldWaitForLoadingOfRequestedResource: returns YES without finishing the loading request immediately, it may be invoked again with another loading request before the prior request is finished; therefore in such cases the delegate should be prepared to manage multiple loading requests.
         */
        print("shouldWaitForLoadingOfRequestedResource\(loadingRequest.description)")
        show(loadingRequest)
        
        return true
    }
    
    func show(loadingRequest:AVAssetResourceLoadingRequest) {
        print(" \(loadingRequest.request), \(loadingRequest.cancelled), \(loadingRequest.finished)")
        
        if let inforeq:AVAssetResourceLoadingContentInformationRequest = loadingRequest.contentInformationRequest {
            print("AVAssetResourceLoadingContentInformationRequest\(inforeq.contentType), \(inforeq.contentType), \(inforeq.byteRangeAccessSupported),\(inforeq.renewalDate)")
            
        }
    }
    
    func resourceLoader(resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool
    {
        /*
         Delegates receive this message when assistance is required of the application to renew a resource previously loaded by resourceLoader:shouldWaitForLoadingOfRequestedResource:. For example, this method is invoked to renew decryption keys that require renewal, as indicated in a response to a prior invocation of resourceLoader:shouldWaitForLoadingOfRequestedResource:.
         If the result is YES, the resource loader expects invocation, either subsequently or immediately, of either -[AVAssetResourceRenewalRequest finishLoading] or -[AVAssetResourceRenewalRequest finishLoadingWithError:]. If you intend to finish loading the resource after your handling of this message returns, you must retain the instance of AVAssetResourceRenewalRequest until after loading is finished.
         If the result is NO, the resource loader treats the loading of the resource as having failed.
         Note that if the delegate's implementation of -resourceLoader:shouldWaitForRenewalOfRequestedResource: returns YES without finishing the loading request immediately, it may be invoked again with another loading request before the prior request is finished; therefore in such cases the delegate should be prepared to manage multiple loading requests.
         */
        print("shouldWaitForRenewalOfRequestedResource\(renewalRequest.description)")
        show(renewalRequest)
        
        return true
    }
    

    func resourceLoader(resourceLoader: AVAssetResourceLoader, didCancelLoadingRequest loadingRequest: AVAssetResourceLoadingRequest) {
        /*
              @discussion	Previously issued loading requests can be cancelled when data from the resource is no longer required or when a loading request is superseded by new requests for data from the same resource. For example, if to complete a seek operation it becomes necessary to load a range of bytes that's different from a range previously requested, the prior request may be cancelled while the delegate is still handling it.
 */
        print("didCancelLoadingRequest\(loadingRequest.description)")
        show(loadingRequest)
    }
    
    func showAuth(authenticationChallenge:NSURLAuthenticationChallenge) {
        print("\(authenticationChallenge.protectionSpace)")
        print("\(authenticationChallenge.proposedCredential)")
        print("\(authenticationChallenge.failureResponse)")
        print("\(authenticationChallenge.error)")
        print("\(authenticationChallenge.previousFailureCount)")
        print("\(authenticationChallenge.sender)")
    }
    
    /*!
     @method 		resourceLoader:shouldWaitForResponseToAuthenticationChallenge:
     @abstract		Invoked when assistance is required of the application to respond to an authentication challenge.
     @param 		resourceLoader
     The instance of AVAssetResourceLoader asking for help with an authentication challenge.
     @param 		authenticationChallenge
     An instance of NSURLAuthenticationChallenge.
     @discussion
     Delegates receive this message when assistance is required of the application to respond to an authentication challenge.
     If the result is YES, the resource loader expects you to send an appropriate response, either subsequently or immediately, to the NSURLAuthenticationChallenge's sender, i.e. [authenticationChallenge sender], via use of one of the messages defined in the NSURLAuthenticationChallengeSender protocol (see NSAuthenticationChallenge.h). If you intend to respond to the authentication challenge after your handling of -resourceLoader:shouldWaitForResponseToAuthenticationChallenge: returns, you must retain the instance of NSURLAuthenticationChallenge until after your response has been made.
     */
    func resourceLoader(resourceLoader: AVAssetResourceLoader, shouldWaitForResponseToAuthenticationChallenge authenticationChallenge: NSURLAuthenticationChallenge) -> Bool
    {
        print("shouldWaitForResponseToAuthenticationChallenge\(authenticationChallenge.description)")
        showAuth(authenticationChallenge)
        
        return true
    }
    
    func resourceLoader(resourceLoader: AVAssetResourceLoader, didCancelAuthenticationChallenge authenticationChallenge: NSURLAuthenticationChallenge)
    {
        print("didCancelAuthenticationChallenge\(authenticationChallenge.description)")
        showAuth(authenticationChallenge)
    }
}

