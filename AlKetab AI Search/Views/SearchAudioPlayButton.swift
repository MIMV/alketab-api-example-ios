//
//  SearchAudioPlayButton.swift
//  AlKetab AI Search
//
//  A simple play/stop button that integrates with SearchAudioPlayerManager.
//

import SwiftUI

struct SearchAudioPlayButton: View {
    let audioURLString: String?
    
    @StateObject private var audioManager = SearchAudioPlayerManager.shared
    
    var body: some View {
        Button(action: {
            guard let urlString = audioURLString, let url = URL(string: urlString) else { return }
            audioManager.toggle(url: url)
        }) {
            ZStack {
                Circle()
                    .fill(isPlaying ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isPlaying ? .red : .accentColor)
            }
        }
        .disabled(audioURLString == nil)
        .opacity(audioURLString == nil ? 0.5 : 1.0)
    }
    
    private var isPlaying: Bool {
        guard let urlString = audioURLString, let url = URL(string: urlString) else { return false }
        return audioManager.playingURL == url
    }
}
