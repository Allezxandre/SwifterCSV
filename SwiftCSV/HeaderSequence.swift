//
//  HeaderSequence.swift
//  SwiftCSV
//
//  Created by Naoto Kaneko on 2/18/16.
//  Copyright © 2016 Naoto Kaneko. All rights reserved.
//

import Foundation

struct HeaderGenerator: GeneratorType {
    typealias Element = String
    
    private var fieldGenerator: FieldGenerator
    
    init(text: String, delimiter: NSCharacterSet) {
        let newline = NSCharacterSet.newlineCharacterSet()
        let rows = text.componentsSeparatedByCharactersInSet(newline)
        let header = rows[0]
        fieldGenerator = FieldGenerator(text: header, delimiter: delimiter)
    }
    
    mutating func next() -> String? {
        return fieldGenerator.next()
    }
}

struct HeaderSequence: SequenceType {
    typealias Generator = HeaderGenerator
    
    private let text: String
    private let delimiter: NSCharacterSet
    
    init(text: String, delimiter: NSCharacterSet) {
        self.text = text
        self.delimiter = delimiter
    }
    
    func generate() -> HeaderGenerator {
        return HeaderGenerator(text: text, delimiter: delimiter)
    }
}
