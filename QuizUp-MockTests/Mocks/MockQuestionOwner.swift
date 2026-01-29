//
//  MockQuestionOwner.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Foundation
@testable import Life_In_The_UK_Prep

/// Mock implementation of QuestionOwner protocol for testing QuestionViewModel
@MainActor
class MockQuestionOwner: QuestionOwner {

    // MARK: - Call Tracking

    var progressToNextCalled = false
    var progressToNextCallCount = 0

    var allowProgressCalled = false
    var allowProgressCallCount = 0

    // MARK: - QuestionOwner Protocol

    func progressToNextQuestions() async {
        progressToNextCalled = true
        progressToNextCallCount += 1
    }

    func allowProgressToNextQuestion() async {
        allowProgressCalled = true
        allowProgressCallCount += 1
    }

    // MARK: - Test Helpers

    func reset() {
        progressToNextCalled = false
        progressToNextCallCount = 0
        allowProgressCalled = false
        allowProgressCallCount = 0
    }
}
