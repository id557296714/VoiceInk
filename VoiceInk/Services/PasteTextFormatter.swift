import Foundation

enum PasteTextFormatter {
    private static let exactContractionsToFlatten: Set<String> = [
        "it's", "he's", "she's", "that's", "what's", "who's", "there's",
        "here's", "where's", "when's", "why's", "how's", "let's"
    ]

    static func formatForPaste(_ text: String) -> String {
        var formattedText = text

        if UserDefaults.standard.bool(forKey: "LowercaseTranscription") {
            formattedText = formattedText.lowercased()
        }

        if UserDefaults.standard.bool(forKey: "SergeiModeForPaste") {
            formattedText = applySergeiMode(formattedText)
        }

        if UserDefaults.standard.bool(forKey: "RemoveTrailingPeriodForSingleSentence") {
            formattedText = removeTrailingPeriodIfSingleSentence(formattedText)
        }

        if UserDefaults.standard.bool(forKey: "RemoveTrailingPeriodForMultipleSentences") {
            formattedText = removeTrailingPeriodIfMultipleSentences(formattedText)
        }

        if UserDefaults.standard.bool(forKey: "AppendTrailingSpace") {
            formattedText += " "
        }

        return formattedText
    }

    static func formatForLivePreview(_ text: String) -> String {
        var formattedText = text

        if UserDefaults.standard.bool(forKey: "LowercaseLivePreview") {
            formattedText = formattedText.lowercased()
        }

        if UserDefaults.standard.bool(forKey: "SergeiModeForLivePreview") {
            formattedText = applySergeiMode(formattedText)
        }

        return formattedText
    }

    private static func applySergeiMode(_ text: String) -> String {
        let pattern = #"\b[\p{L}]+(?:['’][\p{L}]+)+\b"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
        var result = text

        let matches = regex.matches(in: text, options: [], range: fullRange).reversed()
        for match in matches {
            guard let range = Range(match.range, in: result) else { continue }
            let word = String(result[range])
            let normalizedWord = word.lowercased().replacingOccurrences(of: "’", with: "'")

            guard shouldFlattenApostrophes(in: normalizedWord) else { continue }

            let flattened = word
                .replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: "’", with: "")
            result.replaceSubrange(range, with: flattened)
        }

        return result
    }

    private static func shouldFlattenApostrophes(in word: String) -> Bool {
        if exactContractionsToFlatten.contains(word) {
            return true
        }

        if word.hasSuffix("n't") || word.hasSuffix("'re") || word.hasSuffix("'ve") || word.hasSuffix("'ll") || word.hasSuffix("'d") || word.hasSuffix("'m") {
            return true
        }

        return false
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

    private static func removeTrailingPeriodIfMultipleSentences(_ text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedText.hasSuffix(".") else {
            return text
        }

        let sentenceEnderCount = trimmedText.reduce(into: 0) { count, character in
            if character == "." || character == "!" || character == "?" {
                count += 1
            }
        }

        guard sentenceEnderCount > 1 else {
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
