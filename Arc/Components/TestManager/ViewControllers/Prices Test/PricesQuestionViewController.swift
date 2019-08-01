//
//  PricesQuestionViewController.swift
// Arc
//
//  Created by Philip Hayes on 10/8/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit


open class PricesQuestionViewController: UIViewController {
    //@IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var questionLabel: UILabel!
    //@IBOutlet weak var priceLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var buttonStack: UIStackView!
	@IBOutlet weak var questionDisplay: UIStackView!
	private var buttons:[ChoiceView] = []
	public var shouldAutoProceed = true
    let topButton:ChoiceView = .get()
    let bottomButton:ChoiceView = .get()
	weak var delegate:PricesTestDelegate?

    var controller = Arc.shared.pricesTestController
    var responseId:String = ""
    var questionIndex = 0
    var questions:Set<Int> = []
    var presentedQuestions:Set<Int> = []
    override open func viewDidLoad() {
        super.viewDidLoad();

        
        
    }
    override open func viewWillAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        buildButtonStackView()
        if isBeingPresented {

			
			prepareQuestions()
        }
    }
	public func prepareQuestions() {
		let test:PriceTestResponse = try! controller.get(id: responseId)
		questions = Set(0 ..< test.sections.count)
	}
    public func didSelect(id:Int) {
		
        _ = controller.mark(timeTouched: responseId, index: questionIndex)
        _ = controller.set(choice: id, id: responseId, index: questionIndex)
		if shouldAutoProceed {
        	selectQuestion()
		}
		delegate?.didSelectPrice(id)
    }
	
	/// Select question will check to see what prices were shown to the user
	/// and then pick a random value that has NOT been presented to the user.
	/// if it cannot find a value it will mark the test as complete and defer
	/// to the application for navigation.
    public func selectQuestion() {
		
        if let value = questions.subtracting(presentedQuestions).randomElement() {
            presentQuestion(index: value, id: responseId)
        } else {
			
			_  = controller.mark(filled: responseId)
			
			//If the delegate implements this method and returns false it will not proceed automatically.
			if delegate?.shouldEndTest() ?? true {
				Arc.shared.nextAvailableState()
			}
        }
    }
	
	
	/// Present question will track question indicies passed into this function.
	/// It will then fetch the data for that question and configure the view.
	/// Once the user makes a selection it will immediately present the next question.
	/// - Parameter index: The index of a question to be presented
	/// - Parameter id: the id of the survey to present the question from
    func presentQuestion(index:Int, id:String){
        presentedQuestions.insert(index)
        questionIndex = index
        responseId = id
		
		
        _ = controller.mark(questionDisplayTime: id, index: index)
        let item = controller.get(question: index, id: id)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        questionLabel.text = String(describing: item!.item)
        
        buttons.forEach { (b) in
            b.isHidden = true
        }
        for b in buttons {
            let priceIndex = buttons.firstIndex(of: b)!
            
            let string = controller.get(option: priceIndex, forQuestion: index, id: id)!
            
            b.set(message: "\("".localized("money_prefix"))\(string)")
            b.isHidden = false
            
            b.set(selected: false, shouldUpdateColors: false)
        }
            
    }
    
    public func buildButtonStackView() {
        //topButton.set(message: top)
        //bottomButton.set(message: bottom)
        
        topButton.needsImmediateResponse = true
        bottomButton.needsImmediateResponse = true
        
        topButton.button.titleLabel?.numberOfLines = 1
        bottomButton.button.titleLabel?.numberOfLines = 1
        
        topButton.set(state: .button)
        bottomButton.set(state: .button)
        
        topButton.tapped = {
            [weak self] view in
            if self?.topButton.getSelected() == false {
                self?.topButton.set(selected: true)
                self?.didSelect(id: 0)
            }
        }
        
        bottomButton.tapped = {
            [weak self] view in
            if self?.bottomButton.getSelected() == false {
                self?.bottomButton.set(selected: true)
                self?.didSelect(id: 1)
            }
        }
        
        buttons.append(topButton)
        buttons.append(bottomButton)
        buttonStack.addArrangedSubview(topButton)
        buttonStack.addArrangedSubview(bottomButton)
    }
    
}

