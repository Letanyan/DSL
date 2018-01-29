//
//  Standard Library.swift
//  Pattern Programming
//
//  Created by Letanyan Arumugam on 2016/09/22.
//  Copyright © 2016 Letanyan Arumugam. All rights reserved.
//

import Foundation

struct std {
	static let s = "\\s*"
	static let bool = "(?:true|false)"
	static let int = "[-+]?\\d+"
	static let real = "[-+]?\\d+(?:\\.\\d+)?"
	
	
	static let list: (_ item: String, _ seperator: String) -> String = {item,sep in
		return "\(item)(?:\(s)\(sep)\(s)\(item))*"
	}
	static let csList: (_ item: String) -> String = {item in
		return list(item, ";")
	}
}

func anyList<T>(with items: [T], seperatedBy seperator: String, andEnclosedWith enclosure: (String, String)) -> String {
	guard items.count > 0 else { return "\(enclosure.0)\(enclosure.1)" }
	
	var result = "\(enclosure.0)\(items.first!)"
	for s in items.dropFirst() {
		result += "\(seperator)\(s)"
	}
	return result + enclosure.1
}

func regexList(_ array: [String]) -> String {
	return anyList(with: array, seperatedBy: "|", andEnclosedWith: ("(", ")"))
}
