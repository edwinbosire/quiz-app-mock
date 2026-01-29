//
//  QuestionViewModelTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import XCTest
@testable import Life_In_The_UK_Prep

@MainActor
final class QuestionViewModelTests: XCTestCase {

    var mockOwner: MockQuestionOwner!

    override func setUp() {
        super.setUp()
        mockOwner = MockQuestionOwner()
    }

    override func tearDown() {
        mockOwner = nil
        super.tearDown()
    }

    // MARK: - Selection Tests (Single Answer)

    func test_selected_correctAnswer_singleAnswer_callsProgressToNext() async {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects the correct answer
        let correctChoice = question.choices[0]
        vm.selected(correctChoice)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: progressToNextQuestions is called
        XCTAssertTrue(mockOwner.progressToNextCalled)
        XCTAssertEqual(mockOwner.progressToNextCallCount, 1)
    }

    func test_selected_wrongAnswer_callsAllowProgressToNext() async {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects a wrong answer
        let wrongChoice = question.choices[1]
        vm.selected(wrongChoice)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: allowProgressToNextQuestion is called
        XCTAssertTrue(mockOwner.allowProgressCalled)
        XCTAssertEqual(mockOwner.allowProgressCallCount, 1)
    }

    func test_selected_wrongAnswer_showsHint() {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)
        XCTAssertFalse(vm.showHint)

        // When: User selects a wrong answer
        let wrongChoice = question.choices[1]
        vm.selected(wrongChoice)

