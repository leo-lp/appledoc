/// Make an expectation on a given actual value. The value given is lazily evaluated.
public func expect<T>( _ expression: @autoclosure @escaping () throws -> T?, file: String = #file, line: UInt = #line) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an expectation on a given actual value. The closure is lazily invoked.
public func expect<T>(_ file: String = #file, line: UInt = #line, expression: () throws -> T?) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Always fails the test with a message and a specified location.
public func fail(_ message: String, location: SourceLocation) {
    NimbleAssertionHandler.assert(false, message: FailureMessage(stringValue: message), location: location)
}

/// Always fails the test with a message.
public func fail(_ message: String, file: String = #file, line: UInt = #line) {
    fail(message, location: SourceLocation(file: file, line: line))
}

/// Always fails the test.
public func fail(_ file: String = #file, line: UInt = #line) {
    fail("fail() always fails", file: file, line: line)
}
