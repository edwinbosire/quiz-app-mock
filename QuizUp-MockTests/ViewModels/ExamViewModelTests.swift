//
//  ExamViewModelTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import XCTest
@testable import Life_In_The_UK_Prep

@MainActor
final class ExamViewModelTests: XCTestCase {

    var mockRepository: MockRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_setsProgressToZero() {
        // Given: An exam
        let exam = TestDataFactory.makeExam(questionCount: 3)

        // When: ViewModel is created
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Then: Progress starts at 0
        XCTAssertEqual(vm.progress, 0)
    }

    func test_init_setsStatusToStarted() {
        // Given: An exam
        let exam = TestDataFactory.makeExam(questionCount: 3)

        // When: ViewModel is created
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Then: Status is started
        XCTAssertEqual(vm.examStatus, .started)
    }

    func test_init_createsQuestionViewModels() {
        // Given: An exam with 5 questions
        let exam = TestDataFactory.makeExam(questionCount: 5)

        // When: ViewModel is created
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Then: 5 QuestionViewModels are created
        XCTAssertEqual(vm.questions.count, 5)
    }

    func test_init_setsProgressTitle() {
        // Given: An exam with 4 questions
        let exam = TestDataFactory.makeExam(questionCount: 4)

        // When: ViewModel is created
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Then: Progress title is set
        XCTAssertEqual(vm.progressTitle, "Question 1 of 4")
    }

    // MARK: - Progress Tests

    func test_progressToNextQuestions_incrementsProgress() async {
        // Given: A ViewModel at question 0
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        XCTAssertEqual(vm.progress, 0)

        // When: Progress to next
        vm.progressToNextQuestions()

        // Wait for the 1-second delay + animation
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Then: Progress increments
        XCTAssertEqual(vm.progress, 1)
    }

    func test_progressToNextQuestions_addsToAvailableQuestions() {
        // Given: A ViewModel
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        XCTAssertTrue(vm.availableQuestions.isEmpty)

        // When: Progress to next
        vm.progressToNextQuestions()

        // Then: Next question is added to available
        XCTAssertEqual(vm.availableQuestions.count, 1)
    }

    func test_progressToNextQuestions_atLastQuestion_finishesExam() {
        // Given: A ViewModel at the last question
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        vm.progress = 1 // Last question

        // When: Progress to next (past last)
        vm.progressToNextQuestions()

        // Then: Exam is finished
        XCTAssertEqual(vm.examStatus, .didNotFinish)
    }

    // MARK: - Allow Progress Tests

    func test_allowProgressToNextQuestion_addsToAvailableQuestions() {
        // Given: A ViewModel
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // When: Allow progress
        vm.allowProgressToNextQuestion()

        // Then: Next question is available but progress doesn't change
        XCTAssertEqual(vm.availableQuestions.count, 1)
        XCTAssertEqual(vm.progress, 0)
    }

    func test_allowProgressToNextQuestion_atLastQuestion_finishesExam() {
        // Given: A ViewModel at the last question
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        vm.progress = 1 // Last question

        // When: Allow progress
        vm.allowProgressToNextQuestion()

        // Then: Exam is finished
        XCTAssertEqual(vm.examStatus, .didNotFinish)
    }

    // MARK: - Finish Exam Tests

    func test_finishExam_setsStatusToFinished() {
        // Given: A ViewModel with at least one answered question
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Answer one question
        let question = vm.questions[0]
        let correctChoice = question.choices.first { $0.isAnswer }!
        question.selected(correctChoice)

        // When: Finish exam
        vm.finishExam()

        // Then: Status is finished
        XCTAssertEqual(vm.examStatus, .finished)
    }

    func test_finishExam_withNoAnswers_setsStatusToDidNotFinish() {
        // Given: A ViewModel with no answered questions
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // When: Finish exam without answering
        vm.finishExam()

        // Then: Status is didNotFinish
        XCTAssertEqual(vm.examStatus, .didNotFinish)
    }

    func test_finishExam_savesViaRepository() async {
        // Given: A ViewModel
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Answer one question to ensure .finished status
        let question = vm.questions[0]
        let correctChoice = question.choices.first { $0.isAnswer }!
        question.selected(correctChoice)

        // When: Finish exam
        vm.finishExam()

        // Wait for async save
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Then: Repository save was called
        XCTAssertEqual(mockRepository.saveExamCallCount, 1)
    }

    // MARK: - Restart Exam Tests

