//
//  AppStoreUpdateChecker.swift
//  AppStoreUpdateChecker
//
//  Created by MTIshiwata on 2019/09/13.
//  Copyright © 2019 Mates Inc. All rights reserved.
//

import UIKit

public class AppStoreUpdateChecker {
    
    /// Check the Bundle Identifier of the calling Project and show an alert when the update is needed.
    /// - Parameter setBundleID: When using any bundle identifier.
    /// - Parameter setAppVersion: When using any app version.
    /// - Parameter completion: The closure is executed when "OK" is tapped on the alert. Returns the URL to update.
    static public func check(setBundleID: String? = nil, setAppVersion: String? = nil, completion: ( (_ appUpdateURL: URL?) -> Void )? ) {
        if setBundleID != nil {
            self.setBundleID = setBundleID
        }
        if setAppVersion != nil {
            self.setAppVersion = setAppVersion
        }
        updateCheckWith { (isUpdate, appUpdateURL) in
            guard isUpdate else { completion?(nil); return }
            DispatchQueue.main.async {
                self.showAlert {
                    completion?(appUpdateURL)
                }
            }
        }
    }
}

private extension AppStoreUpdateChecker {
    /// Any bundle identifier.
    static var setBundleID: String?
    /// Any app version.
    static var setAppVersion: String?
    /// Request timeout constant.
    static let defaultTimeOutIntervalForRequest = 30.0
    /// Response timeout constant.
    static let defaultTimeOutIntervalForResouse = 30.0
    /// Maximum connection constant per host.
    static let httpMaximumConnectionPerHost = 1
    
    /// Get the Bundle Identifier.
    /// - Returns: The Bundle Identifier of the calling Project
    static func checkBundleID() -> String? {
        if setBundleID != nil {
            return setBundleID
        }
        guard let infoDictionary = Bundle.main.infoDictionary else { return nil }
        let bundleID = infoDictionary["CFBundleIdentifier"] as? String
        return bundleID
    }
    
    /// Get the app version.
    /// - Returns: The app version of the calling Project.
    static func checkAppVersion() -> String? {
        if setAppVersion != nil {
            return setAppVersion
        }
        guard let infoDictionary = Bundle.main.infoDictionary else { return nil }
        let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String
        return currentVersion
    }
    
    /// Get JSON URL for AppStore.
    /// - Returns: URL for JSON.
    static func checkURL() -> URL? {
        guard let myBundleID = checkBundleID() else { return nil }
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(myBundleID)&country=JP"
        let url = URL(string: urlString)
        return url
    }
    
    /// Get results on connection to fixes URL.
    /// - Parameter completion: Check updated and return update URL.
    ///                         If the method fails, it will set false to isUpdate and nil to appUpdateURL.
    static func updateCheckWith(completion: @escaping (_ isUpdate: Bool, _ appUpdateURL: URL?) -> Void) {
        guard let checkURL = checkURL() else { completion(false, nil); return }
        connectionWith(url: checkURL, completion: completion)
    }
    
    /// Default session configs.
    static var defaultSessionConfigration: URLSessionConfiguration {
        let sessionConfigration = URLSessionConfiguration.default
        sessionConfigration.timeoutIntervalForRequest = defaultTimeOutIntervalForRequest
        sessionConfigration.timeoutIntervalForResource = defaultTimeOutIntervalForResouse
        sessionConfigration.httpMaximumConnectionsPerHost = httpMaximumConnectionPerHost
        sessionConfigration.networkServiceType = .default
        return sessionConfigration
    }
    
