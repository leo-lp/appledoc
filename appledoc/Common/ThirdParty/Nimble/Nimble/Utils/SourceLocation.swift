import Foundation


open class SourceLocation : NSObject {
    open let file: String
    open let line: UInt

    override init() {
        file = "Unknown File"
        line = 0
    }

    init(file: String, line: UInt) {
        self.file = file
        self.line = line
    }

    override open var description: String {
        return "\(file):\(line)"
    }
}
