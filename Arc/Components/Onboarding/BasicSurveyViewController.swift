//
//  OnboardingNavigationViewController.swift
//  Arc
//
//  Created by Philip Hayes on 7/12/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
struct OnboardingConfig {
	
	var willCommit:Bool = false
	var didAllowNotifications:Bool = false
}

public class BasicSurveyViewController: UINavigationController, SurveyInputDelegate {

	var survey:Survey
	var questions = Array<Survey.Question>()
	var subQuestions:[Survey.Question]?
	var currentIndex:Int = 0
	var answeredQuestions:[Survey.Question] = []
	var surveyId:String
	var shouldNavigateToNextState:Bool = true
	public init(file:String) {
		survey = Arc.shared.surveyController.load(survey: file)
		surveyId = Arc.shared.surveyController.create()
		questions = survey.questions
		
		subQuestions = survey.subQuestions
		
		super.init(nibName: nil, bundle: nil)
		addController()
	}
	public func setCompleted() {
		//If this survey is being stored in core data
		//mark it as filled out.
		_ = Arc.shared.surveyController.mark(filled: surveyId)
		
		//Subclasses may perform conditional async operations
		//that determine if the app should proceed.
		if shouldNavigateToNextState {
			Arc.shared.nextAvailableState()
		}
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func getTopViewController<T:UIView>() -> CustomViewController<T>? {
		return topViewController as? CustomViewController<T>
	}
	func getCurrentQuestion() -> String {
		
		return questions[currentIndex].questionId
	}
	func getInput() -> SurveyInput? {
		let vc:CustomViewController<InfoView>? = getTopViewController()
		return vc?.customView.inputItem
	}
	
	override public func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	func addController() {
		pushViewController(CustomViewController<InfoView>(), animated: true)

	}
	func display(question:Survey.Question) {
		let style = question.style ?? .none
		switch style {
		case .instruction:
			instructionStyle(question)
			
		default:
			questionStyle(question)

		}
		
	}
	
	func instructionStyle(_ question:Survey.Question) {
		// Do any additional setup after loading the view.
		let vc:CustomViewController<InfoView> = getTopViewController()!
		
		vc.customView.infoContent.alignment = .center
		vc.customView.backgroundColor = UIColor(named:"Primary")!
		vc.customView.setTextColor(UIColor(named: "Secondary Text"))
		vc.customView.setButtonColor(primary: UIColor(named:"Secondary"),
									 secondary: UIColor(named:"Secondary Gradient"),
									 textColor: .black)
		vc.customView.setHeading(question.prompt)
		vc.customView.setSubHeading(question.subTitle)
		vc.customView.setContentLabel(question.detail)
		
		if let input = question.type?.create(inputWithQuestion: question) as? (UIView & SurveyInput) {
			vc.customView.setInput(input)
		}
		vc.customView.inputDelegate = self
		
		vc.customView.nextButton?.addTarget(self, action: #selector(nextButtonPressed(sender:)), for: .primaryActionTriggered)
		//		pushViewController(vc, animated: true)
	}
	func questionStyle(_ question:Survey.Question) {
		// Do any additional setup after loading the view.
		let vc:CustomViewController<InfoView> = getTopViewController()!

		vc.customView.infoContent.alignment = .leading
		
		vc.customView.setTextColor(UIColor(named: "Primary Text"))
		vc.customView.setButtonColor(primary: UIColor(named:"Primary"),
										secondary: UIColor(named:"Primary Gradient"),
										textColor: .white)
		vc.customView.setHeading(question.prompt)
		vc.customView.setSeparatorWidth(0.15)
		vc.customView.setContentLabel(question.detail)
		
		if let input = question.type?.create(inputWithQuestion: question) as? (UIView & SurveyInput) {
			vc.customView.setInput(input)
		}
		vc.customView.inputDelegate = self
		
		vc.customView.nextButton?.addTarget(self, action: #selector(nextButtonPressed(sender:)), for: .primaryActionTriggered)

	}
	open func valueSelected(value:QuestionResponse, index:String) {
		
		let question = Arc.shared.surveyController.get(question: index)
		
		let _ = Arc.shared.surveyController.set(response: value,
												questionId: question.questionId,
												question: question.prompt,
												forSurveyId: self.surveyId)
	}
	
	
	public func didPresentQuestion(input: SurveyInput?) {}
	
	open func templateForQuestion(id: String) -> Dictionary<String, String> {return [:]}
	
	open func didPresentQuestion(input: SurveyInput) {}
	
	open func didFinishSetup() {}
	
	open func tryNextPressed() {}
	
	@objc open func nextButtonPressed(sender:Any) {
		if let item = getInput() {
			nextPressed(input: item, value: item.getValue())
		} else {
			nextPressed(input: nil, value: nil)
		}

	}
	open func didChangeValue() {
		let question = questions[currentIndex]
		
		let _ = Arc.shared.surveyController.mark(responseTime: question.questionId,
												 question: question.prompt,
												 forSurveyResponse: self.surveyId)
	}
	public func nextPressed(input: SurveyInput?, value: QuestionResponse?) {
		var nextQuestion = questions.index(currentIndex, offsetBy: 1, limitedBy: questions.count - 1)
		guard currentIndex < questions.count else {
			//Move on to the next step
			return
		}
		guard let value = getInput()?.getValue(),  value.value != nil else {
			if nextQuestion != nil {
				self.addController()
			} else {
				//No questions were added, move on to the next step
				setCompleted()
			}
			return
		}
		
		
		let question = questions[currentIndex]
		//Check to see if any questions were added as a result of a choice
		updateNextQuestion(question: question, answer: value)
		nextQuestion = questions.index(currentIndex, offsetBy: 1, limitedBy: questions.count - 1)

		if nextQuestion != nil {
			self.addController()
		} else {
			//No questions were added, move on to the next step
			setCompleted()
		}

	}
	
	public override func popViewController(animated: Bool) -> UIViewController? {
		let vc = super.popViewController(animated: animated)

		currentIndex = viewControllers.count - 1
		print("Controller index:", currentIndex)
		while answeredQuestions.count >= viewControllers.count && answeredQuestions.count > 0 {
			_ = answeredQuestions.popLast()
		}
		return vc

	}
	/// This override will control what to display as the questions unfold
	///
	public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		
		currentIndex = viewControllers.count - 1
		print(currentIndex)
		guard currentIndex < questions.count else {
			return
		}
		
		display(question: questions[currentIndex])
	}
	
	open func updateNextQuestion(question:Survey.Question, answer:QuestionResponse){
		self.answeredQuestions.append(question)

		if let routes = question.routes?.reversed() {
			for route in routes {
				//Make sure to insert new subquestions only (if they go back)
				
				questions = questions.filter({ (q) -> Bool in
					return q.questionId != route.nextQuestionId
				})
				switch answer.value {
				case let value as String:
					if value == route.value as? String {
						let question = Arc.shared.surveyController.get(question: route.nextQuestionId)
						questions.insert(question, at: currentIndex + 1)
					}
				case let number as Int:
					
					if number == route.value as? Int {
						let question = Arc.shared.surveyController.get(question: route.nextQuestionId)
						questions.insert(question, at: currentIndex + 1)
					} else if let validAnswers = (route.value as? [Int]), validAnswers.contains(number) {
						let question = Arc.shared.surveyController.get(question: route.nextQuestionId)
						questions.insert(question, at: currentIndex + 1)
					}
					
					
				case let intArray as [Int]:
					for value in intArray {
						if let validAnswers = (route.value as? [Int]), validAnswers.contains(value) {
							let question = Arc.shared.surveyController.get(question: route.nextQuestionId)
							questions.insert(question, at: currentIndex + 1)
						} else if value == route.value as? Int {
							let question = Arc.shared.surveyController.get(question: route.nextQuestionId)
							questions.insert(question, at: currentIndex + 1)
						}
					}
				case .none:
					break
				case .some(_):
					break
				}
				
			}
		}
	}
}
