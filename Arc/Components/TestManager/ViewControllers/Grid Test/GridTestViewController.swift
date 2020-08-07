//
//  GridTestViewController.swift
// Arc
//
//  Created by Philip Hayes on 10/5/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public protocol GridTestViewControllerDelegate : class {
	func didSelectGrid(indexPath:IndexPath)
	func didSelectLetter(indexPath:IndexPath)
	func didDeselectLetter(indexPath:IndexPath)
	
}
open class GridTestViewController: ArcViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TestProgressViewControllerDelegate {
	
	
    public enum Mode {
        case none
        case image
        case fCell
		case answers
    }
    
    public enum PopupAction {
        case set(responseData:Int, index:IndexPath)
        case unset(index:IndexPath)
    }
    public var mode:Mode = .none
    
    public var choiceIndicator:IndicatorView?
    public var controller = Arc.shared.gridTestController
    public var tests:[GridTest] = []
    public var responseId:String = ""
    public var testNumber:Int = 0
    public var phase:Int = 0
    public var endTimer:Timer?
    public var maybeEndTimer:Timer?
	public var isVisible = true
	public var shouldAutoProceed = true
    public var isPracticeTest = false
	public var fIndexPaths:[IndexPath] = []
	public var symbolIndexPaths:[IndexPath] = []
    var interstitial:InterstitialView = .get()
    @IBOutlet public weak var collectionStack: UIStackView!
    @IBOutlet public weak var collectionView: UICollectionView!
    @IBOutlet public weak var collectionViewHeight:NSLayoutConstraint!
    @IBOutlet public weak var tapOnTheFsLabel: ACLabel!
    @IBOutlet public weak var collectionViewWidth: NSLayoutConstraint!
    @IBOutlet public weak var continueButton: ACButton!
	public weak var delegate:GridTestViewControllerDelegate?
    private var symbols:[UIImage] = [#imageLiteral(resourceName: "key"),
                                     #imageLiteral(resourceName: "phone"),
                                     #imageLiteral(resourceName: "pen")]
	public var revealedIndexPaths:[IndexPath] = []
	
    private var IMAGE_HEIGHT:Int {
        get {
            return SMALLER_GRIDS ? 58 : 80
        }
    }
    private var IMAGE_WIDTH:Int {
        get {
            return SMALLER_GRIDS ? 48 : 60
        }
    }
    private var SMALLER_GRIDS:Bool {
        get {
            return (self.isPracticeTest && (PhoneClass.getClass() == .iphoneSE))
        }
    }
    private let IMAGE_ROWS = 5
    private let LETTER_SIZE = 42
    private let LETTER_ROWS = 10
    private var LETTER_BUFFER = 20
    private let LINE_SPACING = 1
    private let IMAGE_GRID_TUTORIAL_WIDTH:CGFloat = 260
    private let LETTER_GRID_TUTORIAL_WIDTH:CGFloat = 284

	private weak var currentAlert:MHAlertView?
    override open func viewDidLoad() {
        super.viewDidLoad()
		if shouldAutoProceed && !isPracticeTest {
        	ACState.testCount += 1
		}
		let app = Arc.shared
		let studyId = Int(app.studyController.getCurrentStudyPeriod()?.studyID ?? -1)
		if let sessionId = app.currentTestSession, shouldAutoProceed {
			let session = app.studyController.get(session: sessionId, inStudy: studyId)
			let data = session.surveyFor(surveyType: .gridTest)
			responseId = data!.id! //A crash here means that the session is malformed
			
			tests = controller.createTest(numberOfTests: 2)
			_ = controller.createResponse(id: responseId, numSections: 2)

		} else if !isPracticeTest {
        	tests = controller.createTest(numberOfTests: 2)
        	responseId = controller.createResponse(numSections: 2)
        } else {
            tests = controller.createTutorialTest()
            responseId = controller.createResponse(numSections: 1)
        }
		collectionView.register(UINib(nibName: "GridFCell", bundle: Bundle(for: GridFCell.self)), forCellWithReuseIdentifier: "fCell")
		collectionView.register(UINib(nibName: "GridImageCell", bundle: Bundle(for: GridImageCell.self)), forCellWithReuseIdentifier: "imageCell")

        // Do any additional setup after loading the view.
        
        if let h = UIApplication.shared.keyWindow?.rootViewController?.view.frame.height, h > 568 {
            LETTER_BUFFER = 60
        }
		continueButton.isHidden = true
		let _ = controller.set(symbols: responseId, gridTests: tests)
        
    }
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		isVisible = true

			
		_ = controller.start(test: responseId)
		_  = controller.mark(filled: responseId)

		if shouldAutoProceed {
			displayPreSymbols();
		}
    }
	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		isVisible = false
        maybeEndTimer?.invalidate()
        maybeEndTimer = nil
		currentAlert?.remove()
	}
    open func displaySymbols()
    {
		guard isVisible else {
			return
		}
        
        continueButton.isHidden = true
        
        self.collectionViewHeight.constant = CGFloat((IMAGE_HEIGHT*IMAGE_ROWS) + (LINE_SPACING*(IMAGE_ROWS-1)))
        if SMALLER_GRIDS {
            collectionViewWidth.constant = IMAGE_GRID_TUTORIAL_WIDTH
        }
        
        interstitial.set(message: nil)
        interstitial.removeFromSuperview()
        self.mode = .image
        
        endTimer?.invalidate();
        
        phase = 0;
        
        collectionView.allowsSelection = false;
        symbolIndexPaths = []
        collectionView.reloadData();
        
        _ = controller.markTime(gridDisplayedSymbols: responseId, questionIndex: testNumber)
       
		if shouldAutoProceed {
			Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {
				[weak self] (timer) in
				self?.displayFs()
			}
		}
    }
    
    open func displayFs()
    {
		guard isVisible else {
			return
		}
        
        self.collectionViewHeight.constant = CGFloat((LETTER_SIZE*LETTER_ROWS) + (LINE_SPACING*(LETTER_ROWS-1)) + LETTER_BUFFER)
        if SMALLER_GRIDS {
            collectionViewWidth.constant = LETTER_GRID_TUTORIAL_WIDTH
        }

        self.mode = .fCell

        phase = 1

        collectionView.allowsSelection = true

        collectionView.allowsMultipleSelection = true
		fIndexPaths = []
        collectionView.reloadData()

        _ = controller.markTime(gridDisplayedFs: responseId, questionIndex: testNumber)
        
        tapOnTheFsLabel.isHidden = false
		tapOnTheFsLabel.translationKey = "grids_subheader_fs"
        tapOnTheFsLabel.text = "Tap on the F's"
        tapOnTheFsLabel.numberOfLines = 0
        
		if shouldAutoProceed {

			Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {[weak self] (timer) in
				self?.displayReady()
			}
		}
        
    }
	open func clearGrids()
	{
		guard isVisible else {
			return
		}
		
		self.collectionViewHeight.constant = CGFloat((LETTER_SIZE*LETTER_ROWS) + (LINE_SPACING*(LETTER_ROWS-1)) + LETTER_BUFFER)
        if SMALLER_GRIDS {
            collectionViewWidth.constant = IMAGE_GRID_TUTORIAL_WIDTH
        }

		self.mode = .none
		
		phase = 0
		
		collectionView.allowsSelection = false
		
		collectionView.allowsMultipleSelection = false
		fIndexPaths = []
		collectionView.reloadData()
		
		
		tapOnTheFsLabel.isHidden = false
		
        self.currentHint?.removeFromSuperview()
        self.currentHint = nil

		
	}
    open func displayReady()
    {
        
		guard isVisible else {
			return
		}

		currentAlert = Arc.shared.displayAlert(message: "Ready".localized(ACTranslationKey.grids_overlay3_pt2), options: [.wait(waitTime: 1.0, {
			[weak self] in
			self?.displayGrid()
//			if let s = self {
//				s.tapOnTheFsLabel.isHidden = true
//			}
			$0.removeFromSuperview()
		})])

		
    }
    
    open func displayPreSymbols()
    {
		guard isVisible else {
			return
		}
		self.tapOnTheFsLabel.isHidden = true
        continueButton.isHidden = true
        currentAlert = Arc.shared.displayAlert(message: "".localized(ACTranslationKey.grids_overlay1),
									options: [.wait(waitTime: 2.0, {
										self.displaySymbols()
										$0.removeFromSuperview()
									})])

		
    }
    
    open func displayGrid()
    {
		guard isVisible else {
			return
		}
        tapOnTheFsLabel.isHidden = false
        tapOnTheFsLabel.translationKey = nil
        tapOnTheFsLabel.text = "Tap on the location of each item"
        tapOnTheFsLabel.numberOfLines = 0
        interstitial.set(message: nil)
        interstitial.removeFromSuperview()
        self.collectionViewHeight.constant = CGFloat((IMAGE_HEIGHT*IMAGE_ROWS) + (LINE_SPACING*(IMAGE_ROWS-1)))
        mode = .image
        
        collectionView.allowsSelection = true;
        
        
        if isPracticeTest {
            tapOnTheFsLabel.isHidden = false
			tapOnTheFsLabel.translationKey = nil
			tapOnTheFsLabel.text = "Tap the boxes where the items were located in part one.".localized(ACTranslationKey.grids_subheader_boxes)
            tapOnTheFsLabel.numberOfLines = 0
        }
        
        collectionView.allowsMultipleSelection = true;
        
        phase = 2
        
        collectionView.reloadData()
        
        _ = controller.markTime(gridDisplayedTestGrid: responseId, questionIndex: testNumber)
		if shouldAutoProceed {

        	endTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(endTest), userInfo: nil, repeats: false)
		}
    }
    
    @IBAction func continuePressed(_ sender: Any)
    {
        maybeEndTest()
    }
    
    @objc open  func endTest()
    {
        if phase == 3
        {
            return;
        }
        
        phase = 3
        
        testNumber += 1;
        
//        test?.selectValue(option: gridData as AnyObject?);
		
//        gridData = DNGridInputSet(selectedFs: 0, selectedEs: 0, selectedGridItems: []);
        
//        test?.gridTestMetrics.append(self.gridMetrics);
        
//        self.gridMetrics = DNGridTestMetrics();
        
        if testNumber >= controller.get(testCount: responseId)
        {
			_ = controller.mark(filled: responseId)
			let nextMessage = (ACState.testCount == 3) ? "Well done!".localized(ACTranslationKey.testing_done) : "Loading next test...".localized(ACTranslationKey.testing_loading)
			let vc = TestProgressViewController(title: "Symbols Test Complete!".localized(ACTranslationKey.grids_complete), subTitle: nextMessage, count: ACState.testTaken - 1)
			vc.delegate = self
			self.addChild(vc)
			self.view.anchor(view: vc.view)
			vc.set(count: ACState.testTaken)
			vc.waitAndExit(time: 3.0)
			
        }
        else
        {
            displayPreSymbols();
        }
        
    }
	public func testProgressDidComplete() {
		Arc.shared.nextAvailableState()

	}
    open func maybeEndTest()
    {
        if controller.get(numChoicesFor: responseId, testIndex: testNumber) >= 3
        {
            endTimer?.invalidate();
            endTest();
        }
    }
    
    // Sets numbers of cells for each grids test portion
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch mode {
        case .image, .answers:
            return 25

        case .fCell:
            return 60
        default:
            return 0
        }
        
    }
    
    // Sets images and f's for cell with value
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = (mode == .image) ? "imageCell" : "fCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type, for: indexPath)
        let index = indexPath.row
        
        if (mode == .image || mode == .answers) {
            
            let iCell = cell as! GridImageCell
            iCell.clear()
            iCell.layer.cornerRadius = 4
            iCell.layer.borderWidth = 1
            iCell.layer.borderColor = UIColor(named: "Modal Fade")!.cgColor
            iCell.isPracticeCell = self.isPracticeTest
            
			if mode != .answers {
            	iCell.image.isHidden = false;
			} else {
				if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false{
					iCell.image.isHidden = true
				}
 			}
			if phase == 0 {
                let value = controller.get(item: index, section: testNumber, gridType: .image)
                if value > -1 {
                    iCell.setImage(image: self.symbols[value]);
                    iCell.image.isHidden = false;
                    symbolIndexPaths.append(indexPath)
                }
            } else if (self.isPracticeTest && phase == 2) {
                let value = controller.get(item: index, section: testNumber, gridType: .image)
                if value > -1 {
                    iCell.setImage(image: self.symbols[value]);
                }
            } else if phase == 2 {
                if let selection = controller.get(selectedData: index, id: responseId,       questionIndex: testNumber, gridType: .image)?.selection {
                        iCell.setImage(image:self.symbols[selection])
                        iCell.image.isHidden = false
                }
                var selected = 0
                for i in 0...24
                {
                    let value = (controller.get(selectedData: i, id: responseId, questionIndex: testNumber, gridType: .image)?.selection) ?? -1
                    if value > -1
                    {
                        selected += 1
                    }
                }
                if selected == 3
                {
                    continueButton.isHidden = false
                    collectionStack.setCustomSpacing(16, after: tapOnTheFsLabel)
                } else {
                    continueButton.isHidden = true
                }
            }
                            
            
        } else if (mode == .fCell) {
            let fCell = cell as! GridFCell
            
            fCell.contentView.layer.cornerRadius = 22.0
            fCell.contentView.layer.backgroundColor = UIColor.clear.cgColor;
            fCell.contentView.layer.masksToBounds = true
            
            let value = controller.get(item: index, section: testNumber, gridType: .distraction)

            if value == 1 {
                fCell.setCharacter(character: "F")
				fIndexPaths.append(indexPath)

            }
            else
            {
                fCell.setCharacter(character: "E");
            }
        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if (collectionView.cellForItem(at: indexPath) as? GridImageCell) != nil
        {
            if collectionView.indexPathsForSelectedItems?.count == 3
            {
                
            }
        }
        
        return true;
    }
    
    //Sets value to cells
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let c = collectionView.cellForItem(at: indexPath) as? GridImageCell
        {
//            if self.choiceIndicator?.isHidden == true{
//
//
//
//
//                delegate?.didSelectGrid(indexPath: indexPath)
//                //showDot(on: indexPath)
//                if shouldAutoProceed {
//                    maybeEndTimer?.invalidate();
//                    maybeEndTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (timer) in
//                        self.maybeEndTest()
//                    })
//                }
//            }

            
            
            let touchedAt = c.touchTime!
            let response = responseId
            let test = testNumber
            let controller = self.controller
            let coll = collectionView
            let selection = controller.get(selectedData: indexPath.row, id: responseId, questionIndex: testNumber, gridType: .image)?.selection
            
            choiceIndicator?.removeFromSuperview()
            choiceIndicator?.targetView?.backgroundColor = UIColor(red: 191.0/255.0, green: 215.0/255.0, blue: 224.0/255.0, alpha: 1.0)
            choiceIndicator?.targetView?.layer.borderWidth = 1
            choiceIndicator?.targetView?.layer.borderColor = UIColor(named: "Modal Fade")!.cgColor
            
            choiceIndicator = imagePopup(in: self.view, indexPath: indexPath, view: c, choice: selection) { popupSelection in
                
                switch popupSelection {
                case .set(let imageIndex, let index):
                    let _ = controller.setValue(responseIndex: index.row,
                    responseData: imageIndex,
                    questionIndex: test,
                    gridType: .image,
                    time: touchedAt,
                    id: response)
                case .unset(let imageIndex):
                    let _ = controller.unsetValue(responseIndex: imageIndex.row,
                               questionIndex: test,
                               gridType: .image,
                               id: response)
                }
                coll.reloadData()
            }
        }
        else if let c = collectionView.cellForItem(at: indexPath) as? GridFCell
        {
           // c.contentView.layer.backgroundColor = UIColor(red: 191.0/255.0, green: 215.0/255.0, blue: 224.0/255.0, alpha: 1.0).cgColor
            //c.backgroundColor = UIColor(red: 191.0/255.0, green: 215.0/255.0, blue: 224.0/255.0, alpha: 1.0) //UIColor(red: 182.0/255.0, green: 221.0/255.0, blue: 236.0/255.0, alpha: 1.0);
			//UIColor(red:0, green:0.37, blue:0.52, alpha:0.25)
			c.contentView.layer.backgroundColor = UIColor(named: "Primary Selected")!.cgColor
			c.label.textColor = UIColor(named: "Primary")
			if c.label.text == "F" {
                _ = controller.update(fCountSteps: 1, testIndex: testNumber, id: responseId)
            } else if c.label.text == "E"{
                _ = controller.update(eCountSteps: 1, testIndex: testNumber, id: responseId)

            }
			//c.isSelected = true
			delegate?.didSelectLetter(indexPath: indexPath)
        }

    }
