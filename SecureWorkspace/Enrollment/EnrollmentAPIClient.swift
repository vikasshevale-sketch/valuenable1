import Foundation
import UIKit

/// REST client for the Valuenable enrollment backend. Implements the
/// OTP-to-IT approval flow (requirement 4): the backend emails the OTP
/// to the IT team's mailbox — never shown in the app — and an IT admin
/// must enter or approve it before the app receives mail credentials
/// and configures IMAP/SMTP.
public final class EnrollmentAPIClient {
    public enum APIError: LocalizedError {
        case invalidResponse
        case http(Int)

        public var errorDescription: String? {
            switch self {
            case .invalidResponse: return "The enrollment service returned an invalid response."
            case let .http(code): return "The enrollment service returned HTTP \(code)."
            }
        }
    }

    private let baseURL: URL
    private let session: URLSession

    public init(endpoint: URL, session: URLSession = .shared) {
        self.baseURL = endpoint
        self.session = session
    }

    // MARK: - Endpoints

    /// Step 1 — user submits the corporate email; the backend emails an
    /// OTP to the IT team's mailbox and returns the pending requestId.
    public func requestEnrollment(corporateEmail: String,
                                   completion: @escaping (Result<String, Error>) -> Void) {
        let body = EnrollRequest(corporateEmail: corporateEmail, device: Self.deviceInfo())
        post("api/enroll", body: body) { (result: Result<EnrollResponse, Error>) in
            completion(result.map { $0.requestId })
        }
    }

    /// Step 2 — the IT admin (physically with the user, or via the admin
    /// console) submits the OTP emailed to the IT mailbox. On approval
    /// the response carries the provisioned mail credentials.
    public func submitOTP(requestId: String, otp: String,
                          completion: @escaping (Result<ApprovalStatus, Error>) -> Void) {
        post("api/approve", body: ["requestId": requestId, "otp": otp]) {
            (result: Result<ApprovalStatus, Error>) in
            completion(result)
        }
    }

    /// Step 2b — poll while waiting for the IT admin to approve from the
    /// admin console instead of typing the OTP in the app.
    public func checkStatus(requestId: String,
                            completion: @escaping (Result<ApprovalStatus, Error>) -> Void) {
        get("api/status/\(requestId)") { (result: Result<ApprovalStatus, Error>) in
            completion(result)
        }
    }


    // MARK: - Plumbing

    private func url(for path: String) -> URL? {
        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: base + "/" + path)
    }

    private func post<Body: Encodable, Response: Decodable>(
        _ path: String, body: Body,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        guard let url = url(for: path) else {
            DispatchQueue.main.async { completion(.failure(APIError.invalidResponse)) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }
        execute(request, completion: completion)
    }

    private func get<Response: Decodable>(
        _ path: String,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        guard let url = url(for: path) else {
            DispatchQueue.main.async { completion(.failure(APIError.invalidResponse)) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        execute(request, completion: completion)
    }

    private func execute<Response: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        session.dataTask(with: request) { data, urlResponse, error in
            let finish: (Result<Response, Error>) -> Void = { result in
                DispatchQueue.main.async { completion(result) }
            }
            if let error { return finish(.failure(error)) }
            guard let http = urlResponse as? HTTPURLResponse else {
                return finish(.failure(APIError.invalidResponse))
            }
            guard (200..<300).contains(http.statusCode), let data else {
                return finish(.failure(APIError.http(http.statusCode)))
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                finish(.success(try decoder.decode(Response.self, from: data)))
            } catch {
                finish(.failure(error))
            }
        }.resume()
    }

    // MARK: - Device info

    static var deviceIdentifier: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    static func deviceInfo() -> EnrollmentDeviceInfo {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        return EnrollmentDeviceInfo(
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            appVersion: appVersion,
            deviceIdentifier: deviceIdentifier
        )
    }
}

    /// Audit events (screenshots, DLP violations, jailbreak hits) are
    /// fire-and-forget: never block the UI on them.
    public func sendAuditEvent(type: String, details: String, corporateEmail: String?) {
        let event = AuditEvent(deviceIdentifier: Self.deviceIdentifier,
                               corporateEmail: corporateEmail,
                               type: type,
                               details: details,
                               timestamp: Date())
        post("api/audit", body: event) { (_: Result<ApprovalStatus, Error>) in }
    }
