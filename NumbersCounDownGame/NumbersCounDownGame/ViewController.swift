//
//  ViewController.swift
//  NumbersCounDownGame
//
//  Created by ShamlaTech on 1/19/19.
//  Copyright © 2019 ShamlaTech. All rights reserved.
//

import UIKit

extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
    
    func randomIndex() -> Int {
        return Int(arc4random_uniform(UInt32(self.count)))
    }
}

extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
    
}

enum Operation: String {
    case add = "+", subtract = "-", multiply = "*", divide = "/"
    
    static func all() -> [Operation] {
        return [.add, .subtract, .multiply, .divide]
    }
}

struct SolutionStep {
    let operand1: Int
    let operand2: Int
    let operation: Operation
    
    init(operand1: Int, operand2: Int, operation: Operation) {
        self.operand1 = operand1
        self.operand2 = operand2
        self.operation = operation
    }
}

class BaseViewController: UIViewController {
    var bigNumbers = [25, 50, 75, 100].shuffled()
    var smallNumbers1 = [1,2,3,4,5,6,7,8,9,10].shuffled()
    var smallNumbers2 = [1,2,3,4,5,6,7,8,9,10].shuffled()
    
    var row1ChoosenNumbers = [Int]()
    
    var row2ChoosenNumbers = [Int]()
    
    var row3ChoosenNumbers = [Int]()
    
    var choosenNumbers = [Int]()
    var solution = ""
    
    func generateTarget() -> Int {
        var targetResult = 0
        repeat {
            targetResult = 0
            self.solution = ""
            var updatedChoosenNumbers = self.choosenNumbers
            var operationsCount = 0
            repeat {
                let idx1 = updatedChoosenNumbers.randomIndex()
                var idx2 = updatedChoosenNumbers.randomIndex()
                while idx2 == idx1 {
                    idx2 = updatedChoosenNumbers.randomIndex()
                }
                let operand1 = updatedChoosenNumbers[idx1]
                let operand2 = updatedChoosenNumbers[idx2]
                let arithmeticResult = self.tryArithmeticOpertationWith(operand1, operand2: operand2)
                if idx1 > idx2 {
                    updatedChoosenNumbers.remove(at: idx1)
                    updatedChoosenNumbers.remove(at: idx2)
                } else {
                    updatedChoosenNumbers.remove(at: idx2)
                    updatedChoosenNumbers.remove(at: idx1)
                }
                if targetResult != 0 {
                    let result = self.tryArithmeticOpertationWith(arithmeticResult.0, operand2: targetResult)
                    self.solution.append(",(\(arithmeticResult.1.operand1)\(arithmeticResult.1.operation.rawValue)\(arithmeticResult.1.operand2))\(result.1.operation.rawValue)\(targetResult)=\(result.0)")
                    targetResult = result.0
                } else {
                    targetResult = arithmeticResult.0
                    self.solution.append("\(arithmeticResult.1.operand1)\(arithmeticResult.1.operation.rawValue)\(arithmeticResult.1.operand2)=\(arithmeticResult.0)")
                }
                operationsCount += 1
            } while operationsCount < 2
        } while targetResult < 0 || targetResult > 999
        return targetResult
    }
    
    func tryArithmeticOpertationWith(_ operand1: Int, operand2: Int) -> (Int, SolutionStep) {
        switch Operation.all()[Operation.all().randomIndex()] {
        case .add:
            return (operand1 + operand2, SolutionStep.init(operand1: operand1, operand2: operand2, operation: .add))
        case .subtract:
            return (operand1 - operand2, SolutionStep.init(operand1: operand1, operand2: operand2, operation: .subtract))
        case .multiply:
            return (operand1 * operand2, SolutionStep.init(operand1: operand1, operand2: operand2, operation: .multiply))
        case .divide:
            if operand1 > operand2 && operand1%operand2 == 0 {
                return (operand1 / operand2, SolutionStep.init(operand1: operand1, operand2: operand2, operation: .divide))
            } else {
                return self.tryArithmeticOpertationWith(operand1,operand2: operand2)
            }
        }
    }
    
    func reset() {
        self.solution = ""
        row1ChoosenNumbers.removeAll()
        row2ChoosenNumbers.removeAll()
        row3ChoosenNumbers.removeAll()
        choosenNumbers.removeAll()
    }
    
