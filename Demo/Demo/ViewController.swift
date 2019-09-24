//
//  ViewController.swift
//  Demo
//
//  Created by MTIshiwata on 2019/09/24.
//  Copyright © 2019 Mates Inc. All rights reserved.
//

import UIKit
import AppStoreUpdateChecker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Any Bundle Identifer
        AppStoreUpdateChecker.check(setBundleID: "com.apple.itunesu") { updateURL in
            print("`\(String(describing: updateURL))")
        }
        
//      Use Your App Bundle Identifer
//        AppStoreUpdateChecker.check { updateURL in
//            print("`\(String(describing: updateURL))")
//        }
    }


}

//28179
