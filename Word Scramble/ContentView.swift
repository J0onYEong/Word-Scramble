//
//  ContentView.swift
//  Word Scramble
//
//  Created by 최준영 on 2022/11/09.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowing = false
    
    @FocusState private var isFocused
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(alertTitle, isPresented: $isShowing) {
                Button("Ok") {
                    //focusing textFeild
                    isFocused = true
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            wordError(title: "Empty word", message: "the word is empty")
            return;
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Used word", message: "the word is already used")
            return;
        }
        guard isPossible(word: answer) else {
            wordError(title: "Impossible combination", message: "the word couldn't be formed like this")
            return;
        }
        guard isRealWord(word: answer) else {
            wordError(title: "Failed to find word", message: "the word isn't exist")
            return;
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        startGame()
    }
    
    func startGame() {
        if let fileName = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: fileName) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Elephant"
                //focusing textFeild
                isFocused = true
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    /// Checking inserting word is alreay injected to usedWords property.
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    /// Checking inserting word is formed in letters from rootWord.
    func isPossible(word: String) -> Bool {
        var copy = rootWord
        for letter in word {
            if let index = copy.firstIndex(of: letter) {
                copy.remove(at: index)
            }
            else {
                return false
            }
        }
        return true
    }
    /// Checking inserting word is real word in english dictionary.
    func isRealWord(word: String) -> Bool {
        let uITextChecker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let result = uITextChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return result.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
