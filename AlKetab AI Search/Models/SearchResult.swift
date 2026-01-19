//
//  SearchResult.swift
//  AlKetab AI Search
//
//  Model for search results
//

import Foundation

struct SearchResult: Identifiable, Equatable {
    let id: Int  // verse ID
    let verseText: String  // Display text (HTML for API)
    let surahNameArabic: String
    let surahNameEnglish: String
    let surahNumber: Int
    let ayahNumber: Int
    let pageNumber: Int
    let recitationURL: String?
    let prevAyaText: String?
    let nextAyaText: String?
    let prevAyaID: Int?
    let nextAyaID: Int?
    
    // Initialize from API data (already has HTML highlighting)
    init(
        id: Int, verseText: String, surahNameArabic: String, surahNameEnglish: String, surahNumber: Int,
        ayahNumber: Int, pageNumber: Int, recitationURL: String?, prevAyaText: String?,
        nextAyaText: String?, prevAyaID: Int?, nextAyaID: Int?
    ) {
        self.id = id
        self.verseText = verseText
        self.surahNameArabic = surahNameArabic
        self.surahNameEnglish = surahNameEnglish
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.pageNumber = pageNumber
        self.recitationURL = recitationURL
        self.prevAyaText = prevAyaText
        self.nextAyaText = nextAyaText
        self.prevAyaID = prevAyaID
        self.nextAyaID = nextAyaID
    }
}