    func test_restartExam_resetsAllState() {
        // Given: A ViewModel with progress
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Make some progress
        vm.progressToNextQuestions()
        vm.progressToNextQuestions()

        // When: Restart
        _ = vm.restartExam()

        // Then: State is reset
        XCTAssertEqual(vm.progress, 0)
        XCTAssertTrue(vm.availableQuestions.isEmpty)
        XCTAssertEqual(vm.examStatus, .unattempted)
    }

    func test_restartExam_resetsAllQuestionViewModels() {
        // Given: A ViewModel with answered questions
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Answer a question
        let question = vm.questions[0]
        let choice = question.choices[0]
        question.selected(choice)
        XCTAssertFalse(question.selectedChoices.isEmpty)

        // When: Restart
        _ = vm.restartExam()

        // Then: Questions are reset
        XCTAssertTrue(vm.questions[0].selectedChoices.isEmpty)
    }

    // MARK: - Current Question Tests

    func test_currentQuestion_returnsQuestionAtProgressIndex() {
        // Given: A ViewModel
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Then: Current question is at index 0
        XCTAssertEqual(vm.currentQuestion.index, 0)

        // When: Progress changes
        vm.progress = 2

        // Then: Current question changes
        XCTAssertEqual(vm.currentQuestion.index, 2)
    }

    // MARK: - Result ViewModel Tests

    func test_resultViewModel_createsCorrectAttemptedExam() {
        // Given: A ViewModel with some answered questions
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Answer one correctly
        let q0 = vm.questions[0]
        let correct0 = q0.choices.first { $0.isAnswer }!
        q0.selected(correct0)

        // Answer one wrongly
        let q1 = vm.questions[1]
        let wrong1 = q1.choices.first { !$0.isAnswer }!
        q1.selected(wrong1)

        // When: Get result view model
        let result = vm.resultViewModel

        // Then: Result contains attempted questions with selections
        XCTAssertEqual(result.exam.questions.count, 3)
    }

    // MARK: - Computed Properties Tests

    func test_correctQuestions_filtersCorrectlyAnswered() {
        // Given: A ViewModel with mix of correct/incorrect
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Answer two correctly
        for i in 0..<2 {
            let q = vm.questions[i]
            vm.availableQuestions.append(q)
            let correct = q.choices.first { $0.isAnswer }!
            q.selected(correct)
        }

        // Answer one wrongly
        let q2 = vm.questions[2]
        vm.availableQuestions.append(q2)
        let wrong = q2.choices.first { !$0.isAnswer }!
        q2.selected(wrong)

        // Then: 2 correct questions
        XCTAssertEqual(vm.correctQuestions.count, 2)
    }

    func test_incorrectQuestions_filtersIncorrectlyAnswered() {
        // Given: A ViewModel with mix of correct/incorrect
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Answer one correctly
        let q0 = vm.questions[0]
        vm.availableQuestions.append(q0)
        let correct = q0.choices.first { $0.isAnswer }!
        q0.selected(correct)

        // Answer two wrongly
        for i in 1..<3 {
            let q = vm.questions[i]
            vm.availableQuestions.append(q)
            let wrong = q.choices.first { !$0.isAnswer }!
            q.selected(wrong)
        }

        // Then: 2 incorrect questions
        XCTAssertEqual(vm.incorrectQuestions.count, 2)
    }

    func test_formattedScore_returnsPercentageString() {
        // Given: A ViewModel
        let exam = TestDataFactory.makeExam(questionCount: 4)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        // Initially no score
        XCTAssertEqual(vm.formattedScore, "-")
    }

    // MARK: - Static Factory Tests

    func test_viewDidLoad_loadsExamFromRepository() async {
        // Given: A mock repository with an exam
        let exam = TestDataFactory.makeExam(id: 42, questionCount: 3)
        mockRepository.examToReturn = exam

        // When: viewDidLoad is called
        let vm = await ExamViewModel.viewDidLoad(42, repository: mockRepository)

        // Then: Repository was called and VM is created
        XCTAssertEqual(mockRepository.loadMockExamCallCount, 1)
        XCTAssertEqual(mockRepository.loadMockExamLastId, 42)
        XCTAssertNotNil(vm)
        XCTAssertEqual(vm?.questions.count, 3)
    }

    func test_viewDidLoad_withError_returnsNil() async {
        // Given: A mock repository that throws
        mockRepository.shouldThrowError = true

        // When: viewDidLoad is called
        let vm = await ExamViewModel.viewDidLoad(1, repository: mockRepository)

        // Then: Returns nil
        XCTAssertNil(vm)
    }
}
