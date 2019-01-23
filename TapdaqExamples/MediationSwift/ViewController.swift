//
//  ViewController.swift
//  MediationSwift
//
//  Created by Nick Reffitt on 16/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

import UIKit
import Tapdaq

func AdTypeNameFromTDAdTypes(types: TDAdTypes) -> String {
    switch types {
    case .typeInterstitial:
        return "interstitial"
    case .typeVideo:
        return "video interstitial"
    case .typeRewardedVideo:
        return "rewarded video"
    default:
        return "unknown"
    }
}

class ViewController: UIViewController, TapdaqDelegate {
    
    struct RewardConstants {
        static let rewardNameKey = "MyRewardName"
        static let rewardAmountKey = "MyRewardAmount"
        static let rewardPayloadKey = "MyRewardPayload"
    }
    
    @IBOutlet var bannerView: UIView!
    var adBanner: UIView?
    
    @IBOutlet var loadInterstitialBtn: UIButton!
    @IBOutlet var loadVideoBtn: UIButton!
    @IBOutlet var loadRewardedBtn: UIButton!
    @IBOutlet var loadBannerBtn: UIButton!
    
    @IBOutlet var showInterstitialBtn: UIButton!
    @IBOutlet var showVideoBtn: UIButton!
    @IBOutlet var showRewardedBtn: UIButton!
    @IBOutlet var showBannerBtn: UIButton!
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var rewardNameLabel: UILabel!
    @IBOutlet var rewardAmountLabel: UILabel!
    
    fileprivate var interstitialAdRequest: TDAdRequest?
    fileprivate var videoAdRequest: TDAdRequest?
    fileprivate var rewardedAdRequest: TDAdRequest?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Tapdaq.sharedSession().delegate = self
        updateRewardUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func updateUI() {
        self.loadInterstitialBtn.isEnabled = Tapdaq.sharedSession()?.isInitialised() ?? false;
        self.loadVideoBtn.isEnabled = Tapdaq.sharedSession()?.isInitialised() ?? false;
        self.loadRewardedBtn.isEnabled = Tapdaq.sharedSession()?.isInitialised() ?? false;
        self.loadBannerBtn.isEnabled = Tapdaq.sharedSession()?.isInitialised() ?? false;
        
        self.showInterstitialBtn.isEnabled = self.interstitialAdRequest?.isReady() ?? false;
        self.showVideoBtn.isEnabled = self.videoAdRequest?.isReady() ?? false;
        self.showRewardedBtn.isEnabled = self.rewardedAdRequest?.isReady() ?? false;
        
        self.showBannerBtn.isEnabled = self.adBanner != nil;
    }
    
    fileprivate func log(message: String) {
        
        let text: String = textView!.text
        let textAddition: String = message + "\n\n" + text
        textView!.text = textAddition
        
        print("Mediation App: " + message)
    }
    
    fileprivate func updateRewardUI() {
 
        let rewardName: String = UserDefaults.standard.string(forKey: RewardConstants.rewardNameKey) ?? "Reward"
        let rewardAmount: Int = UserDefaults.standard.integer(forKey: RewardConstants.rewardAmountKey)

        rewardNameLabel.text = rewardName
        rewardAmountLabel.text = String(rewardAmount)
        
    }
 
    // Target actions
 
    @IBAction func loadInterstitial(sender: UIButton) {
        Tapdaq.sharedSession().loadInterstitial(forPlacementTag: TDPTagDefault, delegate: self)
    }
    
    @IBAction func showInterstitial(sender: UIButton) {
        Tapdaq.sharedSession()?.showInterstitial(forPlacementTag: TDPTagDefault)
    }
    
    @IBAction func loadVideo(sender: UIButton) {
        Tapdaq.sharedSession().loadVideo(forPlacementTag: TDPTagDefault, delegate: self)
    }
    
    @IBAction func showVideo(sender: UIButton) {
        Tapdaq.sharedSession()?.showVideo(forPlacementTag: TDPTagDefault)
    }
    
    @IBAction func loadRewarded(sender: UIButton) {
        Tapdaq.sharedSession().loadRewardedVideo(forPlacementTag: TDPTagDefault, delegate: self)
    }

    @IBAction func showRewarded(sender: UIButton) {
        Tapdaq.sharedSession()?.showRewardedVideo(forPlacementTag: TDPTagDefault)
    }
    
    @IBAction func loadBanner(sender: UIButton) {
        Tapdaq.sharedSession()?.loadBanner(with: .standard, completion: { (bannerView) in
            self.adBanner = bannerView
        })
    }
    
