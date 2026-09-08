import LocalAuthentication

final class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access valuenable.in workspace."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    completion(success, authError)
                }
            }
        } else {
            completion(false, error)
        }
    }
}