//
//  ExamResultViewModelTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Foundation
import Testing
@testable import Life_In_The_UK_Prep

@Suite("ExamResultViewModel Tests")
@MainActor
struct ExamResultViewModelTests {

    // MARK: - Score Formatting Tests

    @Test("score formats as ratio")
    func score_formatsAsRatio() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 1,
            unansweredCount: 1
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.score == "3 / 5")
    }

    @Test("score with all correct shows full ratio")
    func score_allCorrect_showsFullRatio() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.score == "4 / 4")
    }

    @Test("score with all wrong shows zero ratio")
    func score_allWrong_showsZeroRatio() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.score == "0 / 4")
    }

    // MARK: - Formatted Percentage Score Tests

    @Test("formattedPercentageScore formats with percent")
    func formattedPercentageScore_formatsWithPercent() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.formattedPercentageScore == "75 %")
    }

    @Test("formattedPercentageScore with perfect score shows 100")
    func formattedPercentageScore_perfectScore_shows100() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.formattedPercentageScore == "100 %")
    }

    @Test("formattedPercentageScore with zero score returns dash")
    func formattedPercentageScore_zeroScore_returnsDash() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.formattedPercentageScore == "-")
    }

    // MARK: - Prompt Tests (Pass/Fail)

    @Test("prompt with passing score shows congratulations")
    func prompt_passingScore_showsCongratulations() {
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
        let result = ExamResultViewModel(exam: exam)

        #expect(result.prompt == "Congratulation! You've passed the test")
    }

    @Test("prompt with above passing score shows congratulations")
    func prompt_abovePassingScore_showsCongratulations() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.prompt == "Congratulation! You've passed the test")
    }

    @Test("prompt with failing score shows fail message")
    func prompt_failingScore_showsFailMessage() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.prompt == "Your score is below the 75% pass mark")
    }

    @Test("prompt barely failing shows fail message")
    func prompt_barelyFailing_showsFailMessage() {
        var questions: [AttemptedQuestion] = []
        for i in 0..<74 {
            let q = TestDataFactory.makeSingleAnswerQuestion(id: "correct\(i)")
            questions.append(TestDataFactory.makeCorrectlyAnsweredQuestion(from: q))
        }
        for i in 0..<26 {
            let q = TestDataFactory.makeSingleAnswerQuestion(id: "wrong\(i)")
            questions.append(TestDataFactory.makeIncorrectlyAnsweredQuestion(from: q))
        }

        let exam = AttemptedExam(
            examId: 1,
            questions: questions,
            status: .finished,
            dateAttempted: Date(),
            duration: 1000
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.prompt == "Your score is below the 75% pass mark")
    }

    // MARK: - Score Percentage Tests

    @Test("scorePercentage matches exam percentage")
    func scorePercentage_matchesExamPercentage() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.scorePercentage == exam.scorePercentage)
        #expect(result.scorePercentage == 50.0)
    }

    // MARK: - Question Access Tests

    @Test("correctQuestions matches exam correctQuestions")
    func correctQuestions_matchesExamCorrectQuestions() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.correctQuestions.count == 3)
        #expect(result.correctQuestions.count == exam.correctQuestions.count)
    }

    @Test("incorrectQuestions matches exam incorrectQuestions")
    func incorrectQuestions_matchesExamIncorrectQuestions() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 1,
            incorrectCount: 3,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.incorrectQuestions.count == 3)
        #expect(result.incorrectQuestions.count == exam.incorrectQuestions.count)
    }

    // MARK: - Questions ViewModels Tests

    @Test("questionsViewModels creates ViewModels for all questions")
    func questionsViewModels_createsViewModelsForAllQuestions() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 1,
            unansweredCount: 1
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.questionsViewModels.count == 4)
    }

    @Test("questionsViewModels preserves selected choices")
    func questionsViewModels_preservesSelectedChoices() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 1,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        let firstVM = result.questionsViewModels[0]
        #expect(!firstVM.selectedChoices.isEmpty)
    }

    @Test("questionsViewModels has correct indices")
    func questionsViewModels_hasCorrectIndices() {
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 0,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        for (index, vm) in result.questionsViewModels.enumerated() {
            #expect(vm.index == index)
        }
    }

    // MARK: - Date Tests

    @Test("date matches exam dateAttempted")
    func date_matchesExamDateAttempted() {
        let specificDate = Date(timeIntervalSince1970: 1000000)
        let exam = AttemptedExam(
            examId: 1,
            questions: [],
            status: .finished,
            dateAttempted: specificDate,
            duration: 100
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.date == specificDate)
    }

    @Test("formattedDate uses localized format")
    func formattedDate_usesLocalizedFormat() {
        let exam = TestDataFactory.makeAttemptedExam()
        let result = ExamResultViewModel(exam: exam)

        #expect(!result.formattedDate.isEmpty)
    }

    // MARK: - Multi-Answer Score Tests (Critical)

    @Test("score with multi-answer questions counts correctly")
    func score_withMultiAnswerQuestions_countsCorrectly() {
        let exam = TestDataFactory.makeAttemptedExamWithMultiAnswer(
            multiAnswerAllCorrect: 1,
            multiAnswerOneWrong: 1,
            singleAnswerCorrect: 1,
            singleAnswerWrong: 1
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.score == "2 / 4")
        #expect(result.scorePercentage == 50.0)
        #expect(result.formattedPercentageScore == "50 %")
    }

    @Test("multi-answer with any wrong counts as incorrect")
    func score_multiAnswerWithAnyWrong_countsAsIncorrect() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let oneCorrectOneWrong = TestDataFactory.makeOneCorrectOneWrongQuestion(from: question)

        let exam = AttemptedExam(
            examId: 1,
            questions: [oneCorrectOneWrong],
            status: .finished,
            dateAttempted: Date(),
            duration: 100
        )
        let result = ExamResultViewModel(exam: exam)

        #expect(result.score == "0 / 1")
        #expect(result.prompt == "Your score is below the 75% pass mark")
    }

    // MARK: - Initialization Tests

    @Test("init sets examId from exam")
    func init_setsExamIdFromExam() {
        let exam = AttemptedExam(
            examId: 42,
            questions: [],
            status: .finished,
            dateAttempted: Date(),
            duration: 0
        )

        let result = ExamResultViewModel(exam: exam)

        #expect(result.examId == 42)
    }

    @Test("init generates unique ID")
    func init_generatesUniqueId() {
        let exam = TestDataFactory.makeAttemptedExam()
        let result1 = ExamResultViewModel(exam: exam)
        let result2 = ExamResultViewModel(exam: exam)

        #expect(result1.id != result2.id)
    }
}
