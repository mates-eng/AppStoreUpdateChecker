//
//  AppStoreUpdateCheckerLocalizedStringKeys.swift
//  AppStoreUpdateChecker
//
//  Created by MTIshiwata on 2019/09/18.
//  Copyright © 2019 Mates Inc. All rights reserved.
//

import Foundation

/// Localized String cases.
enum AppStoreUpdateCheckerLocalizedStringKeys: String {
    case confirm = "Confirm"
    case okButton = "OK"
    case newAppVersionMessage = "NewAppVersionMessage"
    func localized() -> String {
        return self.rawValue.localized()
    }
}
