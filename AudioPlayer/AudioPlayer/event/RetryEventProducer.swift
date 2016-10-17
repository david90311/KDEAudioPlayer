//
//  RetryEventProducer.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 10/04/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import Foundation

private extension Selector {
    /// The selector to call when the timer ticks.
    static let timerTicked = #selector(RetryEventProducer.timerTicked(_:))
}

/**
 *  A `RetryEventProducer` generates `RetryEvent`s when there should be a retry based on some
 *  information about interruptions.
 */
class RetryEventProducer: NSObject, EventProducer {
    /**
     `RetryEvent` is a list of event that can be generated by `RetryEventProducer`.

     - retryAvailable: A retry is available.
     - retryFailed:    Retrying is no longer an option.
     */
    enum RetryEvent: Event {
        case retryAvailable
        case retryFailed
    }

    /// The timer used to adjust quality
    private var timer: Timer?

    /// The listener that will be alerted a new event occured.
    weak var eventListener: EventListener?

    /// A boolean value indicating whether we're currently producing events or not.
    private var listening = false

    /// Interruption counter. It will be used to determine whether the quality should change.
    private var retryCount = 0

    /// The maximum number of interruption before generating an event. Default value is 10.
    var maximumRetryCount = 10

    /// The delay to wait before cancelling last retry and retrying. Default value is 10 seconds.
    var retryTimeout = TimeInterval(10)


    /**
     Stops producing events on deinitialization.
     */
    deinit {
        stopProducingEvents()
    }

    /**
     Starts listening to the player events.
     */
    func startProducingEvents() {
        guard !listening else {
            return
        }

        //Reset state
        retryCount = 0

        //Creates a new timer for next retry
        restartTimer()

        //Saving that we're currently listening
        listening = true
    }

    /**
     Stops listening to the player events.
     */
    func stopProducingEvents() {
        guard listening else {
            return
        }

        timer?.invalidate()
        timer = nil

        //Saving that we're not listening anymore
        listening = false
    }

    /**
     Stops the current timer if any and restart a new one.
     */
    private func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: retryTimeout,
            target: self,
            selector: .timerTicked,
            userInfo: nil,
            repeats: false)
    }

    /**
     The retry timer ticked.
     */
    @objc fileprivate func timerTicked(_: AnyObject) {
        retryCount += 1

        if retryCount < maximumRetryCount {
            eventListener?.onEvent(RetryEvent.retryAvailable, generetedBy: self)

            restartTimer()
        } else {
            eventListener?.onEvent(RetryEvent.retryFailed, generetedBy: self)
        }
    }
}