    @IBAction func showBanner(sender: UIButton) {
        
        let tagInt: Int = showBannerBtn.tag
        
        if tagInt == 1 {
            
            adBanner?.removeFromSuperview()
            
            showBannerBtn.tag = 0
            showBannerBtn.setTitle("Show", for: UIControl.State.normal)
            showBannerBtn.isEnabled = false
            
        } else {
            
            let isBannerReady = self.adBanner != nil
            
            if isBannerReady {
                
                bannerView!.addSubview(adBanner!)
                bannerView.setNeedsDisplay()
                
                showBannerBtn.tag = 1
                showBannerBtn.setTitle("Hide", for: UIControl.State.normal)
                
            }
            
        }
        
    }
    
    @IBAction func showDebugger(_ sender: Any?) {
        Tapdaq.sharedSession().presentDebugViewController()
    }
    
    // TapdaqDelegate
    
    func didLoadConfig() {
        
        log(message: "Tapdaq config loaded")
        updateUI()
    }
    
    func didFailToLoadConfigWithError(_ error: TDError!) {
        log(message: "Tapdaq failed to load config with error: \(error?.localizedDescription ?? "")")
        updateUI()
    }
    
    // Banner
    
    func didLoadBanner() {
        updateUI()
        log(message: "Did load banner")
    }
    
    func didFailToLoadBanner() {
        log(message: "Failed to load banner")
    }
    
    func didClickBanner() {
        log(message: "Did click banner")
    }
    
    func didRefreshBanner() {
        log(message: "Did refresh banner")
    }
}

extension ViewController: TDAdRequestDelegate {
    func didLoad(_ adRequest: TDAdRequest) {
        log(message: "Did load \"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\"")
        switch (adRequest.placement.adTypes) {
        case .typeInterstitial:
            interstitialAdRequest = adRequest
        case .typeVideo:
            videoAdRequest = adRequest
        case .typeRewardedVideo:
            rewardedAdRequest = adRequest
        default:
            break;
        }
        
        updateUI()
    }
    
    func adRequest(_ adRequest: TDAdRequest, didFailToLoadWithError error: TDError?) {
        log(message: "Failed to load \"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\" error: \(error?.localizedDescription ?? "")")
        updateUI()
    }
}

extension ViewController: TDDisplayableAdRequestDelegate {
    func willDisplay(_ adRequest: TDAdRequest) {
        log(message: "Will display\"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\"")
    }
    
    func didDisplay(_ adRequest: TDAdRequest) {
        log(message: "Did display\"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\"")
    }
    
    func adRequest(_ adRequest: TDAdRequest, didFailToDisplayWithError error: TDError?) {
        log(message: "Failed to display \"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\" error: \(error?.localizedDescription ?? "")")
        updateUI()
    }
    
    func didClose(_ adRequest: TDAdRequest) {
        log(message: "Did close \"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\"")
    }
}

extension ViewController: TDClickableAdRequestDelegate {
    func didClick(_ adRequest: TDAdRequest) {
        log(message: "Did click \"\(AdTypeNameFromTDAdTypes(types: adRequest.placement.adTypes))\" - tag: \"\(adRequest.placement.tag ?? "")\"")
    }
}

extension ViewController: TDRewardedVideoAdRequestDelegate {
    func adRequest(_ adRequest: TDAdRequest, didValidate reward: TDReward) {
        let storedRewardAmount: Int = UserDefaults.standard.integer(forKey: RewardConstants.rewardAmountKey)
        
        let updatedRewardAmount: Int = storedRewardAmount + Int(reward.value)
        
        UserDefaults.standard.set(updatedRewardAmount, forKey: RewardConstants.rewardAmountKey)
        UserDefaults.standard.set(reward.name, forKey: RewardConstants.rewardNameKey)
        if let _ = reward.customJson {
            UserDefaults.standard.set(reward.customJson, forKey: RewardConstants.rewardPayloadKey)
        }
        updateRewardUI()
        
        log(message: "Received reward for tag:\(adRequest.placement.tag ?? "") name:\(reward.name) value:\(reward.value) custom JSON: \(reward.customJson)")
    }
    
    func didFail(toValidateRewardAdRequest adRequest: TDAdRequest) {
        log(message: "Failed to validate reward for tag: \(adRequest.placement.tag ?? "")")
    }
}

extension ViewController: TDOfferwallAdRequestDelegate {
    func adRequest(_ adRequest: TDAdRequest, didReceiveOfferwallCredits creditInfo: [AnyHashable : Any]?) {
        log(message: "Received offerwall credits: \(creditInfo ?? [:])")
    }
}
