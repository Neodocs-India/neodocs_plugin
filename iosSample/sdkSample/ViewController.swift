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
        // Do any additional setup after loading the view.
        
        if let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine {
            GeneratedPluginRegistrant.register(with: flutterEngine);
            methodChannel = FlutterMethodChannel(name: "app.channel.neodocs/native",
                                                 binaryMessenger: flutterEngine.binaryMessenger)
            methodChannel?.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                // Note: this method is invoked on the UI thread.
                if call.method == "getExtraData"  {
                    self?.getExtraData(result: result)
                } else if call.method == "nativeCallback"{
                    self?.nativeCallback(call: call)
                } else{
                    result(FlutterMethodNotImplemented)
                }
                
            })
        }
        
        let button = UIButton(type:UIButton.ButtonType.custom)
        
        button.addTarget(self, action: #selector(startTestView), for: .touchUpInside)
        button.setTitle("Start test", for: UIControl.State.normal)
        button.frame = CGRect(x: 80.0, y: 210.0, width: 160.0, height: 40.0)
        button.center = self.view.center
        button.backgroundColor = UIColor.blue
        
        self.view.addSubview(button)
    }
    
    @objc func startTestView(_ sender: UIButton) {
        let flutterEngine = ((UIApplication.shared.delegate as? AppDelegate)?.flutterEngine)!;
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil);
        
        flutterViewController.modalPresentationStyle = .fullScreen
        self.present(flutterViewController, animated: true, completion: nil)
        
    }
    
    private func getExtraData(result: FlutterResult){
        var args = [String: String]()
        args["userId"] = "iosUser"
        args["firstName"] = "firstName"
        args["lastName"] = "lastName"
        args["gender"] = "gender"
        args["dateOfBirth"] = "1651047119"
        args["apiKey"] = "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0"
        
        result(args)
    }
    
    private func nativeCallback(call: FlutterMethodCall){
        if let args = call.arguments as? Dictionary<String, Any>,
           let status = args["status"] as? String{
            if(status == "0"){
                // user exited from the process
                //args["data"] has details of the test if required
            }else if(status == "200"){
                //test complete with result
                //args["data"]
            } else{
                //test complete wait error
                //args["data"]
            }
            print(args);
        }
    
    }
    
    
    
}

