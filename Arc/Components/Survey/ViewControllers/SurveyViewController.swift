//
//  SurveyViewController.swift
// Arc
//
//  Created by Philip Hayes on 9/27/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import HMMarkup

open class SurveyViewController: UIViewController, SurveyInput, UIScrollViewDelegate {
	
	var app = Arc.shared
	public var orientation: UIStackView.Alignment = .center
    public var didChangeValue: (() -> ())?
	public var tryNext:(() -> ())?
    public var didFinishSetup: (() -> ())?

	
    var nextPressed:((SurveyInput?, QuestionResponse?)->Void)?
    var questionPresented:((SurveyInput?)->Void)?
	var templateHandler:((String)->Dictionary<String,String>)?
	public var helpPressed:(()->())?
    @IBOutlet public weak var promptLabel: UILabel!
	@IBOutlet weak var errorLabel:UILabel!
    @IBOutlet public weak var detailsLabel:UILabel!
	@IBOutlet public weak var nextButton:UIButton!

    @IBOutlet public weak var container: UIStackView!
    @IBOutlet public weak var views: UIStackView!
    @IBOutlet weak var nextBottomSpacing: NSLayoutConstraint!
    @IBOutlet public weak var bottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var privacyStack: UIStackView!
    @IBOutlet weak var privacyPolicyButton: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var scrollIndicator: UIView!
    @IBOutlet weak var scrollIndicatorLabel:UILabel!
//    @IBOutlet weak var spacerView: UIView!
    
    var id:String?
    var prompt:String?
    var details:String?
    var input:SurveyInput?
    var questionIndex:String?
    var surveyId:String?

	open var renderer:HMMarkupRenderer!
    private var controller = Arc.shared.surveyController

    @IBAction func nextButtonPressed(_ sender: Any) {
        
			let value = input?.getValue()
			
            nextPressed?(input, value)
    }
	
