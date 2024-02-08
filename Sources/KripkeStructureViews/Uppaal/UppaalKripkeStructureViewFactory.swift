import IO
import KripkeStructure

public final class UppaalKripkeStructureViewFactory: KripkeStructureViewFactory {

    private let layoutIterations: Int

    private let outputStreamFactory: OutputStreamFactory

    public init(layoutIterations: Int = 3, outputStreamFactory: OutputStreamFactory = FileOutputStreamFactory()) {
        self.layoutIterations = layoutIterations
        self.outputStreamFactory = outputStreamFactory
    }

    public func make(identifier: String) -> UppaalKripkeStructureView {
        return UppaalKripkeStructureView(
            identifier: identifier,
            layoutIterations: layoutIterations,
            outputStreamFactory: outputStreamFactory
        )
    }

}
