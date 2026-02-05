//
//  AlKetabModels.swift
//  AlKetab AI Search
//
//  Response models for AlKetab Quran Search API
//

import Foundation

// MARK: - Main Response

// MARK: - API Response Wrapper

/// The top-level response from the AlKetab API.
///
/// The API wraps the actual search data in a `search` object and provides metadata like `success` status.
struct AlKetabResponse: Decodable {
    /// Whether the request was successful
    let success: Bool
    /// The main search payload (optional, only present on success)
    let search: AlKetabSearch?
    /// AI-specific metadata like explanations and generated queries
    let ai: AlKetabAI?
    
    enum CodingKeys: String, CodingKey {
        case success
        case search
        case ai
    }
}

// MARK: - Sort Order

enum SortOrder: String, CaseIterable, Identifiable {
    case relevance = "score"
    case mushaf = "mushaf"
    case revelation = "tanzil"
    case alphabetical = "alphabet"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .relevance: return "Relevance"
        case .mushaf: return "Mushaf Order"
        case .revelation: return "Revelation Order"
        case .alphabetical: return "Alphabetical"
        }
    }
}

// MARK: - AI Section

struct AlKetabAI: Decodable {
    let explain: String?
    let generatedQuery: String?
    let sortBy: String?
    let userQuery: String?
    let queryLanguage: String?
    let userQueryProofread: String?
    let aiTimingMS: Int?
    
    enum CodingKeys: String, CodingKey {
        case explain
        case generatedQuery = "generated_query"
        case sortBy = "sort_by"
        case userQuery = "user_query"
        case queryLanguage = "query_language"
        case userQueryProofread = "proofread_user_query"
        case aiTimingMS = "ai_timing_ms"
    }
    
    /// Convert sortBy string to SortOrder enum
    var sortOrder: SortOrder {
        guard let sortBy = sortBy else { return .mushaf }
        return SortOrder(rawValue: sortBy) ?? .mushaf
    }
}

// MARK: - Search Section

/// Contains the actual search results and metadata.
struct AlKetabSearch: Decodable {
    /// Dictionary of Ayah matches, keyed by a unique ID string.
    let ayas: [String: AlKetabAyaWrapper]?
    /// Pagination information (start, end, total, page).
    let interval: AlKetabInterval?
    /// Server processing time in seconds.
    let runtime: Double?
    /// Word frequency data for the charts.
    let words: Words?
}

struct AlKetabInterval: Decodable {
    let start: Int?
    let end: Int?
    let page: Int?
    let nbPages: Int?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case start, end, page, total
        case nbPages = "nb_pages"
    }
}

// MARK: - Aya Wrapper

struct AlKetabAyaWrapper: Decodable {
    let aya: AlKetabAya?
    let identifier: AlKetabIdentifier?
    let position: AlKetabPosition?
    let sura: AlKetabSura?
    let theme: AlKetabTheme?
    let sajda: AlKetabSajda?
    let stat: AlKetabStat?
}

// MARK: - Aya

// MARK: - Adjacent Aya
struct AlKetabAdjacentAya: Decodable {
    let id: Int?
    let sura: String?
    let suraArabic: String?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case id, sura, text
        case suraArabic = "sura_arabic"
    }
}

// MARK: - Aya

struct AlKetabAya: Decodable {
    let id: Int?
    let text: String?  // With HTML highlight
    let textNoHighlight: String?  // Plain text
    let recitation: String?
    let translation: String?
    let nextAya: AlKetabAdjacentAya?
    let prevAya: AlKetabAdjacentAya?
    
    enum CodingKeys: String, CodingKey {
        case id, text, recitation, translation
        case textNoHighlight = "text_no_highlight"
        case nextAya = "next_aya"
        case prevAya = "prev_aya"
    }
}

// MARK: - Identifier

struct AlKetabIdentifier: Decodable {
    let ayaId: Int?
    let gid: Int?
    let suraId: Int?
    let suraName: String?
    let suraArabicName: String?
    
    enum CodingKeys: String, CodingKey {
        case gid
        case ayaId = "aya_id"
        case suraId = "sura_id"
        case suraName = "sura_name"
        case suraArabicName = "sura_arabic_name"
    }
}

// MARK: - Position

struct AlKetabPosition: Decodable {
    let page: Int?
    let pageIN: Int?
    let juz: Int?
    let hizb: Int?
    let rub: Int?
    let manzil: Int?
    let ruku: Int?
    
    enum CodingKeys: String, CodingKey {
        case page, juz, hizb, rub, manzil, ruku
        case pageIN = "page_IN"
    }
}

// MARK: - Sura

struct AlKetabSura: Decodable {
    let id: Int?
    let name: String?
    let arabicName: String?
    let englishName: String?
    let type: String?
    let arabicType: String?
    let ayas: Int?
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, ayas, order
        case arabicName = "arabic_name"
        case englishName = "english_name"
        case arabicType = "arabic_type"
    }
}

// MARK: - Theme

struct AlKetabTheme: Decodable {
    let chapter: String?
    let topic: String?
    let subtopic: String?
}

// MARK: - Sajda

struct AlKetabSajda: Decodable {
    let exist: Bool?
    let id: Int?
    let type: String?
}

// MARK: - Stat

struct AlKetabStat: Decodable {
    let letters: Int?
    let words: Int?
    let godnames: Int?
}

// MARK: - Result Models (for UI consumption)

struct AlKetabSearchResult {
    var verses: [AlKetabVerse]
    let pagination: AlKetabPagination
    let runtime: Double
    let words: Words?
    let aiExplain: String?
    let generatedQuery: String?
    let sortBy: SortOrder
}

struct AlKetabVerse: Identifiable {
    let id: Int
    let text: String
    let textWithHighlight: String
    let surahID: Int
    let surahName: String
    let surahNameEnglish: String
    let ayahID: Int
    var pageNumber: Int
    let theme: AlKetabTheme?
    let recitationURL: String?
    let prevAyaText: String?
    let nextAyaText: String?
    let prevAyaID: Int?
    let nextAyaID: Int?
}

struct AlKetabPagination {
    let currentPage: Int
    let totalResults: Int
    let totalPages: Int
    let startIndex: Int
    let endIndex: Int
}

// MARK: - Shared Models

// MARK: - Words
struct Words: Codable {
    let individual: [Int: Individual]?
    let global: Global?
}

// MARK: - Global
struct Global: Codable {
    let nbMatches, nbWords, nbVocalizations: Int?
    
    enum CodingKeys: String, CodingKey {
        case nbMatches = "nb_matches"
        case nbWords = "nb_words"
        case nbVocalizations = "nb_vocalizations"
    }
}

// MARK: - Individual
struct Individual: Codable {
    let synonyms: [String]?
    let nbMatches: Int?
    let romanization: String?
    let vocalizations: [String]?
    let nbDerivationsExtra, nbSynonyms: Int?
    let lemma: String?
    let nbVocalizations: Int?
    let derivationsExtra: [String]?
    let nbDerivations: Int?
    let derivations: [String]?
    let nbAyas: Int?
    let root, word: String?
    
    enum CodingKeys: String, CodingKey {
        case synonyms
        case nbMatches = "nb_matches"
        case romanization, vocalizations
        case nbDerivationsExtra = "nb_derivations_extra"
        case nbSynonyms = "nb_synonyms"
        case lemma
        case nbVocalizations = "nb_vocalizations"
        case derivationsExtra = "derivations_extra"
        case nbDerivations = "nb_derivations"
        case derivations
        case nbAyas = "nb_ayas"
        case root, word
    }
}
