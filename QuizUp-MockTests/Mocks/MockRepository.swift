//
//  MockRepository.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Foundation
@testable import Life_In_The_UK_Prep

/// Mock implementation of Repository protocol for testing
class MockRepository: Repository {

    // MARK: - Configurable Return Values

    var examsToReturn: [Exam] = []
    var examToReturn: Exam?
    var shouldThrowError: Bool = false
    var errorToThrow: Error = ExamRepositoryErrors.ExamNotFound

    // MARK: - Call Tracking

    var loadMockExamsCallCount = 0
    var loadMockExamCallCount = 0
    var loadMockExamLastId: Int?
    var saveExamCallCount = 0
    var savedExams: [AttemptedExam] = []
    var saveResultCallCount = 0
    var savedResults: [ExamResultViewModel] = []
    var resetCallCount = 0

    // MARK: - Repository Protocol

    func loadMockExams() async throws -> [Exam] {
        loadMockExamsCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        return examsToReturn
    }

    func loadMockExam(with withId: Int) async throws -> Exam {
        loadMockExamCallCount += 1
        loadMockExamLastId = withId
        if shouldThrowError {
            throw errorToThrow
        }
        if let exam = examToReturn {
            return exam
        }
        // Return a default exam if none configured
        return Exam(id: withId, questions: [])
    }

    func save(exam: AttemptedExam) async throws {
        saveExamCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        savedExams.append(exam)
    }

    func save(result: ExamResultViewModel) async throws {
        saveResultCallCount += 1
        if shouldThrowError {
            throw errorToThrow
        }
        savedResults.append(result)
    }

    func reset() {
        resetCallCount += 1
        examsToReturn = []
        examToReturn = nil
        savedExams = []
        savedResults = []
        shouldThrowError = false
    }

    // MARK: - Test Helpers

    func resetCallCounts() {
        loadMockExamsCallCount = 0
        loadMockExamCallCount = 0
        loadMockExamLastId = nil
        saveExamCallCount = 0
        resetCallCount = 0
    }
}