    /// If the connection has an error, output log.
    /// - Parameter url: Update URL.
    /// - Parameter completion: Check updated and return update URL.
    ///                         If the method fails, it will set false to isUpdate and nil to appUpdateURL.
    static func connectionWith(url: URL, completion: @escaping (_ isUpdate: Bool, _ appUpdateURL: URL?) -> Void) {
        let session =  URLSession(configuration: defaultSessionConfigration)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            defer { session.finishTasksAndInvalidate() }
            let errorCompletion = { completion(false, nil) }
            guard error == nil else {
                print("AppStoreUpdateChecker: Error ->")
                dump(error)
                errorCompletion()
                return
            }
            responseCodeCheck(response: response, completion: completion)
            guard let checkData = data else {
                print("AppStoreUpdateChecker: Data is nil")
                errorCompletion()
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: checkData, options: .mutableContainers)
                guard let responseDictionary = jsonObject as? [String: Any] else {
                    print("AppStoreUpdateChecker: Not in JSON format")
                    errorCompletion()
                    return
                }
                analyze(with: responseDictionary, completion: completion)
            } catch {
                print("AppStoreUpdateChecker:Data error")
                completion(false, nil)
            }
        }
        task.resume()
    }
    /// Checking on response code.
    /// If the response code is “3xx”, out put log.
    /// If the response code is “4xx” or “5xx”, out put log and error.
    /// - Parameter response: response data
    /// - Parameter completion: Check updated and return update URL.
    ///                         If the method fails, it will set false to isUpdate and nil to appUpdateURL.
    static func responseCodeCheck(response: URLResponse?,
                                  completion: @escaping (_ isUpdate: Bool, _ appUpdateURL: URL?) -> Void) {
        guard let httpURLResponse = response as? HTTPURLResponse else { return }
        let statusCode = httpURLResponse.statusCode
        let statusErrorCompletion = {
            print("AppStoreUpdateChecker: Status -> \(statusCode)")
            completion(false, nil)
        }
        switch statusCode {
        case 300 ... 308:
            print("AppStoreUpdateChecker: Status -> \(statusCode)")
        case 400 ... 451:
            print("AppStoreUpdateChecker: Clinent Error")
            statusErrorCompletion()
        case 500 ... 511:
            print("AppStoreUpdateChecker: Server Error")
            statusErrorCompletion()
        default:
            break
        }
    }
    
    /// Analyze the response data.
    /// If the dictionary has the value of "resultCount" key and the value is over 0, the method will continue.
    /// If the dictionary has the value of “result” key and the first element of the value has the value of “version” key, the method will continue.
    /// - Parameter dictionay: JSON parsed ddictionary.
    /// - Parameter completion: Check updated and return update URL.
    ///                         if it failed return false on isUpdate and nil on appdateURL.
    static func analyze(with dictionary: [String: Any],
                        completion: @escaping (_ isUpdate: Bool, _ appUpdateURL: URL?) -> Void) {
        let errorCompletion = { completion(false, nil) }
        let resultCountValue = dictionary["resultCount"] as? Int
        guard resultCountValue ?? 0 > 0 else {
            print("AppStoreUpdateChecker: Does not exist in AppStore")
            errorCompletion()
            return
        }
        let results = dictionary["results"] as? [Any]
        let result = results?.first as? [String: Any]
        guard let checkedVersion = result?["version"] as? String else {
            errorCompletion()
            return
        }
        let updatePath = result?["trackViewUrl"] as? String
        checkVersion(with: checkedVersion, updatePath: updatePath, completion: completion)
    }
    
    /// If the version of the App on App Store is not latest, the method will set the update info.
    /// - Parameter checkVersion: is appversion
    /// - Parameter updatePath: update URL.
    /// - Parameter completion: Check updated and return update URL.
    ///                         If the method fails, it will set false to isUpdate and nil to appdateURL.
    static func checkVersion(with checkedVersion: String, updatePath: String?,
                             completion: @escaping (_ isUpdate: Bool, _ appUpdateURL: URL?) -> Void) {
        let errorCompletion = { completion(false, nil) }
        guard let bundleVersionCompare = checkAppVersion()?.compare(checkedVersion, options: .numeric) else {
            print("AppStoreUpdateChecker: ")
            errorCompletion()
            return
        }
        switch bundleVersionCompare {
        case .orderedSame, .orderedDescending:
            print("AppStoreUpdateChecker: This app is latest")
            errorCompletion()
        case .orderedAscending:
            guard var updatePath = updatePath else {
                print("AppStoreUpdateChecker: Path does not exist")
                errorCompletion()
                return
            }
            updatePath = updatePath.replacingOccurrences(of: "&uo=4", with: "")
            let appURL = URL(string: updatePath)
            completion(true, appURL)
        }
    }
    
    /// Display alert
    /// - Parameter completion: If the button on the alert is tapped, the method will execute closure.
    static func showAlert(_ completion: ( () -> Void )? ) {
        let alertController = UIAlertController(
            title: AppStoreUpdateCheckerLocalizedStringKeys.confirm.localized(),
            message: AppStoreUpdateCheckerLocalizedStringKeys.newAppVersionMessage.localized(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
            title: AppStoreUpdateCheckerLocalizedStringKeys.okButton.localized(),
            style: .default,
            handler: { _ in
                completion?()
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
