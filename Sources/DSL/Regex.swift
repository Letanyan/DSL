//
//  Regex.swift
//  Pillar
//
//  Created by Letanyan Arumugam on 2016/04/28.
//  Copyright © 2016 Letanyan Arumugam. All rights reserved.
//

import Foundation

extension NSRegularExpression.MatchingOptions {
	static var RecursiveSearch: NSRegularExpression.MatchingOptions {
		return NSRegularExpression.MatchingOptions(rawValue: 1 << 5)
	}
}

extension String {
	var boolValue: Bool {
		return self == "true" ? true : false
	}
	
	var intValue: Int {
		return (self as NSString).integerValue
	}
	
	var floatValue: Float {
		return (self as NSString).floatValue
	}
	
	var doubleValue: Double {
		return (self as NSString).doubleValue
	}
	
	func arrayValue(seperatedBy seperator: String) -> [String] {
		return (self as NSString).components(separatedBy: seperator)
	}
	
	var vectorValue: Vector {
		return Vector(trimmed(by: 1).arrayValue(seperatedBy: ",").map { $0.doubleValue })
	}
	
	var range: Range<Index> {
		return startIndex..<endIndex
	}
	
	var nsRange: NSRange {
		return NSRange(location: 0, length: count)
	}
	
	var regex: Regex {
		return Regex(pattern: self) ?? Regex(pattern: "")!
	}
	
	func regex(with options: NSRegularExpression.Options) -> Regex {
		return Regex(pattern: self, options: options) ?? Regex(pattern: "")!
	}
	
	func trimmed(by count: Int) -> String {
		let start = index(startIndex, offsetBy: count)
		let end = index(endIndex, offsetBy: -count)
		return String(self[start..<end])
	}
}

func stringRange(for string: String, from range: NSRange) -> Range<String.Index> {
	let start = string.index(string.startIndex, offsetBy: range.location)
	let end = string.index(string.startIndex, offsetBy: range.location + range.length)
	let result = start..<end
	return result
}

struct Capture: CustomStringConvertible {
	let range: NSRange
	let capture: String
	
	var stringValue: String {
		return capture
	}
	
	var boolValue: Bool {
		return capture.boolValue
	}
	
	var intValue: Int {
		return capture.intValue
	}
	
	var floatValue: Float {
		return capture.floatValue
	}
	
	var doubleValue: Double {
		return capture.doubleValue
	}
	
	func arrayValue(with seperator: String) -> [String] {
		return capture.arrayValue(seperatedBy: seperator)
	}
	
	var vectorValue: Vector {
		return capture.vectorValue
	}
	
	var description: String {
		return "\(range.location)..<\(range.location + range.length) :: \(capture)"
	}
}

struct Match: CustomStringConvertible {
	let range: NSRange
	let match: String
	var captures = [Capture]()
	
	init(source: String) {
		range = source.nsRange
		match = source
	}
	
	init(textCheckingResult: NSTextCheckingResult, source: String) {
		range = textCheckingResult.range
		match = String(source[stringRange(for: source, from: range)])
		
		for i in 1..<textCheckingResult.numberOfRanges {
			let r = textCheckingResult.range(at: i)
			if r.location < source.count {
				let c = String(source[stringRange(for: source, from: r)])
				captures.append(Capture(range: r, capture: c))
			}
		}
	}
	
	var description: String {
		return "\(range.location)..<\(range.location + range.length) :: \(match)"
	}
}

struct Regex {
	private let regularExpression: NSRegularExpression
	let options: NSRegularExpression.Options
	let matchingOptions: NSRegularExpression.MatchingOptions = .withTransparentBounds
	let pattern: String
	
	init?(pattern: String, options: NSRegularExpression.Options) {
		self.options = options
		self.pattern = pattern
		
		do {
			regularExpression = try NSRegularExpression(pattern: pattern, options: options)
		} catch {
			return nil
		}
	}
	
	init?(pattern: String) {
		options = [.allowCommentsAndWhitespace, .anchorsMatchLines]
		self.pattern = pattern
		
		do {
			regularExpression = try NSRegularExpression(pattern: pattern, options: options)
		} catch {
			return nil
		}
	}
	
	func matches(in string: String, over range: NSRange, with options: NSRegularExpression.MatchingOptions = []) -> [Match]? {
		var result = [Match]()
		
		let ms = regularExpression.matches(in: string, options: options, range: range)
		if ms.count == 0 {
			return nil
		}
		
		for m in ms {
			result.append(Match(textCheckingResult: m, source: string))
		}
		return result
	}
	
	private func replaceCaptureRefrences(in string: String, with captures: [Capture]) -> String {
		var string = string
		let captureRefrencePattern = Regex(pattern: "\\$\\d")
		
		let ms = captureRefrencePattern?.matches(in: string, over: string.nsRange)
		
		
		if let ms = ms {
			for m in ms {
				let ci = m.match[m.match.index(after: m.match.startIndex)...]
				guard let i = Int(ci) else {
					break
				}
				
				let c = captures[i].capture
				string = string.replacingCharacters(in: stringRange(for: string, from: m.range), with: c)
			}
		}
		
		return string
	}
	
	func replacedMatches(in string: String, with template: String, and options: NSRegularExpression.MatchingOptions = []) -> String {
		var result = string
		
		let isRec = options.contains(.RecursiveSearch)
		
		let range = { () -> NSRange in
			return isRec ? result.nsRange : result.nsRange
		}
		
		while let ms = matches(in: result, over: range(), with: options), ms.count > 0 {
			let css = ms.map { $0.captures }
			
			guard let m = ms.first else {
				break
			}
			
			let t: String
			if let cs = css.first {
				t = replaceCaptureRefrences(in: template, with: cs)
			} else {
				t = template
			}
			result = result.replacingCharacters(in: stringRange(for: result, from: m.range), with: t)
			break
		}
		
		
		return result
	}
}
