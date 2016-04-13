//
//  Parser.swift
//  SwiftCSV
//
//  Created by Will Richardson on 11/04/16.
//  Copyright © 2016 JavaNut13. All rights reserved.
//

extension CSV {
    /// List of dictionaries that contains the CSV data
    public var rows: [[String: String]] {
        if _rows == nil {
            parse()
        }
        return _rows!
    }
    
    /// Dictionary of header name to list of values in that column
    /// Will not be loaded if loadColumns in init is false
    public var columns: [String: [String]] {
        if !loadColumns {
            return [:]
        } else if _columns == nil {
            parse()
        }
        return _columns!
    }
//    
//    /// Parse the file and call a block for each row, passing it as a dictionary
//    public func enumerateAsDict(block: [String: String] -> ()) {
//        var first = true
//        let enumeratedHeader = header.enumerate()
//        
//        text.enumerateLines { line, _ in
//            if !first {
//                let fields = self.parseLine(line)
//                var dict = [String: String]()
//                for (index, head) in enumeratedHeader {
//                    dict[head] = index < fields.count ? fields[index] : ""
//                }
//                block(dict)
//            } else {
//                first = false
//            }
//        }
//    }
//    
//    /// Parse the file and call a block for each row, passing it as an array
//    public func enumerateAsArray(block: [String] -> ()) {
//        var first = true
//        text.enumerateLines { line, _ in
//            if !first {
//                block(self.parseLine(line))
//            } else {
//                first = false
//            }
//        }
//    }
    
    private func parse() {
        var rows = [[String: String]]()
        var columns = [String: [String]]()
        
        if loadColumns {
            for head in header {
                columns[head] = []
            }
        }
        let enumeratedHeader = header.enumerate()
        let block: [String] -> () = { fields in
            var dict = [String: String]()
            for (index, head) in enumeratedHeader {
                dict[head] = index < fields.count ? fields[index] : ""
            }
            rows.append(dict)
        }
        
        var currentIndex = text.startIndex
        let endIndex = text.endIndex
        
        var atStart = true
        var parsingField = false
        var parsingQuotes = false
        var innerQuotes = false
        
        var fields = [String]()
        var field = [Character]()
        
        while currentIndex < endIndex {
            let char = text[currentIndex]
            print(currentIndex, char, innerQuotes)
            if atStart {
                if char == "\"" {
                    atStart = false
                    parsingQuotes = true
                } else if char == "," || char == "\n" {
                    fields.append(String(field))
                    block(fields)
                    fields = [String]()
                    field = [Character]()
                } else {
                    parsingField = true
                    atStart = false
                    field.append(char)
                }
            } else if parsingField {
                if innerQuotes {
                    if char == "\"" {
                        field.append(char)
                        innerQuotes = false
                    } else {
                        fatalError("Can't have non-quote here: \(char)")
                    }
                } else {
                    if char == "\"" {
                        innerQuotes = true
                    } else if char == "," || char == "\n" {
                        atStart = true
                        parsingField = false
                        innerQuotes = false
                        fields.append(String(field))
                        field = [Character]()
                    } else {
                        field.append(char)
                    }
                }
            } else if parsingQuotes {
                if innerQuotes {
                    if char == "\"" {
                        field.append(char)
                        innerQuotes = false
                    } else if char == "," || char == "\n" {
                        atStart = true
                        parsingQuotes = false
                        innerQuotes = false
                        fields.append(String(field))
                        field = [Character]()
                    } else {
                        fatalError("Can't have non-quote here: \(char)")
                    }
                } else {
                    if char == "\"" {
                        innerQuotes = true
                    } else {
                        field.append(char)
                    }
                }
            } else {
                fatalError("me_irl")
            }
            currentIndex = currentIndex.successor()
        }
        
        _rows = rows
        _columns = columns
    }
    
    func parseLine(line: String) -> [String] {
        let escape: Character = "\\"
        let quote: Character = "\""
        
        var fields = [String]()
        
        var inQuotes = false
        var currentIndex = line.startIndex
        
        var field = [Character]()
        
        while currentIndex < line.endIndex {
            let char = line[currentIndex]
            if !inQuotes && char == self.delimiter {
                fields.append(String(field))
                field = [Character]()
            } else {
                if char == quote {
                    inQuotes = !inQuotes
                } else if char == escape {
                    currentIndex = currentIndex.successor()
                    field.append(line[currentIndex])
                } else {
                    field.append(char)
                }
            }
            currentIndex = currentIndex.successor()
        }
        fields.append(String(field))
        
        return fields
    }
}
