// Sources/InspectorMacros/Helpers/CamelCaseConverter.swift

enum CamelCaseConverter {
    /// Converts a camelCase identifier to a space-separated display name.
    /// "borderColor"  → "Border Color"
    /// "URLString"    → "URL String"  (acronym run: space before last uppercase of a run)
    /// "isHidden"     → "Is Hidden"
    static func toDisplayName(_ identifier: String) -> String {
        guard !identifier.isEmpty else { return "" }
        var result = ""
        let chars = Array(identifier)

        for i in 0..<chars.count {
            let c = chars[i]
            if c.isUppercase && i > 0 {
                let prev = chars[i - 1]
                let next: Character? = i + 1 < chars.count ? chars[i + 1] : nil
                // Insert a space before this uppercase letter if:
                // – previous was lowercase ("borderColor" → "border|Color")
                // – previous was uppercase AND next is lowercase ("URLString" → "URL|String")
                if prev.isLowercase || (prev.isUppercase && next?.isLowercase == true) {
                    result.append(" ")
                }
            }
            result.append(c)
        }

        // Capitalise the first character
        return result.prefix(1).uppercased() + result.dropFirst()
    }
}
