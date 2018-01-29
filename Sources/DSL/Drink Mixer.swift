//
//  Drink Mixer.swift
//  DSL
//
//  Created by Letanyan Arumugam on 2018/01/29.
//

import Swift

struct DrinkMixer : Commander {
	
	struct Ingredient {
		var name: String
		var amount: Int
	}
	
	struct Drink {
		var ingredients: [Ingredient] = []
	}
	
	static let double = "(?:double|twice|two)"
	static let triple = "(?:triple|three)"
	static let conjuntion = "(?:with|and)"
	static let ingredient = "\\w+"
	
	static var result = Drink()
	
	let request = Command(pattern: "please".regex) { _, matches in
		print(1)
		return ""
	}
	
	let conj = Command(pattern: "\(conjuntion)\(std.s)".regex) { _, matches in
		print(2)
		return ""
	}
	
	let ingredient1 = Command(pattern: "(\(ingredient))\(std.s)".regex) { _, matches in
		print(3)
		guard let f = matches.first else {
			return ""
		}
		
		let ing = f.captures[0].stringValue
		result.ingredients.append(Ingredient(name: ing, amount: 1))
		
		return ""
	}
	
	let ingredient2 = Command(pattern: "\(double)\(std.s)(\(ingredient))\(std.s)".regex) { _, matches in
		print(4)
		guard let f = matches.first else {
			return ""
		}
		
		let ing = f.captures[0].stringValue
		result.ingredients.append(Ingredient(name: ing, amount: 2))
		
		return ""
	}
	
	let ingredient3 = Command(pattern: "\(triple)\(std.s)(\(ingredient))\(std.s)".regex) { _, matches in
		print(5)
		guard let f = matches.first else {
			return ""
		}
		
		let ing = f.captures[0].stringValue
		result.ingredients.append(Ingredient(name: ing, amount: 3))
		
		return ""
	}
	
	var commands: [Command]
	var showTrace = false
	var recursive = true
	init() {
		commands = [
			request,
			conj,
			ingredient2,
			ingredient3,
			ingredient1
		]
	}
	
	var please: Drink { return DrinkMixer.result }
}
