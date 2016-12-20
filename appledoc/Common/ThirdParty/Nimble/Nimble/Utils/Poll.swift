import Foundation

internal enum PollResult  {
    case success, failure, timeout
    case errorThrown(Error)

    var boolValue : Bool {
        switch (self) {
        case .success:
            return true
        default:
            return false
        }
    }
}

internal class RunPromise {
    private lazy var __once: () = {
            RunPromise.didFinish = false
        }()
    var token: Int = 0
    var didFinish = false
    var didFail = false

    init() {}

    func succeed() {
        _ = self.__once
    }

    func fail(_ block: () -> Void) {
        // Migrator FIXME: multiple dispatch_once calls using the same dispatch_once_t token cannot be automatically migrated
        dispatch_once(&self.token) {
            self.didFail = true
            block()
        }
    }
}

let killQueue = DispatchQueue(label: "nimble.waitUntil.queue", attributes: [])

internal func stopRunLoop(_ runLoop: RunLoop, delay: TimeInterval) -> RunPromise {
    let promise = RunPromise()
    let killTimeOffset = Int64(CDouble(delay) * CDouble(NSEC_PER_SEC))
    let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
    killQueue.asyncAfter(deadline: killTime) {
        promise.fail {
            CFRunLoopStop(runLoop.getCFRunLoop())
        }
    }
    return promise
}

internal func pollBlock(pollInterval: TimeInterval, timeoutInterval: TimeInterval, expression: () throws -> Bool) -> PollResult {
    let runLoop = RunLoop.main

    let promise = stopRunLoop(runLoop, delay: min(timeoutInterval, 0.2))

    let startDate = Date()

    // trigger run loop to make sure enqueued tasks don't block our assertion polling
    // the stop run loop task above will abort us if necessary
    runLoop.run(until: startDate)
    killQueue.sync {
        promise.succeed()
    }

    if promise.didFail {
        return .timeout
    }

    var pass = false
    do {
        repeat {
            pass = try expression()
            if pass {
                break
            }

            let runDate = Date().addingTimeInterval(pollInterval)
            runLoop.run(until: runDate)
        } while(Date().timeIntervalSince(startDate) < timeoutInterval)
    } catch let error {
        return .errorThrown(error)
    }

    return pass ? .success : .failure
}
