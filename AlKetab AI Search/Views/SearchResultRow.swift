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
        VStack(alignment: .center, spacing: 2) {
            // Header: Surah and Play info
            HStack {
                Text("\(result.surahNameEnglish) - \(result.surahNameArabic)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                SearchAudioPlayButton(audioURLString: result.recitationURL)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(0.2))
                    .shadow(radius: 4)
            )
            .padding(.bottom)
            
            // Previous Ayah (Context)
            if let prevText = result.prevAyaText, let prevID = result.prevAyaID {
                let number = convertToArabic(prevID)
                Text(prevText + "\u{00a0}" + number)
                    .font(.custom("KFGQPC HAFS Uthmanic Script", size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1, antialiased: true)
                    )
            }
            
            // Verse Text
            let arabicNumber = convertToArabic(result.ayahNumber)
            let mainText =
            parseHTMLHighlighting(result.verseText) + AttributedString("\u{00a0}\(arabicNumber)")
            
            Text(mainText)
                .font(.custom("KFGQPC HAFS Uthmanic Script", size: 27))
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
            
            // Next Ayah (Context)
            if let nextText = result.nextAyaText, let nextID = result.nextAyaID {
                let number = convertToArabic(nextID)
                Text(nextText + "\u{00a0}" + number)
                    .font(.custom("KFGQPC HAFS Uthmanic Script", size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1, antialiased: true)
                    )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Methods
    
    private func convertToArabic(_ number: Int) -> String {
        let arabicDigits = Array("٠١٢٣٤٥٦٧٨٩")  // 0 to 9
        
        return "\(number)".map { char in
            if let digit = char.wholeNumberValue {
                return String(arabicDigits[digit])
            }
            return String(char)
        }.joined()
    }
    
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

// MARK: - Previews

struct SearchResultRow_Previews: PreviewProvider {
    static var previews: some View {
        let mockResult = SearchResult(
            id: 1,
            verseText:  "إِنَّ ٱلَّذِينَ كَفَرُوا سَوَآءٌ عَلَيْهِمْ ءَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ",
            surahNameArabic: "البقرة",
            surahNameEnglish: "Al-Baqarah",
            surahNumber: 2,
            ayahNumber: 6,
            pageNumber: 1,
            recitationURL: nil,
            prevAyaText: "أُولَـٰٓئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولـٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ",
            nextAyaText: "خَتَمَ ٱللَّهُ عَلَىٰ قُلُوبِهِمْ وَعَلَىٰ سَمْعِهِمْ ۖ وَعَلَىٰٓ أَبْصَـٰرِهِمْ غِشَـٰوَةٌۭ ۖ وَلَهُمْ عَذَابٌ عَظِيمٌۭ",
            prevAyaID: 5,
            nextAyaID: 7
        )
        
        return ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            SearchResultRow(result: mockResult)
                .padding()
        }
    }
}
