import Foundation


internal func identityAsString(_ value: AnyObject?) -> String {
    if value == nil {
        return "nil"
    }
    return NSString(format: "<%p>", unsafeBitCast(value!, to: Int.self)).description
}

internal func arrayAsString<T>(_ items: [T], joiner: String = ", ") -> String {
    return items.reduce("") { accum, item in
        let prefix = (accum.isEmpty ? "" : joiner)
        return accum + prefix + "\(stringify(item))"
    }
}

@objc internal protocol NMBStringer {
    func NMB_stringify() -> String
}

internal func stringify<S: Sequence>(_ value: S) -> String {
    var generator = value.makeIterator()
    var strings = [String]()
    var value: S.Iterator.Element?
    repeat {
        value = generator.next()
        if value != nil {
            strings.append(stringify(value))
        }
    } while value != nil
    let str = strings.joined(separator: ", ")
    return "[\(str)]"
}

extension NSArray : NMBStringer {
    func NMB_stringify() -> String {
        let str = self.componentsJoined(by: ", ")
        return "[\(str)]"
    }
}

internal func stringify<T>(_ value: T) -> String {
    if let value = value as? Double {
        return NSString(format: "%.4f", (value)).description
    }
    return String(describing: value)
}

internal func stringify(_ value: NMBDoubleConvertible) -> String {
    if let value = value as? Double {
        return NSString(format: "%.4f", (value)).description
    }
    return value.stringRepresentation
}

internal func stringify<T>(_ value: T?) -> String {
    if let unboxed = value {
       return stringify(unboxed)
    }
    return "nil"
}
