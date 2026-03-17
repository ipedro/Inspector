// Sources/InspectorMacros/Helpers/InspectorMacroDiagnostic.swift

import SwiftDiagnostics
import SwiftSyntax

enum InspectorMacroDiagnostic: DiagnosticMessage {
    case notAClass
    case notAStoredProperty
    case missingTitle
    case noInspectableProperties
    case unsupportedTypeForAutoDescriptor(typeName: String)
    case descriptorTypeMismatch(descriptor: String, typeName: String)

    var message: String {
        switch self {
        case .notAClass:
            return "@InspectorPanel can only be applied to a class"
        case .notAStoredProperty:
            return "@InspectorProperty can only be applied to a stored var property"
        case .missingTitle:
            return "@InspectorPanel requires a non-empty title argument"
        case .noInspectableProperties:
            return "@InspectorPanel found no @InspectorProperty-annotated stored properties — panel will be empty"
        case .unsupportedTypeForAutoDescriptor(let typeName):
            return "@InspectorProperty requires an explicit descriptor for '\(typeName)' — no default control exists for this type"
        case .descriptorTypeMismatch(let descriptor, let typeName):
            return "@InspectorProperty(\(descriptor)) is not compatible with '\(typeName)'"
        }
    }

    // Use stable string IDs — do NOT use String(describing: self) here because
    // cases with associated values produce IDs that include runtime values (unstable).
    var diagnosticID: MessageID {
        switch self {
        case .notAClass:
            return MessageID(domain: "InspectorMacros", id: "notAClass")
        case .notAStoredProperty:
            return MessageID(domain: "InspectorMacros", id: "notAStoredProperty")
        case .missingTitle:
            return MessageID(domain: "InspectorMacros", id: "missingTitle")
        case .noInspectableProperties:
            return MessageID(domain: "InspectorMacros", id: "noInspectableProperties")
        case .unsupportedTypeForAutoDescriptor:
            return MessageID(domain: "InspectorMacros", id: "unsupportedTypeForAutoDescriptor")
        case .descriptorTypeMismatch:
            return MessageID(domain: "InspectorMacros", id: "descriptorTypeMismatch")
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .noInspectableProperties:
            return .warning
        default:
            return .error
        }
    }
}
