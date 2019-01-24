//
//  ViewController.swift
//  NativeAdsSwift
//
//  Created by Nick Reffitt on 16/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

import UIKit
import Tapdaq

class ViewController: UIViewController, TapdaqDelegate {
   
    @IBOutlet var loadNativeAdBtn: UIButton!
    @IBOutlet var showNativeAdBtn: UIButton!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textView: UITextView!
    
    var nativeAdvert: TDNativeAdvert?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tapdaq.sharedSession().delegate = self
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapAdvert(sender:)))
        singleTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showDebugger(_ sender: Any?) {
        Tapdaq.sharedSession().presentDebugViewController()
    }
    
    @IBAction func loadNativeAd(sender: UIButton) {
        
        removeNativeTapdaqAdvert()
        
        Tapdaq.sharedSession().loadNativeAdvert(forPlacementTag: TDPTagDefault, adType: TDNativeAdType.type1x1Large)
    
    }
    
    @IBAction func showNativeAd(sender: UIButton) {
        
        if let nativeAd: TDNativeAdvert = Tapdaq.sharedSession().getNativeAdvert(forPlacementTag: TDPTagDefault, adType: TDNativeAdType.type1x1Large) {
            
            imageView.image = (nativeAd.creative as? TDImageCreative)?.image
            imageView.setNeedsDisplay()
            
            Tapdaq.sharedSession().triggerImpression(nativeAd)
            
            nativeAdvert = nativeAd
            showNativeAdBtn.isEnabled = true
            
        }
        
    }
    
    @IBAction func tapAdvert(sender: UIButton) {
        
        if let nativeAd: TDNativeAdvert = nativeAdvert {
            Tapdaq.sharedSession().triggerClick(nativeAd)
        }
        
    }
    
    private func logMessage(message: String) {
        
        let text: String = textView!.text
        let textAddition: String = message + "\n\n" + text
        textView!.text = textAddition
        
        print("NativeAds App: " + message)
    }
    
    private func removeNativeTapdaqAdvert() {
        imageView.image = nil
        imageView.setNeedsDisplay()
        nativeAdvert = nil
    }
    
    // TapdaqDelegate
    
    func didLoadConfig() {
        loadNativeAdBtn.isEnabled = true
        
        logMessage(message: "didLoadConfig()")
    }
    
    func didFailToLoadConfig() {
        logMessage(message: "didFailToLoadConfig()")
    }
    
    func didLoadNativeAdvert(forPlacementTag placementTag: String!, adType nativeAdType: TDNativeAdType) {
        
        if placementTag == TDPTagDefault && nativeAdType == TDNativeAdType.type1x1Large {
            showNativeAdBtn.isEnabled = true
        }
        
        logMessage(message: "didLoadNativeAdvert(forPlacementTag \(placementTag!), adType \(nativeAdTypeString(givenNativeAdType: nativeAdType)))")
    }
    
    func didFailToLoadNativeAdvert(forPlacementTag placementTag: String!, adType nativeAdType: TDNativeAdType) {
        logMessage(message: "didFailToLoadNativeAdvert(forPlacementTag \(placementTag!), adType \(nativeAdTypeString(givenNativeAdType: nativeAdType)))")
    }
    
    private func nativeAdTypeString(givenNativeAdType nativeAdType: TDNativeAdType) -> String {
        
        var nativeAdTypeStr : String = kNativeAdTypeUnknown
        
        if nativeAdType == TDNativeAdType.type1x1Large {
            nativeAdTypeStr = kNativeAdType1x1Large;
        } else if nativeAdType == TDNativeAdType.type1x1Medium {
            nativeAdTypeStr = kNativeAdType1x1Medium;
        } else if nativeAdType == TDNativeAdType.type1x1Small {
            nativeAdTypeStr = kNativeAdType1x1Small;
        } else if nativeAdType == TDNativeAdType.type1x2Large {
            nativeAdTypeStr = kNativeAdType1x2Large;
        } else if nativeAdType == TDNativeAdType.type1x2Medium {
            nativeAdTypeStr = kNativeAdType1x2Medium;
        } else if nativeAdType == TDNativeAdType.type1x2Small {
            nativeAdTypeStr = kNativeAdType1x2Small;
        } else if nativeAdType == TDNativeAdType.type2x1Large {
            nativeAdTypeStr = kNativeAdType2x1Large;
        } else if nativeAdType == TDNativeAdType.type2x1Medium {
            nativeAdTypeStr = kNativeAdType2x1Medium;
        } else if nativeAdType == TDNativeAdType.type2x1Small {
            nativeAdTypeStr = kNativeAdType2x1Small;
        } else if nativeAdType == TDNativeAdType.type2x3Large {
            nativeAdTypeStr = kNativeAdType2x3Large;
        } else if nativeAdType == TDNativeAdType.type2x3Medium {
            nativeAdTypeStr = kNativeAdType2x3Medium;
        } else if nativeAdType == TDNativeAdType.type2x3Small {
            nativeAdTypeStr = kNativeAdType2x3Small;
        } else if nativeAdType == TDNativeAdType.type3x2Large {
            nativeAdTypeStr = kNativeAdType3x2Large;
        } else if nativeAdType == TDNativeAdType.type3x2Medium {
            nativeAdTypeStr = kNativeAdType3x2Medium;
        } else if nativeAdType == TDNativeAdType.type3x2Small {
            nativeAdTypeStr = kNativeAdType3x2Small;
        } else if nativeAdType == TDNativeAdType.type1x5Large {
            nativeAdTypeStr = kNativeAdType1x5Large;
        } else if nativeAdType == TDNativeAdType.type1x5Medium {
            nativeAdTypeStr = kNativeAdType1x5Medium;
        } else if nativeAdType == TDNativeAdType.type1x5Small {
            nativeAdTypeStr = kNativeAdType1x5Small;
        } else if nativeAdType == TDNativeAdType.type5x1Large {
            nativeAdTypeStr = kNativeAdType5x1Large;
        } else if nativeAdType == TDNativeAdType.type5x1Medium {
            nativeAdTypeStr = kNativeAdType5x1Medium;
        } else if nativeAdType == TDNativeAdType.type5x1Small {
            nativeAdTypeStr = kNativeAdType5x1Small;
        }
        
        return nativeAdTypeStr
        
    }

}