    override open func viewDidLoad() {
        super.viewDidLoad()
		renderer = HMMarkupRenderer(baseFont: promptLabel.font)
        // Do any additional setup after loading the view.
        if let nav = self.navigationController, nav.viewControllers.count > 1 {
            let backButton = UIButton(type: .custom)
            backButton.frame = CGRect(x: 0, y: 0, width: 60, height: 10)
            backButton.setImage(UIImage(named: "cut-ups/icons/arrow_left_blue"), for: .normal)
            backButton.adjustsImageWhenHighlighted = false
            backButton.setTitle("BACK".localized("button_back"), for: .normal)
            backButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 14)
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
            backButton.setTitleColor(UIColor(named: "Primary"), for: .normal)
            backButton.addTarget(self, action: #selector(self.backPressed), for: .touchUpInside)
            
            //NSLayoutConstraint(item: backButton, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: super.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: -75).isActive = true
            let leftButton = UIBarButtonItem(customView: backButton)
            
            //self.navigationItem.setLeftBarButton(leftButton, animated: true)
            self.navigationItem.leftBarButtonItem = leftButton
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
			
		}
        
        nextBottomSpacing.constant = getNextButtonSpacing()
        
		let attributes = [ NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: UIColor(named: "Primary") ?? .blue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium) ] as [NSAttributedString.Key : Any]
        let attrString = NSAttributedString(string: "Privacy Policy".localized("privacy_linked"), attributes: attributes)
        privacyPolicyButton.setAttributedTitle(attrString, for: .normal)
    }
	@objc func keyboardWillShow(notification: NSNotification) {
		print("keyboardWillShow")
		setBottomScrollInset(value: 40)
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		print("keyboardWillHide")
		setBottomScrollInset(value: 0)

	}
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = view.backgroundColor
        
    }
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollIndicatorState(scrollView)
		if scrollView.contentSize.height > scrollView.bounds.height && !(input is SignatureView){
			scrollView.delaysContentTouches = true

		} else {
			scrollView.delaysContentTouches = false
		}
		
    }
    func getNextButtonSpacing() -> CGFloat {
        var nextHeight:CGFloat = 0
        if #available(iOS 11.0, *) {
            if let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                nextHeight += bottomPadding
            }
        }
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            nextHeight += navBarHeight
        }
        nextHeight += UIApplication.shared.statusBarFrame.height
        return -nextHeight
    }
    
    @objc func backPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func set(questionIndex:String) {
        
       self.questionIndex = questionIndex
    }
    func loadQuestion(questionIndex:String) {
        let question = controller.get(question: questionIndex)
        
		displayQuestion(question: question)
        
    }
	
	
	func displayQuestion(question:Survey.Question) {
		//promptLabel.text = question.prompt
		//Get supplied template for question
		if let nextButtonTitle = question.nextButtonTitle {
			nextButton.setTitle(nextButtonTitle.localized(nextButtonTitle), for: .normal)
        } else {
            if question.nextButtonImage == nil {
                nextButton.setTitle("NEXT".localized("button_next"), for: .normal)
            }
        }
        if let nextButtonTitle = question.nextButtonImage {
            nextButton.setImage(UIImage(named: nextButtonTitle), for: .normal)
        } else {
            nextButton.setImage(nil, for: .normal)
        }
		let template = templateHandler?(question.questionId) ?? [:]

		let markedUpString = renderer.render(text: question.prompt, template:template)
		
		// Increase line height
		let attributedString = NSMutableAttributedString(attributedString: markedUpString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        promptLabel.attributedText = attributedString
        
		detailsLabel.text = question.detail
		
		self.id = question.questionId
        input?.parentScrollView = nil
		if question.type == .slider {
			let inputView:SliderView = input as? SliderView ?? .get()
			
			inputView.set(min: question.minValue ?? 0,
						  max: question.maxValue ?? 100,
						  minMessage: question.minMessage ?? "",
						  maxMessage: question.maxMessage ?? "")
			
			input = inputView

			
			
//            spacerView.isHidden = true
            
            container.alignment = inputView.orientation
            
		} else if question.type == .time {
			let inputView:TimeView = input as? TimeView ?? .get()
			
			input = inputView
            
            container.alignment = inputView.orientation
            
		} else if question.type == .duration {
			let inputView:DurationView = input as? DurationView ?? .get()
			
			input = inputView
            
            container.alignment = inputView.orientation
            
		} else if question.type == .choice {
			let inputView:MultipleChoiceView = input as? MultipleChoiceView ?? .get()
			input = inputView
            disableNextButton()
			inputView.set(question:question)
            
            container.alignment = inputView.orientation
			
			
		} else if question.type == .checkbox {
			let inputView:MultipleChoiceView = input as? MultipleChoiceView ?? .get()
			input = inputView
			inputView.state = .checkBox
			inputView.set(question:question)
            
            container.alignment = inputView.orientation
            
			
		}  else if question.type == .password {
			let inputView:PasswordView = input as? PasswordView ?? .get()
            inputView.openKeyboard()
			input = inputView
            privacyStack.isHidden = false
            container.alignment = inputView.orientation
            
		} else if question.type == .segmentedText {
			let inputView:SegmentedTextView = input as? SegmentedTextView ?? .get()
			inputView.openKeyboard()
            inputView.tryNext = self.tryNextButton
            input = inputView
            privacyStack.isHidden = false
            container.alignment = inputView.orientation
        } else if question.type == .multilineText {
            let inputView:MultilineTextView = input as? MultilineTextView ?? .get()
            input = inputView
			inputView.minCharacters = 1

            container.alignment = inputView.orientation
            
		} else if question.type == .number {
			let inputView:MultilineTextView = input as? MultilineTextView ?? .get()
			input = inputView
			inputView.maxCharacters = 2
			inputView.minCharacters = 1
			inputView.keyboardType = .numberPad
			
        } else if question.type == .image {
            let inputView:SignatureView = input as? SignatureView ?? .get()
            input = inputView
            
            
        } else if question.type == .calendar {
            let inputView:ACCalendarView = input as? ACCalendarView ?? ACCalendarView(frame: .zero
            )
            input = inputView
            
        } else if question.type == .picker {
            let inputView:ACPickerView = input as? ACPickerView ?? .get()
            
            input = inputView
        }
        if bottomAnchor != nil {
            bottomAnchor.isActive = input?.isBottomAnchored ?? false
        }
        container.alignment = input?.orientation ?? .top
        input?.setError(message: nil)
        input?.parentScrollView = self.scrollView
        input?.didFinishSetup = {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            if weakSelf.input?.getValue()?.value == nil {
                weakSelf.disableNextButton()
            } else {
                weakSelf.enableNextButton()
            }
        }
        input?.didChangeValue = {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            if weakSelf.input?.getValue()?.value == nil {
                weakSelf.disableNextButton()
            } else {
                weakSelf.enableNextButton()
            }
            
            self?.didChangeValue?();
        }
        
        if container.arrangedSubviews.isEmpty, let input = input as? UIView {
            container.addArrangedSubview(input)
        }
        

	}
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadQuestion(questionIndex: questionIndex ?? "")
        self.questionPresented?(input)
		scrollView.delegate = self
		scrollIndicatorState(scrollView)
        self.didFinishSetup?()
        
    }
	public func getValue() -> QuestionResponse? {
		return input?.getValue()
	}
	
	public func setValue(_ value: QuestionResponse?) {
		input?.setValue(value)
	}
	
	
	public func setError(message: String?) {
        
        if message != nil && (self.input is PasswordView || self.input is SegmentedTextView) {
            showContactButton()
        } else {
            showContactButton(false)
        }
		input?.setError(message: message)
		errorLabel.text = message
	}
    public func tryNextButton() {
        if self.nextButton.isEnabled {
            self.nextButtonPressed(UIButton())
        }
    }
    public func enableNextButton()
    {
        self.nextButton.isEnabled = true;
        self.nextButton.alpha = 1;
        if let id = self.id, let title = Arc.shared.surveyController.get(question: id).altNextButtonTitle {
            self.nextButton.setTitle(title, for: .normal)
        }
    }
    
    public func disableNextButton()
    {
        self.nextButton.isEnabled = false;
        self.nextButton.alpha = 0.5;
        if let id = self.id, let title = Arc.shared.surveyController.get(question: id).nextButtonTitle {
            self.nextButton.setTitle(title, for: .normal)
        }
    }
    
    
    @IBAction public func goToPrivacy() {
        app.appNavigation.defaultPrivacy()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //TODO:Remove this and refactor
    func showContactButton(_ shouldShow:Bool = true) {
        for v in views.arrangedSubviews {
            if v is LoginHelpView {
                v.removeFromSuperview()
            }
        }
        guard shouldShow else {
            return
        }
        let helpView:LoginHelpView = .get()
        helpView.helpButton.addTarget(self, action: #selector(navigateToHelp), for: .touchUpInside)
        views.addArrangedSubview(helpView)
    }
    
    @objc open func navigateToHelp() {
		if let helpPressed = helpPressed {
			helpPressed()
		} else {
            app.appNavigation.navigate(vc: app.appNavigation.defaultHelpState(), direction: .toRight)
		}
    }
	
	public func setBottomScrollInset(value:CGFloat) {
		var inset = scrollView.contentInset
		
			inset.bottom = value
		
		scrollView.contentInset = inset
	}
	
	// MARK: ScrollView
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
	}
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)

	}
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)

	}
	
	private func scrollIndicatorState(_ scrollView: UIScrollView) {
		let contentHeight = scrollView.contentSize.height
		
		let viewHeight = scrollView.bounds.height
		let offset = scrollView.contentOffset.y
		
		let effectiveHeight = contentHeight - viewHeight - 20
		let maxProgress = contentHeight - viewHeight - effectiveHeight
		
		let progress = min(maxProgress, max(offset - effectiveHeight, 0))
        let convertedRect = nextButton.convert(nextButton.frame, to: scrollView)
       // dump(scrollView.bounds)
        
        
        //dump(convertedRect)
		guard !scrollView.bounds.contains(convertedRect) && !scrollView.bounds.intersects(convertedRect) else {
			scrollIndicator.alpha = 0
			return
		}
		let alpha:CGFloat = 1.0 - (progress/maxProgress)
		scrollIndicator.alpha = alpha
		
		
		
	}

}
