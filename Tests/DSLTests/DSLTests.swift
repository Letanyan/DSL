import XCTest
@testable import DSL

class DSLTests: XCTestCase {
    func testExample() {
		struct Calculator : System {
			let commanders: [Commander]
		}
		
		var calc = ExpressionCalculator()
		calc.showTrace = false
		
		let system = Calculator(commanders: [calc])
		
		let test = "5 * (3 + 2 * 2) / sqrt(5 * 7 - power(10, cos(0))) + sum([1, 2, 3])" //= 13
		let result = system.execute(on: test)
		dump(result)
		
		
		print("\n> ", separator: "", terminator: "")
		var input: String? = ""
		var show = false
		repeat {
			input = readLine()
			if var input = input {
				
				if input.count > 2 && input[..<input.index(input.startIndex, offsetBy: 2)] == "//" {
					input.remove(at: input.startIndex)
					input.remove(at: input.startIndex)
					show = false
				} else {
					show = true
				}
				
				if (show) {
					print(system.execute(on: input))
				} else {
					_ = system.execute(on: input)
				}
				print("\n> ", separator: "", terminator: "")
			}
		} while input != "bye"
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
