import Foundation

/// Implement this protocol to implement a custom matcher for Swift
public protocol Matcher {
    associatedtype ValueType
    func matches(_ actualExpression: Expression<ValueType>, failureMessage: FailureMessage) throws -> Bool
    func doesNotMatch(_ actualExpression: Expression<ValueType>, failureMessage: FailureMessage) throws -> Bool
}

/// Objective-C interface to the Swift variant of Matcher.
@objc public protocol NMBMatcher {
    func matches(_ actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool
    func doesNotMatch(_ actualBlock: () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool
}

/// Protocol for types that support contain() matcher.
@objc public protocol NMBContainer {
    func containsObject(_ object: AnyObject!) -> Bool
}
extension NSArray : NMBContainer {}
extension NSSet : NMBContainer {}
extension NSHashTable : NMBContainer {}

/// Protocol for types that support only beEmpty(), haveCount() matchers
@objc public protocol NMBCollection {
    var count: Int { get }
}
extension NSSet : NMBCollection {}
extension NSDictionary : NMBCollection {}
extension NSHashTable : NMBCollection {}
extension NSMapTable : NMBCollection {}

/// Protocol for types that support beginWith(), endWith(), beEmpty() matchers
@objc public protocol NMBOrderedCollection : NMBCollection {
    func indexOfObject(_ object: AnyObject!) -> Int
}
extension NSArray : NMBOrderedCollection {}

/// Protocol for types to support beCloseTo() matcher
@objc public protocol NMBDoubleConvertible {
    var doubleValue: CDouble { get }
}
extension NSNumber : NMBDoubleConvertible {
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    return formatter
    }()

extension Date: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        get {
            return self.timeIntervalSinceReferenceDate
        }
    }
}


extension NMBDoubleConvertible {
    public var stringRepresentation: String {
        get {
            if let date = self as? Date {
                return dateFormatter.string(from: date)
            }
            
            if let debugStringConvertible = self as? CustomDebugStringConvertible {
                return debugStringConvertible.debugDescription
            }
            
            if let stringConvertible = self as? CustomStringConvertible {
                return stringConvertible.description
            }
            
            return ""
        }
    }
}

/// Protocol for types to support beLessThan(), beLessThanOrEqualTo(),
///  beGreaterThan(), beGreaterThanOrEqualTo(), and equal() matchers.
///
/// Types that conform to Swift's Comparable protocol will work implicitly too
@objc public protocol NMBComparable {
    func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult
}
extension NSNumber : NMBComparable {
    public func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult {
        return compare(otherObject as! NSNumber)
    }
}
extension NSString : NMBComparable {
    public func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult {
        return compare(otherObject as! String)
    }
}
