import Foundation

final class SandboxedFileManager {
    static let shared = SandboxedFileManager()
    private let secureDirectory: URL

    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        secureDirectory = paths[0].appendingPathComponent("EncryptedWorkspaceTemp", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: secureDirectory, withIntermediateDirectories: true)
        try? (secureDirectory as NSURL).setResourceValue(URLFileProtection.complete, forKey: .fileProtectionKey)
    }

    func saveTemporaryAttachment(data: Data, fileName: String) -> URL? {
        let targetURL = secureDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: targetURL, options: .completeFileProtection)
            return targetURL
        } catch {
            return nil
        }
    }

    func purgeTemporaryFiles() {
        try? FileManager.default.removeItem(at: secureDirectory)
        try? FileManager.default.createDirectory(at: secureDirectory, withIntermediateDirectories: true)
    }
}