        // Then: Hint is shown
        XCTAssertTrue(vm.showHint)
    }

    func test_selected_correctAnswer_doesNotShowHint() {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects the correct answer
        let correctChoice = question.choices[0]
        vm.selected(correctChoice)

        // Then: Hint is NOT shown
        XCTAssertFalse(vm.showHint)
    }

    // MARK: - Selection Tests (Multi Answer)

    func test_selected_multiAnswer_firstCorrect_doesNotProgress() async {
        // Given: A multi-answer question (2 correct: A and B)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects first correct answer
        let firstCorrect = question.choices[0]
        vm.selected(firstCorrect)

        // Wait for any async task
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: Neither progress nor allowProgress is called (waiting for more)
        XCTAssertFalse(mockOwner.progressToNextCalled)
        XCTAssertFalse(mockOwner.allowProgressCalled)
    }

    func test_selected_multiAnswer_allCorrect_callsProgressToNext() async {
        // Given: A multi-answer question (2 correct: A and B)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects both correct answers
        vm.selected(question.choices[0]) // First correct
        vm.selected(question.choices[1]) // Second correct

        // Wait for async task
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: progressToNextQuestions is called
        XCTAssertTrue(mockOwner.progressToNextCalled)
    }

    func test_selected_multiAnswer_oneCorrectOneWrong_callsAllowProgress() async {
        // Given: A multi-answer question (2 correct: A and B)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects one correct (A) and one wrong (C)
        vm.selected(question.choices[0]) // Correct
        vm.selected(question.choices[2]) // Wrong

        // Wait for async task
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then: allowProgressToNextQuestion is called (wrong answer)
        XCTAssertTrue(mockOwner.allowProgressCalled)
    }

    func test_selected_multiAnswer_wrongAnswer_showsHint() {
        // Given: A multi-answer question
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects a wrong answer
        vm.selected(question.choices[2]) // Wrong

        // Then: Hint is shown
        XCTAssertTrue(vm.showHint)
    }

    // MARK: - State Tests

    func test_selectedChoices_updatesQuestionModel() {
        // Given: A question
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // When: User selects an answer
        let choice = question.choices[0]
        vm.selected(choice)

        // Then: Question model is updated via didSet
        XCTAssertEqual(vm.question.selectedChoices[choice], .correct)
    }

    func test_allowChoiceSelection_whenFullyAnswered_returnsFalse() {
        // Given: A question with answer selected
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // Initially can select
        XCTAssertTrue(vm.allowChoiceSelection)

        // When: User fully answers
        vm.selected(question.choices[0])

        // Then: Cannot select more
        XCTAssertFalse(vm.allowChoiceSelection)
    }

    func test_allAnswersSelected_matchesRequiredCount() {
        // Given: A multi-answer question (2 required)
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // Initially false
        XCTAssertFalse(vm.allAnswersSelected)

        // After 1 selection
        vm.selected(question.choices[0])
        XCTAssertFalse(vm.allAnswersSelected)

        // After 2 selections (matches required)
        vm.selected(question.choices[1])
        XCTAssertTrue(vm.allAnswersSelected)
    }

    // MARK: - state(for:) Tests

    func test_state_forSelectedCorrectAnswer_returnsCorrect() {
        // Given: A question with correct answer selected
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let correctChoice = question.choices[0]
        vm.selected(correctChoice)

        // Then: State returns .correct
        XCTAssertEqual(vm.state(for: correctChoice), .correct)
    }

    func test_state_forSelectedWrongAnswer_returnsWrong() {
        // Given: A question with wrong answer selected
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        let wrongChoice = question.choices[1]
        vm.selected(wrongChoice)

        // Then: State returns .wrong
        XCTAssertEqual(vm.state(for: wrongChoice), .wrong)
    }

    func test_state_forUnselectedAnswer_afterWrongAnswer_revealsCorrect() {
        // Given: A question where user answered wrong
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // User selects wrong
        vm.selected(question.choices[1])

        // Then: The correct answer is revealed
        let correctChoice = question.choices[0]
        XCTAssertEqual(vm.state(for: correctChoice), .correct)
    }

    // MARK: - Reset Tests

    func test_reset_clearsAllState() {
        // Given: A question with selections and state
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[1]) // wrong
        XCTAssertFalse(vm.selectedChoices.isEmpty)
        XCTAssertTrue(vm.showHint)
        XCTAssertEqual(vm.attempts, 1)

        // When: Reset is called
        vm.reset()

        // Then: All state is cleared
        XCTAssertTrue(vm.selectedChoices.isEmpty)
        XCTAssertFalse(vm.showHint)
        XCTAssertEqual(vm.attempts, 0)
    }

    // MARK: - Finish Tests

    func test_finish_returnsAttemptedQuestionWithSelections() {
        // Given: A question with selections
        let question = TestDataFactory.makeSingleAnswerQuestion(correctIndex: 0)
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        vm.selected(question.choices[0])
        vm.bookmarked = true

        // When: Finish is called
        let finished = vm.finish()

        // Then: Returns AttemptedQuestion with selections preserved
        XCTAssertEqual(finished.selectedChoices.count, 1)
        XCTAssertEqual(finished.selectedChoices[question.choices[0]], .correct)
        XCTAssertTrue(finished.bookmarked)
    }

    // MARK: - Prompt Tests

    func test_prompt_singleAnswer_showsSelectOne() {
        // Given: A single-answer question
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // Then: Prompt says ONE
        XCTAssertEqual(vm.prompt, "Please select ONE answer")
    }

    func test_prompt_twoAnswers_showsSelectTwo() {
        // Given: A two-answer question
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // Then: Prompt says TWO
        XCTAssertEqual(vm.prompt, "Please select TWO answers")
    }

    func test_prompt_threeOrMoreAnswers_showsSelectMultiple() {
        // Given: A three-answer question
        let question = TestDataFactory.makeMultiAnswerQuestion(correctIndices: [0, 1, 2])
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        // Then: Prompt says MULTIPLE
        XCTAssertEqual(vm.prompt, "Please select MULTIPLE answers")
    }

    // MARK: - Bookmark Tests

    func test_bookmarked_togglesQuestionBookmark() {
        // Given: An unbookmarked question
        let question = TestDataFactory.makeSingleAnswerQuestion()
        let attempted = AttemptedQuestion(from: question)
        let vm = QuestionViewModel(question: attempted, owner: mockOwner)

        XCTAssertFalse(vm.bookmarked)
        XCTAssertFalse(vm.question.bookmarked)

        // When: Bookmark is toggled
        vm.bookmarked = true

        // Then: Both VM and question are bookmarked
        XCTAssertTrue(vm.bookmarked)
        XCTAssertTrue(vm.question.bookmarked)
    }
}
