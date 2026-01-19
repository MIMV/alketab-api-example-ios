//
//  SearchAudioPlayerManager.swift
//  AlKetab AI Search
//
//  Singleton manager for simple audio playback in search results.
//  Handles playing one track at a time.
//

import AVFoundation
import Combine
import Foundation

class SearchAudioPlayerManager: ObservableObject {
    static let shared = SearchAudioPlayerManager()
    
    @Published var playingURL: URL?
    
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Setup audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    /// Play audio from a URL. If something is already playing, it stops first.
    func play(url: URL) {
        // Stop current if different or restart if same?
        // Requirement is simple: Play.
        stop()
        
        let playerItem = AVPlayerItem(url: url)
        
        // Observe end of playback
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.stop()
            }
            .store(in: &cancellables)
        
        player = AVPlayer(playerItem: playerItem)
        player?.play()
        
        playingURL = url
    }
    
    /// Stop current playback
    func stop() {
        player?.pause()
        player = nil
        playingURL = nil
        cancellables.removeAll()
    }
    
    /// Toggle playback for a URL
    func toggle(url: URL) {
        if playingURL == url {
            stop()
        } else {
            play(url: url)
        }
    }
}
