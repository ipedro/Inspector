import InspectorContract
import UIKit

func inspectorObjectIdentityToken(for object: AnyObject) -> String {
    String(ObjectIdentifier(object).hashValue)
}

struct InspectorInjectedPanelSection {
    let title: String?
    let rows: [InspectorInjectedPanelRow]
}

struct InspectorInjectedPanelRow {
    let title: String
    let subtitle: String?
    let fields: [InspectorInjectedPanelField]
}

struct InspectorInjectedPanelField {
    let descriptor: InspectorPropertyDescriptor
    let value: InspectorValue
    let runtimePresentation: InspectorPropertyRuntimePresentation?
}

final class InspectorInjectedPanelRegistry {
    static let shared = InspectorInjectedPanelRegistry()

    private struct RegisteredPanel {
        let id: String
        let objectIdentityToken: String
        let panel: ElementInspectorPanel
        let sections: [InspectorInjectedPanelSection]
    }

    private var panelsByID: [String: RegisteredPanel] = [:]

    private init() {}

    func upsert(
        panelId: String,
        objectIdentityToken: String,
        panel: ElementInspectorPanel,
        sections: [InspectorInjectedPanelSection]
    ) {
        panelsByID[panelId] = RegisteredPanel(
            id: panelId,
            objectIdentityToken: objectIdentityToken,
            panel: panel,
            sections: sections
        )
    }

    @discardableResult
    func remove(panelId: String) -> Bool {
        panelsByID.removeValue(forKey: panelId) != nil
    }

    func sections(for object: NSObject, panel: ElementInspectorPanel) -> InspectorElementSections {
        let token = inspectorObjectIdentityToken(for: object)

        return panelsByID.values
            .filter { $0.objectIdentityToken == token && $0.panel == panel }
            .sorted { $0.id < $1.id }
            .flatMap { registeredPanel in
                registeredPanel.sections.map { section in
                    InspectorElementSection(
                        title: section.title,
                        rows: section.rows.map(InspectorInjectedPanelRowDataSource.init(row:))
                    )
                }
            }
    }

    func reset() {
        panelsByID.removeAll()
    }
}

private final class InspectorInjectedPanelRowDataSource: InspectorElementSectionDataSource {
    var state: InspectorElementSectionState = .expanded
    let title: String
    let subtitle: String?
    let propertyBindings: [InspectorPropertyBinding]

    init(row: InspectorInjectedPanelRow) {
        title = row.title
        subtitle = row.subtitle
        propertyBindings = row.fields.map { field in
            InspectorPropertyBinding(
                descriptor: field.descriptor,
                read: { field.value },
                write: nil,
                refreshHint: .reloadSection,
                runtimePresentation: field.runtimePresentation
            )
        }
    }
}
