import IO
import KripkeStructure

public final class UppaalKripkeStructureViewFactory: KripkeStructureViewFactory {

    private let outputStreamFactory: OutputStreamFactory

    public init(outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()) {
        self.outputStreamFactory = outputStreamFactory
    }

    public func make(identifier: String) -> UppaalKripkeStructureView {
        return UppaalKripkeStructureView(
            identifier: identifier,
            outputStreamFactory: outputStreamFactory
        )
    }

}
