//
//  ViewController.swift
//  sdkSample
//
//  Created by Avinash Joshi on 28/04/22.
//

import UIKit
import Flutter
// Used to connect plugins (only if you have plugins with iOS platform code).
import FlutterPluginRegistrant

class ViewController: UIViewController {
    
    var methodChannel : FlutterMethodChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type:UIButton.ButtonType.custom)
        
        button.addTarget(self, action: #selector(startTestView), for: .touchUpInside)
        button.setTitle("Start VC", for: UIControl.State.normal)
        button.frame = CGRect(x: 80.0, y: 210.0, width: 160.0, height: 40.0)
        button.center = self.view.center
        button.backgroundColor = UIColor.blue
        
        self.view.addSubview(button)
    }
    
    @objc func startTestView(_ sender: UIButton) {
        let vc = NewVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:nil)
    }
    
}

