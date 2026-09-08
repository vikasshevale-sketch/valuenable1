import LocalAuthentication

final class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Biometric authentication required to unlock valuenable.in workspace."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    completion(success, authError)
                }
            }
        } else {
            // Biometrics not set or unavailable on device/simulator
            completion(true, nil)
        }
    }
}