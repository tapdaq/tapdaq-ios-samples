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

func NSStringFromBannerSize(_ bannerSize: TDMBannerSize) -> String {
    switch bannerSize {
    case .standard:
        return "Standard";
    case .medium:
        return "Medium";
    case .large:
        return "Large";
    case .smart:
        return "Smart";
    case .leaderboard:
        return "Leaderboard";
    case .full:
        return "Full";
    default:
        return "Unknown";
    }
}

class MediationViewController: UIViewController, TapdaqDelegate, TDAdRequestDelegate, TDInterstitialAdRequestDelegate, TDRewardedVideoAdRequestDelegate, TDBannerAdRequestDelegate, TDNativeAdRequestDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // View
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var textFieldAdUnit: UITextField!
    @IBOutlet weak var textFieldPlacementTag: UITextField!
    @IBOutlet weak var buttonLoad: UIButton!
    @IBOutlet weak var buttonShow: UIButton!
    @IBOutlet weak var logView: LogView!
    @IBOutlet weak var viewAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBannerContainer: UIView!
    @IBOutlet weak var labelPlacementTag: UILabel!
    
    var textFieldDummy: UITextField!
    var textFieldBannerSizeDummy: UITextField!
    var pickerViewAdUnit: UIPickerView!
    var pickerViewBannerSize: UIPickerView!
    // Data
    let adUnits: [TDAdUnit] = [ .unitStaticInterstitial,
                                 .unitVideoInterstitial,
                                 .unitRewardedVideo,
                                 .unitBanner,
                                 .unitMediatedNative ]
    let bannerSizes: [TDMBannerSize] = [ .standard,
                                 .smart,
                                 .medium,
                                 .large,
                                 .leaderboard,
                                 .full]
    var bannerView: UIView? = nil
    var nativeAd: TDMediatedNativeAd? = nil
    
    // State
    var selectedAdUnit: TDAdUnit! {
        didSet {
            if (textFieldAdUnit != nil) {
                textFieldAdUnit.text = NSStringFromAdUnit(selectedAdUnit)
            }
        }
    }
    var selectedBannerSize: TDMBannerSize!
    var placementTag: String = TDPTagDefault
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        selectedAdUnit = adUnits.first
        selectedBannerSize = bannerSizes.first
        textFieldDummy = UITextField(frame: .zero)
        view.addSubview(textFieldDummy)
        pickerViewAdUnit = UIPickerView(frame: .zero)
        pickerViewAdUnit.delegate = self
        pickerViewAdUnit.dataSource = self
        textFieldDummy.inputView = pickerViewAdUnit
        
        textFieldBannerSizeDummy = UITextField(frame: .zero)
        view.addSubview(textFieldBannerSizeDummy)
        pickerViewBannerSize = UIPickerView(frame: .zero)
        pickerViewBannerSize.delegate = self
        pickerViewBannerSize.dataSource = self
        textFieldBannerSizeDummy.inputView = pickerViewBannerSize
        labelVersion.text = "Tapdaq SDK v" + Tapdaq.sharedSession().sdkVersion;
        
        
        update()
    }
    
    func update() {
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            self.buttonShow.isEnabled  = Tapdaq.sharedSession().isInitialised() && self.isCurrentAdTypeReady
            var isLoadEnabled = Tapdaq.sharedSession().isInitialised()
            
            if (self.selectedAdUnit == .unitMediatedNative ||
                self.selectedAdUnit == .unitBanner) {
                if (self.viewBannerContainer.subviews.count == 0) {
                    isLoadEnabled = isLoadEnabled && true
                    self.buttonShow.setTitle("Show", for: .normal)
                }
                else {
                    isLoadEnabled = false
                    self.buttonShow.setTitle("Hide", for: .normal)
                }
            }
            if (self.selectedAdUnit == .unitBanner) {
                self.labelPlacementTag.text = "Banner Size:"
                self.textFieldPlacementTag.text = NSStringFromBannerSize(self.selectedBannerSize);
            } else {
                self.labelPlacementTag.text = "Placement Tag:"
            }
            self.buttonLoad.isEnabled = isLoadEnabled;
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Tapdaq
    
    func setupTapdaq() {
        var properties = Tapdaq.sharedSession()?.properties
        if properties == nil {
            properties = TDProperties.default()
        }
        TDLogger.setLogLevel(.debug)
        Tapdaq.sharedSession()?.delegate = self
        Tapdaq.sharedSession()?.setApplicationId(kAppId, clientKey: kClientKey, properties: properties)
        logView.log(format: "Loading config for:\n    App ID: %@\n    Client Key: %@", kAppId, kClientKey)
    }
    
    var isCurrentAdTypeReady: Bool {
        switch selectedAdUnit {
        case .unitStaticInterstitial:
            return Tapdaq.sharedSession().isInterstitialReady(forPlacementTag: placementTag)
        case .unitVideoInterstitial:
            return Tapdaq.sharedSession().isVideoReady(forPlacementTag: placementTag)
        case .unitRewardedVideo:
            return Tapdaq.sharedSession().isRewardedVideoReady(forPlacementTag: placementTag)
        case .unitBanner:
            return bannerView != nil
        case .unitMediatedNative:
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
        if selectedAdUnit != .unitBanner {
            logView.log(format:"Loading %@ for tag %@...", NSStringFromAdUnit(self.selectedAdUnit), self.placementTag)
        }
        switch selectedAdUnit {
        case .unitStaticInterstitial:
            Tapdaq.sharedSession()?.loadInterstitial(forPlacementTag: placementTag, delegate: self)
        case .unitVideoInterstitial:
            Tapdaq.sharedSession()?.loadVideo(forPlacementTag: placementTag, delegate: self)
        case .unitRewardedVideo:
            Tapdaq.sharedSession()?.loadRewardedVideo(forPlacementTag: placementTag, delegate: self)
        case .unitBanner:
            logView.log(format:"Loading %@ %@ for tag %@...", NSStringFromBannerSize(selectedBannerSize), NSStringFromAdUnit(self.selectedAdUnit), self.placementTag)

            Tapdaq.sharedSession()?.loadBanner(forPlacementTag: self.placementTag, with: selectedBannerSize, delegate: self)
        case .unitMediatedNative:
            Tapdaq.sharedSession()?.loadNativeAd(in: self, placementTag: placementTag, options: .adChoicesTopRight, delegate: self)
        default:
            break
        }
    }
    
    func showCurrentAdType() {
        var logMessage: String? = String(format: "Showing %@ for tag %@...", NSStringFromAdUnit(selectedAdUnit), placementTag)
        
        switch selectedAdUnit {
        case .unitStaticInterstitial:
            Tapdaq.sharedSession()?.showInterstitial(forPlacementTag: placementTag, delegate: self)
        case .unitVideoInterstitial:
            Tapdaq.sharedSession()?.showVideo(forPlacementTag: placementTag, delegate: self)
        case .unitRewardedVideo:
            Tapdaq.sharedSession()?.showRewardedVideo(forPlacementTag: placementTag, delegate: self)
        case .unitBanner:
            if bannerView != nil && viewBannerContainer.subviews.count == 0 {
                show(adView: self.bannerView)
            } else {
                logMessage = nil
                self.bannerView = nil
                hideAdView()
            }
        case .unitMediatedNative:
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
        logView.log(format: "Hidden %@ for tag %@", NSStringFromAdUnit(self.selectedAdUnit), self.placementTag)
        viewAdHeightConstraint.constant = 0
        for subview in viewBannerContainer.subviews {
            subview.removeFromSuperview()
        }
        update()
    }
    
    func handleDidLoad(_ adRequest: TDAdRequest) {
        logView.log(format: "Did load ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)
        update()
    }
    
    
    // MARK: - TapdaqDelegate
    
    func didLoadConfig() {
        logView.log(format: "Did load config")
        update()
    }
    
    func didFailToLoadConfigWithError(_ error: TDError!) {
        logView.log(format: "Did fail to load config with error: %@", error.localizedDescription)
        update()
    }
    
    func didClick(_ adRequest: TDAdRequest) {
        logView.log(format: "Did click ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)
    }
    
    // MARK: - TDAdRequestDelegate
    
    func adRequest(_ adRequest: TDAdRequest, didFailToLoadWithError error: TDError?) {
        guard let error = error else {
            logView.log(format: "Did fail to load ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)
            return
        }
        var errorString = ""
        errorString += error.localizedDescription
        for network in error.subErrors.keys {
            errorString += "\n    \(network):"
            for subError in error.subErrors[network] ?? [] {
                errorString += "\n      -> \(subError.localizedDescription)"
            }
        }
        
        logView.log(format: "Did fail to load ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, errorString)
    }
    
    // MARK: - TDInterstitialAdRequestDelegate
    
    func didLoad(_ adRequest: TDInterstitialAdRequest) {
        handleDidLoad(adRequest)
    }
    
    func adRequest(_ adRequest: TDInterstitialAdRequest, didFailToDisplayWithError error: TDError?) {
        logView.log(format: "Did fail to display ad unit - %@ tag - %@\nError: %@\n", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, error?.localizedDescription ?? "")
    }
    
    func willDisplay(_ adRequest: TDInterstitialAdRequest) {
        logView.log(format: "Will display ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)
    }
    
    func didDisplay(_ adRequest: TDInterstitialAdRequest) {
        logView.log(format: "Did display ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)
    }
    
    func didClose(_ adRequest: TDInterstitialAdRequest) {
        logView.log(format: "Did close ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)
        update()
    }

    // MARK: - TDRewardedVideoAdRequestDelegate
    func adRequest(_ adRequest: TDInterstitialAdRequest, didValidate reward: TDReward) {
        logView.log(format: "Validated reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Custom JSON:\n%@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? "TRUE" : "FALSE", (reward.customJson as! NSObject ).description)
    }
    
    func adRequest(_ adRequest: TDInterstitialAdRequest, didFailToValidate reward: TDReward) {
        logView.log(format: "Failed to validate reward for ad unit - %@ for tag - %@\nReward:\n    ID: %@\n    Name: %@\n    Amount: %i\n    Is valid: %@\n    Custom JSON:\n%@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, reward.rewardId, reward.name, reward.value, reward.isValid ? "TRUE" : "FALSE", (reward.customJson as! NSObject ).description)
    }
    
    // MARK: - TDNativeAdRequestDelegate
    
    func didLoad(_ adRequest: TDNativeAdRequest) {
        nativeAd = adRequest.nativeAd
        handleDidLoad(adRequest)
    }
    
    // MARK: - TDBannerAdRequestDelegate
    
    func didLoad(_ adRequest: TDBannerAdRequest) {
        bannerView = adRequest.bannerView()
        handleDidLoad(adRequest)
    }
    
    func didRefreshBanner(for adRequest: TDBannerAdRequest) {
        logView.log(format: "Did refresh ad unit - %@ tag - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag)

    }
    
    func didFailToRefreshBanner(for adRequest: TDBannerAdRequest, withError error: TDError?) {
        logView.log(format: "Did fail to refresh ad unit - %@ tag - %@ - %@", NSStringFromAdUnit(adRequest.placement.adUnit), adRequest.placement.tag, error?.localizedDescription ?? "")

    }
    
    // MARK: - Actions
    
    @IBAction func actionButtonInitialise(_ sender: Any) {
        setupTapdaq()
    }
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
        } else if textField === textFieldPlacementTag && selectedAdUnit == .unitBanner {
            textFieldBannerSizeDummy.becomeFirstResponder()
            nativeAd = nil
            bannerView = nil
            hideAdView()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === textFieldDummy {
            pickerViewAdUnit.selectRow(adUnits.firstIndex(of: selectedAdUnit!) ?? 0, inComponent: 0, animated: false)
        } else if textField === textFieldBannerSizeDummy {
            pickerViewAdUnit.selectRow(bannerSizes.firstIndex(of: selectedBannerSize!) ?? 0, inComponent: 0, animated: false)

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
        if pickerView === pickerViewBannerSize {
            return bannerSizes.count
        }
        return adUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === pickerViewBannerSize {
            return NSStringFromBannerSize(bannerSizes[row])
        }
        return NSStringFromAdUnit(adUnits[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === pickerViewBannerSize {
            selectedBannerSize = bannerSizes[row]
        } else if pickerView === pickerViewAdUnit {
            
            selectedAdUnit = adUnits[row]
        }
        update()
    }
}
