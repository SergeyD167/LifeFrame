//
//  Character+Extensions.swift
//  LifeFrame
//
//  Created by Сергей Дятлов on 23.02.2024.
//

import Foundation

extension Character {
    func isEmoji() -> Bool {
        let emojiRanges = [
            (8205, 11093),
            (12336, 12953),
            (65039, 65039),
            (126980, 129685)
        ]
        let codePoint = self.unicodeScalars[self.unicodeScalars.startIndex].value
        for emojiRange in emojiRanges {
            if codePoint >= emojiRange.0 && codePoint <= emojiRange.1 {
                return true
            }
        }
        return false
    }
}
