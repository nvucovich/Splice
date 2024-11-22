//
//  WordManager.swift
//  Splice
//
//  Created by NVucovich on 11/15/24.
//

import Foundation

struct WordManager {
    // Dictionary of dates and words
    private static let dailyWords: [String: String] = [
        "2024-11-15": "CUSTOM",
        "2024-11-16": "SPLICE",
        "2024-11-17": "HEROIC",
        "2024-11-18": "",
        "2024-11-19": "APACHE",
        "2024-11-20": "",
        // Add more dates and words
    ]
    
    static func getWordOfTheDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        return dailyWords[today] ?? "SPLICE" // Default word if date not found
    }
    
    static func validateWord(_ word: String) async -> Bool {
        let word = word.lowercased()
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}

/*
 6 Letters
 A words: __, AB, AC, AD, AE, AF, AG, __, AI, __, __, AL, AM, AN, AO, AP, AQ, AR, AS, AT, AU, AV, AW, AX, 
 */

