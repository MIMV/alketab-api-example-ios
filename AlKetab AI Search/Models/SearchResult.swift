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
  let surahName: String
  let surahNumber: Int
  let ayahNumber: Int
  let pageNumber: Int

  // Initialize from API data (already has HTML highlighting)
  init(
    id: Int, verseText: String, surahName: String, surahNumber: Int, ayahNumber: Int,
    pageNumber: Int
  ) {
    self.id = id
    self.verseText = verseText
    self.surahName = surahName
    self.surahNumber = surahNumber
    self.ayahNumber = ayahNumber
    self.pageNumber = pageNumber
  }
}
