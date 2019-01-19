//
//  SolvationViewController.swift
//  NumbersCounDownGame
//
//  Created by ShamlaTech on 1/19/19.
//  Copyright © 2019 ShamlaTech. All rights reserved.
//

import UIKit

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

class SolvationViewController: BaseViewController {
    @IBOutlet weak var targetLbl: UILabel!
    @IBOutlet weak var numbersCollectionView: UICollectionView!
    var targetNumber: Int = 0
    @IBAction func add(_ sender: Any) {
        guard self.operand1 != 0 && self.operand2 != 0 else {
            self.showAlertWith("", message: "Select Any Two Numbers to perform Addition", completion: nil)
            return
        }
        self.steps.append((self.operand1, self.operand2, self.numbers))
        self.numbers = self.numbers.difference(from: [self.operand1, self.operand2])
        self.numbers.insert(self.operand1+self.operand2, at: 0)
        self.checkTarget(self.operand1+self.operand2)
        self.clearOperands()
    }
    
    func clearOperands() {
        self.operand2 = 0
        self.operand1 = 0
        self.numbersCollectionView.reloadData()
    }
    
    @IBAction func multiply(_ sender: Any) {
        guard self.operand1 != 0 && self.operand2 != 0 else {
            self.showAlertWith("", message: "Select Any Two Numbers to perform Multiplication", completion: nil)
            return
        }
        self.steps.append((self.operand1, self.operand2, self.numbers))
        self.numbers = self.numbers.difference(from: [self.operand1, self.operand2])
        self.numbers.insert(self.operand1*self.operand2, at: 0)
        self.numbers = self.numbers.unique
        self.checkTarget(self.operand1*self.operand2)
        self.clearOperands()
    }
    
    @IBAction func divide(_ sender: Any) {
        guard self.operand1 != 0 && self.operand2 != 0 else {
            self.showAlertWith("", message: "Select Any Two Numbers to perform Division", completion: nil)
            return
        }
        if operand1 > operand2 && operand1%operand2 == 0 {
            self.steps.append((self.operand1, self.operand2, self.numbers))
            self.numbers = self.numbers.difference(from: [self.operand1, self.operand2])
            self.numbers.insert(self.operand1/self.operand2, at: 0)
            self.numbers = self.numbers.unique
            self.checkTarget(self.operand1/self.operand2)
        } else {
            self.showAlertWith("", message: "Result of the operation cannot at fraction", completion: nil)
        }
        self.clearOperands()
    }
    @IBAction func subtract(_ sender: Any) {
        guard self.operand1 != 0 && self.operand2 != 0 else {
            self.showAlertWith("", message: "Select Any Two Numbers to perform Subtraction", completion: nil)
            return
        }
        self.steps.append((self.operand1, self.operand2, self.numbers))
        self.numbers = self.numbers.difference(from: [self.operand1, self.operand2])
        self.numbers.insert(self.operand1-self.operand2, at: 0)
        self.numbers = self.numbers.unique
        self.checkTarget(self.operand1-self.operand2)
        self.clearOperands()
    }
    
    @IBAction func resetView(_ sender: Any) {
        self.operand1 = 0
        self.operand2 = 0
        self.numbers = self.choosenNumbers
        self.numbersCollectionView.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        if self.steps.count > 0 {
            let lastStep = self.steps.last
            self.operand1 = 0
            self.operand2 = 0
            self.numbers = lastStep?.2 ?? self.choosenNumbers
            self.numbers = self.numbers.unique
            self.steps.removeLast()
            self.numbersCollectionView.reloadData()
        }
    }
    
    var operand1: Int = 0
    var operand2: Int = 0
    
    var numbers = [Int]()
    
    var steps: [(Int, Int, [Int])] = []
    
    @IBOutlet weak var countDownLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startNewRound()
    }
    
    func checkTarget(_ value: Int) {
        if self.targetNumber == value {
            self.countDownTimer?.invalidate()
            self.showAlertMessage("Wow! You have reached the Target!", title: "Target Reached", actionPhrase: "Start New Round") { (style) -> (Void) in
                if style == .default {
                    self.startNewRound()
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.numbersCollectionView.reloadData()
        }
    }
    
    func startNewRound() {
        self.choosenNumbers.removeAll()
        self.generateNumbers()
        self.numbersCollectionView.reloadData()
        self.targetNumber = self.generateTarget()
        self.targetLbl.text = "Target is \(self.targetNumber)"
        self.startTimer()
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func generateNumbers() {
        var numbers = self.bigNumbers
        numbers.append(contentsOf: self.smallNumbers1)
        numbers.shuffle()
        var idx1 = numbers.randomIndex()
        var indexs = [Int]()
        repeat {
            if indexs.contains(idx1) {
                idx1 = numbers.randomIndex()
            } else {
                indexs.append(idx1)
            }
        } while indexs.count < 6
        for idx in indexs {
            self.choosenNumbers.append(numbers[idx])
        }
        self.numbers = self.choosenNumbers
    }
    
    func startTimer() {
        if self.countDownTimer != nil {
            self.countDownTimer?.invalidate()
            self.countDownTimer = nil
        }
        self.countDownLbl.text = "\(30)"
        self.countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            var countDown = Int(self.countDownLbl.text ?? "0")!
            if countDown > 0 {
                countDown -= 1
                self.countDownLbl.text = "\(countDown)"
            } else {
                self.countDownTimer?.invalidate()
                self.countDownTimer = nil
                self.showAlertMessage("time went out.", dismisPhrase: "End Game", completion: { (style) -> (Void) in
                    if style == .default {
                        self.showAlertWith(message:self.solution, completion: { (style) -> (Void) in
                            self.resetView(self.targetLbl!)
                            self.showAlertMessage("Do you want to start new round?", title: "", actionPhrase: "Yes", dismisPhrase: "No", completion: { (style) -> (Void) in
                                if style == .default {
                                    self.startNewRound()
                                } else {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        })
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
    
    var countDownTimer: Timer?

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SolvationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "BigNumCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let tmpCell = cell as? BigNumCell {
            let number = self.numbers[indexPath.item]
            tmpCell.numLbl.textColor = .black
            tmpCell.numLbl.text = "\(number)"
            tmpCell.backgroundColor = self.operand1 == number || self.operand2 == number ? .red : .white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.operand2 == self.numbers[indexPath.item] {
            self.operand2 = 0
            self.numbersCollectionView.reloadData()
            return
        }
        if self.operand1 == self.numbers[indexPath.item] {
            self.operand1 = 0
            self.numbersCollectionView.reloadData()
            return
        }
        if self.operand1 == 0 {
            self.operand1 = self.numbers[indexPath.item]
        } else {
            self.operand2 = self.numbers[indexPath.item]
        }
        
        self.numbersCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.width = collectionView.bounds.size.width/CGFloat(6)
        size.height = size.width
        return size
    }
}
