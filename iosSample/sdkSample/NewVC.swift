//
//  NewVC.swift
//  sdkSample
//
//  Created by Avinash Joshi on 14/05/22.
//


import Flutter
import FlutterPluginRegistrant
import Foundation

class NewVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type:UIButton.ButtonType.custom)
        
        button.addTarget(self, action: #selector(startTestView), for: .touchUpInside)
        button.setTitle("Start test", for: UIControl.State.normal)
        button.frame = CGRect(x: 80.0, y: 210.0, width: 160.0, height: 40.0)
        button.center = self.view.center
        button.backgroundColor = UIColor.blue
        
        self.view.addSubview(button)
    }
    
    @objc func startTestView(_ sender: UIButton) {
        let vc = FlutterVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)        
    }
    
}
