//
//  PricesTestViewController.swift
// Arc
//
//  Created by Philip Hayes on 10/8/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

public class PricesTestViewController: ArcViewController {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var goodPriceLabel: UILabel!
    
    @IBOutlet weak var buttonStack: UIStackView!
    private var questionDisplay:PricesQuestionViewController?

    var controller = Arc.shared.pricesTestController
    var test:PriceTest?
    var responseID = ""
    public static var testVersion:String {
        
        return Arc.shared.appController.locale.availablePriceTest
        
        
        
    }
//    private var questionDisplay:DNPricesQuestionViewController?
//    private var test:DNPricesTest?
    private var itemIndex = 0
    private var questionIndex = 0
    private var flippedPrices:Set<Int>! = nil
    var displayTimer:Timer?;
    
    // Buttons
    private var views:[ChoiceView] = []
    let topButton:ChoiceView = .get()
    let bottomButton:ChoiceView = .get()
    

    override open func viewDidLoad() {
        super.viewDidLoad()

        ACState.testCount += 1

        buildButtonStackView()
		let app = Arc.shared
		let studyId = Int(app.studyController.getCurrentStudyPeriod()?.studyID ?? -1)
		let sessionId = app.currentTestSession ?? -1
		let session = app.studyController.get(session: sessionId, inStudy: studyId)
		if let data = session.surveyFor(surveyType: .priceTest){
			
			responseID = data.id! //A crash here means that the session is malformed
			
		} else {
		
        	test = controller.loadTest(index: 0, file: PricesTestViewController.testVersion )
        	responseID = controller.createResponse(withTest: test!)
		}
		
		//Selecte a group of question indicies such that then they are displayed,
		//they will be flipped.
		if flippedPrices == nil
		{
			let count = controller.get(testCount: responseID)
			flippedPrices = Set<Int>.uniqueSet(numberOfItems: count / 2, maxValue: count)
		}
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            _ = controller.start(test: responseID)
		_  = controller.mark(filled: responseID)

            displayItem()
        
    }
	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		displayTimer?.invalidate()
	}
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	public func nextStep() {
		itemIndex += 1
	}
	
	@objc func nextItem()
    {
        nextStep()
		
        displayItem();
    }
	
	/// Invalidates the display timer, deselects all buttons for reuse,
	/// and ensures that user interaction is enabled.
	public func resetController() {
		displayTimer?.invalidate();
		
		topButton._isSelected = false;
		topButton.isUserInteractionEnabled = true;
		bottomButton._isSelected = false;
		bottomButton.isUserInteractionEnabled = true;
	}
	
	/// Displays a question stimuli and asks the user to confirm if the price is good or not.
	/// - Parameter index: The index is fed into the controller powering the test and used
	/// to retrieve a question from the selected test.
	/// - Parameter isTimed: Defaulting to true, this will cause the test to only display the stimuli for a limited period of time.
	public func displayPrice(index:Int, isTimed:Bool = true) {
		
		guard let item = controller.get(question: index, id: responseID) else {
			return
		}
		let topLabel = (flippedPrices.contains(itemIndex)) ? itemNameLabel : itemPriceLabel
		let bottomLabel = (topLabel == itemNameLabel) ? itemPriceLabel : itemNameLabel
		
		topLabel?.text = item.item
		
		let correctPrice = "".localized("money_prefix") + item.price
		bottomLabel?.text = correctPrice
		
		bottomLabel?.resizeFontForSingleWords();
		topLabel?.resizeFontForSingleWords();
		
		_ = controller.mark(stimulusDisplayTime: responseID, index: index)
		if isTimed {
			displayTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(nextItem), userInfo: nil, repeats: false)
		}
	}
	
	/// Displays the recall portion of the test. This controller is not timed.
	/// As the user makes selections the test will progress and track their
	/// response time.
	public func showQuestionController() {
		//Present controller
		questionDisplay = .get()
		questionDisplay?.responseId = responseID
		
		present(questionDisplay!, animated: false, completion: { [weak self] in
			guard let weakself = self else {
				return
			}
			weakself.questionDisplay?.selectQuestion()
		})
	}
	
	/// Display an alert telling the user that the recall portion of the test will begin.
	/// They can either wait 12 seconds or after 3 seconds hit the begin button to begin
	/// the next phase of the test.
	public func displayTransition() {
		Arc.shared.displayAlert(message: "You will now start the test.\nYou will see an item and two prices. Please select the price that matches the item you studied.".localized("price_overlay"), options: [
			
			.delayed(name: "BEGIN".localized("button_begin"), delayTime: 3.0, showQuestionController),
			
			.wait(waitTime: 12.0, showQuestionController)
			
		])
	}
	
	/// Hide the buttons and remove all text from the display
	/// this will prevent the user from seeing stimuli for too long.
	public func hideInterface() {
		self.topButton.isHidden = true;
		self.bottomButton.isHidden = true;
		self.goodPriceLabel.isHidden = true;
		self.itemNameLabel.text = ""
		self.itemPriceLabel.text = ""
	}
	
	func displayItem()
	{
		//Reset the state of the top and bottom selection bottons
		resetController()
		
		
		//If our item index is less than the number of items in this particular
		//run of the prices test we can safely display the price at that index
        if itemIndex < controller.get(testCount: responseID)
		{
			displayPrice(index: itemIndex)
        }
		//Else we've reached the end of the first phase of the test
		else
		{
			
			displayTransition()
            
			hideInterface()
        }
        
    }
    
    func buildButtonStackView() {
        topButton.set(message: "Yes".localized("YES").capitalized)
        bottomButton.set(message: "No".localized("NO").capitalized)
        
        topButton.needsImmediateResponse = true
        bottomButton.needsImmediateResponse = true
        
        topButton.button.titleLabel?.numberOfLines = 1
        bottomButton.button.titleLabel?.numberOfLines = 1
        
        topButton.set(state: .radio)
        bottomButton.set(state: .radio)
        
        topButton.tapped = {
            [weak self] view in
            self?.yesPressed()
        }
        
        bottomButton.tapped = {
            [weak self] view in
            self?.noPressed()
        }
        
        views.append(topButton)
        views.append(bottomButton)
        buttonStack.addArrangedSubview(topButton)
        buttonStack.addArrangedSubview(bottomButton)
    }
    
    func yesPressed() {
        if itemIndex < controller.get(testCount: responseID) {
            
            topButton.set(selected: true)
            bottomButton.set(selected: false)
            
            let p = controller.set(goodPrice: 1, id: responseID, index: itemIndex)
//            print(p.toString())
        }
    }
    
    func noPressed() {
        if itemIndex < controller.get(testCount: responseID) {
            
            topButton.set(selected: false)
            bottomButton.set(selected: true)
            
            let p = controller.set(goodPrice: 0, id: responseID, index: itemIndex)
//            print(p.toString())
        }
    }
    
}



