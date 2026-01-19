//
//  AlKetabSearchViewModel.swift
//  AlKetab AI Search
//
//  ViewModel for AlKetab AI Search state management
//

import Combine
import Foundation

class AlKetabSearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isLoadingAPI: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var apiError: String?
    
    // AI-specific data
    @Published var aiExplain: String?
    @Published var wordsData: Words?
    
    // Pagination state
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var hasMorePages: Bool = false
    @Published var totalResults: Int = 0
    
    // Sort state
    @Published var sortBy: SortOrder = .mushaf
    
    // Current search query
    @Published var searchQuery: String = ""
    
    // Generated query for pagination (Step 2)
    private var generatedQuery: String?
    
    private let apiService = AlKetabSearchService.shared
    
    // MARK: - Computed Properties
    
    private var trimmedQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Public Methods
    
    /// Perform AI search with natural language message
    func performAISearch() {
        guard trimmedQuery.count >= 2 else { return }
        
        // Clear all previous data
        searchResults = []
        wordsData = nil
        aiExplain = nil
        generatedQuery = nil
        hasMorePages = false
        totalPages = 1
        totalResults = 0
        currentPage = 1
        apiError = nil
        
        isLoadingAPI = true
        
        let query = trimmedQuery
        
        apiService.searchWithAI(message: query) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingAPI = false
            
            switch result {
            case .success(let apiResult):
                self.handleSearchSuccess(apiResult)
                
            case .failure(let error):
                self.handleSearchError(error)
            }
        }
    }
    
    /// Load more results (pagination using generated_query)
    func loadMoreResults() {
        guard !isLoadingMore && hasMorePages else { return }
        guard let generatedQuery = generatedQuery, !generatedQuery.isEmpty else {
            print("⚠️ No generated_query available for pagination")
            return
        }
        
        let nextPage = currentPage + 1
        isLoadingMore = true
        apiError = nil
        
        apiService.loadMoreResults(
            generatedQuery: generatedQuery,
            page: nextPage,
            sortBy: sortBy
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingMore = false
            
            switch result {
            case .success(let apiResult):
                // Append new results
                let newResults = apiResult.verses.map { self.convertToSearchResult($0) }
                self.searchResults.append(contentsOf: newResults)
                self.currentPage = apiResult.pagination.currentPage
                self.totalPages = apiResult.pagination.totalPages
                self.hasMorePages = apiResult.pagination.currentPage < apiResult.pagination.totalPages
                
            case .failure(let error):
                self.apiError = error.localizedDescription
            }
        }
    }
    
    /// Change sort order and re-run the search
    func changeSortOrder(to newSortBy: SortOrder) {
        guard sortBy != newSortBy else { return }
        
        sortBy = newSortBy
        
        // Re-run search with new sort order if we have results
        if !searchResults.isEmpty {
            performAISearch()
        }
    }
    
    /// Clear all search data
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        isLoadingAPI = false
        isLoadingMore = false
        apiError = nil
        wordsData = nil
        aiExplain = nil
        generatedQuery = nil
        currentPage = 1
        totalPages = 1
        hasMorePages = false
        totalResults = 0
    }
    
    // MARK: - Private Methods
    
    private func handleSearchSuccess(_ apiResult: AlKetabSearchResult) {
        // Store generated query for pagination
        generatedQuery = apiResult.generatedQuery
        
        // Update AI explanation
        aiExplain = apiResult.aiExplain
        
        // Store words data for charts
        wordsData = apiResult.words
        
        // Update sort order from AI suggestion
        sortBy = apiResult.sortBy
        
        // Convert and store results
        searchResults = apiResult.verses.map { convertToSearchResult($0) }
        
        // Update pagination state
        currentPage = apiResult.pagination.currentPage
        totalPages = apiResult.pagination.totalPages
        hasMorePages = apiResult.pagination.currentPage < apiResult.pagination.totalPages
        totalResults = apiResult.pagination.totalResults
    }
    
    private func handleSearchError(_ error: AlKetabAPIError) {
        searchResults = []
        wordsData = nil
        aiExplain = nil
        generatedQuery = nil
        hasMorePages = false
        currentPage = 1
        totalPages = 1
        totalResults = 0
        
        apiError = error.localizedDescription
    }
    
    /// Convert AlKetabVerse to SearchResult for UI compatibility
    private func convertToSearchResult(_ verse: AlKetabVerse) -> SearchResult {
        SearchResult(
            id: verse.id,
            verseText: verse.textWithHighlight,
            surahName: verse.surahNameEnglish,  // Using English name for English app
            surahNumber: verse.surahID,
            ayahNumber: verse.ayahID,
            pageNumber: verse.pageNumber
        )
    }
}
