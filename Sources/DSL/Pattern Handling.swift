//
//  Pattern Handling.swift
//  Pattern Programming
//
//  Created by Letanyan Arumugam on 2016/09/21.
//  Copyright © 2016 Letanyan Arumugam. All rights reserved.
//

import Darwin

enum Pattern {
	case regex(Regex)
	case manual
}

struct Command {
	let pattern: Pattern
	let command: (Commander, [Match]) -> String?
	var recursiveMatch: Bool = false
	
	init(pattern: Pattern, command: @escaping (Commander, [Match]) -> String?, recursiveMatch: Bool = false) {
		self.pattern = pattern
		self.command = command
		self.recursiveMatch = recursiveMatch
	}
	
	init(pattern: Pattern, command: @escaping (Commander, [Match]) -> String?) {
		self.pattern = pattern
		self.command = command
	}
	
	init(pattern: Regex, command: @escaping (Commander, [Match]) -> String?) {
		self.pattern = .regex(pattern)
		self.command = command
	}
	
	init(command: @escaping (Commander, [Match]) -> String?) {
		pattern = .manual
		self.command = command
	}
	
	func execute(on text: String, with commander: Commander) -> String? {
		switch pattern {
		case .regex(let r):
			if let matches = r.matches(in: text, over: text.nsRange) {
				if let result = command(commander, matches) {
					return r.replacedMatches(in: text, with: recursiveMatch ? commander.execute(on: result) : result)
				}
				return nil
			}
			return nil
		
		case .manual:
			let m = Match(source: text)
			if let result = command(commander, [m]) {
				return result
			}
			return nil
		}
	}
}

protocol Commander {
	var showTrace: Bool { get set }
	var commands: [Command] { get set }
	var recursive: Bool { get set }
	func execute(on text: String) -> String
}

extension Commander {
	func execute(on text: String) -> String {
		var result = text
		
		var i = 0
		if showTrace { print("""
		----------------------Execution Trace----------------------
		\(text)
		-----------------------------------------------------------
		""")}
		
		while i < commands.count {
			let c = commands[i]
			if let change = c.execute(on: result, with: self) {
				if change.contains("!fatal!") {
					return String(change[change.index(change.startIndex, offsetBy: 7)...])
				}
				result = change
				
				if showTrace { print(result) }
				if recursive {
					i = -1
				}
			}
			i += 1
		}
		
		return result
	}
}

protocol System {
	var commanders: [Commander] { get }
	func execute(on text: String) -> String
}

extension System {
	func execute(on text: String) -> String {
		var result = text
		for c in commanders {
			result = c.execute(on: result)
		}
		return result
	}
}
