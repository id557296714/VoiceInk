import Foundation

enum PasteTextFormatter {
    static func formatForPaste(_ text: String) -> String {
        var formattedText = text

        if UserDefaults.standard.bool(forKey: "LowercaseTranscription") {
            formattedText = formattedText.lowercased()
        }

        if UserDefaults.standard.bool(forKey: "AppendTrailingSpace") {
            formattedText += " "
        }

        return formattedText
    }
}
