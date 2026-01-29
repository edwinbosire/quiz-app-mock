//
//  AttemptedQuestionTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Testing
@testable import Life_In_The_UK_Prep

@Suite("AttemptedQuestion Tests")
@MainActor
struct AttemptedQuestionTests {

    // MARK: - isAnsweredCorrectly Tests (Single Answer)

    @Test("Single answer - correct selection returns true")
    func isAnsweredCorrectly_singleAnswer_correctSelection_returnsTrue() {
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        var attempted = AttemptedQuestion(from: question)

        let correctChoice = question.choices[0]
        attempted.updateSelected(correctChoice, state: .correct)

        #expect(attempted.isAnsweredCorrectly)
    }

    @Test("Single answer - wrong selection returns false")
    func isAnsweredCorrectly_singleAnswer_wrongSelection_returnsFalse() {
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        var attempted = AttemptedQuestion(from: question)

        let wrongChoice = question.choices[1]
        attempted.updateSelected(wrongChoice, state: .wrong)

        #expect(!attempted.isAnsweredCorrectly)
    }

    @Test("No selection - vacuous truth for isAnsweredCorrectly but not fully answered")
    func isAnsweredCorrectly_noSelection() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)

        // Note: allSatisfy on empty collection returns true (vacuous truth)
        #expect(attempted.isAnsweredCorrectly)
        #expect(!attempted.isFullyAnswered)
    }

    // MARK: - isAnsweredCorrectly Tests (Multi-Answer) - Critical Tests

    @Test("Multi-answer - all correct returns true")
    func isAnsweredCorrectly_multiAnswer_allCorrect_returnsTrue() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        let answerA = question.choices[0]
        let answerB = question.choices[1]
        attempted.updateSelected(answerA, state: .correct)
        attempted.updateSelected(answerB, state: .correct)

        #expect(attempted.isAnsweredCorrectly)
        #expect(attempted.isFullyAnswered)
    }

    @Test("Multi-answer - one correct one wrong returns false (ANY wrong = entire question wrong)")
    func isAnsweredCorrectly_multiAnswer_oneCorrectOneWrong_returnsFalse() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        let answerA = question.choices[0] // correct
        let wrongC = question.choices[2]  // wrong
        attempted.updateSelected(answerA, state: .correct)
        attempted.updateSelected(wrongC, state: .wrong)

        #expect(!attempted.isAnsweredCorrectly)
    }

    @Test("Multi-answer - all wrong returns false")
    func isAnsweredCorrectly_multiAnswer_allWrong_returnsFalse() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        let wrongC = question.choices[2]
        let wrongD = question.choices[3]
        attempted.updateSelected(wrongC, state: .wrong)
        attempted.updateSelected(wrongD, state: .wrong)

        #expect(!attempted.isAnsweredCorrectly)
    }

    @Test("Multi-answer - three correct plus one wrong returns false")
    func isAnsweredCorrectly_multiAnswer_threeCorrectOneWrong_returnsFalse() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1, 2])
        var attempted = AttemptedQuestion(from: question)

        attempted.updateSelected(question.choices[0], state: .correct)
        attempted.updateSelected(question.choices[1], state: .correct)
        attempted.updateSelected(question.choices[2], state: .correct)
        attempted.updateSelected(question.choices[3], state: .wrong)

        #expect(!attempted.isAnsweredCorrectly)
    }

    // MARK: - isFullyAnswered Tests

    @Test("Single answer - all required selected returns true")
    func isFullyAnswered_allRequiredSelected_returnsTrue() {
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        var attempted = AttemptedQuestion(from: question)

        attempted.updateSelected(question.choices[0], state: .correct)

        #expect(attempted.isFullyAnswered)
    }

    @Test("Multi-answer - all required selected returns true")
    func isFullyAnswered_multiAnswer_allRequiredSelected_returnsTrue() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        attempted.updateSelected(question.choices[0], state: .correct)
        attempted.updateSelected(question.choices[2], state: .wrong) // wrong but still counts

        #expect(attempted.isFullyAnswered)
    }

    @Test("Multi-answer - partial selection returns false")
    func isFullyAnswered_partialSelection_returnsFalse() {
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        var attempted = AttemptedQuestion(from: question)

        attempted.updateSelected(question.choices[0], state: .correct)

        #expect(!attempted.isFullyAnswered)
    }

    @Test("No selection returns false for isFullyAnswered")
    func isFullyAnswered_noSelection_returnsFalse() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)

        #expect(!attempted.isFullyAnswered)
    }

    // MARK: - Mutation Tests

    @Test("updateSelected adds choice to selectedChoices")
    func updateSelected_addsChoiceToSelectedChoices() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        #expect(attempted.selectedChoices.isEmpty)

        let choice = question.choices[0]
        attempted.updateSelected(choice, state: .correct)

        #expect(attempted.selectedChoices.count == 1)
        #expect(attempted.selectedChoices[choice] == .correct)
    }

    @Test("removeSelected removes choice from selectedChoices")
    func removeSelected_removesChoiceFromSelectedChoices() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        let choice = question.choices[0]
        attempted.updateSelected(choice, state: .correct)
        #expect(attempted.selectedChoices.count == 1)

        attempted.removeSelected(choice)

        #expect(attempted.selectedChoices.isEmpty)
    }

    @Test("bookmark toggles bookmarked state")
    func bookmark_togglesBookmarkedState() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        #expect(!attempted.bookmarked)

        attempted.bookmark()
        #expect(attempted.bookmarked)

        attempted.bookmark()
        #expect(!attempted.bookmarked)
    }

    @Test("updateSelectedChoices replaces all choices")
    func updateSelectedChoices_replacesAllChoices() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        var attempted = AttemptedQuestion(from: question)
        attempted.updateSelected(question.choices[0], state: .correct)

        let newChoices: [Choice: AttemptedQuestion.State] = [
            question.choices[1]: .wrong,
            question.choices[2]: .correct
        ]
        attempted.updateSelectedChoices(newChoices)

        #expect(attempted.selectedChoices.count == 2)
        #expect(attempted.selectedChoices[question.choices[0]] == nil)
        #expect(attempted.selectedChoices[question.choices[1]] == .wrong)
        #expect(attempted.selectedChoices[question.choices[2]] == .correct)
    }

    // MARK: - Accessor Tests

    @Test("title returns question title")
    func title_returnsQuestionTitle() {
        let question = TestDataFactory.makeSingleAnswerQuestion(id: "testQ")
        let attempted = AttemptedQuestion(from: question)

        #expect(attempted.title == question.title)
    }

    @Test("hint returns question hint")
    func hint_returnsQuestionHint() {
        let question = TestDataFactory.makeSingleAnswerQuestion(id: "testQ")
        let attempted = AttemptedQuestion(from: question)

        #expect(attempted.hint == "Hint for question testQ")
    }

    @Test("hint returns N/A when nil")
    func hint_whenNil_returnsNA() {
        let question = Question(id: "q1", sectionId: "s1", title: "Title", hint: nil, choices: [])
        let attempted = AttemptedQuestion(from: question)

        #expect(attempted.hint == "N/A")
    }

    @Test("choices returns question choices")
    func choices_returnsQuestionChoices() {
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)

        #expect(attempted.choices.count == 4)
        #expect(attempted.choices == question.choices)
    }
}
