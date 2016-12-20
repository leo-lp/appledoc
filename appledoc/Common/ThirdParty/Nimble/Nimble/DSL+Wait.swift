import Foundation

/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
internal class NMBWait: NSObject {
    private lazy var __once: () = {
                DispatchQueue.main.async {
                    action() { completed = true }
                }
            }()
    internal class func until(timeout: TimeInterval, file: String = #file, line: UInt = #line, action: (() -> Void) -> Void) -> Void {
        var completed = false
        var token: Int = 0
        let result = pollBlock(pollInterval: 0.01, timeoutInterval: timeout) {
            _ = self.__once
            return completed
        }
        switch (result) {
        case .failure:
            let pluralize = (timeout == 1 ? "" : "s")
            fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
        case .timeout:
            fail("Stall on main thread - too much enqueued on main run loop before waitUntil executes.", file: file, line: line)
        case let .errorThrown(error):
            // Technically, we can never reach this via a public API call
            fail("Unexpected error thrown: \(error)", file: file, line: line)
        case .success:
            break
        }
    }

    @objc(untilFile:line:action:)
    internal class func until(_ file: String = #file, line: UInt = #line, action: (() -> Void) -> Void) -> Void {
        until(timeout: 1, file: file, line: line, action: action)
    }
}

/// Wait asynchronously until the done closure is called.
///
/// This will advance the run loop.
public func waitUntil(timeout: TimeInterval = 1, file: String = #file, line: UInt = #line, action: (() -> Void) -> Void) -> Void {
    NMBWait.until(timeout: timeout, file: file, line: line, action: action)
}
