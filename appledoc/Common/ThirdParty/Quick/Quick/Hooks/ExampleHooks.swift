/**
    A container for closures to be executed before and after each example.
*/
final internal class ExampleHooks {

    internal var befores: [BeforeExampleWithMetadataClosure] = []
    internal var afters: [AfterExampleWithMetadataClosure] = []

    internal func appendBefore(_ closure: @escaping BeforeExampleWithMetadataClosure) {
        befores.append(closure)
    }

    internal func appendBefore(_ closure: @escaping BeforeExampleClosure) {
        befores.append { (exampleMetadata: ExampleMetadata) in closure() }
    }

    internal func appendAfter(_ closure: @escaping AfterExampleWithMetadataClosure) {
        afters.append(closure)
    }

    internal func appendAfter(_ closure: @escaping AfterExampleClosure) {
        afters.append { (exampleMetadata: ExampleMetadata) in closure() }
    }

    internal func executeBefores(_ exampleMetadata: ExampleMetadata) {
        for before in befores {
            before(exampleMetadata)
        }
    }

    internal func executeAfters(_ exampleMetadata: ExampleMetadata) {
        for after in afters {
            after(exampleMetadata)
        }
    }
}
