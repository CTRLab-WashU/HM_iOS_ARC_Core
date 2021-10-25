//
//  HmToSageMigrationViewController.swift
//  Arc
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

open class HmToSageMigrationViewController: UIViewController, MigrationCompletedListener {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleText.textColor = UIColor.white
        self.titleText.font = UIFont(name: "Roboto-Medium", size: 18.0)!
        
        // Localization not needed, no international users need migrated
        self.tryAgainButton.setTitle("Try again", for: .normal)
        self.contactUsButton.setTitle("Contact Study Coordinator", for: .normal)
        
        self.checkAndPossiblyRunMigration()
    }
    
    private func checkAndPossiblyRunMigration() {
        let sage = TaskListScheduleManager.shared
        if sage.userNeedsToMigrate() {
            self.setUpdatingUi()
            sage.migrateUserToSageBridge(completionListener: self)
        } else {
            success()
        }
    }
    
    public func progressUpdate(progress: Int) {
        self.progressBar.progress = Float(progress) / Float(TaskListScheduleManager.migrationSteps)
    }
    
    public func success() {
        Arc.shared.nextAvailableState(runPeriodicBackgroundTask: false, direction: .fade)
    }
    
    public func failure(errorString: String) {
        self.showFailureState()
        self.titleText.text = errorString
    }
    
    func setUpdatingUi() {
        self.hideFailureState()
        self.progressBar.isHidden = false
        self.progressBar.progress = Float(0)
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "app"
        self.titleText.text = "Updating \(appName)..."
    }
    
    func hideFailureState() {
        self.progressBar.isHidden = false
        self.tryAgainButton.isHidden = true
        self.contactUsButton.isHidden = true
    }
    
    func showFailureState() {
        self.progressBar.isHidden = true
        self.tryAgainButton.isHidden = false
        self.contactUsButton.isHidden = false
    }
    
    @IBAction open func tryAgainPressed(_ sender: UIButton) {
        self.checkAndPossiblyRunMigration()
    }
    
    @IBAction open func contactUsPressed(_ sender: UIButton) {
        let helpState = Arc.shared.appNavigation.defaultHelpState()
        Arc.shared.appNavigation.navigate(vc: helpState, direction: .toRight)
    }
}
