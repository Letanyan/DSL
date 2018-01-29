//
//  Expression Calculator.swift
//  Pattern Programming
//
//  Created by Letanyan Arumugam on 2016/09/22.
//  Copyright © 2016 Letanyan Arumugam. All rights reserved.
//

import Darwin

enum ExpressionError: String {
	case prefix = "{Expression Error: Prefix Function}"
	case varFunction = "{Expression Error: Var Arg Function}"
	case binaryFunction = "{Expression Error: Binary Function}"
	case unaryFunction = "{Expression Error: Unary Function}"
	case brackets = "{Expression Error: Brackets}"
	case range = "{Expression Error: Range}"
	case exponential = "{Expression Error: Exponential}"
	case multiplicative = "{Expression Error: Multiplicative}"
	case additive = "{Expression Error: Additive}"
	case vectorMultiplicative = "{Expression Error: Vector Multiplication}"
	case vectorAdditive = "{Expression Error: Vector Addition}"
	case numberComparison = "{Expression Error: Number Comparison}"
	case logicGate = "{Expression Error: Logic Gate}"
}

struct ExpressionCalculator: Commander {
	static var variables = [String: String]()
	
	static let vector = "\\[\(std.list(std.real, ","))\\]"
	static let matrix = "\\[\(std.list(vector, ","))\\]"
	static let operand = "(?:\(vector)|\(std.real)|[a-zA-Z]+)"
	static let expression = "\(std.list(operand, "[-+*/^=]"))"
	static let emptyFunction = "(?:pi|random|rand)"
	static let unaryFunction = "(?:sqrt?|ln|log10|log2|a?sinh?|a?cosh?|a?tanh?|floor|ceil|round)"
	static let binaryFunction = "(?:power|log|sumproduct)"
	static let varFunction = "(?:sum|product)"
	static let postfixFunction = "(?:!)"
	static let prefixFunction = "(?:!)"
	static let closure = "\\{([^\\{\\}]+)\\}"
	static let s = "\\s*"
	static let ss = "\\s+"
	
	let hex = Command(pattern: "0x([A-Fa-f0-9])+".regex) {_, matches in
		if let f = matches.first {
			let hexs = f.captures[0].stringValue
			var result = 0
			let hexValue: (Character) -> Int = {c in
				switch c {
					case "a", "A": return 10
					case "b", "B": return 11
					case "c", "C": return 12
					case "d", "D": return 13
					case "e", "E": return 14
					case "f", "F": return 15
					default: return "\(c)".intValue
				}
			}
			
			for hex in hexs {
				result += hexValue(hex)
			}
			return result.description
		}
		return nil
	}
	
