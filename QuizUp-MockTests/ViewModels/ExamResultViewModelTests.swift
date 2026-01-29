//
//  ExamResultViewModelTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import XCTest
@testable import Life_In_The_UK_Prep

@MainActor
final class ExamResultViewModelTests: XCTestCase {

    // MARK: - Score Formatting Tests

    func test_score_formatsAsRatio() {
        // Given: An exam with 3 correct out of 5
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 1,
            unansweredCount: 1
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Score is formatted as "3 / 5"
        XCTAssertEqual(result.score, "3 / 5")
    }

    func test_score_allCorrect_showsFullRatio() {
        // Given: An exam with all correct
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Score shows 4 / 4
        XCTAssertEqual(result.score, "4 / 4")
    }

    func test_score_allWrong_showsZeroRatio() {
        // Given: An exam with none correct
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Score shows 0 / 4
        XCTAssertEqual(result.score, "0 / 4")
    }

    // MARK: - Formatted Percentage Score Tests

    func test_formattedPercentageScore_formatsWithPercent() {
        // Given: An exam with 75% score
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Shows "75 %"
        XCTAssertEqual(result.formattedPercentageScore, "75 %")
    }

    func test_formattedPercentageScore_perfectScore_shows100() {
        // Given: An exam with 100% score
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 0,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Shows "100 %"
        XCTAssertEqual(result.formattedPercentageScore, "100 %")
    }

    func test_formattedPercentageScore_zeroScore_returnsDash() {
        // Given: An exam with 0% score
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 0,
            incorrectCount: 4,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Shows "-"
        XCTAssertEqual(result.formattedPercentageScore, "-")
    }

    // MARK: - Prompt Tests (Pass/Fail)

    func test_prompt_passingScore_showsCongratulations() {
        // Given: An exam with 75% score (passing threshold)
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

        // Then: Shows congratulations
        XCTAssertEqual(result.prompt, "Congratulation! You've passed the test")
    }

    func test_prompt_abovePassingScore_showsCongratulations() {
        // Given: An exam with 80% score (above passing)
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 4,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Shows congratulations
        XCTAssertEqual(result.prompt, "Congratulation! You've passed the test")
    }

    func test_prompt_failingScore_showsFailMessage() {
        // Given: An exam below 75%
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Shows fail message
        XCTAssertEqual(result.prompt, "Your score is below the 75% pass mark")
    }

    func test_prompt_barelyFailing_showsFailMessage() {
        // Given: An exam with 74% score (just below passing)
        // 74/100 requires careful construction
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

        // Then: Shows fail message (74% < 75%)
        XCTAssertEqual(result.prompt, "Your score is below the 75% pass mark")
    }

    // MARK: - Score Percentage Tests

    func test_scorePercentage_matchesExamPercentage() {
        // Given: An exam
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 2,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Percentage matches exam
        XCTAssertEqual(result.scorePercentage, exam.scorePercentage)
        XCTAssertEqual(result.scorePercentage, 50.0)
    }

    // MARK: - Question Access Tests

    func test_correctQuestions_matchesExamCorrectQuestions() {
        // Given: An exam with known correct questions
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Correct questions match
        XCTAssertEqual(result.correctQuestions.count, 3)
        XCTAssertEqual(result.correctQuestions.count, exam.correctQuestions.count)
    }

    func test_incorrectQuestions_matchesExamIncorrectQuestions() {
        // Given: An exam with known incorrect questions
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 1,
            incorrectCount: 3,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Incorrect questions match
        XCTAssertEqual(result.incorrectQuestions.count, 3)
        XCTAssertEqual(result.incorrectQuestions.count, exam.incorrectQuestions.count)
    }

    // MARK: - Questions ViewModels Tests

    func test_questionsViewModels_createsViewModelsForAllQuestions() {
        // Given: An exam with 4 questions
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 2,
            incorrectCount: 1,
            unansweredCount: 1
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: ViewModels are created for all questions
        XCTAssertEqual(result.questionsViewModels.count, 4)
    }

    func test_questionsViewModels_preservesSelectedChoices() {
        // Given: An exam with answered questions
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 1,
            incorrectCount: 1,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: ViewModels have pre-populated selections
        let firstVM = result.questionsViewModels[0]
        XCTAssertFalse(firstVM.selectedChoices.isEmpty)
    }

    func test_questionsViewModels_hasCorrectIndices() {
        // Given: An exam
        let exam = TestDataFactory.makeAttemptedExam(
            correctCount: 3,
            incorrectCount: 0,
            unansweredCount: 0
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Each VM has correct index
        for (index, vm) in result.questionsViewModels.enumerated() {
            XCTAssertEqual(vm.index, index)
        }
    }

    // MARK: - Date Tests

    func test_date_matchesExamDateAttempted() {
        // Given: An exam with specific date
        let specificDate = Date(timeIntervalSince1970: 1000000)
        let exam = AttemptedExam(
            examId: 1,
            questions: [],
            status: .finished,
            dateAttempted: specificDate,
            duration: 100
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Date matches
        XCTAssertEqual(result.date, specificDate)
    }

    func test_formattedDate_usesLocalizedFormat() {
        // Given: A result
        let exam = TestDataFactory.makeAttemptedExam()
        let result = ExamResultViewModel(exam: exam)

        // Then: Formatted date is not empty
        XCTAssertFalse(result.formattedDate.isEmpty)
    }

    // MARK: - Multi-Answer Score Tests (Critical)

    func test_score_withMultiAnswerQuestions_countsCorrectly() {
        // Given: An exam with multi-answer questions
        // - 1 multi-answer all correct = CORRECT
        // - 1 multi-answer one wrong = WRONG
        // - 1 single correct = CORRECT
        // - 1 single wrong = WRONG
        let exam = TestDataFactory.makeAttemptedExamWithMultiAnswer(
            multiAnswerAllCorrect: 1,
            multiAnswerOneWrong: 1,
            singleAnswerCorrect: 1,
            singleAnswerWrong: 1
        )
        let result = ExamResultViewModel(exam: exam)

        // Then: Score is 2/4 = 50%
        XCTAssertEqual(result.score, "2 / 4")
        XCTAssertEqual(result.scorePercentage, 50.0)
        XCTAssertEqual(result.formattedPercentageScore, "50 %")
    }

    func test_score_multiAnswerWithAnyWrong_countsAsIncorrect() {
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
        let result = ExamResultViewModel(exam: exam)

        // Then: Score is 0/1 (any wrong = entire question wrong)
        XCTAssertEqual(result.score, "0 / 1")
        XCTAssertEqual(result.prompt, "Your score is below the 75% pass mark")
    }

    // MARK: - Initialization Tests

    func test_init_setsExamIdFromExam() {
        // Given: An exam with specific ID
        let exam = AttemptedExam(
            examId: 42,
            questions: [],
            status: .finished,
            dateAttempted: Date(),
            duration: 0
        )

        // When: Result is created
        let result = ExamResultViewModel(exam: exam)

        // Then: examId is set
        XCTAssertEqual(result.examId, 42)
    }

    func test_init_generatesUniqueId() {
        // Given: Two results from same exam
        let exam = TestDataFactory.makeAttemptedExam()
        let result1 = ExamResultViewModel(exam: exam)
        let result2 = ExamResultViewModel(exam: exam)

        // Then: IDs are unique
        XCTAssertNotEqual(result1.id, result2.id)
    }
}
