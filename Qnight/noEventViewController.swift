//
//  noEventViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-08.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseDatabase
import FirebaseAnalytics

class noEventViewController: UIViewController{
    
    // Properties
    
    var productPage: ProductPage?
    
    var venueGoingID: String = ""
    var ages: [String: Int]? = [:]
    var genders: [String: Int] = ["male": 0, "female": 0]
    var currentVenueID: String = ""
    let dateFormat = DateFormatter()
    var currentNoEventRef: DatabaseReference? = nil
    
    var facebookUser: FacebookUser?
    
    var vote: Bool = false
    var votes: [Int] = [0,0,0,0,0]
    var voteIndex: Int = 5 // nonsense number
    
    @IBOutlet weak var vote1: UILabel!
    @IBOutlet weak var vote2: UILabel!
    @IBOutlet weak var vote3: UILabel!
    @IBOutlet weak var vote4: UILabel!
    @IBOutlet weak var vote5: UILabel!
    @IBOutlet weak var encouragementLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        showGoing()
        
    }
    
    
    func showGoing() {
        
        updateVotes()
        
        self.encouragementLabel.text = "Every Vote Counts! 🙆‍♂️🙆"
    }

    
    func updateVotes(){
        self.vote1.text = String(self.votes[0])
        self.vote2.text = String(self.votes[1])
        self.vote3.text = String(self.votes[2])
        self.vote4.text = String(self.votes[3])
        self.vote5.text = String(self.votes[4])
    }
    
    func voted(bool: Bool){
        vote = bool
    }
    
    func returnVote()->Bool{
        return vote
    }
    
    func setVote(buttonIndex: Int){
        if (returnVote() == false){
            self.votes[buttonIndex] += 1
            self.voteIndex = buttonIndex
            voted(bool: true)
        }
        else {
            changeVote(index: buttonIndex)
        }
        updateVotes()
    }
    
    func changeVote(index: Int){
        // check to see if we are unvoting
        if (self.voteIndex == index){
            self.votes[index] -= 1
            voted(bool: false)
        } // change vote
        else{
            self.votes[index] += 1
            self.votes[self.voteIndex] -= 1
        }
        self.voteIndex = index
    }
    
    // MARK: IBAction
    
    @IBAction func button1(_ sender: UIButton) {
        setVote(buttonIndex: 0)
    }
    @IBAction func button2(_ sender: UIButton) {
        setVote(buttonIndex: 1)
    }
    @IBAction func button3(_ sender: UIButton) {
        setVote(buttonIndex: 2)
    }
    @IBAction func button4(_ sender: UIButton) {
        setVote(buttonIndex: 3)
    }
    @IBAction func button5(_ sender: UIButton) {
        setVote(buttonIndex: 4)
    }
    
}
