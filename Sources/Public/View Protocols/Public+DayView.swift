//
//  DayView.swift of CalendarView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public protocol DayView: View {
    // MARK: Attributes
    var date: Date { get }
    var isCurrentMonth: Bool { get }
    var selectedDate: Binding<Date?>? { get }
    var selectedRange: Binding<MDateRange?>? { get }

    // MARK: Associated Types
    associatedtype ContentViewType: View
    associatedtype DayLabelViewType: View
    associatedtype SelectionViewType: View
    associatedtype RangeSelectionViewType: View

    // MARK: View Customisation
    func createContent() -> ContentViewType
    func createDayLabel() -> DayLabelViewType
    func createSelectionView() -> SelectionViewType
    func createRangeSelectionView() -> RangeSelectionViewType

    // MARK: Logic
    func onAppear()
    func onSelection()
}

// MARK: - Default View Implementation
public extension DayView {
    func createContent() -> some View { createDefaultContent() }
    func createDayLabel() -> some View { createDefaultDayLabel() }
    func createSelectionView() -> some View { createDefaultSelectionView() }
    func createRangeSelectionView() -> some View { createDefaultRangeSelectionView() }
}
private extension DayView {
    func createDefaultContent() -> some View { ZStack {
        createSelectionView()
        createRangeSelectionView()
        createDayLabel()
    }}
    func createDefaultDayLabel() -> some View {
        Text(getStringFromDay(format: "d"))
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected() ? .backgroundPrimary : .onBackgroundPrimary)
    }
    func createDefaultSelectionView() -> some View {
        Circle()
            .fill(Color.onBackgroundPrimary)
            .transition(.asymmetric(insertion: .scale(scale: 0.52).combined(with: .opacity), removal: .opacity))
            .active(if: isSelected())
    }
    func createDefaultRangeSelectionView() -> some View {
        RoundedRectangle(corners: rangeSelectionViewCorners)
            .fill(Color.onBackgroundPrimary.opacity(0.12))
            .transition(.opacity)
            .active(if: isWithinRange())
    }
}
private extension DayView {
    var rangeSelectionViewCorners: RoundedRectangle.Corner { 
        if isBeginningOfRange() { return [.topLeft, .bottomLeft] }
        if isEndOfRange() { return [.topRight, .bottomRight] }

        return []
    }
}

// MARK: - Default Logic Implementation
public extension DayView {
    func onAppear() {}
    func onSelection() { selectedDate?.wrappedValue = date }
}

// MARK: - Helpers

// MARK: Text Formatting
public extension DayView {
    /// Returns a string of the selected format for the date.
    func getStringFromDay(format: String) -> String { MDateFormatter.getString(from: date, format: format) }
}

// MARK: Date Helpers
public extension DayView {
    func isPast() -> Bool { date.isBefore(.day, than: .now) }
    func isToday() -> Bool { date.isSame(.day, as: .now) }
}

// MARK: Day Selection Helpers
public extension DayView {
    func isSelected() -> Bool { date.isSame(.day, as: selectedDate?.wrappedValue) || isBeginningOfRange() || isEndOfRange() }
}

// MARK: Range Selection Helpers
public extension DayView {
    func isBeginningOfRange() -> Bool { date.isSame(.day, as: selectedRange?.wrappedValue?.getRange()?.lowerBound) }
    func isEndOfRange() -> Bool { date.isSame(.day, as: selectedRange?.wrappedValue?.getRange()?.upperBound) }
    func isWithinRange() -> Bool { selectedRange?.wrappedValue?.isRangeCompleted() == true && selectedRange?.wrappedValue?.contains(date) == true }
}

// MARK: - Others
public extension DayView {
    var body: some View { Group {
        if isCurrentMonth { createBodyForCurrentMonth() }
        else { createBodyForOtherMonth() }
    }}
}
private extension DayView {
    func createBodyForCurrentMonth() -> some View {
        createContent()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
            .onAppear(perform: onAppear)
            .onTapGesture(perform: onSelection)
    }
    func createBodyForOtherMonth() -> some View { Rectangle().fill(Color.clear) }
}

