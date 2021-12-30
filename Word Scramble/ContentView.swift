//
//  ContentView.swift
//  Word Scramble
//
//  Created by Brian Steele on 12/23/21.
//

import SwiftUI

let MIN_LENGTH = 1

struct ContentView: View {
    @State private var currentWord = ""
    @State private var currentAnswer = ""
    @State private var enteredWords = [String]()
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var shouldShowError = false
    @State private var userScore = 0
    
    @FocusState private var answerFieldIsFocused: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $currentAnswer)
                        .autocapitalization(.none)
                        .focused($answerFieldIsFocused)
                        .disableAutocorrection(true)
                        .onSubmit(addWord)
                }
                
                Section("Your score") {
                    Text("\(userScore)")
                }
                
                Section("Entered words") {
                    ForEach(enteredWords, id: \.self) {word in
                        Text(word)
                    }
                }
            }

            .navigationTitle(currentWord != "" ? currentWord : "Get Started")
            .toolbar {
                Button("New word") {
                    startGame()
                }
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $shouldShowError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addWord() {
        let answer = currentAnswer.lowercased().trimmingCharacters(in: .whitespaces)
         guard validate(word: answer) else {
             shouldShowError = true
             return
         }
        calculateScoreFor(word: answer)
        withAnimation {
            enteredWords.insert(answer, at: 0)
        }
        currentAnswer = ""
        answerFieldIsFocused = true
    }
    
    func startGame() {
        userScore = 0
        enteredWords.removeAll()
        if let wordListURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let wordListContents = try? String(contentsOf: wordListURL) {
                let wordList = wordListContents.components(separatedBy: "\n")
                currentWord = wordList.randomElement() ?? "hamilton"
                return
            }
        }
        fatalError("Coud not load word list file")
    }
    
    func calculateScoreFor(word: String) -> Void {
        userScore += word.count * currentWord.count
    }
    
    func isMinLength(word: String) -> Bool {
        return word.count >= MIN_LENGTH
    }
    
    func isNotOriginalWord(word: String) -> Bool {
        return word != currentWord
    }
    
    func isUnique(word: String) -> Bool {
        return !enteredWords.contains(word)
    }
    
    func isValid(word: String) -> Bool {
        guard word.components(separatedBy: " ").count <= 2 else {
            return false
        }
        var localCurrentWord = currentWord
        for letter in word {
            let letterIndex = localCurrentWord.firstIndex(of: letter)
            if letterIndex != nil {
                localCurrentWord.remove(at: letterIndex!)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func validate(word: String) -> Bool {
        var validityCheck: Bool
        
        guard isMinLength(word: word) else {
            errorTitle = "Too short"
            errorMessage = "Your word must be at least \(MIN_LENGTH) \(MIN_LENGTH == 1 ? "character" : "characters")"
            validityCheck = false
            return validityCheck
        }
        guard isNotOriginalWord(word: word) else {
            errorTitle = "Invalid word"
            errorMessage = "You can't use that word"
            validityCheck = false
            return validityCheck
        }
        guard isValid(word: word) else {
            errorTitle = "Invalid word!"
            errorMessage = "Can't use that combination of letters"
            validityCheck = false
            return validityCheck
        }
        guard isUnique(word: word) else {
            errorTitle = "Duplicate word!"
            errorMessage = "You've already used that one"
            validityCheck = false
            return validityCheck
        }
        guard isReal(word: word) else {
            errorTitle = "Invalid word"
            errorMessage = "That's not a word"
            validityCheck = false
            return validityCheck
        }
        validityCheck = true
        return validityCheck
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
