import Foundation

public struct InspectorSectionDescriptor: Hashable, Sendable {
    public var id: String
    public var title: String?
    public var defaultState: InspectorElementSectionState
    public var fields: [InspectorPropertyDescriptor]

    public init(
        id: String,
        title: String? = nil,
        defaultState: InspectorElementSectionState = .collapsed,
        fields: [InspectorPropertyDescriptor] = []
    ) {
        self.id = id
        self.title = title
        self.defaultState = defaultState
        self.fields = fields
    }
}
