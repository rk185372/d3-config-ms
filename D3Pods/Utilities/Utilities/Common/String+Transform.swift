//
//  String+Transform.swift
//  Pods
//
//  Created by Chris Carranza on 6/2/17.
//
//

import Foundation

public extension String {
    /// Returns a version of the string with the beginning of the string masked up to the given amount from the end of the string.
    /// The string 'maskedtext' would result in '••••••text'.
    ///
    /// - Parameters:
    ///   - maskCharacter: character to use for masking.
    ///   - unmaskedAmount: the amount of the string to remain unmasked. This amount starts at the end of the string traversing backwards.
    /// - Returns: the masked string
    func masked(maskCharacter: Character = "•", unmaskedAmount amount: Int = 4) -> String {
        guard self.count > amount else { return self }
        
        let maskLength = self.count - amount
        let masked = String(repeatElement(maskCharacter, count: maskLength))
        let unmasked = self[index(endIndex, offsetBy: -amount)...]
        
        return masked + unmasked
    }
    
    /// Returns a version of the string truncated to the given amount. Truncation will only occur if text length is beyond limit.
    ///
    /// - Parameters:
    ///   - limit: the limit of the text before truncation occurs.
    ///   - char: the character to use at the end of truncation to signify that truncation has occured. Defaults to '.'
    ///           (character is repeated 3 times)
    /// - Returns: truncated string
    func truncated(limit: Int, trunkationCharacter char: Character = ".") -> String {
        guard self.count > limit && self.count > 4 else { return self }
        
        var returnVal = self
        
        let range = index(startIndex, offsetBy: limit - 3)..<endIndex
        returnVal.removeSubrange(range)
        returnVal += repeatElement(char, count: 3)
        
        return returnVal
    }

    /// Returns a string with all the characters in the given set removed.
    /// - parameters:
    ///   - charactersInSet: the characters to remove
    /// - returns: the new string
    func removing(charactersInSet characters: CharacterSet) -> String {
        return self.components(separatedBy: characters).joined()
    }
    
    /// Returns a copy of the receiver with the right single quote "\u{2019}" removed.
    /// For some reason, the apostrophe on the iphone defaults to the right single quote
    /// instead of the actual apostrophe. This can cause rendering issues in the web.
    ///
    /// - Returns: A new String with all instances of the right single quote replaced with an apostrophe.
    func replacingRightSingleQuote() -> String {
        return self.replacingOccurrences(of: "\u{2019}", with: "'")
    }
    
    /// Returns an abbreviation of the receiver, consisting of the first letter of up to the first
    /// `n` words, capitalized. Words are determined by splitting on whitespace and the ASCII hyphen
    /// character `"-"`, and omitting empty subsequences. Numbers are ignored.
    ///
    /// If there are less than `length` words, multiple letters will be taken from the last word
    /// to pad to `length`.
    ///
    /// Example:
    /// ```
    /// "alfa bravo charlie delta".abbreviated(length: 3)
    /// // results in "ABC"
    /// "checking".abbreviated()
    /// // results in "CH"
    /// ```
    ///
    /// - parameters:
    ///   - length: The number of words to abbreviate. Additional words will be ignored.
    /// - returns: The abbreviation as a new string.
    func abbreviated(length: Int = 2) -> String {
        let splitCharacters = CharacterSet(charactersIn: "-").union(.whitespaces)
        let nonAlphaCharacters = CharacterSet
            .alphanumerics
            .subtracting(CharacterSet(charactersIn: "0123456789"))
            .inverted
        
        let words = self
            .components(separatedBy: splitCharacters)
            .map { $0.removing(charactersInSet: nonAlphaCharacters)}
            .filter { !$0.isEmpty }
            .prefix(length)
        
        var abbreviation = words.map { $0.prefix(1).capitalized }.joined()
        
        // If the abbreviation is too short, append letters from the last word
        if abbreviation.count < length, let lastWord = words.last {
            let pad = lastWord.dropFirst().prefix(length - abbreviation.count).capitalized
            abbreviation.append(pad)
        }
        
        return abbreviation
    }

    // The following functions mimic behavior that the web is using. The library they are
    // using may be found at https://github.com/epeli/underscore.string
    func camelize() -> String {
        let expr = try! NSRegularExpression(pattern: "[-_\\s]+(.)?")
        var res = self
        for match in expr.matches(in: self, range: NSRange(0..<res.count)).reversed() {
            let range = Range(match.range, in: self)!
            let letterRange = Range(match.range(at: 1), in: self)!
            res.replaceSubrange(range, with: self[letterRange].uppercased())
        }

        return res
    }

    func capitalize() -> String {
        guard !isEmpty else { return self }
        let range = Range(NSRange(location: 0, length: 1), in: self)!

        return replacingCharacters(in: range, with: self[range].uppercased())
    }

    func convertToTitle() -> String {
        let kebabName = camelize().dasherize()
        let humanName = kebabName.humanize().titleize()
        let components = Helpers.handleAcronyms(in: humanName.split(separator: " ").map(String.init))

        return components.reduce("", { result, newPiece in
            "\(result) \(newPiece)"
        })
        .trimmingCharacters(in: [" ", "_", "-"])
    }

    func decapitalize() -> String {
        guard !isEmpty else { return self }
        let range = Range(NSRange(location: 0, length: 1), in: self)!

        return replacingCharacters(in: range, with: self[range].lowercased())
    }

    func dasherize() -> String {
        let capitalsRegex = try! NSRegularExpression(pattern: "([A-Z])", options: [])
        let dashesUnderscoresSpaces = try! NSRegularExpression(pattern: "[-_\\s]+", options: [])

        var str = capitalsRegex.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: count),
            withTemplate: "-$1"
        )

        str = dashesUnderscoresSpaces.stringByReplacingMatches(
            in: str,
            options: [],
            range: NSRange(location: 0, length: count),
            withTemplate: "-"
        )

        return str
    }

    func humanize() -> String {
        return underscored()
            .replacingOccurrences(of: "_", with: " ")
            .capitalize()
    }

    func titleize() -> String {
        let regex = try! NSRegularExpression(pattern: "(?:^|\\s|-|_)(\\S)", options: [])
        var res = self
        for match in regex.matches(in: self, range: NSRange(0..<res.count)).reversed() {
            let letterRange = Range(match.range(at: 1), in: self)!
            res.replaceSubrange(letterRange, with: self[letterRange].uppercased())
        }

        return res
    }

    func underscored() -> String {
        let camelCasePattern = try! NSRegularExpression(pattern: "([a-z\\d])([A-Z]+)", options: [])
        let dashesAndWhitespacesPattern = try! NSRegularExpression(pattern: "[-\\s]", options: [])

        var str = camelCasePattern.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.count),
            withTemplate: "$1_$2"
        )

        str = dashesAndWhitespacesPattern.stringByReplacingMatches(
            in: str,
            options: [],
            range: NSRange(location: 0, length: str.count),
            withTemplate: "_"
        )

        return str.lowercased()
    }
    
    func asDate() -> Date? {
        return ISO8601DateFormatter.longForm.date(from: self)
            ?? ISO8601DateFormatter.shortForm.date(from: self)
            ?? DateFormatter.shortStyleDashes.date(from: self)
    }
}
