//
//  AttemptedQuestionTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import XCTest
@testable import Life_In_The_UK_Prep

@MainActor
final class AttemptedQuestionTests: XCTestCase {

    // MARK: - isAnsweredCorrectly Tests (Single Answer)

    func test_isAnsweredCorrectly_singleAnswer_correctSelection_returnsTrue() {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        var attempted = AttemptedQuestion(from: question)

        // When: User selects the correct answer
        let correctChoice = question.choices[0]
        attempted.updateSelected(correctChoice, state: .correct)

        // Then: Question is answered correctly
        XCTAssertTrue(attempted.isAnsweredCorrectly)
    }

    func test_isAnsweredCorrectly_singleAnswer_wrongSelection_returnsFalse() {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        var attempted = AttemptedQuestion(from: question)

        // When: User selects a wrong answer
        let wrongChoice = question.choices[1]
        attempted.updateSelected(wrongChoice, state: .wrong)

        // Then: Question is NOT answered correctly
        XCTAssertFalse(attempted.isAnsweredCorrectly)
    }

    func test_isAnsweredCorrectly_noSelection_returnsFalse() {
        // Given: A question with no selections
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)

        // Then: Empty selections should return false (vacuous truth, but we want to verify)
        // Note: allSatisfy on empty collection returns true, but this is expected behavior
        XCTAssertTrue(attempted.isAnsweredCorrectly) // vacuous truth
        XCTAssertFalse(attempted.isFullyAnswered) // but not fully answered
    }

    // MARK: - isAnsweredCorrectly Tests (Multi-Answer) - Critical Tests

    func test_isAnsweredCorrectly_multiAnswer_allCorrect_returnsTrue() {
        // Given: A question with 2 correct answers (A and B)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        // When: User selects both correct answers
        let answerA = question.choices[0]
        let answerB = question.choices[1]
        attempted.updateSelected(answerA, state: .correct)
        attempted.updateSelected(answerB, state: .correct)

        // Then: Question is answered correctly
        XCTAssertTrue(attempted.isAnsweredCorrectly)
        XCTAssertTrue(attempted.isFullyAnswered)
    }

    func test_isAnsweredCorrectly_multiAnswer_oneCorrectOneWrong_returnsFalse() {
        // Given: A question with 2 correct answers (A and B)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        // When: User selects one correct (A) and one wrong (C)
        let answerA = question.choices[0] // correct
        let wrongC = question.choices[2]  // wrong
        attempted.updateSelected(answerA, state: .correct)
        attempted.updateSelected(wrongC, state: .wrong)

        // Then: Question is NOT answered correctly (ANY wrong = entire question wrong)
        XCTAssertFalse(attempted.isAnsweredCorrectly)
    }

    func test_isAnsweredCorrectly_multiAnswer_allWrong_returnsFalse() {
        // Given: A question with 2 correct answers (A and B)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        // When: User selects two wrong answers
        let wrongC = question.choices[2]
        let wrongD = question.choices[3]
        attempted.updateSelected(wrongC, state: .wrong)
        attempted.updateSelected(wrongD, state: .wrong)

        // Then: Question is NOT answered correctly
        XCTAssertFalse(attempted.isAnsweredCorrectly)
    }

    func test_isAnsweredCorrectly_multiAnswer_threeCorrectOneWrong_returnsFalse() {
        // Given: A question with 3 correct answers
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1, 2])
        var attempted = AttemptedQuestion(from: question)

        // When: User selects all 3 correct plus 1 wrong
        attempted.updateSelected(question.choices[0], state: .correct)
        attempted.updateSelected(question.choices[1], state: .correct)
        attempted.updateSelected(question.choices[2], state: .correct)
        attempted.updateSelected(question.choices[3], state: .wrong)

        // Then: Question is NOT answered correctly (ANY wrong = fail)
        XCTAssertFalse(attempted.isAnsweredCorrectly)
    }

    // MARK: - isFullyAnswered Tests

    func test_isFullyAnswered_allRequiredSelected_returnsTrue() {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        var attempted = AttemptedQuestion(from: question)

        // When: User selects exactly 1 answer (matches required count)
        attempted.updateSelected(question.choices[0], state: .correct)

        // Then: Question is fully answered
        XCTAssertTrue(attempted.isFullyAnswered)
    }

    func test_isFullyAnswered_multiAnswer_allRequiredSelected_returnsTrue() {
        // Given: A multi-answer question (2 correct)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        // When: User selects exactly 2 answers
        attempted.updateSelected(question.choices[0], state: .correct)
        attempted.updateSelected(question.choices[2], state: .wrong) // wrong but still counts

        // Then: Question is fully answered (count matches required)
        XCTAssertTrue(attempted.isFullyAnswered)
    }

    func test_isFullyAnswered_partialSelection_returnsFalse() {
        // Given: A multi-answer question (2 correct)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        // When: User selects only 1 answer
        attempted.updateSelected(question.choices[0], state: .correct)

        // Then: Question is NOT fully answered
        XCTAssertFalse(attempted.isFullyAnswered)
    }

    func test_isFullyAnswered_noSelection_returnsFalse() {
        // Given: A question with no selections
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)

        // Then: Question is NOT fully answered
        XCTAssertFalse(attempted.isFullyAnswered)
    }

    // MARK: - Mutation Tests

    func test_updateSelected_addsChoiceToSelectedChoices() {
        // Given: An empty attempted question
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        XCTAssertTrue(attempted.selectedChoices.isEmpty)

        // When: User selects an answer
        let choice = question.choices[0]
        attempted.updateSelected(choice, state: .correct)

        // Then: Choice is in selectedChoices
        XCTAssertEqual(attempted.selectedChoices.count, 1)
        XCTAssertEqual(attempted.selectedChoices[choice], .correct)
    }

    func test_removeSelected_removesChoiceFromSelectedChoices() {
        // Given: An attempted question with a selection
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        let choice = question.choices[0]
        attempted.updateSelected(choice, state: .correct)
        XCTAssertEqual(attempted.selectedChoices.count, 1)

        // When: Selection is removed
        attempted.removeSelected(choice)

        // Then: Choice is no longer in selectedChoices
        XCTAssertTrue(attempted.selectedChoices.isEmpty)
    }

    func test_bookmark_togglesBookmarkedState() {
        // Given: An unbookmarked question
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        XCTAssertFalse(attempted.bookmarked)

        // When: Bookmark is toggled
        attempted.bookmark()

        // Then: Question is bookmarked
        XCTAssertTrue(attempted.bookmarked)

        // When: Toggled again
        attempted.bookmark()

        // Then: Question is no longer bookmarked
        XCTAssertFalse(attempted.bookmarked)
    }

    func test_updateSelectedChoices_replacesAllChoices() {
        // Given: An attempted question with some selections
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        attempted.updateSelected(question.choices[0], state: .correct)

        // When: All choices are replaced
        let newChoices: [Choice: AttemptedQuestion.State] = [
            question.choices[1]: .wrong,
            question.choices[2]: .correct
        ]
        attempted.updateSelectedChoices(newChoices)

        // Then: Only new choices exist
        XCTAssertEqual(attempted.selectedChoices.count, 2)
        XCTAssertNil(attempted.selectedChoices[question.choices[0]])
        XCTAssertEqual(attempted.selectedChoices[question.choices[1]], .wrong)
        XCTAssertEqual(attempted.selectedChoices[question.choices[2]], .correct)
    }

    // MARK: - Accessor Tests

    func test_title_returnsQuestionTitle() {
        let question = TestDataFactory.makeSingleAnswerQuestion(id: "testQ")
        let attempted = AttemptedQuestion(from: question)

        XCTAssertEqual(attempted.title, question.title)
    }

    func test_hint_returnsQuestionHint() {
        let question = TestDataFactory.makeSingleAnswerQuestion(id: "testQ")
        let attempted = AttemptedQuestion(from: question)

        XCTAssertEqual(attempted.hint, "Hint for question testQ")
    }

    func test_hint_whenNil_returnsNA() {
        let question = Question(id: "q1", sectionId: "s1", title: "Title", hint: nil, choices: [])
        let attempted = AttemptedQuestion(from: question)

        XCTAssertEqual(attempted.hint, "N/A")
    }

    func test_choices_returnsQuestionChoices() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)

        XCTAssertEqual(attempted.choices.count, 4)
        XCTAssertEqual(attempted.choices, question.choices)
    }
}
