//
//  AttemptedExamTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import XCTest
@testable import Life_In_The_UK_Prep

@MainActor
final class AttemptedExamTests: XCTestCase {

    // MARK: - correctQuestions Tests

    func test_correctQuestions_filtersFullyAnsweredAndCorrect() {
        // Given: An exam with 2 correct, 1 incorrect, 1 unanswered
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 1,
            unansweredCount: 1
        )

        // Then: Only the 2 correctly answered questions are counted
        XCTAssertEqual(exam.correctQuestions.count, 2)
    }

    func test_correctQuestions_excludesPartiallyAnswered() {
        // Given: A multi-answer question with only partial answers
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let partiallyAnswered = TestDataFactory.makePartiallyAnsweredQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [partiallyAnswered],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )

        // Then: Partially answered is NOT counted as correct
        XCTAssertEqual(exam.correctQuestions.count, 0)
    }

    func test_correctQuestions_excludesQuestionsWithAnyWrongAnswer() {
        // Given: A multi-answer question with one correct and one wrong answer
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let oneCorrectOneWrong = TestDataFactory.makeOneCorrectOneWrongQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [oneCorrectOneWrong],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )

        // Then: Question with any wrong answer is NOT counted as correct
        XCTAssertEqual(exam.correctQuestions.count, 0)
    }

    // MARK: - incorrectQuestions Tests

    func test_incorrectQuestions_filtersQuestionsWithAllWrongAnswers() {
        // Given: An exam with mix of correct and incorrect
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )

        // Then: Only questions where ALL selections are not correct are counted
        XCTAssertEqual(exam.incorrectQuestions.count, 2)
    }

    // MARK: - unansweredQuestions Tests

    func test_unansweredQuestions_filtersNotFullyAnswered() {
        // Given: An exam with some unanswered questions
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 1,
            incorrectCount: 1,
            unansweredCount: 2
        )

        // Then: Only unanswered questions are counted
        XCTAssertEqual(exam.unansweredQuestions.count, 2)
    }

    // MARK: - Score Calculation Tests

    func test_score_calculatesRatio() {
        // Given: An exam with 2 correct out of 4 total
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 1,
            unansweredCount: 1
        )

        // Then: Score is 2/4 = 0.5
        XCTAssertEqual(exam.score, 0.5)
    }

    func test_score_allCorrect_returns1() {
        // Given: An exam where all questions are correct
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )

        // Then: Score is 1.0 (100%)
        XCTAssertEqual(exam.score, 1.0)
    }

    func test_score_allWrong_returns0() {
        // Given: An exam where all questions are wrong
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )

        // Then: Score is 0.0
        XCTAssertEqual(exam.score, 0.0)
    }

    func test_score_emptyExam_returnsZero() {
        // Given: An exam with no questions
        let exam = AttemptedExam(
            examId: 1,
            questions: [],
            status: .finished,
            dateAttempted: Date(),
            duration: 0
        )

        // Then: Score is 0.0 (handles division by zero)
        XCTAssertEqual(exam.score, 0.0)
    }

    func test_score_allUnanswered_returns0() {
        // Given: An exam where nothing is answered
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 0,
            unansweredCount: 4
        )

        // Then: Score is 0.0
        XCTAssertEqual(exam.score, 0.0)
    }

    // MARK: - Score Percentage Tests

    func test_scorePercentage_multipliesBy100() {
        // Given: An exam with 50% score
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )

        // Then: Percentage is 50.0
        XCTAssertEqual(exam.scorePercentage, 50.0)
    }

    func test_scorePercentage_perfectScore_returns100() {
        // Given: An exam with all correct
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )

        // Then: Percentage is 100.0
        XCTAssertEqual(exam.scorePercentage, 100.0)
    }

    func test_scorePercentage_zeroScore_returns0() {
        // Given: An exam with nothing correct
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )

        // Then: Percentage is 0.0
        XCTAssertEqual(exam.scorePercentage, 0.0)
    }

    func test_scorePercentage_75PercentPassingThreshold() {
        // Given: An exam with 18 correct out of 24 (passing threshold)
        var questions: [AttemptedQuestion] = []
        for i in 0..<18 {
            let q = TestDataFactory.makeSingleAnswerQuestion(id: "correct\(i)")
            questions.append(TestDataFactory.makeCorrectlyAnsweredQuestion(from: q))
        }
        for i in 0..<6 {
            let q = TestDataFactory.makeSingleAnswerQuestion(id: "wrong\(i)")
            questions.append(TestDataFactory.makeIncorrectlyAnsweredQuestion(from: q))
        }

        let exam = AttemptedExam(
            examId: 1,
            questions: questions,
            status: .finished,
            dateAttempted: Date(),
            duration: 600
        )

        // Then: Percentage is 75.0 (18/24 = 0.75)
        XCTAssertEqual(exam.scorePercentage, 75.0)
    }

    // MARK: - Multi-Answer Score Tests (Critical)

    func test_score_withMultiAnswerQuestions_calculatesCorrectly() {
        // Given: An exam with multi-answer questions
        // - 1 multi-answer all correct = CORRECT
        // - 1 multi-answer one wrong = WRONG (any wrong = entire question wrong)
        // - 1 single correct = CORRECT
        // - 1 single wrong = WRONG
        let exam = TestDataFactory.makeAttemptedExamWithMultiAnswer(
            multiAnswerAllCorrect: 1,
            multiAnswerOneWrong: 1,
            singleAnswerCorrect: 1,
            singleAnswerWrong: 1
        )

        // Then: Score is 2/4 = 50%
        XCTAssertEqual(exam.correctQuestions.count, 2)
        XCTAssertEqual(exam.score, 0.5)
        XCTAssertEqual(exam.scorePercentage, 50.0)
    }

    func test_score_multiAnswerWithOneWrong_countsAsIncorrect() {
        // Given: A multi-answer question with one correct and one wrong
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let oneCorrectOneWrong = TestDataFactory.makeOneCorrectOneWrongQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [oneCorrectOneWrong],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )

        // Then: Score is 0 (the question is wrong)
        XCTAssertEqual(exam.correctQuestions.count, 0)
        XCTAssertEqual(exam.score, 0.0)
    }

    // MARK: - Status Tests

    func test_update_status_changesExamStatus() {
        // Given: An exam with started status
        var exam = TestDataFactory.makeAttemptedExam()
        exam.update(status: .started)
        XCTAssertEqual(exam.status, .started)

        // When: Status is updated
        exam.update(status: .finished)

        // Then: Status changes
        XCTAssertEqual(exam.status, .finished)
    }

    func test_update_date_changesDateAttempted() {
        // Given: An exam
        var exam = TestDataFactory.makeAttemptedExam()
        let originalDate = exam.dateAttempted

        // When: Date is updated
        let newDate = Date().addingTimeInterval(3600)
        exam.update(date: newDate)

        // Then: Date changes
        XCTAssertNotEqual(exam.dateAttempted, originalDate)
        XCTAssertEqual(exam.dateAttempted, newDate)
    }

    func test_update_duration_changesDuration() {
        // Given: An exam
        var exam = TestDataFactory.makeAttemptedExam()
        let originalDuration = exam.duration

        // When: Duration is updated
        let newDuration: TimeInterval = 999
        exam.update(duration: newDuration)

        // Then: Duration changes
        XCTAssertNotEqual(exam.duration, originalDuration)
        XCTAssertEqual(exam.duration, newDuration)
    }

    func test_finish_setsStatusDurationAndDate() {
        // Given: An exam in progress
        var exam = TestDataFactory.makeAttemptedExam()
        exam.update(status: .started)
        let beforeFinish = Date()

        // When: Exam is finished
        exam.finish(duration: 500)

        // Then: Status, duration, and date are updated
        XCTAssertEqual(exam.status, .finished)
        XCTAssertEqual(exam.duration, 500)
        XCTAssertTrue(exam.dateAttempted >= beforeFinish)
    }

    // MARK: - Initialization Tests

    func test_init_fromExam_createsAttemptedQuestions() {
        // Given: A raw Exam
        let rawExam = TestDataFactory.makeExam(questionCount: 3)

        // When: AttemptedExam is created
        let attemptedExam = AttemptedExam(from: rawExam)

        // Then: Questions are converted to AttemptedQuestions
        XCTAssertEqual(attemptedExam.examId, rawExam.id)
        XCTAssertEqual(attemptedExam.questions.count, 3)
        XCTAssertEqual(attemptedExam.status, .attempted)
        XCTAssertEqual(attemptedExam.duration, 0)
    }
}
