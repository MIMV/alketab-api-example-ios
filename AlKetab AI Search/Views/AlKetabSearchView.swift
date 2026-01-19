//
//  AlKetabSearchView.swift
//  AlKetab AI Search
//
//  AlKetab AI search results view
//

import SwiftUI

struct AlKetabSearchView: View {
    @ObservedObject var viewModel: AlKetabSearchViewModel
    let onClearSearch: (() -> Void)?
    
    init(
        viewModel: AlKetabSearchViewModel,
        onClearSearch: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onClearSearch = onClearSearch
    }
    
    var body: some View {
        List {
            // Loading indicator
            if viewModel.isLoadingAPI {
                loadingView
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
            
            // Error message
            if let error = viewModel.apiError {
                errorView(message: error)
                    .listRowBackground(Color.clear)
            }
            
            // Words frequency chart
            if let words = viewModel.wordsData, let nbWords = words.global?.nbWords, nbWords > 1 {
                if let nbMatches = words.global?.nbMatches, nbMatches > nbWords {
                    WordsDisplayChartView(words: words)
                        .frame(height: 390)
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
            }
            
            // AI Explanation
            if !viewModel.searchResults.isEmpty, let aiExplain = viewModel.aiExplain, !aiExplain.isEmpty {
                aiExplanationView(text: aiExplain)
                    .listRowBackground(Color.clear)
            }
            
            // Results Section
            if !viewModel.searchResults.isEmpty {
                Section {
                    ForEach(viewModel.searchResults) { result in
                        SearchResultRow(result: result)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    
                    // Load More
                    if viewModel.hasMorePages {
                        loadMoreButton
                    }
                } header: {
                    Text(
                        "Found \(viewModel.totalResults > 0 ? viewModel.totalResults : viewModel.searchResults.count) Verses"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .textCase(nil)
                }
            }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.accentColor)
                
                Text("AI search in progress...")
                    .font(.headline)
                
                Text("This may take a moment while we analyze the Quran")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.vertical, 40)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                onClearSearch?()
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private func aiExplanationView(text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.indigo)
                Text("AI Analysis")
                    .font(.headline)
                    .foregroundStyle(.indigo)
            }
            
            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .lineSpacing(6)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.indigo.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.indigo.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var loadMoreButton: some View {
        Button {
            viewModel.loadMoreResults()
        } label: {
            HStack {
                Spacer()
                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding(.horizontal, 8)
                    Text("Loading more...")
                } else {
                    Text("Load More Results (\(viewModel.currentPage)/\(viewModel.totalPages))")
                        .fontWeight(.medium)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .disabled(viewModel.isLoadingMore)
    }
}
