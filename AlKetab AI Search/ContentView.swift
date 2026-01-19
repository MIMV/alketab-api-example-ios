//
//  ContentView.swift
//  AlKetab AI Search
//
//  Created by AlKetab Team on 1/19/26.
//  Copyright © 2026 AlKetab. All rights reserved.
//
//  This is an EXAMPLE PROJECT demonstrating how to integrate the AlKetab AI Search API.
//  It shows:
//  1. Sending natural language queries to the AI endpoint.
//  2. Handling the AI explanation and generated metadata.
//  3. Implementing pagination using the `generated_query` token.
//  4. Visualizing word frequency data.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AlKetabSearchViewModel()
    @State private var isSearchFocused_local = false  // cannot use FocusState directly in animation block sometimes, using state for ID
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    if !viewModel.searchResults.isEmpty || viewModel.isLoadingAPI || viewModel.apiError != nil
                    {
                        // Results Mode
                        AlKetabSearchView(
                            viewModel: viewModel,
                            onClearSearch: {
                                withAnimation {
                                    viewModel.clearSearch()
                                    isFocused = true
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // Empty State / Search Mode
                        emptyStateView
                            .transition(.opacity)
                    }
                }
            }
            .navigationTitle(viewModel.searchResults.isEmpty ? "" : "AlKetab AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.searchResults.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                viewModel.clearSearch()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 24))
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer(minLength: 60)
                
                // Logo / Header
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .yellow, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("AlKetab AI Search")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                    
                    Text("Explore the Quran with Intelligence")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Search Input
                VStack(spacing: 24) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.title2)
                        
                        TextField("Ask anything about the Quran...", text: $viewModel.searchQuery)
                            .font(.title3)
                            .focused($isFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                withAnimation {
                                    viewModel.performAISearch()
                                }
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    Button {
                        withAnimation {
                            isFocused = false
                            viewModel.performAISearch()
                        }
                    } label: {
                        Text("Search Quran")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.accentColor, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                
                // Examples / Hints
                VStack(spacing: 20) {
                    Text("Try asking:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        exampleButton("The greatest Ayah in the Quran")
                        exampleButton("How many times was Prophet Mousa mentioned?")
                        exampleButton("Verses about patience and prayer")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private func exampleButton(_ text: String) -> some View {
        Button {
            viewModel.searchQuery = text
            // delay slightly to show text populate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isFocused = false
                    viewModel.performAISearch()
                }
            }
        } label: {
            HStack {
                Text(text)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
                Image(systemName: "arrow.up.left")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ContentView()
}
