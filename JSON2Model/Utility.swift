//
//  Utility.swift
//  JSON2Model
//
//  Created by lau on 2020/5/31.
//  Copyright © 2020 xllau. All rights reserved.
//

import Foundation

struct Config {
    let name: String
    let indent: String
    let modelType: ModelType
    enum ModelType: String {
        case `struct`, `class`
    }
}

class Utility {
    static func formtter(text: String, name: String, type: Config.ModelType) -> String {
        guard let data = text.data(using: .utf8) else {
            return "not valid JSON object"
        }
        let modelName = name.isEmpty ? "Example" : name
        do {
            let config = Config(name: modelName, indent: "", modelType: type)
            return try Utility.text(form: data, config: config)
        } catch {
            return error.localizedDescription
        }
    }
    
    
    static func text(form data: Data, config: Config) throws -> String {
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        return text(form: object, config: config)
    }
    
    static func text(form object: Any, config: Config) -> String {
        switch object {
        case is Array<Any>:
            return text(form: object as! [Any], config: config)
        case is Dictionary<String, Any>:
            return text(form: object as! [String: Any], config: config)
        default:
            return "Error"
        }
    }
    
    static func text(form dictinary: [String: Any], config: Config) -> String {
        let name = config.name
        let type = config.modelType.rawValue
        let currentIndent = config.indent
        var newText = "\(currentIndent)\(type) \(name): Codable {"
        let indent = config.indent + "    "
        let dictText = dictinary.map { (item) -> String in
            let value = item.value
            let key = item.key
            switch value {
            case is Int:
                return "\(indent)let \(key): Int?"
            case is String:
                return "\(indent)let \(key): String?"
            case is Data:
                return "\(indent)let \(key): Data?"
            case is Double:
                return "\(indent)let \(key): Double?"
            case is Bool:
                return "\(indent)let \(key): Bool?"
            case is Date:
                return "\(indent)let \(key): Date?"
            case is Array<Any>:
                let subArray = value as! Array<Any>
                guard let first = subArray.first else {
                    return "\(indent)let \(key): [Any]?"
                }
                switch first {
                case is Int:
                    return "\(indent)let \(key): [Int]?"
                case is String:
                    return "\(indent)let \(key): [String]?"
                case is Data:
                    return "\(indent)let \(key): [Data]?"
                case is Double:
                    return "\(indent)let \(key): [Double]?"
                case is Bool:
                    return "\(indent)let \(key): [Bool]?"
                case is Date:
                    return "\(indent)let \(key): [Date]?"
                default:
                    let subConfig = Config(name: key, indent: indent, modelType: config.modelType)
                    var subText = text(form: first, config: subConfig)
                    subText.append("\(indent)let \(key): [\(key)]?")
                    return subText
                }
            case is Dictionary<String, Any>:
                let subDict = value as! Dictionary<String, Any>
                let subConfig = Config(name: key, indent: indent, modelType: config.modelType)
                var subText = text(form: subDict, config: subConfig)
                subText.append("\(indent)let \(key): \(key)?")
                return subText
            default:
                return "\(indent)let object: Any?"
            }
        }
        newText.append("\n")
        newText.append(dictText.joined(separator: "\n"))
        newText.append("\n")
        newText.append("\(currentIndent)}")
        newText.append("\n")
        return newText
    }
    
    static func text(form array: [Any], config: Config) -> String {
        let name = config.name
        let indent = config.indent + "    "
        guard let first = array.first else {
            return "\(indent)let \(name): [Any]?"
        }
        switch first {
        case is Int:
            return "\(indent)let \(name): [Int]?"
        case is String:
            return "\(indent)let \(name): [String]?"
        case is Data:
            return "\(indent)let \(name): [Data]?"
        case is Double:
            return "\(indent)let \(name): [Double]?"
        case is Bool:
            return "\(indent)let \(name): [Bool]?"
        case is Date:
            return "\(indent)let \(name): [Date]?"
        default:
            let subConfig = Config(name: name, indent: indent, modelType: config.modelType)
            var subText = text(form: first, config: subConfig)
            subText.append("\(indent)let \(name): [\(name)]?")
            return subText
        }
    }
}
