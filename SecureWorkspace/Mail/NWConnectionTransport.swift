import Foundation
import Network

/// A strict sequential line/byte reader over a TLS `NWConnection`.
/// Used by `SecureIMAPSession` and `SecureSMTPSession`.
///
/// All completion handlers fire on the connection's private queue, so
/// the protocol sessions can chain their next command synchronously
/// without any race conditions. A watchdog cancels the connection when
/// an operation exceeds the configured timeout.
final class NWConnectionTransport {
    enum TransportError: Error {
        case connectionFailed(String)
        case timedOut
        case closed
    }

    private enum PendingRead {
        case line((Result<String, Error>) -> Void)
        case bytes(Int, (Result<Data, Error>) -> Void)
    }

    private let connection: NWConnection
    private let queue: DispatchQueue
    private let timeout: TimeInterval

    private var buffer = Data()
    private var pending: [PendingRead] = []
    private var isReceiving = false
    private var isClosed = false
    private var didCallReady = false
    private var timeoutWork: DispatchWorkItem?

    init(host: String, port: UInt16, timeout: TimeInterval = 45) {
        self.connection = NWConnection(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(rawValue: port) ?? 993,
            using: NWParameters.tls
        )
        self.queue = DispatchQueue(label: "in.valuenable.transport.\(UUID().uuidString)")
        self.timeout = timeout
    }

    // MARK: - Connection lifecycle

    func start(completion: @escaping (Error?) -> Void) {
        connection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                guard !self.didCallReady else { return }
                self.didCallReady = true
                completion(nil)
            case let .failed(error):
                self.isClosed = true
                self.failAllPending(with: .connectionFailed(error.localizedDescription))
                if !self.didCallReady {
                    self.didCallReady = true
                    completion(TransportError.connectionFailed(error.localizedDescription))
                }
            case .cancelled:
                self.isClosed = true
                self.failAllPending(with: .closed)
            default:
                break
            }
        }
        connection.start(queue: queue)
    }

    func cancel() {
        isClosed = true
        connection.cancel()
    }

    // MARK: - Writes

    func write(_ data: Data, completion: @escaping (Error?) -> Void) {
        connection.send(content: data) { error in
            if let error {
                completion(TransportError.connectionFailed(error.localizedDescription))
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - Reads

    func readLine(completion: @escaping (Result<String, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            self.pending.append(.line(completion))
            self.drainPending()

    // MARK: - Internals (connection queue only)

    private func drainPending() {
        while !pending.isEmpty {
            guard let first = pending.first else { return }
            switch first {
            case let .line(completion):
                guard let (range, lineLength) = firstNewlineRange() else {
                    if isClosed { return failFirst(TransportError.closed) }
                    armTimeout()
                    receiveMore()
                    return
                }
                let lineData = buffer.subdata(in: range)
                buffer.removeFirst(lineLength)
                disarmTimeout()
                pending.removeFirst()
                completion(.success(Self.string(from: lineData)))
            case let .bytes(count, completion):
                guard buffer.count >= count else {
                    if isClosed { return failFirst(TransportError.closed) }
                    armTimeout()
                    receiveMore()
                    return
                }
                let chunk = Data(buffer.prefix(count))
                buffer.removeFirst(count)
                disarmTimeout()
                pending.removeFirst()
                completion(.success(chunk))
            }
        }
    }

    private func failFirst(_ error: Error) {
        guard let first = pending.first else { return }
        pending.removeFirst()
        switch first {
        case let .line(completion): completion(.failure(error))
        case let .bytes(_, completion): completion(.failure(error))
        }
    }

    private func failAllPending(with error: Error) {
        disarmTimeout()
        while !pending.isEmpty { failFirst(error) }
    }

    /// Range covering everything before the first CRLF (or bare LF for
    /// leniency), plus the number of bytes the line ending occupies.
    private func firstNewlineRange() -> (Range<Data.Index>, Int)? {
        if let range = buffer.firstRange(of: Data([0x0D, 0x0A])) {
            return (range, range.count + 2)
        }
        if let range = buffer.firstRange(of: Data([0x0A])) {
            return (range, range.count + 1)
        }
        return nil
    }

    private func receiveMore() {
        guard !isReceiving, !isClosed else { return }
        isReceiving = true
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            self.isReceiving = false
            if let data, !data.isEmpty { self.buffer.append(data) }
            if error != nil || isComplete { self.isClosed = true }
            self.drainPending()
        }
    }

    private func armTimeout() {
        timeoutWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, !self.isClosed else { return }
            self.disarmTimeout()
            self.isClosed = true
            self.connection.cancel()
            self.failAllPending(with: TransportError.timedOut)
        }
        timeoutWork = work
        queue.asyncAfter(deadline: .now() + timeout, execute: work)
    }

    private func disarmTimeout() {
        timeoutWork?.cancel()
        timeoutWork = nil
    }

    private static func string(from data: Data) -> String {
        String(data: data, encoding: .utf8)
            ?? String(data: data, encoding: .isoLatin1)
            ?? ""
    }
}

        }
    }

    func readBytes(_ count: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            self.pending.append(.bytes(count, completion))
            self.drainPending()
        }
    }
