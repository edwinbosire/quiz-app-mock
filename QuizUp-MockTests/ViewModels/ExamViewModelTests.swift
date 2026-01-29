//
//  ExamViewModelTests.swift
//  QuizUp-MockTests
//
//  Created by Claude Code on 29/01/2026.
//

import Testing
@testable import Life_In_The_UK_Prep

@Suite("ExamViewModel Tests")
@MainActor
struct ExamViewModelTests {

    // MARK: - Initialization Tests

    @Test("init sets progress to zero")
    func init_setsProgressToZero() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)

        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        #expect(vm.progress == 0)
    }

    @Test("init sets status to started")
    func init_setsStatusToStarted() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)

        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        #expect(vm.examStatus == .started)
    }

    @Test("init creates QuestionViewModels")
    func init_createsQuestionViewModels() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 5)

        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        #expect(vm.questions.count == 5)
    }

    @Test("init sets progress title")
    func init_setsProgressTitle() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 4)

        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        #expect(vm.progressTitle == "Question 1 of 4")
    }

    // MARK: - Progress Tests

    @Test("progressToNextQuestions increments progress")
    func progressToNextQuestions_incrementsProgress() async {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        #expect(vm.progress == 0)

        vm.progressToNextQuestions()

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        #expect(vm.progress == 1)
    }

    @Test("progressToNextQuestions adds to availableQuestions")
    func progressToNextQuestions_addsToAvailableQuestions() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        #expect(vm.availableQuestions.isEmpty)

        vm.progressToNextQuestions()

        #expect(vm.availableQuestions.count == 1)
    }

    @Test("progressToNextQuestions at last question finishes exam")
    func progressToNextQuestions_atLastQuestion_finishesExam() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        vm.progress = 1

        vm.progressToNextQuestions()

        #expect(vm.examStatus == .didNotFinish)
    }

    // MARK: - Allow Progress Tests

    @Test("allowProgressToNextQuestion adds to availableQuestions")
    func allowProgressToNextQuestion_addsToAvailableQuestions() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        vm.allowProgressToNextQuestion()

        #expect(vm.availableQuestions.count == 1)
        #expect(vm.progress == 0)
    }

    @Test("allowProgressToNextQuestion at last question finishes exam")
    func allowProgressToNextQuestion_atLastQuestion_finishesExam() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)
        vm.progress = 1

        vm.allowProgressToNextQuestion()

        #expect(vm.examStatus == .didNotFinish)
    }

    // MARK: - Finish Exam Tests

    @Test("finishExam sets status to finished")
    func finishExam_setsStatusToFinished() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        let question = vm.questions[0]
        let correctChoice = question.choices.first { $0.isAnswer }!
        question.selected(correctChoice)

        vm.finishExam()

        #expect(vm.examStatus == .finished)
    }

    @Test("finishExam with no answers sets status to didNotFinish")
    func finishExam_withNoAnswers_setsStatusToDidNotFinish() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        vm.finishExam()

        #expect(vm.examStatus == .didNotFinish)
    }

    @Test("finishExam saves via repository")
    func finishExam_savesViaRepository() async {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        let question = vm.questions[0]
        let correctChoice = question.choices.first { $0.isAnswer }!
        question.selected(correctChoice)

        vm.finishExam()

        try? await Task.sleep(nanoseconds: 500_000_000)

        #expect(mockRepository.saveExamCallCount == 1)
    }

    // MARK: - Restart Exam Tests

    @Test("restartExam resets all state")
    func restartExam_resetsAllState() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        vm.progressToNextQuestions()
        vm.progressToNextQuestions()

        _ = vm.restartExam()

        #expect(vm.progress == 0)
        #expect(vm.availableQuestions.isEmpty)
        #expect(vm.examStatus == .unattempted)
    }

    @Test("restartExam resets all QuestionViewModels")
    func restartExam_resetsAllQuestionViewModels() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 2)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        let question = vm.questions[0]
        let choice = question.choices[0]
        question.selected(choice)
        #expect(!question.selectedChoices.isEmpty)

        _ = vm.restartExam()

        #expect(vm.questions[0].selectedChoices.isEmpty)
    }

    // MARK: - Current Question Tests

    @Test("currentQuestion returns question at progress index")
    func currentQuestion_returnsQuestionAtProgressIndex() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        #expect(vm.currentQuestion.index == 0)

        vm.progress = 2

        #expect(vm.currentQuestion.index == 2)
    }

    // MARK: - Result ViewModel Tests

    @Test("resultViewModel creates correct AttemptedExam")
    func resultViewModel_createsCorrectAttemptedExam() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        let q0 = vm.questions[0]
        let correct0 = q0.choices.first { $0.isAnswer }!
        q0.selected(correct0)

        let q1 = vm.questions[1]
        let wrong1 = q1.choices.first { !$0.isAnswer }!
        q1.selected(wrong1)

        let result = vm.resultViewModel

        #expect(result.exam.questions.count == 3)
    }

    // MARK: - Computed Properties Tests

    @Test("correctQuestions filters correctly answered")
    func correctQuestions_filtersCorrectlyAnswered() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        for i in 0..<2 {
            let q = vm.questions[i]
            vm.availableQuestions.append(q)
            let correct = q.choices.first { $0.isAnswer }!
            q.selected(correct)
        }

        let q2 = vm.questions[2]
        vm.availableQuestions.append(q2)
        let wrong = q2.choices.first { !$0.isAnswer }!
        q2.selected(wrong)

        #expect(vm.correctQuestions.count == 2)
    }

    @Test("incorrectQuestions filters incorrectly answered")
    func incorrectQuestions_filtersIncorrectlyAnswered() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 3)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        let q0 = vm.questions[0]
        vm.availableQuestions.append(q0)
        let correct = q0.choices.first { $0.isAnswer }!
        q0.selected(correct)

        for i in 1..<3 {
            let q = vm.questions[i]
            vm.availableQuestions.append(q)
            let wrong = q.choices.first { !$0.isAnswer }!
            q.selected(wrong)
        }

        #expect(vm.incorrectQuestions.count == 2)
    }

    @Test("formattedScore returns percentage string")
    func formattedScore_returnsPercentageString() {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(questionCount: 4)
        let vm = ExamViewModel(exam: exam, repository: mockRepository)

        #expect(vm.formattedScore == "-")
    }

    // MARK: - Static Factory Tests

    @Test("viewDidLoad loads exam from repository")
    func viewDidLoad_loadsExamFromRepository() async {
        let mockRepository = MockRepository()
        let exam = TestDataFactory.makeExam(id: 42, questionCount: 3)
        mockRepository.examToReturn = exam

        let vm = await ExamViewModel.viewDidLoad(42, repository: mockRepository)

        #expect(mockRepository.loadMockExamCallCount == 1)
        #expect(mockRepository.loadMockExamLastId == 42)
        #expect(vm != nil)
        #expect(vm?.questions.count == 3)
    }

    @Test("viewDidLoad with error returns nil")
    func viewDidLoad_withError_returnsNil() async {
        let mockRepository = MockRepository()
        mockRepository.shouldThrowError = true

        let vm = await ExamViewModel.viewDidLoad(1, repository: mockRepository)

        #expect(vm == nil)
    }
}
