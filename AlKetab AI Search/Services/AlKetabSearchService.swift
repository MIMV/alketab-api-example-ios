//
//  AlKetabSearchService.swift
//  AlKetab AI Search
//
//  HTTP client for AlKetab Quran AI Search API
//

import Foundation

// MARK: - Error Types

enum AlKetabAPIError: Error, LocalizedError {
    case emptyQuery
    case invalidURL
    case networkError(String)
    case noData
    case parsingError(String)
    case apiError(Int, String)
    case noResults
    case insufficientCredits
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Search query is empty"
        case .invalidURL:
            return "Invalid search URL"
        case .networkError(let message):
            return "Connection error: \(message)"
        case .noData:
            return "No data received from server"
        case .parsingError(let message):
            return "Data parsing error: \(message)"
        case .apiError(let code, let message):
            return "Error \(code): \(message)"
        case .noResults:
            return "No results found"
        case .insufficientCredits:
            return "Service currently unavailable, please try again later"
        case .unauthorized:
            return "Unauthorized: Please update 'private let apiKey' with your own key."
        }
    }
}

// MARK: - Service

class AlKetabSearchService {
    static let shared = AlKetabSearchService()
    
    private let baseURL = "https://alketab-api.web.app/api/search"
    
    // ⚠️ TODO: Replace with your actual API Key from https://alketab-api.web.app
    // You can sign up for free to get 5000 credits.
#warning("Please enter your AlKetab API Key below and remove this warning")
    private let apiKey = "ak_xxx"
    
    private init() {}
    
    // MARK: - Step 1: AI Search
    
    /// Step 1: Perform the initial AI Search
    ///
    /// This endpoint takes a natural language query (e.g., "Stories about patience") and returns:
    /// 1. A semantic understanding of the query
    /// 2. The first page of results
    /// 3. A `generated_query` string used to fetch subsequent pages
    /// 4. An AI explanation of the results
    ///
    /// - Parameters:
    ///   - message: The user's natural language query
    func searchWithAI(
        message: String,
        completion: @escaping (Result<AlKetabSearchResult, AlKetabAPIError>) -> Void
    ) {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.emptyQuery))
            return
        }
        
        guard let url = buildURL(message: message) else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    // MARK: - Step 2: Pagination
    
    /// Step 2: Load More Results (Pagination)
    ///
    /// Pagination in AlKetab API is **stateless** but requires the `generated_query` from Step 1.
    /// You cannot pagination using the original `message` string.
    ///
    /// - Parameters:
    ///   - generatedQuery: The opaque query string returned by Step 1 (`apiResponse.ai.generatedQuery`)
    ///   - page: The page number to fetch (1-based index)
    ///   - sortBy: Sorting preference (default is Mushaf order)
    func loadMoreResults(
        generatedQuery: String,
        page: Int,
        sortBy: SortOrder = .mushaf,
        completion: @escaping (Result<AlKetabSearchResult, AlKetabAPIError>) -> Void
    ) {
        // Validation: We must have a generated_query to paginate
        guard !generatedQuery.isEmpty else {
            completion(.failure(.emptyQuery))
            return
        }
        
        guard let url = buildURL(generatedQuery: generatedQuery, page: page, sortBy: sortBy) else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    // MARK: - URL Building
    
    private func buildURL(message: String) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "message", value: message)
        ]
        return components?.url
    }
    
    private func buildURL(generatedQuery: String, page: Int, sortBy: SortOrder) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "generated_query", value: generatedQuery),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: sortBy.rawValue),
        ]
        return components?.url
    }
    
    // MARK: - Request Handling
    
    private func performRequest(
        url: URL,
        completion: @escaping (Result<AlKetabSearchResult, AlKetabAPIError>) -> Void
    ) {
        print("🚀 [AlKetabAPI] Starting Request: \(url.absoluteString)")
        
        var request = URLRequest(url: url, timeoutInterval: 60)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ [AlKetabAPI] Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [AlKetabAPI] Response Status Code: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 401:
                    print("⛔️ [AlKetabAPI] Unauthorized: Invalid API Key")
                    DispatchQueue.main.async { completion(.failure(.unauthorized)) }
                    return
                case 402:
                    print("💰 [AlKetabAPI] Payment Required: Insufficient Credits")
                    DispatchQueue.main.async { completion(.failure(.insufficientCredits)) }
                    return
                case 400:
                    print("⚠️ [AlKetabAPI] Bad Request")
                    DispatchQueue.main.async { completion(.failure(.apiError(400, "Bad Request"))) }
                    return
                default:
                    break
                }
            }
            
            guard let data = data else {
                print("⚠️ [AlKetabAPI] No Data Received")
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            
            // Log Raw JSON for developers
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 [AlKetabAPI] Raw JSON Response:")
                print("--------------------------------------------------")
                print(jsonString)
                print("--------------------------------------------------")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.parseResponse(data: data, completion: completion)
            }
        }.resume()
    }
    
    // MARK: - Response Parsing
    
    private func parseResponse(
        data: Data,
        completion: @escaping (Result<AlKetabSearchResult, AlKetabAPIError>) -> Void
    ) {
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(AlKetabResponse.self, from: data)
            
            guard apiResponse.success else {
                completion(.failure(.apiError(0, "Search failed")))
                return
            }
            
            if let result = convertAPIResponse(apiResponse) {
                completion(.success(result))
            } else {
                completion(.failure(.noResults))
            }
        } catch {
            completion(.failure(.parsingError(error.localizedDescription)))
        }
    }
    
    // MARK: - Response Conversion
    
    private func convertAPIResponse(_ apiResponse: AlKetabResponse) -> AlKetabSearchResult? {
        guard let search = apiResponse.search,
              let ayas = search.ayas, !ayas.isEmpty
        else {
            return nil
        }
        
        var verses: [AlKetabVerse] = []
        let sortedAyas = ayas.sorted { (Int($0.key) ?? 0) < (Int($1.key) ?? 0) }
        
        for (_, wrapper) in sortedAyas {
            guard let ayaData = wrapper.aya,
                  let identifier = wrapper.identifier
            else {
                continue
            }
            
            let page = wrapper.position?.page ?? 0
            
            let verse = AlKetabVerse(
                id: identifier.gid ?? 0,
                text: ayaData.textNoHighlight ?? "",
                textWithHighlight: ayaData.text ?? "",
                surahID: identifier.suraId ?? 0,
                surahName: identifier.suraArabicName ?? "",
                surahNameEnglish: identifier.suraName ?? "",
                ayahID: identifier.ayaId ?? 0,
                pageNumber: page,
                theme: wrapper.theme,
                recitationURL: ayaData.recitation,
                prevAyaText: ayaData.prevAya?.text,
                nextAyaText: ayaData.nextAya?.text,
                prevAyaID: ayaData.prevAya?.id,
                nextAyaID: ayaData.nextAya?.id
            )
            verses.append(verse)
        }
        
        let pagination = AlKetabPagination(
            currentPage: search.interval?.page ?? 1,
            totalResults: search.interval?.total ?? 0,
            totalPages: search.interval?.nbPages ?? 1,
            startIndex: search.interval?.start ?? 1,
            endIndex: search.interval?.end ?? 1
        )
        
        return AlKetabSearchResult(
            verses: verses,
            pagination: pagination,
            runtime: search.runtime ?? 0,
            words: search.words,
            aiExplain: apiResponse.ai?.explain,
            generatedQuery: apiResponse.ai?.generatedQuery,
            sortBy: apiResponse.ai?.sortOrder ?? .mushaf
        )
    }
}