    func showAlertWith(_ title: String = "Solution is", message: String, completion: ((UIAlertActionStyle) -> (Void))? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
            completion?(.cancel)
            switch action.style {
            case .default:
                print("Default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertMessage(_ message: String, title: String = "Time Up", actionPhrase: String = "show solution", dismisPhrase: String = "Cancel", completion: ((UIAlertActionStyle) -> (Void))? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: dismisPhrase, style: UIAlertActionStyle.cancel, handler: { action in
            completion?(.cancel)
            switch action.style {
            case .default:
                print("Default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: actionPhrase, style: UIAlertActionStyle.default, handler: { action in
            completion?(.default)
            switch action.style {
            case .default:
                print("Default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

class ViewController: BaseViewController {
    @IBOutlet weak var targetBtn: UIButton!
    
    @IBOutlet weak var smallNumCollectionView2: UICollectionView!
    @IBOutlet weak var smallNumCollectionView1: UICollectionView!
    @IBOutlet weak var bigNumCollectionView: UICollectionView!
    
    @IBOutlet weak var choosenNumCollectionView: UICollectionView!
    @IBOutlet weak var selectedNumContentView: UIView!
    
    @IBOutlet weak var targetResult: UILabel!
    @IBAction func generateTarget(_ sender: Any) {
        guard self.choosenNumbers.count == 6 else {
            self.showAlertWith("", message: "Please select any SIX numbers from the above") { (style) -> (Void) in
                
            }
            return
        }
        self.targetResult.text = "Target is \(self.generateTarget())"
        self.startTimer()
        self.selectedNumContentView.isHidden = false
        self.choosenNumCollectionView.reloadData()
    }
    
    @IBOutlet weak var countDownLbl: UILabel!
    
    func startTimer() {
        if self.countDownTimer != nil {
            self.countDownTimer?.invalidate()
            self.countDownTimer = nil
        }
        self.targetBtn.isUserInteractionEnabled = false
        self.countDownLbl.text = "\(30)"
        self.countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            var countDown = Int(self.countDownLbl.text ?? "0")!
            if countDown > 0 {
                countDown -= 1
                self.countDownLbl.text = "\(countDown)"
            } else {
                self.countDownTimer?.invalidate()
                self.countDownTimer = nil
                self.showAlertMessage("time went out.", completion: { (style) -> (Void) in
                    if style == .default {
                        self.showAlertWith(message:self.solution, completion: { (style) -> (Void) in
                            self.reset()
                        })
                        return
                    }
                    self.reset()
                })
            }
        })
    }
    
    var countDownTimer: Timer?
    
    override func reset() {
        super.reset()
        self.countDownLbl.text = "Get\nTarget"
        self.targetResult.text = nil
        self.targetBtn.isUserInteractionEnabled = true
        self.bigNumCollectionView.reloadData()
        self.smallNumCollectionView1.reloadData()
        self.smallNumCollectionView2.reloadData()
        self.selectedNumContentView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.targetBtn.layer.cornerRadius = self.targetBtn.bounds.height/2
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == bigNumCollectionView ? bigNumbers.count : collectionView == choosenNumCollectionView ? self.choosenNumbers.count : smallNumbers1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = collectionView == bigNumCollectionView || collectionView == choosenNumCollectionView ? "BigNumCell" : "SmallNumCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let tmpCell = cell as? BigNumCell, collectionView == bigNumCollectionView {
            let number = self.bigNumbers[indexPath.item]
            tmpCell.numLbl.textColor = self.row1ChoosenNumbers.contains(number) ? .black : .white
            tmpCell.numLbl.text = "\(number)"
        } else if let tmpCell = cell as? SmallNumCell, collectionView == smallNumCollectionView1 {
            let number = self.smallNumbers1[indexPath.item]
            tmpCell.numLbl.textColor = self.row2ChoosenNumbers.contains(number) ? .black : .white
            tmpCell.numLbl.text = "\(number)"
        } else if let tmpCell = cell as? SmallNumCell, collectionView == smallNumCollectionView2 {
            let number = self.smallNumbers2[indexPath.item]
            tmpCell.numLbl.textColor = self.row3ChoosenNumbers.contains(number) ? .black : .white
            tmpCell.numLbl.text = "\(number)"
        } else if let tmpCell = cell as? BigNumCell, collectionView == choosenNumCollectionView {
            let number = self.choosenNumbers[indexPath.item]
            tmpCell.numLbl.textColor = .black
            tmpCell.numLbl.text = "\(number)"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bigNumCollectionView {
            let number = self.bigNumbers[indexPath.item]
            if !self.row1ChoosenNumbers.contains(number) && self.choosenNumbers.count < 6 {
                self.row1ChoosenNumbers.append(number)
                self.bigNumCollectionView.reloadData()
            }
        } else if collectionView == smallNumCollectionView1 {
            var number = self.smallNumbers1[indexPath.item]
            if !self.row2ChoosenNumbers.contains(number) && self.choosenNumbers.count < 6 {
                while self.choosenNumbers.contains(number) {
                    self.smallNumbers1.shuffle()
                    number = self.smallNumbers1[indexPath.item]
                }
                self.row2ChoosenNumbers.append(number)
                self.smallNumCollectionView1.reloadData()
            }
        } else if collectionView == smallNumCollectionView2 {
            var number = self.smallNumbers2[indexPath.item]
            if !self.row3ChoosenNumbers.contains(number) && self.choosenNumbers.count < 6 {
                while self.choosenNumbers.contains(number) {
                    self.smallNumbers2.shuffle()
                    number = self.smallNumbers2[indexPath.item]
                }
                self.row3ChoosenNumbers.append(number)
                self.smallNumCollectionView2.reloadData()
            }
        }
        self.updateChoosenNumbers()
    }
    
    func updateChoosenNumbers() {
        self.choosenNumbers = []
        self.choosenNumbers.append(contentsOf: self.row1ChoosenNumbers)
        self.choosenNumbers.append(contentsOf: self.row2ChoosenNumbers)
        self.choosenNumbers.append(contentsOf: self.row3ChoosenNumbers)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size
        size.width = collectionView == bigNumCollectionView ? collectionView.bounds.size.width/4 : collectionView == choosenNumCollectionView ? collectionView.bounds.size.width/6 : collectionView.bounds.size.width/10
        size.height = size.width
        return size
    }
    
    
}