	let range = Command(pattern: "(\(std.real))(\\:)(?:(\(std.real))\\:)?(\(std.real))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			let o = f.captures[1].stringValue
			var b = f.captures[2].doubleValue
			let by: Double
			if f.captures.count > 3 {
				by = b
				b = f.captures[3].doubleValue
			} else {
				by = 1.0
			}
			
			let r = stride(from: a, through: b, by: by)
			var s = [Double]()
			for rr in r {
				s.append(rr)
			}
			
			return anyList(with: s, seperatedBy: ",", andEnclosedWith: ("[", "]"))
		}
		return ExpressionError.range.rawValue
	}
	
	var postfixFunctions = Command(pattern: "(\(std.int))(\(postfixFunction))".regex) {_, matches in
		if let f = matches.first {
			let fn = f.captures[1].stringValue
			let n = f.captures[0].intValue
			
			switch fn {
				case "!": return n > 1 ? (1...n).reduce(1, *).description : (n < 0 ? "{factorial applies to n >= 0}" : "1")
				default: return ExpressionError.prefix.rawValue
			}
		}
		return ExpressionError.prefix.rawValue
	}
	
	var prefixFunctions = Command(pattern: "(\(prefixFunction))(\(std.bool))".regex) {_, matches in
		if let f = matches.first {
			let fn = f.captures[0].stringValue
			let n = f.captures[1].stringValue
			
			switch fn {
			case "!": return n == "true" ? "false" : "true"
			default: return ExpressionError.prefix.rawValue
			}
		}
		return ExpressionError.prefix.rawValue
	}
	
	var varFunctions = Command(pattern: "(\(varFunction)) \\(? (\(vector)) \\)?".regex) {commander, matches in
		if let f = matches.first {
			let fn = f.captures[0].stringValue
			let args = f.captures[1].vectorValue
			
			switch fn {
			case "sum":
				var result: Double = 0
				for a in args.values {
					result += a
				}
				return result.description
				
			case "product":
				var result: Double = 1
				for a in args.values {
					result *= a
				}
				return result.description
				
			default: return ExpressionError.varFunction.rawValue
			}
		}
		return ExpressionError.varFunction.rawValue
	}
	
	var emptyFunctions = Command(pattern: "(\(emptyFunction))(?:\\(\\))?".regex) {commander, matches in
		if let first = matches.first {
			let f = first.captures[0].stringValue
			
			switch f {
			case "pi": return Double.pi.description
			case "random": return arc4random().description
			case "rand": return (Double(arc4random()) / Double(UInt32.max)).description
			
				
			default: return ExpressionError.unaryFunction.rawValue
			}
		}
		return ExpressionError.unaryFunction.rawValue
	}
	
	var unaryFunctions = Command(pattern: "(\(unaryFunction))\\((\(expression))\\)".regex) {commander, matches in
		if let first = matches.first {
			let f = first.captures[0].stringValue
			var e = first.captures[1].stringValue
			e = commander.execute(on: e)
			let d = Double(e) ?? 0
			
			switch f {
			case "sqrt": return sqrt(d).description
			case "ln": return log(d).description
			case "log10": return log10(d).description
			case "ln": return log2(d).description
			case "floor": return floor(d).description
			case "ceil": return ceil(d).description
			case "round": return round(d).description
				
			case "sin": return sin(d).description
			case "cos": return cos(d).description
			case "tan": return tan(d).description
				
			case "asin": return asin(d).description
			case "acos": return acos(d).description
			case "atan": return atan(d).description
				
			case "sinh": return sinh(d).description
			case "cosh": return cosh(d).description
			case "tanh": return tanh(d).description
			
			case "asinh": return asinh(d).description
			case "acosh": return acosh(d).description
			case "atanh": return atanh(d).description
				
			case "silent":
				return ""
				
			default: return ExpressionError.unaryFunction.rawValue
			}
		}
		return ExpressionError.unaryFunction.rawValue
	}
	
	var binaryFunctions = Command(pattern: "(\(binaryFunction))\\((\(expression))\(s),\(s)(\(expression))\\)".regex) {commander, matches in
		if let first = matches.first {
			let f = first.captures[0].stringValue
			var e1 = first.captures[1].stringValue
			var e2 = first.captures[2].stringValue
			e1 = commander.execute(on: e1)
			e2 = commander.execute(on: e2)
			let d1 = Double(e1) ?? 0
			let d2 = Double(e2) ?? 0
			
			switch f {
			case "power": return pow(d1, d2).description
			case "log": return "\(log(d1) / log(d2))"
			case "sumproduct":
				let e1s = e1.components(separatedBy: ",").map { Double($0) ?? 0 }
				let e2s = e2.components(separatedBy: ",").map { Double($0) ?? 0 }
				var result: Double = 0
				if e1s.count == e2s.count {
					for (a, b) in zip(e1s, e2s) {
						result += a * b
					}
				}
				return result.description
				
			default: return ExpressionError.binaryFunction.rawValue
			}
		}
		return ExpressionError.binaryFunction.rawValue
	}
	
	var brackets = Command(pattern: "\\((\(expression))\\)".regex) {commander, matches in
		if let f = matches.first {
			return f.captures[0].stringValue
		}
		return ExpressionError.brackets.rawValue
	}
	
	let assignment = Command(pattern: "^\(s)([a-zA-Z]+)\(ss)(=)\(ss)(.+)".regex) {commander, matches in
		if let f = matches.first {
			let name = f.captures[0].stringValue
			let o = f.captures[1].stringValue
			let value = f.captures[2].stringValue
			
			switch o {
			case "=":
				let v = commander.execute(on: value)
				ExpressionCalculator.variables[name] = v
				return v
				
			default:
				return nil
			}
		}
		return nil
	}
	
	let inlineAssignment = Command(pattern: "([a-zA-Z]+)\(ss)(=)\(ss)(\(std.real))".regex) {commander, matches in
		if let f = matches.first {
			let name = f.captures[0].stringValue
			let o = f.captures[1].stringValue
			let value = f.captures[2].stringValue
			
			switch o {
			case "=":
				let v = commander.execute(on: value)
				ExpressionCalculator.variables[name] = v
				return v
				
			default:
				return nil
			}
		}
		return nil
	}
	
	let inlineAssignmentInverse = Command(pattern: "(\(std.real))\(ss)(=)\(ss)([a-zA-Z]+)".regex) {commander, matches in
		if let f = matches.first {
			let name = f.captures[2].stringValue
			let o = f.captures[1].stringValue
			let value = f.captures[0].stringValue
			
			switch o {
			case "=":
				let v = commander.execute(on: value)
				ExpressionCalculator.variables[name] = v
				return v
				
			default:
				return nil
			}
		}
		return nil
	}
	
	let variableInterpolation = Command {_,matches in
		if ExpressionCalculator.variables.count > 0, let f = matches.first {
			var result: String = f.match
			let start = result
			for (name, value) in ExpressionCalculator.variables {
				result = result.replacingOccurrences(of: name, with: value)
			}
			if result == start {
				return nil
			} else {
				return result
			}
		}
		return nil
	}
	
	let exponential = Command(pattern: "(\(std.real))\(s)\\^\(s)(\(std.real))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			let b = f.captures[1].doubleValue
			
			return pow(a, b).description
		}
		return ExpressionError.exponential.rawValue
	}
	
	let multiplication = Command(pattern: "(\(std.real))\(s)([*/%])\(s)(\(std.real))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			let o = f.captures[1].stringValue
			let b = f.captures[2].doubleValue
			
			switch o {
				case "*": return "\(a * b)"
				case "/": return "\(a / b)"
				case "%": return "\(a.truncatingRemainder(dividingBy: b))"
				default: return ExpressionError.multiplicative.rawValue
			}
		}
		return ExpressionError.multiplicative.rawValue
	}
	
	let addition = Command(pattern: "(\(std.real))\(s)([-+])\(s)(\(std.real))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			let o = f.captures[1].stringValue
			let b = f.captures[2].doubleValue
			
			return "\(a + b * (o == "+" ? 1 : -1))"
			
		}
		return ExpressionError.additive.rawValue
	}
	
	let vectorMultiplication = Command(pattern: "(\(vector))\(s)([*x])\(s)(\(vector))".regex) {commander,matches in
		if let f = matches.first {
			let a = f.captures[0].vectorValue
			let o = f.captures[1].stringValue
			var b = f.captures[2].vectorValue
			
			switch o {
			case "*":
				return (a * b).description
				
			case "x":
				let cp = a.crossProduct(with: b)!
				return cp.description
				
			default: return ""
			}
			
			
		}
		return ExpressionError.vectorMultiplicative.rawValue
	}
	
	let numberVectorMultiplication = Command(pattern: "(\(std.real))\(s)\\*\(s)(\(vector))".regex) {commander,matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			var b = f.captures[1].vectorValue
			
			return (a * b).description
		}
		return ExpressionError.vectorMultiplicative.rawValue
	}
	
	let vectorNumberMultiplication = Command(pattern: "(\(vector))\(s)\\*\(s)(\(std.real))".regex) {commander,matches in
		if let f = matches.first {
			let a = f.captures[0].vectorValue
			var b = f.captures[1].doubleValue
			
			return (a * b).description
		}
		return ExpressionError.vectorMultiplicative.rawValue
	}
	
	let vectorAddition = Command(pattern: "(\(vector))\(s)([-+])\(s)(\(vector))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].stringValue.trimmed(by: 1).arrayValue(seperatedBy: ",").map { $0.doubleValue }
			let o = f.captures[1].stringValue
			var b = f.captures[2].stringValue.trimmed(by: 1).arrayValue(seperatedBy: ",").map { $0.doubleValue }
			
			if o == "-" {
				b = b.map { $0 * -1 }
			}
			return "\(zip(a, b).map { $0.0 + $0.1 })"
		}
		return ExpressionError.vectorAdditive.rawValue
	}
	
	let numberComparison = Command(pattern: "(\(std.real))\(s)(>|<|==|>=|<=|!=)\(s)(\(std.real))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			let o = f.captures[1].stringValue
			let b = f.captures[2].doubleValue
			
			switch o {
				case "<": return (a < b).description
				case ">": return (a > b).description
				case "==": return (a == b).description
				case "!=": return (a != b).description
				case "<=": return (a <= b).description
				case ">=": return (a >= b).description
				default: return ExpressionError.numberComparison.rawValue
			}
		}
		return ExpressionError.numberComparison.rawValue
	}
	
	let vectorComparison = Command(pattern: "(\(vector))\(s)(>|<|==|>=|<=|!=)\(s)(\(std.real))".regex) {_,matches in
		if let f = matches.first {
			let a: Vector = f.captures[0].vectorValue
			let o = f.captures[1].stringValue
			let b = f.captures[2].doubleValue
			
			switch o {
			case "<": return a.values.filter({ $0 < b }).description
			case ">": return a.values.filter({ $0 > b }).description
			case "==": return a.values.filter({ $0 == b }).description
			case "!=": return a.values.filter({ $0 != b }).description
			case "<=": return a.values.filter({ $0 <= b }).description
			case ">=": return a.values.filter({ $0 >= b }).description
			default: return ExpressionError.numberComparison.rawValue
			}
		}
		return ExpressionError.numberComparison.rawValue
	}
	
	let vectorMapping = Command(pattern: "(\(vector))\(s)\(closure)".regex) {commander,matches in
		if let f = matches.first {
			let a: Vector = f.captures[0].vectorValue
			let b = f.captures[1].stringValue
			
			var result: [Double] = []
			for aa in a.values {
				let form = b.replacingOccurrences(of: "this", with: "\(aa)")
				let res = commander.execute(on: "\(form)")
				if res != "remove" {
					result.append(res.doubleValue)
				}
				
			}
			return result.description
		}
		return ExpressionError.numberComparison.rawValue
	}
	
	let logicGate = Command(pattern: "(\(std.bool))\(s)(and|or|xor|nand|nor|xnor)\(s)(\(std.bool))".regex) {_,matches in
		if let f = matches.first {
			let a = f.captures[0].boolValue
			let o = f.captures[1].stringValue
			let b = f.captures[2].boolValue
			
			switch o {
			case "or": return (a || b).description
			case "and": return (a && b).description
			case "xor": return ((a || b) && !(a && b)).description
			case "nand": return (!(a && b)).description
			case "nor": return (!(a || b)).description
			case "xnor": return (!((a || b) && !(a && b))).description
			default: return ExpressionError.logicGate.rawValue
			}
		}
		return ExpressionError.logicGate.rawValue
	}
	
	let ternaryBoolean = Command(pattern: "(\(std.bool))\(s)\\?\(s)([^:]+)\(s)\\:\(s)([^:]+)".regex) {commander,matches in
		if let f = matches.first {
			let b = f.captures[0].boolValue
			let a = f.captures[1].stringValue
			let c = f.captures[2].stringValue
			
			return b ? commander.execute(on: a) : commander.execute(on: c)
		}
		return ExpressionError.logicGate.rawValue
	}
	
	let assignmentError = Command(pattern: "(\(std.real))\(s)(=)\(s)(\(std.real))".regex) {commander, matches in
		if let f = matches.first {
			let a = f.captures[0].doubleValue
			let o = f.captures[1].stringValue
			let b = f.captures[2].doubleValue
			return "!fatal!{Assignment Error cannot assign number \(b) to number \(a)]}"
		}
		return nil
	}
	
	var nullify = Command(pattern: "(silent)\\{(.*)\\}".regex) {commander, matches in
		if let first = matches.first {
			let f = first.captures[0].stringValue
			var e = first.captures[1].stringValue
			e = commander.execute(on: e)
			let d = Double(e)
			
			switch f {
			case "silent":
				return ""
				
			default: return ExpressionError.unaryFunction.rawValue
			}
		}
		return ExpressionError.unaryFunction.rawValue
	}
	
	
	var commands: [Command]
	var showTrace = false
	var recursive = true
	init() {
		unaryFunctions.recursiveMatch = true
		binaryFunctions.recursiveMatch = true
		varFunctions.recursiveMatch = true
		brackets.recursiveMatch = true
		commands = [
			hex,
			vectorMapping,
			range,
			
			postfixFunctions,
			prefixFunctions,
			
			emptyFunctions,
			unaryFunctions,
			binaryFunctions,
			varFunctions,
			
			brackets,
			
			assignment,
			inlineAssignment,
			inlineAssignmentInverse,
			variableInterpolation,
			
			exponential,
			multiplication,
			addition,
			
			vectorMultiplication,
			numberVectorMultiplication,
			vectorNumberMultiplication,
			vectorAddition,
			
			numberComparison,
			vectorComparison,
			logicGate,
			
			ternaryBoolean,
			
			assignmentError,
			nullify,
		]
	}
	
	
}