//    func showDot(on indexPath: IndexPath) {
//           guard let cell = self.collectionView.cellForItem(at: indexPath) as? GridImageCell else { return }
//           cell.dotView.isHidden = false
//       }
    //Unsets value to cells
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        if let c = collectionView.cellForItem(at: indexPath) as? GridImageCell
        {
            guard !isPracticeTest else { return }
            
            choiceIndicator?.removeFromSuperview()

//            _ = controller.unsetValue(responseIndex: indexPath.row,
//            questionIndex: testNumber,
//            gridType: .image,
//            id: responseId)
//            self.currentHint?.removeFromSuperview()
//            self.currentHint = nil
        }
        else if let c = collectionView.cellForItem(at: indexPath) as? GridFCell
        {
            c.contentView.layer.backgroundColor = UIColor.clear.cgColor
            c.label.textColor = UIColor(named: "Primary")
            if c.label.text == "F" {
                _ = controller.update(fCountSteps: -1, testIndex: testNumber, id: responseId)
            } else if c.label.text == "E"{
                _ = controller.update(eCountSteps: -1, testIndex: testNumber, id: responseId)
                
            }
			//c.isSelected = false
			delegate?.didDeselectLetter(indexPath: indexPath)

        }
    }

	func overlayCell(at indexPath:IndexPath) -> UIView? {
		if mode == .image || mode == .answers {
			if let c = collectionView.cellForItem(at: indexPath) as? GridImageCell {
                view.overlayView(withShapes: [.roundedRect(c, 0, CGSize(width: 0, height: 0))])
				c.highlight()
                c.image.isHidden = false
				return c
			}
		}
		if mode == .fCell {
			if let c = collectionView.cellForItem(at: indexPath) as? GridFCell {
                //c.overlay(radius: c.frame.width/2)
				view.overlayView(withShapes: [.roundedRect(c, c.frame.width/2, CGSize(width: -8, height: -8))])

                c.highlight(radius: c.frame.width/2)
				return c
			}
		}
		return nil
	}
	func overlayCells(at indexPaths:[IndexPath]) {
		
		let shapes = indexPaths.map {
            return OverlayShape.roundedRect(collectionView.cellForItem(at: $0)!, 8, CGSize(width: 0, height: 0))
		}
		view.overlayView(withShapes: shapes)
		for indexPath in indexPaths {
			if mode == .image || mode == .answers {
				if let c = collectionView.cellForItem(at: indexPath) as? GridImageCell {
					
					c.highlight(radius: 0.0)
					c.image.isHidden = false
				}
			}
			if mode == .fCell {
				if let c = collectionView.cellForItem(at: indexPath) as? GridFCell {
					
					c.highlight(radius: c.frame.width/2)
					
				}
			}
		}
	}
    //MARK: Flow layout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if mode == .image || mode == .answers {
            return CGSize(width: IMAGE_WIDTH, height: IMAGE_HEIGHT)
        } else if mode == .fCell {
            return CGSize(width: LETTER_SIZE, height: LETTER_SIZE)
        } else {
            return CGSize(width: 1, height: 1)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if mode == .image || mode == .answers {
            return (SMALLER_GRIDS ? 2 : 3)
        } else if mode == .fCell {
            return 2
        } else {
            return 0
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if mode == .image || mode == .answers {
            return 3
        } else if mode == .fCell {
            return 1
        } else {
            return 0
        }
    }
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if mode == .image || mode == .answers {
            return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            
        } else if mode == .fCell {
            return UIEdgeInsets(top: 8, left: 10, bottom: 4, right: 10)

            
        } else {
            return .zero
        }
    }
    
    public func imagePopup(in parent:UIView, indexPath:IndexPath, view: UIView, choice: Int?, action:@escaping(PopupAction) -> ()) -> IndicatorView
    {
//        var arrowPosition:Bool = false
//        if indexPath.row > 14 {
//            arrowPosition = false
//        } else {
//            arrowPosition = true
//        }
        
        let gridSelection:GridTestSelectionView = .get()
        gridSelection.keyImage.image = symbols[0]
        if choice == 0 {
            gridSelection.keyButton.isEnabled = false
            gridSelection.keyImage.alpha = 0.5
        }
        styleImageButton(imageButton: gridSelection.keyImage)
        gridSelection.keyButton.addAction {
            action(.set(responseData: 0, index: indexPath))
            gridSelection.removeFromSuperview()
        }
        gridSelection.phoneImage.image = symbols[1]
        if choice == 1 {
            gridSelection.phoneButton.isEnabled = false
            gridSelection.phoneImage.alpha = 0.5
        }
        styleImageButton(imageButton: gridSelection.phoneImage)
        gridSelection.phoneButton.addAction {
            action(.set(responseData: 1, index: indexPath))
            gridSelection.removeFromSuperview()
        }
        gridSelection.penImage.image = symbols[2]
        if choice == 2 {
            gridSelection.penButton.isEnabled = false
            gridSelection.penImage.alpha = 0.5
        }
        styleImageButton(imageButton: gridSelection.penImage)
        gridSelection.penButton.addAction {
            action(.set(responseData: 2, index: indexPath))
            gridSelection.removeFromSuperview()
        }
        if choice != nil {
            gridSelection.removeItem.addAction {
                action(.unset(index: indexPath))
                gridSelection.removeFromSuperview()
                
            }
        } else {
            gridSelection.hideRemoveItemButton()
        }
        
        return parent.indicator {
            $0.targetView = view
            $0.configure(with: IndicatorView.Config(primaryColor: .white, secondaryColor: .white, textColor: .black, cornerRadius: 16, arrowEnabled: true, arrowAbove: true))
            $0.container?.axis = .horizontal
            $0.layer.masksToBounds = false
            $0.layer.shadowOpacity = 0.5
            $0.layer.shadowRadius = 4
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.container?.addArrangedSubview(gridSelection)
            $0.layout {
                $0.centerX == view.centerXAnchor ~ 500
                $0.top >= parent.safeAreaLayoutGuide.topAnchor ~ 999
                $0.bottom <= parent.safeAreaLayoutGuide.bottomAnchor ~ 999
                $0.trailing <= parent.safeAreaLayoutGuide.trailingAnchor ~ 999
                $0.leading >= parent.safeAreaLayoutGuide.leadingAnchor ~ 999
//                if indexPath.row > 14{
//                    $0.bottom == view.topAnchor - 8 ~ 500
//                } else{
                    $0.top == view.bottomAnchor + 8 ~ 500
                //}
            }
        }

    }

    public func styleImageButton(imageButton:UIImageView)
    {
        imageButton.layer.cornerRadius = 6
        imageButton.layer.borderColor = UIColor.lightGray.cgColor
        imageButton.layer.borderWidth = 1
        imageButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageButton.layer.shadowColor = UIColor.black.cgColor
        imageButton.layer.shadowRadius = 1
        imageButton.layer.shadowOpacity = 0.5
        imageButton.layer.masksToBounds = false
    }
    
    
}
