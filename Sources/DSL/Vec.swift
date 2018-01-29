import Darwin

struct Vector {
	let values: [Double]
	
	init(_ values: [Double]) {
		self.values = values
	}
	
	init(x: Double, y: Double) {
		values = [x, y]
	}
	
	init(x: Double, y: Double, z: Double) {
		values = [x, y, z]
	}
	
	init(_ values: Double...) {
		self.values = values
	}
	
	static func unitVector(ofDimension dimension: Int, at location: Int) -> Vector {
		var resultArray = [Double](repeating: 0, count: dimension)
		resultArray[location] = 1
		return Vector(resultArray)
	}
	
	var norm: Double {
		return sqrt(values.reduce(0){ $0 + pow($1, 2) })
	}
	
	var dimension: Int {
		return values.count
	}
	
	func isParallel(to vector: Vector) -> Bool {
		guard vector.dimension == dimension else {
			return false
		}
		guard dimension > 1 else {
			return true
		}
		
		let factor: Double = values[0] / vector[0]
		for i in 1..<dimension {
			let f = values[i] / vector[i]
			if f != factor {
				return false
			}
		}
		return true
	}
	
	func crossProduct(with v: Vector) -> Vector? {
		guard v.dimension == 3 && dimension == 3 else {
			return nil
		}
		
		let i = values[1] * v[2] - values[2] * v[1]
		let j = values[2] * v[0] - values[0] * v[2]
		let k = values[0] * v[1] - values[1] * v[0]
		
		return Vector(i, j, k)
	}
	
	subscript(index: Int) -> Double {
		return values[index]
	}
}

extension Vector: ExpressibleByArrayLiteral {
	typealias Element = Double
	
	init(arrayLiteral: Double...) {
		values = arrayLiteral
	}
}

extension Vector: CustomStringConvertible {
	var description: String {
		return "[" + values
		.reduce(""){ (t: String, e: Double) -> String in
			if t == "" {
				return (trunc(e) == e ? String(Int(e)) : String(e))
			} else {
				return t + ", " + (trunc(e) == e ? String(Int(e)) : String(e))
			}
		} 
		+ "]"
	}
}

func +(lhs: Vector, rhs: Vector) -> Vector {
	return Vector(zip(lhs.values, rhs.values).map { $0.0 + $0.1 })
}

prefix func -(operand: Vector) -> Vector {
	return Vector(operand.values.map { -$0 })
}

func -(lhs: Vector, rhs: Vector) -> Vector {
	return lhs + -rhs
}

func *(lhs: Vector, rhs: Vector) -> Double {
	return zip(lhs.values, rhs.values)
		.map { $0.0 * $0.1 }
		.reduce(0, +)
}

func *(lhs: Double, rhs: Vector) -> Vector {
	return Vector(rhs.values.map { $0 * lhs })
}

func *(lhs: Vector, rhs: Double) -> Vector {
	return Vector(lhs.values.map { $0 * rhs })
}

func point(p: Vector, isBetween a: Vector, and b: Vector) -> Bool {
	guard p.dimension == a.dimension && a.dimension == b.dimension else {
		return false
	}
	
	var prev: Double? = nil
	for (idx, v) in p.values.enumerated() {
		let a = a[idx]
		let b = b[idx]
		guard a - b != 0 else {
			return true
		}
		
		let now = (v - b) / (a - b)
		if let p = prev, p != now {
			return false
		}
		prev = now
	}
	return true
}
