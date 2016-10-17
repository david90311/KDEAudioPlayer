//
//  AudioPlayer+QualityAdjustmentEvent.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 03/04/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import AVFoundation

extension AudioPlayer {
    func handleQualityEvent(from producer: EventProducer, with event: QualityAdjustmentEventProducer.QualityAdjustmentEvent) {
        //Early exit if user doesn't want to adjust quality
        guard adjustQualityAutomatically else {
            return
        }

        switch event {
        case .goDown:
            guard let quality = AudioQuality(rawValue: currentQuality.rawValue - 1) else {
                return
            }
            changeQuality(to: quality)

        case .goUp:
            guard let quality = AudioQuality(rawValue: currentQuality.rawValue + 1) else {
                return
            }
            changeQuality(to: quality)
        }
    }

    private func changeQuality(to newQuality: AudioQuality) {
        guard let url = currentItem?.soundURLs[newQuality] else {
            return
        }

        let cip = currentItemProgression
        let item = AVPlayerItem(url: url)

        qualityIsBeingChanged = true
        player?.replaceCurrentItem(with: item)
        if let cip = cip {
            //We can't call self.seek(to:) in here since the player is loading a new
            //item and `cip` is probably not in the seekableTimeRanges.
            player?.seek(to: CMTime(timeInterval: cip))
        }
        qualityIsBeingChanged = false

        currentQuality = newQuality
    }
}
