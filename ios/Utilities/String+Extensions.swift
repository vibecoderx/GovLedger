//
//  String+Extensions.swift
//  GovSpendr
//

import Foundation

extension String {
    /// Converts a string into a more readable sentence-cased format.
    /// It lowercases the entire string and then capitalizes only the first letter.
    /// This is a simple but effective way to improve the display of all-caps text.
    func sentenceCased() -> String {
        guard !self.isEmpty else { return "" }
        return self.lowercased().prefix(1).capitalized + self.lowercased().dropFirst()
    }
}
