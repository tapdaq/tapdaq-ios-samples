//
//  ViewController.swift
//  MoreAppsSwift
//
//  Created by Nick Reffitt on 16/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

import UIKit
import Tapdaq

class ViewController: UIViewController, TapdaqDelegate {

    @IBOutlet var loadMoreAppsBtn: UIButton!
    @IBOutlet var showMoreAppsBtn: UIButton!
    
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tapdaq.sharedSession().delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showDebugger(_ sender: Any?) {
        Tapdaq.sharedSession().presentDebugViewController()
    }
    
    @IBAction func loadMoreApps(sender: UIButton) {
        /**
         * You can either load the more apps popup like this:
         *
         * Tapdaq.sharedSession().loadMoreApps()
         *
         * Or you can pass in a custom config to style the more apps popup, like so:
         */
        
        Tapdaq.sharedSession().loadMoreApps(with: customMoreAppsConfig())
    }
    
    @IBAction func showMoreApps(sender: UIButton) {
        
        let isReady: Bool = Tapdaq.sharedSession().isMoreAppsReady()
        
        if isReady {
            Tapdaq.sharedSession().showMoreApps()
        }
        
    }
    
    private func logMessage(message: String) {
        
        let text: String = textView!.text
        let textAddition: String = message + "\n\n" + text
        textView!.text = textAddition
        
        print("MoreApps App: " + message)
    }
    
    private func customMoreAppsConfig() -> TDMoreAppsConfig {
        
        let moreAppsConfig: TDMoreAppsConfig = TDMoreAppsConfig.init();
        
        moreAppsConfig.headerText = "More Games";
        moreAppsConfig.installedAppButtonText = "Play";
  
        moreAppsConfig.headerTextColor = UIColor.white
        moreAppsConfig.headerColor = UIColor.init(red: 3.0 / 255.0, green: 3.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0)
        
        moreAppsConfig.headerCloseButtonColor = UIColor.init(red:235.0 / 255.0, green:73.0 / 255.0, blue:77.0 / 255.0, alpha:1.0)
        moreAppsConfig.backgroundColor = UIColor.init(red:33.0 / 255.0, green:33.0 / 255.0, blue:33.0 / 255.0, alpha:1.0)
        
        moreAppsConfig.appNameColor = UIColor.white
        moreAppsConfig.appButtonColor = UIColor.init(red:59.0 / 255.0, green:133.0 / 255.0, blue:37.0 / 255.0, alpha:1.0)
        moreAppsConfig.appButtonTextColor = UIColor.white
        moreAppsConfig.installedAppButtonColor = UIColor.init(red:40.0 / 255.0, green:90.0 / 255.0, blue:245.0 / 255.0, alpha:1.0);
        moreAppsConfig.installedAppButtonTextColor = UIColor.white
        
        return moreAppsConfig;
        
    }
    
    // TapdaqDelegate
    
    func didLoadConfig() {
        loadMoreAppsBtn.isEnabled = true
        
        logMessage(message: "didLoadConfig()")
    }
    
    func didFailToLoadConfig() {
        logMessage(message: "didFailToLoadConfig()")
    }
    
    func didLoadMoreApps() {
        showMoreAppsBtn.isEnabled = true
        logMessage(message: "didLoadMoreApps()")
    }
    
    func didFailToLoadMoreApps() {
        logMessage(message: "didFailToLoadMoreApps()")
    }

    func willDisplayMoreApps() {
        logMessage(message: "willDisplayMoreApps()")
    }
    
    func didDisplayMoreApps() {
        showMoreAppsBtn.isEnabled = false
        logMessage(message: "didDisplayMoreApps()")
    }
    
    func didCloseMoreApps() {
        logMessage(message: "didCloseMoreApps()")
    }
    
}

