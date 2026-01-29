//
//  AttemptedExamTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Foundation
import Testing
@testable import Life_In_The_UK_Prep

@Suite("AttemptedExam Tests")
@MainActor
struct AttemptedExamTests {

    // MARK: - correctQuestions Tests

    @Test("correctQuestions filters fully answered and correct")
    func correctQuestions_filtersFullyAnsweredAndCorrect() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 1,
            unansweredCount: 1
        )

        #expect(exam.correctQuestions.count == 2)
    }

    @Test("correctQuestions excludes partially answered")
    func correctQuestions_excludesPartiallyAnswered() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let partiallyAnswered = TestDataFactory.makePartiallyAnsweredQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [partiallyAnswered],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )

        #expect(exam.correctQuestions.count == 0)
    }

    @Test("correctQuestions excludes questions with any wrong answer")
    func correctQuestions_excludesQuestionsWithAnyWrongAnswer() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let oneCorrectOneWrong = TestDataFactory.makeOneCorrectOneWrongQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [oneCorrectOneWrong],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )

        #expect(exam.correctQuestions.count == 0)
    }

    // MARK: - incorrectQuestions Tests

    @Test("incorrectQuestions filters questions with all wrong answers")
    func incorrectQuestions_filtersQuestionsWithAllWrongAnswers() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )

        #expect(exam.incorrectQuestions.count == 2)
    }

    // MARK: - unansweredQuestions Tests

    @Test("unansweredQuestions filters not fully answered")
    func unansweredQuestions_filtersNotFullyAnswered() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 1,
            incorrectCount: 1,
            unansweredCount: 2
        )

        #expect(exam.unansweredQuestions.count == 2)
    }

    // MARK: - Score Calculation Tests

    @Test("score calculates ratio correctly")
    func score_calculatesRatio() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 1,
            unansweredCount: 1
        )

        #expect(exam.score == 0.5)
    }

    @Test("score with all correct returns 1.0")
    func score_allCorrect_returns1() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )

        #expect(exam.score == 1.0)
    }

    @Test("score with all wrong returns 0.0")
    func score_allWrong_returns0() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )

        #expect(exam.score == 0.0)
    }

    @Test("score with empty exam returns zero (handles division by zero)")
    func score_emptyExam_returnsZero() {
        let exam = AttemptedExam(
            examId: 1,
            questions: [],
            status: .finished,
            dateAttempted: Date(),
            duration: 0
        )

        #expect(exam.score == 0.0)
    }

    @Test("score with all unanswered returns 0.0")
    func score_allUnanswered_returns0() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 0,
            unansweredCount: 4
        )

        #expect(exam.score == 0.0)
    }

    // MARK: - Score Percentage Tests

    @Test("scorePercentage multiplies by 100")
    func scorePercentage_multipliesBy100() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )

        #expect(exam.scorePercentage == 50.0)
    }

    @Test("scorePercentage with perfect score returns 100")
    func scorePercentage_perfectScore_returns100() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )

        #expect(exam.scorePercentage == 100.0)
    }

    @Test("scorePercentage with zero score returns 0")
    func scorePercentage_zeroScore_returns0() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )

        #expect(exam.scorePercentage == 0.0)
    }

    @Test("scorePercentage at 75% passing threshold")
    func scorePercentage_75PercentPassingThreshold() {
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

        #expect(exam.scorePercentage == 75.0)
    }

    // MARK: - Multi-Answer Score Tests (Critical)

    @Test("score with multi-answer questions calculates correctly")
    func score_withMultiAnswerQuestions_calculatesCorrectly() {
        let exam = TestDataFactory.makeAttemptedExamWithMultiAnswer(
            multiAnswerAllCorrect: 1,
            multiAnswerOneWrong: 1,
            singleAnswerCorrect: 1,
            singleAnswerWrong: 1
        )

        #expect(exam.correctQuestions.count == 2)
        #expect(exam.score == 0.5)
        #expect(exam.scorePercentage == 50.0)
    }

    @Test("multi-answer with one wrong counts as incorrect")
    func score_multiAnswerWithOneWrong_countsAsIncorrect() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let oneCorrectOneWrong = TestDataFactory.makeOneCorrectOneWrongQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [oneCorrectOneWrong],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )

        #expect(exam.correctQuestions.count == 0)
        #expect(exam.score == 0.0)
    }

    // MARK: - Status Tests

    @Test("update status changes exam status")
    func update_status_changesExamStatus() {
        var exam = TestDataFactory.makeAttemptedExam()
        exam.update(status: .started)
        #expect(exam.status == .started)

        exam.update(status: .finished)
        #expect(exam.status == .finished)
    }

    @Test("update date changes dateAttempted")
    func update_date_changesDateAttempted() {
        var exam = TestDataFactory.makeAttemptedExam()
        let originalDate = exam.dateAttempted

        let newDate = Date().addingTimeInterval(3600)
        exam.update(date: newDate)

        #expect(exam.dateAttempted != originalDate)
        #expect(exam.dateAttempted == newDate)
    }

    @Test("update duration changes duration")
    func update_duration_changesDuration() {
        var exam = TestDataFactory.makeAttemptedExam()
        let originalDuration = exam.duration

        let newDuration: TimeInterval = 999
        exam.update(duration: newDuration)

        #expect(exam.duration != originalDuration)
        #expect(exam.duration == newDuration)
    }

    @Test("finish sets status, duration, and date")
    func finish_setsStatusDurationAndDate() {
        var exam = TestDataFactory.makeAttemptedExam()
        exam.update(status: .started)
        let beforeFinish = Date()

        exam.finish(duration: 500)

        #expect(exam.status == .finished)
        #expect(exam.duration == 500)
        #expect(exam.dateAttempted >= beforeFinish)
    }

    // MARK: - Initialization Tests

    @Test("init from Exam creates AttemptedQuestions")
    func init_fromExam_createsAttemptedQuestions() {
        let rawExam = TestDataFactory.makeExam(questionCount: 3)

        let attemptedExam = AttemptedExam(from: rawExam)

        #expect(attemptedExam.examId == rawExam.id)
        #expect(attemptedExam.questions.count == 3)
        #expect(attemptedExam.status == .attempted)
        #expect(attemptedExam.duration == 0)
    }
}
