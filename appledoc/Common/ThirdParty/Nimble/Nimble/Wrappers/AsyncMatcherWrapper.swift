import Foundation

internal struct AsyncMatcherWrapper<T, U>: Matcher where U: Matcher, U.ValueType == T {
    let fullMatcher: U
    let timeoutInterval: TimeInterval
    let pollInterval: TimeInterval

    init(fullMatcher: U, timeoutInterval: TimeInterval = 1, pollInterval: TimeInterval = 0.01) {
      self.fullMatcher = fullMatcher
      self.timeoutInterval = timeoutInterval
      self.pollInterval = pollInterval
    }

    func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool {
        let uncachedExpression = actualExpression.withoutCaching()
        let result = pollBlock(pollInterval: pollInterval, timeoutInterval: timeoutInterval) {
            try self.fullMatcher.matches(uncachedExpression, failureMessage: failureMessage)
        }
        switch (result) {
        case .success: return true
        case .failure: return false
        case let .errorThrown(error):
            failureMessage.actualValue = "an unexpected error thrown: <\(error)>"
            return false
        case .timeout:
            failureMessage.postfixMessage += " (Stall on main thread)."
            return false
        }
    }

    func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool  {
        let uncachedExpression = actualExpression.withoutCaching()
        let result = pollBlock(pollInterval: pollInterval, timeoutInterval: timeoutInterval) {
            try self.fullMatcher.doesNotMatch(uncachedExpression, failureMessage: failureMessage)
        }
        switch (result) {
        case .success: return true
        case .failure: return false
        case let .errorThrown(error):
            failureMessage.actualValue = "an unexpected error thrown: <\(error)>"
            return false
        case .timeout:
            failureMessage.postfixMessage += " (Stall on main thread)."
            return false
        }
    }
}

private let toEventuallyRequiresClosureError = FailureMessage(stringValue: "expect(...).toEventually(...) requires an explicit closure (eg - expect { ... }.toEventually(...) )\nSwift 1.2 @autoclosure behavior has changed in an incompatible way for Nimble to function")


extension Expectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    public func toEventually<U>(_ matcher: U, timeout: TimeInterval = 1, pollInterval: TimeInterval = 0.01, description: String? = nil) where U: Matcher, U.ValueType == T {
        if expression.isClosure {
            let (pass, msg) = expressionMatches(
                expression,
                matcher: AsyncMatcherWrapper(
                    fullMatcher: matcher,
                    timeoutInterval: timeout,
                    pollInterval: pollInterval),
                to: "to eventually",
                description: description
            )
            verify(pass, msg)
        } else {
            verify(false, toEventuallyRequiresClosureError)
        }
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    public func toEventuallyNot<U>(_ matcher: U, timeout: TimeInterval = 1, pollInterval: TimeInterval = 0.01, description: String? = nil) where U: Matcher, U.ValueType == T {
        if expression.isClosure {
            let (pass, msg) = expressionDoesNotMatch(
                expression,
                matcher: AsyncMatcherWrapper(
                    fullMatcher: matcher,
                    timeoutInterval: timeout,
                    pollInterval: pollInterval),
                toNot: "to eventually not",
                description: description
            )
            verify(pass, msg)
        } else {
            verify(false, toEventuallyRequiresClosureError)
        }
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    public func toNotEventually<U>(_ matcher: U, timeout: TimeInterval = 1, pollInterval: TimeInterval = 0.01, description: String? = nil) where U: Matcher, U.ValueType == T {
        return toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }
}
