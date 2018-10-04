//
//  ViewController.swift
//  InterstitialOnBootupSwift
//
//  Created by Nick Reffitt on 16/05/2017.
//  Copyright © 2017 Tapdaq. All rights reserved.
//

import UIKit
import Tapdaq

class ViewController: UIViewController, TapdaqDelegate {
    
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(receivedLog(_:)), name: NSNotification.Name("TapdaqLogMessageNotification"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func receivedLog(_ notification: NSNotification) {
        guard let message = notification.userInfo?["message"] as? String else {
            return
        }
        
        let text: String = textView.text
        let textAddition: String = message + "\n\n" + text
        textView.text = textAddition
    }
    
    @IBAction func showDebugger(_ sender: Any?) {
        Tapdaq.sharedSession().presentDebugViewController()
    }

    
}

