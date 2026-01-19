//
//  WordsDisplayChartView.swift
//  AlKetab AI Search
//
//  Display-only chart view for word frequency
//

import Charts
import SwiftUI

struct WordsDisplayChartView: View {
    let words: Words
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Quran Word Frequency")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Total Matches: \(words.global?.nbMatches ?? 0)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Chart
            chartView
                .frame(height: 220)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            // Legend
            legendView
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            Divider()
                .padding(.horizontal)
            
            // Words List
            wordsListView
                .frame(height: 80)
        }
    }
    
    // MARK: - Chart View
    
    private var chartView: some View {
        let chartData = prepareChartData()
        let nbWords = words.global?.nbWords ?? 0
        
        return Chart {
            ForEach(chartData, id: \.word) { dataPoint in
                wordMatchesLine(for: dataPoint, nbWords: nbWords)
                ayahCountLine(for: dataPoint, nbWords: nbWords)
                areaGradient(for: dataPoint)
            }
        }
        .chartXAxis {
            chartXAxisContent(nbWords: nbWords)
        }
        .chartYAxis {
            chartYAxisContent()
        }
    }
    
    // MARK: - Chart Components
    
    @ChartContentBuilder
    private func wordMatchesLine(for dataPoint: ChartDataPoint, nbWords: Int) -> some ChartContent {
        LineMark(
            x: .value("Word", dataPoint.word),
            y: .value("Frequency", dataPoint.wordMatches)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        .interpolationMethod(.catmullRom)
        .symbol {
            Circle()
                .fill(Color.accentColor)
                .frame(width: nbWords <= 10 ? 8 : 0, height: nbWords <= 10 ? 8 : 0)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 2)
                }
        }
    }
    
    @ChartContentBuilder
    private func ayahCountLine(for dataPoint: ChartDataPoint, nbWords: Int) -> some ChartContent {
        LineMark(
            x: .value("Word", dataPoint.word),
            y: .value("Ayahs", dataPoint.ayahCount)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [Color.purple, Color.purple.opacity(0.7)],  // Using Purple as Alt
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        .interpolationMethod(.catmullRom)
        .symbol {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.purple)
                .frame(width: nbWords <= 10 ? 8 : 0, height: nbWords <= 10 ? 8 : 0)
                .overlay {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(.white, lineWidth: 2)
                }
        }
    }
    
    @ChartContentBuilder
    private func areaGradient(for dataPoint: ChartDataPoint) -> some ChartContent {
        AreaMark(
            x: .value("Word", dataPoint.word),
            y: .value("Frequency", dataPoint.wordMatches)
        )
        .foregroundStyle(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.05), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .interpolationMethod(.catmullRom)
    }
    
    @AxisContentBuilder
    private func chartXAxisContent(nbWords: Int) -> some AxisContent {
        if nbWords <= 40 {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let word = value.as(String.self) {
                        Text(word)
                            .font(.system(size: nbWords > 20 ? 8 : 10))
                            .rotationEffect(.degrees(-45))
                    }
                }
                AxisGridLine()
            }
        } else {
            AxisMarks { _ in
                AxisGridLine()
            }
        }
    }
    
    @AxisContentBuilder
    private func chartYAxisContent() -> some AxisContent {
        AxisMarks(position: .trailing) { value in
            AxisValueLabel {
                if let intValue = value.as(Int.self) {
                    Text("\(intValue)")
                        .font(.system(size: 12, weight: .thin))
                }
            }
            AxisGridLine()
        }
    }
    
    // MARK: - Legend View
    
    private var legendView: some View {
        HStack(spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
                
                Text("Word Count")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.purple)
                    .frame(width: 12, height: 12)
                
                Text("Ayah Count")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    // MARK: - Words List View
    
    private var wordsListView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if let individual = words.individual {
                    let sortedKeys = individual.keys.sorted(by: >)
                    
                    ForEach(sortedKeys, id: \.self) { key in
                        if let wordData = individual[key] {
                            WordDisplayBadge(
                                word: wordData.word ?? "",
                                nbMatches: wordData.nbMatches ?? 0,
                                nbAyas: wordData.nbAyas ?? 0
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Data Preparation
    
    private func prepareChartData() -> [ChartDataPoint] {
        let nbWords = words.global?.nbWords ?? 0
        let nbWordsTrimed = min(nbWords, 100)
        let individual = words.individual
        
        var dataPoints: [ChartDataPoint] = []
        
        for n in (1...nbWordsTrimed).reversed() {
            guard let wordData = individual?[n] else { continue }
            
            dataPoints.append(
                ChartDataPoint(
                    word: wordData.word ?? "",
                    wordMatches: wordData.nbMatches ?? 0,
                    ayahCount: wordData.nbAyas ?? 0
                ))
        }
        
        return dataPoints
    }
}

// MARK: - Chart Data Point Model

private struct ChartDataPoint {
    let word: String
    let wordMatches: Int
    let ayahCount: Int
}

// MARK: - Word Display Badge

private struct WordDisplayBadge: View {
    let word: String
    let nbMatches: Int
    let nbAyas: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(word)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(minWidth: 80)
            
            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    Image(systemName: "repeat")
                        .font(.system(size: 10))
                    Text("\(nbMatches)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.secondary)
                
                Divider()
                    .frame(height: 12)
                
                HStack(spacing: 2) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 10))
                    Text("\(nbAyas)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.quaternarySystemFill))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
