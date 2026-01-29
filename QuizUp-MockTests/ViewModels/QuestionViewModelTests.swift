//
//  QuestionViewModelTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Testing
@testable import Life_In_The_UK_Prep

@Suite("QuestionViewModel Tests")
@MainActor
struct QuestionViewModelTests {

    // MARK: - Selection Tests (Single Answer)

    @Test("Selecting correct answer calls progressToNextQuestions")
    func selected_correctAnswer_singleAnswer_callsProgressToNext() async {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let correctChoice = question.choices[0]
        vm.selected(correctChoice)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockOwner.progressToNextCalled)
        #expect(mockOwner.progressToNextCallCount == 1)
    }

    @Test("Selecting wrong answer calls allowProgressToNextQuestion")
    func selected_wrongAnswer_callsAllowProgressToNext() async {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let wrongChoice = question.choices[1]
        vm.selected(wrongChoice)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockOwner.allowProgressCalled)
        #expect(mockOwner.allowProgressCallCount == 1)
    }

    @Test("Selecting wrong answer shows hint")
    func selected_wrongAnswer_showsHint() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)
        #expect(!vm.showHint)

        let wrongChoice = question.choices[1]
        vm.selected(wrongChoice)

        #expect(vm.showHint)
    }

    @Test("Selecting correct answer does not show hint")
    func selected_correctAnswer_doesNotShowHint() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let correctChoice = question.choices[0]
        vm.selected(correctChoice)

        #expect(!vm.showHint)
    }

    // MARK: - Selection Tests (Multi Answer)

    @Test("Multi-answer: first correct answer does not progress")
    func selected_multiAnswer_firstCorrect_doesNotProgress() async {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let firstCorrect = question.choices[0]
        vm.selected(firstCorrect)

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(!mockOwner.progressToNextCalled)
        #expect(!mockOwner.allowProgressCalled)
    }

    @Test("Multi-answer: all correct answers calls progressToNext")
    func selected_multiAnswer_allCorrect_callsProgressToNext() async {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[0])
        vm.selected(question.choices[1])

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockOwner.progressToNextCalled)
    }

    @Test("Multi-answer: one correct one wrong calls allowProgress")
    func selected_multiAnswer_oneCorrectOneWrong_callsAllowProgress() async {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[0]) // Correct
        vm.selected(question.choices[2]) // Wrong

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(mockOwner.allowProgressCalled)
    }

    @Test("Multi-answer: wrong answer shows hint")
    func selected_multiAnswer_wrongAnswer_showsHint() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[2]) // Wrong

        #expect(vm.showHint)
    }

    // MARK: - State Tests

    @Test("selectedChoices updates question model")
    func selectedChoices_updatesQuestionModel() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let choice = question.choices[0]
        vm.selected(choice)

        #expect(vm.question.selectedChoices[choice] == .correct)
    }

    @Test("allowChoiceSelection returns false when fully answered")
    func allowChoiceSelection_whenFullyAnswered_returnsFalse() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        #expect(vm.allowChoiceSelection)

        vm.selected(question.choices[0])

        #expect(!vm.allowChoiceSelection)
    }

    @Test("allAnswersSelected matches required count")
    func allAnswersSelected_matchesRequiredCount() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        #expect(!vm.allAnswersSelected)

        vm.selected(question.choices[0])
        #expect(!vm.allAnswersSelected)

        vm.selected(question.choices[1])
        #expect(vm.allAnswersSelected)
    }

    // MARK: - state(for:) Tests

    @Test("state for selected correct answer returns .correct")
    func state_forSelectedCorrectAnswer_returnsCorrect() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let correctChoice = question.choices[0]
        vm.selected(correctChoice)

        #expect(vm.state(for: correctChoice) == .correct)
    }

    @Test("state for selected wrong answer returns .wrong")
    func state_forSelectedWrongAnswer_returnsWrong() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let wrongChoice = question.choices[1]
        vm.selected(wrongChoice)

        #expect(vm.state(for: wrongChoice) == .wrong)
    }

    @Test("state for unselected answer after wrong answer reveals correct")
    func state_forUnselectedAnswer_afterWrongAnswer_revealsCorrect() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[1])

        let correctChoice = question.choices[0]
        #expect(vm.state(for: correctChoice) == .correct)
    }

    // MARK: - Reset Tests

    @Test("reset clears all state")
    func reset_clearsAllState() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[1]) // wrong
        #expect(!vm.selectedChoices.isEmpty)
        #expect(vm.showHint)
        #expect(vm.attempts == 1)

        vm.reset()

        #expect(vm.selectedChoices.isEmpty)
        #expect(!vm.showHint)
        #expect(vm.attempts == 0)
    }

    // MARK: - Finish Tests

    @Test("finish returns AttemptedQuestion with selections")
    func finish_returnsAttemptedQuestionWithSelections() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[0])
        vm.bookmarked = true

        let finished = vm.finish()

        #expect(finished.selectedChoices.count == 1)
        #expect(finished.selectedChoices[question.choices[0]] == .correct)
        #expect(finished.bookmarked)
    }

    // MARK: - Prompt Tests

    @Test("prompt for single answer shows 'select ONE'")
    func prompt_singleAnswer_showsSelectOne() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        #expect(vm.prompt == "Please select ONE answer")
    }

    @Test("prompt for two answers shows 'select TWO'")
    func prompt_twoAnswers_showsSelectTwo() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        #expect(vm.prompt == "Please select TWO answers")
    }

    @Test("prompt for three or more answers shows 'select MULTIPLE'")
    func prompt_threeOrMoreAnswers_showsSelectMultiple() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1, 2])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        #expect(vm.prompt == "Please select MULTIPLE answers")
    }

    // MARK: - Bookmark Tests

    @Test("bookmarked toggles question bookmark")
    func bookmarked_togglesQuestionBookmark() {
        let mockOwner = MockQuestionOwner()
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        #expect(!vm.bookmarked)
        #expect(!vm.question.bookmarked)

        vm.bookmarked = true

        #expect(vm.bookmarked)
        #expect(vm.question.bookmarked)
    }
}
