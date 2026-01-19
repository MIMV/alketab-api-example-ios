//
//  SearchResultRow.swift
//  AlKetab AI Search
//
//  Row component for displaying search results
//

import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Surah and Ayah info
            HStack {
                Text("\(result.surahName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text("Ayah \(result.ayahNumber)")
                    .font(.system(size: 14))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
            }
            
            // Verse Text
            Text(parseHTMLHighlighting(result.verseText))
                .font(.custom("KFGQPC HAFS Uthmanic Script", size: 27))
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.vertical, 4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    
    /// Parse HTML highlighted text and convert to AttributedString
    private func parseHTMLHighlighting(_ htmlText: String) -> AttributedString {
        var attributedString = AttributedString()
        
        // Pattern to match: <span style="...color:COLORNAME;..."><b>content</b></span>
        // Note: The structure might vary slightly, so we'll be more generic
        let pattern = #"<span[^>]*style="[^"]*color:([^;]+);[^"]*"><b>(.*?)<\/b><\/span>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return AttributedString(htmlText)
        }
        
        let nsString = htmlText as NSString
        let matches = regex.matches(
            in: htmlText, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var lastIndex = 0
        
        for match in matches {
            // Add text before the match (normal text)
            if match.range.location > lastIndex {
                let normalRange = NSRange(location: lastIndex, length: match.range.location - lastIndex)
                let normalText = nsString.substring(with: normalRange)
                attributedString += AttributedString(normalText)
            }
            
            // Extract color and text
            if match.numberOfRanges > 2 {
                let colorRange = match.range(at: 1)
                let textRange = match.range(at: 2)
                let colorName = nsString.substring(with: colorRange)
                let matchedText = nsString.substring(with: textRange)
                
                var boldText = AttributedString(matchedText)
                boldText.foregroundColor = parseHTMLColor(colorName)
                attributedString += boldText
            }
            
            lastIndex = match.range.location + match.range.length
        }
        
        // Add remaining text after last match
        if lastIndex < nsString.length {
            let remainingRange = NSRange(location: lastIndex, length: nsString.length - lastIndex)
            let remainingText = nsString.substring(with: remainingRange)
            attributedString += AttributedString(remainingText)
        }
        
        return attributedString.characters.isEmpty ? AttributedString(htmlText) : attributedString
    }
    
    /// Convert HTML color name to SwiftUI Color
    private func parseHTMLColor(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "cyan": return .cyan
        case "brown": return .brown
        case "gray", "grey": return .gray
        default: return .accentColor  // Fallback
        }
    }
}
