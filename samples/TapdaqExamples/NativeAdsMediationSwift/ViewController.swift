//
//  ViewController.swift
//  NativeAdsMediationSwift
//
//  Created by Dmitry Dovgoshliubnyi on 03/04/2018.
//  Copyright © 2018 Tapdaq. All rights reserved.
//

import UIKit
import Tapdaq

class ViewController: UIViewController {
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var callToActionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var socialContextLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    @IBOutlet weak var smallAdView: UIView!
    @IBOutlet weak var smallIconImageView: UIImageView!
    @IBOutlet weak var smallTitleLabel: UILabel!
    @IBOutlet weak var smallSubtitleLabel: UILabel!
    @IBOutlet weak var smallStarsLabel: UILabel!
    @IBOutlet weak var smallCallToActionButton: UIButton!
    
    @IBOutlet weak var loadLargeAdButton: UIButton!
    
    @IBOutlet weak var loadSmallAdButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let placement = TDPlacement(adTypes: [ .typeMediatedNative ], forTag: TDPTagDefault)
        let placementMainMenu = TDPlacement(adTypes: [ .typeMediatedNative ], forTag: "main_menu")
        let properties = TDProperties()
        properties.register(placement)
        
        properties.register(placementMainMenu)
        properties.logLevel = .debug
        Tapdaq.sharedSession().delegate = self
        Tapdaq.sharedSession().setApplicationId(kAppId, clientKey: kClientKey, properties: properties)
        
        
        adView.layer.shadowColor = UIColor.black.cgColor
        adView.layer.shadowOffset = CGSize(width: 1, height: 1)
        adView.layer.shadowOpacity = 0.12
        adView.layer.shadowRadius = 5
        
        smallAdView.layer.shadowColor = UIColor.black.cgColor
        smallAdView.layer.shadowOffset = CGSize(width: 1, height: 1)
        smallAdView.layer.shadowOpacity = 0.12
        smallAdView.layer.shadowRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loadLargeAd(_ sender: Any) {
        Tapdaq.sharedSession().loadNativeAd(in: self, placementTag:TDPTagDefault, options: TDMediatedNativeAdOptions.adChoicesBottomRight, delegate: self)
    }
    
    @IBAction func loadSmallAd(_ sender: Any) {
        Tapdaq.sharedSession().loadNativeAd(in: self, placementTag:"main_menu", options: TDMediatedNativeAdOptions.adChoicesTopRight, delegate: self)
    }
    
}
extension ViewController: TapdaqDelegate {
    func didLoadConfig() {
        self.loadSmallAdButton.isEnabled = true
        self.loadLargeAdButton.isEnabled = true
    }
    
    func didFailToLoadConfigWithError(_ error: TDError!) {
        print("Failed to load config: \(error?.localizedDescription ?? "unknown")")
    }
}

extension ViewController: TDAdRequestDelegate {
    func didLoad(_ adRequest: TDAdRequest) {
        if let nativeRequest = adRequest as? TDNativeAdRequest {
            if let nativeAd = nativeRequest.nativeAd {
                if adRequest.placement.tag == TDPTagDefault {
                    adView.isHidden = false
                    nativeAd.setAdView(adView)
                    nativeAd.register(callToActionButton, type: .callToAction)
                    nativeAd.register(titleLabel, type: .headline)
                    nativeAd.register(iconImageView, type: .logo)
                    nativeAd.register(imageView, type: .imageView)
                    nativeAd.register(priceLabel, type: .price)
                    nativeAd.register(starsLabel, type: .starRating)
                    nativeAd.register(subtitleLabel, type: .subtitle)
                    nativeAd.icon?.getAsyncImage({ (iconImage) in
                        self.iconImageView.image = iconImage
                    })
                    nativeAd.images?.first?.getAsyncImage({ (image) in
                        self.imageView.image = image
                    })
                    titleLabel.text = nativeAd.title
                    subtitleLabel.text = nativeAd.subtitle
                    bodyLabel.text = nativeAd.body
                    priceLabel.text = nativeAd.price
                    socialContextLabel.text = nativeAd.socialContext
                    callToActionButton.isHidden = nativeAd.callToAction == nil
                    callToActionButton.isUserInteractionEnabled = false
                    callToActionButton.setTitle("  \(nativeAd.callToAction ?? "")  ", for: .normal)
                    starsLabel.text = "\(nativeAd.starRating == nil ? "" : "\(nativeAd.starRating!) Stars")"
                    nativeAd.trackImpression()
                    
                    
                } else if adRequest.placement.tag == "main_menu" {
                    smallAdView.isHidden = false
                    nativeAd.setAdView(smallAdView)
                    nativeAd.register(smallCallToActionButton, type: .callToAction)
                    nativeAd.register(smallTitleLabel, type: .headline)
                    nativeAd.register(smallIconImageView, type: .logo)
                    nativeAd.register(smallSubtitleLabel, type: .subtitle)
                    smallTitleLabel.text = nativeAd.title
                    smallSubtitleLabel.text = nativeAd.subtitle
                    nativeAd.icon?.getAsyncImage({ (iconImage) in
                        self.smallIconImageView.image = iconImage
                    })
                    smallCallToActionButton.isHidden = nativeAd.callToAction == nil
                    smallCallToActionButton.isUserInteractionEnabled = false
                    smallCallToActionButton.setTitle("  \(nativeAd.callToAction ?? "")  ", for: .normal)
                    nativeAd.trackImpression()
                }
            }
        }
    }
    
    func adRequest(_ adRequest: TDAdRequest, didFailToLoadWithError error: TDError?) {
        print("Failed to load an ad: \(error?.localizedDescription ?? "unknown")")
    }
}
