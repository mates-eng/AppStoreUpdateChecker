//
//  StringExtensions.swift
//  AppStoreUpdateChecker
//
//  Created by MTIshiwata on 2019/09/18.
//  Copyright © 2019 Mates Inc. All rights reserved.
//

import Foundation

extension String {
    /// Get localized String
    /// - Returns: Localized String.
    func localized() -> String {
        guard let bundle = Bundle(identifier: "com.mates.AppStoreUpdateChecker") else { return self }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, comment: self)
    }
}
