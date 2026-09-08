import UIKit

final class JailbreakDetector {
    static var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/usr/bin/ssh"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) { return true }
        }
        
        if let file = fopen("/bin/bash", "r") {
            fclose(file)
            return true
        }
        
        let testString = "Jailbreak Test"
        do {
            try testString.write(toFile: "/private/jailbreak.test", atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: "/private/jailbreak.test")
            return true
        } catch {
            return false
        }
        #endif
    }
}