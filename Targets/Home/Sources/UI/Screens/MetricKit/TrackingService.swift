//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import MetricKit

// TODO: RND on-going...

public final class TrackingService: NSObject {
    public static let shared = TrackingService()
    
    private let logger = Logger()
    
    override private init() {
        super.init()

        MXMetricManager.shared.add(self)
        
        checkForPayload()
    }
    
    func checkForPayload() {
        logger.log("processPayload: pastDiagnosticPayloads: Size: \(MXMetricManager.shared.pastDiagnosticPayloads.count)")
        logger.log("processPayload: pastPayloads: Size: \(MXMetricManager.shared.pastPayloads.count)")
        
        processPayload(MXMetricManager.shared.pastDiagnosticPayloads)
    }
    
    func processPayload(_ payloads: [MXDiagnosticPayload]) {
        if payloads.isEmpty { return }
        
        var crashes = [String]()
        
        for item in payloads {
            guard let crashDiagnostics = item.crashDiagnostics else { continue }
            
            for crashItem in crashDiagnostics {
                let crashJson = String(decoding: crashItem.jsonRepresentation(), as: UTF8.self)
                
                crashes.append(crashJson)
                
                logger.log("processPayload: crashJson: \(crashJson, privacy: .public)")
            }
        }
        
        if !crashes.isEmpty {
            DiagnosticDataSaver.shared.crashData = crashes
            DiagnosticDataSaver.shared.savedTime = Date().timeIntervalSince1970
        }
    }
}

extension TrackingService: MXMetricManagerSubscriber {
    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
//        guard let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
//            return
//        }
        
        var crashs = [String]()
        
        for item in payloads {
            guard let crashDiagnostics = item.crashDiagnostics else { continue }
            
            for crashItem in crashDiagnostics {
                crashs.append(String(decoding: crashItem.jsonRepresentation(), as: UTF8.self))
            }
        }
        
        DiagnosticDataSaver.shared.crashData = crashs
        DiagnosticDataSaver.shared.savedTime = Date().timeIntervalSince1970
    }
}

// MARK: -

final class DiagnosticDataSaver {
    static let shared = DiagnosticDataSaver()
    
    private let logger = Logger()
    
    private init() {}
    
    private static var defaults: UserDefaults = .standard
    
    private struct UserDefaultsKey {
        private init() {}
        
        static let crashData = "crash_data"
        static let savedTime = "saved_time"
    }
    
    // MARK: Reset methods
    
    func resetAll() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.crashData)
    }
    
    // MARK: Data variables
    
    var crashData: [String]? {
        get {
            guard let jsonData = UserDefaults.standard.data(forKey: UserDefaultsKey.crashData) else {
                return []
            }
            
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([String].self, from: jsonData) as [String] {
                return decoded
            } else {
                return []
            }
        } set(values) {
            guard let values = values else {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKey.crashData)
                UserDefaults.standard.synchronize()
                return
            }
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(values) {
                print("66666")
                UserDefaults.standard.set(encoded, forKey: UserDefaultsKey.crashData)
                
                // Save file in disk
                let documentDirectory = getDocumentsDirectory()
                let crashReportsPath = documentDirectory.appendingPathComponent("crash-reports")
                
                if !FileManager.default.fileExists(atPath: crashReportsPath.path) {
                    do {
                        try FileManager.default.createDirectory(at: crashReportsPath, withIntermediateDirectories: true)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                let filePath = crashReportsPath
                    .appendingPathComponent("\(Date().timeIntervalSince1970)_crash.json", conformingTo: .text)
                
                for item in values {
                    do {
                        try item.write(to: filePath, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error writing crash log: \(error)")
                    }
                }
                // ----
            } else {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKey.crashData)
            }
            
            UserDefaults.standard.synchronize()
            
            logger.log("processPayload: save: \(values.first?.count ?? 0)")
        }
    }
    
    var savedTime: Double? {
        get {
            return UserDefaults.standard.double(forKey: UserDefaultsKey.savedTime)
        } set(value) {
            guard let value = value else {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKey.savedTime)
                UserDefaults.standard.synchronize()
                return
            }
            
            UserDefaults.standard.set(value, forKey: UserDefaultsKey.savedTime)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
