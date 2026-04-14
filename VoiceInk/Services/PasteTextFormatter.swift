import Foundation

enum PasteTextFormatter {
    static func formatForPaste(_ text: String) -> String {
        var formattedText = text

        if UserDefaults.standard.bool(forKey: "LowercaseTranscription") {
            formattedText = formattedText.lowercased()
        }

        if UserDefaults.standard.bool(forKey: "RemoveTrailingPeriodForSingleSentence") {
            formattedText = removeTrailingPeriodIfSingleSentence(formattedText)
        }

        if UserDefaults.standard.bool(forKey: "AppendTrailingSpace") {
            formattedText += " "
        }

        return formattedText
    }

    private static func removeTrailingPeriodIfSingleSentence(_ text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.hasSuffix(".") else {
            return text
        }

        let sentenceEnderCount = trimmedText.reduce(into: 0) { count, character in
            if character == "." || character == "!" || character == "?" {
                count += 1
            }
        }

        guard sentenceEnderCount == 1 else {
            return text
        }

        guard let periodIndex = text.lastIndex(of: ".") else {
            return text
        }

        var updatedText = text
        updatedText.remove(at: periodIndex)
        return updatedText
    }
}
