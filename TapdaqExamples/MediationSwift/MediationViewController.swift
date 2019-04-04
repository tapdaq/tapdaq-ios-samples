//
//  MediationViewController.swift
//  MediationSwift
//
//  Created by Dmitry Dovgoshliubnyi on 04/04/2019.
//

import UIKit
import Tapdaq

extension LogView {
    func log(format: String, _ args: CVarArg...) {
        withVaList(args) {
            self.log(format, args: $0)
        }
    }
}
func NSStringFromAdType(_ adType: TDAdTypes) -> String {
    switch adType {
    case .typeInterstitial:
        return "Static Interstitial";
    case .typeVideo:
        return "Video Interstitial";
    case .typeRewardedVideo:
        return "Rewarded Video";
    case .typeBanner:
        return "Banner";
    case .typeOfferwall:
        return "Offerwall";
    case .typeMediatedNative:
        return "Native";
    default:
        return "Unknown";
    }
}

class MediationViewController: UIViewController, TapdaqDelegate, TDAdRequestDelegate, TDDisplayableAdRequestDelegate, TDClickableAdRequestDelegate, TDRewardedVideoAdRequestDelegate, TDOfferwallAdRequestDelegate, TDBannerAdRequestDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    // View
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var textFieldAdUnit: UITextField!
    @IBOutlet weak var textFieldPlacementTag: UITextField!
    @IBOutlet weak var buttonLoad: UIButton!
    @IBOutlet weak var buttonShow: UIButton!
    @IBOutlet weak var logView: LogView!
    @IBOutlet weak var viewAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBannerContainer: UIView!
    
    var textFieldDummy: UITextField!
    var pickerViewAdUnit: UIPickerView!
    // Data
    let adTypes: [TDAdTypes] = [ .typeInterstitial,
                                 .typeVideo,
                                 .typeRewardedVideo,
                                 .typeBanner,
                                 .typeOfferwall,
                                 .typeMediatedNative ]
    var bannerView: UIView? = nil
    var nativeAd: TDMediatedNativeAd? = nil
    
    // State
    var selectedAdType: TDAdTypes! {
        didSet {
            if (textFieldAdUnit != nil) {
                textFieldAdUnit.text = NSStringFromAdType(selectedAdType)
            }
        }
    }
    var placementTag: String = TDPTagDefault
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTapdaq()
    }
    
    func setup() {
        selectedAdType = adTypes.first
        textFieldDummy = UITextField(frame: .zero)
        view.addSubview(textFieldDummy)
        pickerViewAdUnit = UIPickerView(frame: .zero)
        pickerViewAdUnit.delegate = self
        pickerViewAdUnit.dataSource = self
        textFieldDummy.inputView = pickerViewAdUnit
        labelVersion.text = "Tapdaq SDK v" + Tapdaq.sharedSession().sdkVersion;
        
        
        update()
    }
    
    func update() {
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            self.buttonShow.isEnabled  = Tapdaq.sharedSession().isInitialised() && self.isCurrentAdTypeReady
            var isLoadEnabled = Tapdaq.sharedSession().isInitialised()
            
            if (self.selectedAdType == .typeOfferwall ||
                self.selectedAdType == .typeBanner) {
                self.textFieldPlacementTag.isEnabled = false
                self.textFieldPlacementTag.text = TDPTagDefault
            } else {
                self.textFieldPlacementTag.isEnabled = true
                self.textFieldPlacementTag.text = self.placementTag
            }
            
            if (self.selectedAdType == .typeMediatedNative ||
                self.selectedAdType == .typeBanner) {
                if (self.viewBannerContainer.subviews.count == 0) {
                    isLoadEnabled = isLoadEnabled && true
                    self.buttonShow.setTitle("Show", for: .normal)
                }
                else {
                    isLoadEnabled = false
                    self.buttonShow.setTitle("Hide", for: .normal)
                }
            }
            self.buttonLoad.isEnabled = isLoadEnabled
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Tapdaq
    
    func setupTapdaq() {
        let properties = TDProperties.default()
        properties?.logLevel = .debug
        Tapdaq.sharedSession()?.delegate = self
        Tapdaq.sharedSession()?.setApplicationId(kAppId, clientKey: kClientKey, properties: properties)
        logView.log(format: "Loading config for:\n    App ID: %@\n    Client Key: %@", kAppId, kClientKey)
    }
    
    var isCurrentAdTypeReady: Bool {
        switch selectedAdType {
        case TDAdTypes.typeInterstitial:
            return Tapdaq.sharedSession().isInterstitialReady(forPlacementTag: placementTag)
        case TDAdTypes.typeVideo:
            return Tapdaq.sharedSession().isVideoReady(forPlacementTag: placementTag)
        case TDAdTypes.typeRewardedVideo:
            return Tapdaq.sharedSession().isRewardedVideoReady(forPlacementTag: placementTag)
        case TDAdTypes.typeBanner:
            return bannerView != nil
        case TDAdTypes.typeOfferwall:
            return Tapdaq.sharedSession().isOfferwallReady()
        case TDAdTypes.typeMediatedNative:
            return nativeAd != nil
        default:
            return false;
        }
    }
    
    func loadCurrentAdType() {
        if placementTag.count == 0 {
            let alertController = UIAlertController(title: "Error", message: "Placement Tag cannot be empty.", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(closeAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        logView.log(format:"Loading %@ for tag %@...", NSStringFromAdType(self.selectedAdType), self.placementTag)
        switch selectedAdType {
        case TDAdTypes.typeInterstitial:
            Tapdaq.sharedSession()?.loadInterstitial(forPlacementTag: placementTag, delegate: self)
        case TDAdTypes.typeVideo:
            Tapdaq.sharedSession()?.loadVideo(forPlacementTag: placementTag, delegate: self)
        case TDAdTypes.typeRewardedVideo:
            Tapdaq.sharedSession()?.loadRewardedVideo(forPlacementTag: placementTag, delegate: self)
        case TDAdTypes.typeBanner:
            Tapdaq.sharedSession()?.loadBanner(with: .standard, completion: { (banner) in
                self.bannerView = banner
                self.logView.log(format: "Did load banner")
                self.update()
            })
        case TDAdTypes.typeOfferwall:
            Tapdaq.sharedSession()?.loadOfferwall(with: self)
        case TDAdTypes.typeMediatedNative:
            Tapdaq.sharedSession()?.loadNativeAd(in: self, placementTag: placementTag, options: .adChoicesTopRight, delegate: self)
        default:
            break
        }
    }
    
    func showCurrentAdType() {
        var logMessage: String? = String(format: "Showing %@ for tag %@...", NSStringFromAdType(selectedAdType), placementTag)
        
        switch selectedAdType {
        case TDAdTypes.typeInterstitial:
            Tapdaq.sharedSession()?.showInterstitial(forPlacementTag: placementTag)
        case TDAdTypes.typeVideo:
            Tapdaq.sharedSession()?.showVideo(forPlacementTag: placementTag)
        case TDAdTypes.typeRewardedVideo:
            Tapdaq.sharedSession()?.showRewardedVideo(forPlacementTag: placementTag, hashedUserId: "mediation_sample_user_id")
        case TDAdTypes.typeBanner:
            if bannerView != nil && viewBannerContainer.subviews.count == 0 {
                show(adView: self.bannerView)
            } else {
                logMessage = nil
                self.bannerView = nil
                hideAdView()
            }
        case TDAdTypes.typeOfferwall:
            Tapdaq.sharedSession()?.showOfferwall()
        case TDAdTypes.typeMediatedNative:
            if nativeAd != nil && viewBannerContainer.subviews.count == 0 {
                let nativeAdView = TDNativeAdView(frame: .zero)
                nativeAdView.nativeAd = nativeAd
                show(adView: nativeAdView)
                nativeAd?.setAdView(nativeAdView)
                nativeAd?.trackImpression()
            } else {
                logMessage = nil
                self.bannerView = nil
                hideAdView()
            }
        default:
            break
        }
        if logMessage != nil {
            logView.log(format: logMessage!)
        }
    }
    
    func show(adView: UIView?) {
        guard let adView = adView else { return }
        viewBannerContainer.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        viewAdHeightConstraint.constant = adView.frame.height == 0 ? 250 : adView.frame.height
        let views = [ "adView" : adView ]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[adView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[adView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        viewBannerContainer.addConstraints(verticalConstraints)
        viewBannerContainer.addConstraints(horizontalConstraints)
        update()
    }
    
    func hideAdView() {
        if viewBannerContainer.subviews.count == 0 { return }
        logView.log(format: "Hidden %@ for tag %@", NSStringFromAdType(self.selectedAdType), self.placementTag)
        viewAdHeightConstraint.constant = 0
        for subview in viewBannerContainer.subviews {
            subview.removeFromSuperview()
        }
        update()
    }
    
    // MARK: - TapdaqDelegate
    
    func didLoadConfig() {
        logView.log(format: "Did load config")
        update()
    }
    
    func didFailToLoadConfigWithError(_ error: Error!) {
        logView.log(format: "Did fail to load config with error: %@", error.localizedDescription)
        update()
    }
    
    func didRefreshBanner() {
        logView.log(format: "Did refresh banner")
    }
    
    // MARK: - TDAdRequestDelegate
    func didLoad(_ adRequest: TDAdRequest) {
        logView.log(format: "Did load ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
        if adRequest is TDNativeAdRequest {
            nativeAd = (adRequest as! TDNativeAdRequest).nativeAd
        }
        update()
    }
    
    func adRequest(_ adRequest: TDAdRequest, didFailToLoadWithError error: TDError?) {
        logView.log(format: "Did fail to load ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, error?.localizedDescription ?? "")
    }
    
    // MARK: - TDDisplayableAdRequestDelegate
    
    func adRequest(_ adRequest: TDAdRequest, didFailToDisplayWithError error: TDError?) {
        logView.log(format: "Did fail to display ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, error?.localizedDescription ?? "")
    }
    
    func willDisplay(_ adRequest: TDAdRequest) {
        logView.log(format: "Will display ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
    }
    
    func didDisplay(_ adRequest: TDAdRequest) {
        logView.log(format: "Did display ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
    }
    
    func didClose(_ adRequest: TDAdRequest) {
        logView.log(format: "Did close ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
        update()
    }
    
    // MARK: - TDDisplayableAdRequestDelegate
    func didClick(_ adRequest: TDAdRequest) {
        logView.log(format: "Did click ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
    }
    
    // MARK: - TDRewardedVideoAdRequestDelegate
    func adRequest(_ adRequest: TDAdRequest, didValidate reward: TDReward) {
        logView.log(format: "Validated reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Hashed user ID: %@\n    Custom JSON:\n%@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? "TRUE" : "FALSE", reward.hashedUserId, (reward.customJson as! NSObject ).description)
    }
    
    func adRequest(_ adRequest: TDAdRequest, didFailToValidate reward: TDReward) {
        logView.log(format: "Failed to validate reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Hashed user ID: %@\n    Custom JSON:\n%@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? "TRUE" : "FALSE", reward.hashedUserId, (reward.customJson as! NSObject ).description)
    }
    
    // MARK: - TDOfferwallAdRequestDelegate
    func adRequest(_ adRequest: TDAdRequest, didReceiveOfferwallCredits creditInfo: [AnyHashable : Any]?) {
        logView.log(format: "Did receive credits ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
    }
    
    func didFail(toReceiveOfferwallCreditsAdRequest adRequest: TDAdRequest) {
        logView.log(format: "Did fail to receive credits ad unit - %@ tag - %@", NSStringFromAdType(adRequest.placement.adTypes), adRequest.placement.tag)
    }
    
    // MARK: - Actions
    
    // MARK: Button Debugger
    @IBAction func actionButtonDebuggerTapped(_ sender: Any) {
        view.endEditing(true)
        Tapdaq.sharedSession()?.presentDebugViewController()
    }
    
    // MARK: Button Load
    @IBAction func actionButtonLoadTapped(_ sender: Any) {
        view.endEditing(true)
        loadCurrentAdType()
    }
    
    // MARK: Button Show
    @IBAction func actionButtonShowTapped(_ sender: Any) {
        view.endEditing(true)
        showCurrentAdType()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === textFieldAdUnit {
            textFieldDummy.becomeFirstResponder()
            nativeAd = nil
            bannerView = nil
            hideAdView()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === textFieldDummy {
            pickerViewAdUnit.selectRow(adTypes.firstIndex(of: selectedAdType!) ?? 0, inComponent: 0, animated: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === textFieldPlacementTag {
            let nsString = textField.text as NSString?
            let newString = nsString?.replacingCharacters(in: range, with: string)
            if newString != nil {
                let shouldChange = TDPlacement.isValidTag(newString!) || newString?.count == 0
                if shouldChange {
                    placementTag = newString!
                    update()
                }
                return shouldChange
            }
            
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField === textFieldPlacementTag {
            update()
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return adTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSStringFromAdType(adTypes[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAdType = self.adTypes[row]
        update()
    }
}