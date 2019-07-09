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
    private var buttons:[ChoiceView] = []
    let topButton:ChoiceView = .get()
    let bottomButton:ChoiceView = .get()
    
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

            let test:PriceTestResponse = try! controller.get(id: responseId)
            questions = Set(0 ..< test.sections.count)

        }
    }

    func didSelect(id:Int) {

        _ = controller.mark(timeTouched: responseId, index: questionIndex)
        let p = controller.set(choice: id, id: responseId, index: questionIndex)
        selectQuestion()
    }
	
	/// Select question will check to see what prices were shown to the user
	/// and then pick a random value that has NOT been presented to the user.
	/// if it cannot find a value it will mark the test as complete and defer
	/// to the application for navigation.
    func selectQuestion() {
        if let value = questions.subtracting(presentedQuestions).randomElement() {
            presentQuestion(index: value, id: responseId)
        } else {
			_  = controller.mark(filled: responseId)
			Arc.shared.nextAvailableState()
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
            
            b.set(message: "\("".localized("money_prefix"))\(string)") //setTitle("\(string)", for: .normal)
            b.isHidden = false
            
            //b.set(selected: false)
        }
            
            
            
        
    }
    
    func buildButtonStackView() {
        //topButton.set(message: top)
        //bottomButton.set(message: bottom)
        
        topButton.needsImmediateResponse = true
        bottomButton.needsImmediateResponse = true
        
        topButton.button.titleLabel?.numberOfLines = 1
        bottomButton.button.titleLabel?.numberOfLines = 1
        
        topButton.set(state: .radio)
        bottomButton.set(state: .radio)
        
        topButton.tapped = {
            [weak self] view in
            //self?.topButton.set(selected: true)
            if self?.topButton.getSelected() == false {
                self?.didSelect(id: 0)
            }
            self?.topButton.updateState()
        }
        
        bottomButton.tapped = {
            [weak self] view in
            //self?.bottomButton.set(selected: true)
            if self?.bottomButton.getSelected() == false {
                self?.didSelect(id: 1)
            }
            self?.bottomButton.updateState()
        }
        
        buttons.append(topButton)
        buttons.append(bottomButton)
        buttonStack.addArrangedSubview(topButton)
        buttonStack.addArrangedSubview(bottomButton)
    }
    
}

