//
//  ViewController.swift
//  project-8
//
//  Created by Bruno Guirra on 23/01/22.
//

import UIKit

class ViewController: UIViewController {
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var level = 1
    
    // Set a observer to update scoreLabel
    // text when the score property changes
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    // Create UI elements and add constraints to each one
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .right
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.text = "CLUES"
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
         
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.text = "ANSWERS"
        answersLabel.textAlignment = .right
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.numberOfLines = 0
        answersLabel .setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.textAlignment = .center
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let configuration = UIButton.Configuration.plain()
        
        let submit = UIButton(configuration: configuration, primaryAction: nil)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.layer.borderWidth = 1
        submit.layer.cornerRadius = 5
        submit.layer.borderColor = UIColor.systemGray.cgColor
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(configuration: configuration, primaryAction: nil)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.layer.borderWidth = 1
        clear.layer.cornerRadius = 5
        clear.layer.borderColor = UIColor.systemGray.cgColor
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsGrid = createButtonsGrid(rows: 4, columns: 5, spacing: 10.0)
        buttonsGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsGrid)
        
        // An array with all active constraints
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 20),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsGrid.widthAnchor.constraint(equalToConstant: 720),
            buttonsGrid.heightAnchor.constraint(equalToConstant: 320),
            buttonsGrid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsGrid.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }

    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                // Split the content of the file in lines and shuffle them
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    // The lines is splited in two parts, one contains
                    // the answer and other the clue
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    // Create the clue string
                    clueString += "\(index + 1). \(clue)\n"
                    
                    // Create a hint containing the answer's amount of letters
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    // Split the answer in bits that will go in
                    // the buttons to user plays it
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        
        // Removes the line breaks of clue and answer
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Suffle the bits and sets each one as title of
        // a button
        letterBits.shuffle()
        
        if letterButtons.count == letterBits.count {
            for i in 0..<letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        sender.isEnabled = false
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        clearSelectedButtons()
    }
    
    @objc func submitTapped(_ sender: UIButton?) {
        guard let answerText = currentAnswer.text else { return }
        
        if let solutionPosition = solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            
            var splitedAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitedAnswers?[solutionPosition] = answerText
            answersLabel.text = splitedAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            // Upgrades the level of the game
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Wrong!", message: "You answer isn't correct", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) {
                _ in
                self.clearSelectedButtons()
            })
            present(ac, animated: true)
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for button in letterButtons {
            button.isEnabled = true
        }
    }
    
    func createButtonsGrid(rows: Int, columns: Int, spacing: CGFloat) -> UIStackView {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 10
        
        for _ in 0..<rows {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.distribution = .fillEqually
            horizontalStack.alignment = .fill
            horizontalStack.spacing = 10
            
            for _ in 0..<columns {
                let letterButton = UIButton(type: .system)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.layer.borderWidth = 1
                letterButton.layer.cornerRadius = 5
                letterButton.layer.borderColor = UIColor.gray.cgColor
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                horizontalStack.addArrangedSubview(letterButton)
                letterButtons.append(letterButton)
            }
            
            verticalStack.addArrangedSubview(horizontalStack)
        }
        
        return verticalStack
    }
    
    func clearSelectedButtons() {
        currentAnswer.text = ""
        
        for button in activatedButtons {
            button.isEnabled = true
        }
        
        activatedButtons.removeAll()
    }
}

