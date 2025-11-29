//
// PlatformSupport.swift
// AvoidObstaclesGame
//

import Foundation

#if os(macOS)
import AppKit
typealias PlatformColor = NSColor
typealias PlatformView = NSView
#else
import UIKit
typealias PlatformColor = UIColor
typealias PlatformView = UIView
#endif

class PlatformSupport {
    static let shared = PlatformSupport()
    
    var isTouch: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
    
    var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    func getOptimalSettings() -> GameConfiguration {
        var config = GameConfiguration.load()
        
        #if os(macOS)
        // macOS optimizations
        var visual = config.visual
        visual = GameConfiguration.Visual(
            theme: visual.theme,
            particleQuality: "high",
            frameRateCap: 120,
            showFPS: visual.showFPS
        )
        
        return GameConfiguration(
            player: config.player,
            obstacle: config.obstacle,
            difficulty: config.difficulty,
            audio: config.audio,
            accessibility: config.accessibility,
            visual: visual
        )
        #else
        return config
        #endif
    }
}
