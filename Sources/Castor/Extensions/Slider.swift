//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS 16, *)
@available(tvOS, unavailable)
@MainActor
public extension Slider {
    /// Creates a slider bound to a progress tracker.
    ///
    /// - Parameters:
    ///   - progressTracker: The tracker that updates the slider value.
    ///   - label: A view describing the purpose of the slider.
    ///   - minimumValueLabel: A view describing the lower bound.
    ///   - maximumValueLabel: A view describing the upper bound.
    ///   - onEditingChanged: A closure called when editing begins or ends.
    init(
        progressTracker: CastProgressTracker,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> ValueLabel,
        @ViewBuilder maximumValueLabel: () -> ValueLabel,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress),
            in: progressTracker.range,
            label: label,
            minimumValueLabel: minimumValueLabel,
            maximumValueLabel: maximumValueLabel
        ) { isEditing in
            progressTracker.isInteracting = isEditing
            onEditingChanged(isEditing)
        }
    }
}

@available(iOS 16, *)
@available(tvOS, unavailable)
@MainActor
public extension Slider where ValueLabel == EmptyView {
    /// Creates a slider bound to a progress tracker.
    ///
    /// - Parameters:
    ///   - progressTracker: The tracker that updates the slider value.
    ///   - label: A view describing the purpose of the slider.
    ///   - onEditingChanged: A closure called when editing begins or ends.
    init(
        progressTracker: CastProgressTracker,
        @ViewBuilder label: () -> Label,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress),
            in: progressTracker.range,
            label: label
        ) { isEditing in
            progressTracker.isInteracting = isEditing
            onEditingChanged(isEditing)
        }
    }
}

@available(iOS 16, *)
@available(tvOS, unavailable)
@MainActor
public extension Slider where Label == EmptyView, ValueLabel == EmptyView {
    /// Creates a slider bound to a progress tracker.
    ///
    /// - Parameters:
    ///   - progressTracker: The tracker that updates the slider value.
    ///   - onEditingChanged: A closure called when editing begins or ends.
    init(
        progressTracker: CastProgressTracker,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            value: Binding(progressTracker, at: \.progress),
            in: progressTracker.range
        ) { isEditing in
            progressTracker.isInteracting = isEditing
            onEditingChanged(isEditing)
        }
    }
}
