# DSL
Use regex matching strings to easily build ChatBots and  calculators

## Installation
Include "Regex.swift" and "Pattern Handling.swift" in your project.

## How it works
It's fairly simple, all the logic is only a 100 lines. Have a look at "Pattern Handling.swift" to see how this works exactly.

The gist of it is you create commands (closures) that are tied to a pattern (regex). Then when a pattern is found in the user input string the command gets executed and returns a value that then replaces the matched part the string.

### Recursive
When the result of a match is computed that newly formed result will be used as a new input for the entire sytem and will then be processed until no matches can occur. It is then sent back to replace the original match.

### Show Trace
Show all executions of a match

### Command Priorty
The priority of a command is it's position in the `commands` variable 0 is highest

### System protocol
Systems are compositions of multiple commanders. This is just for convenience.

## Example
Run the main.swift and see some of the calculator features. One could imagine how easy it would be to build a chatbot with this pattern. Look at the "Expression Calculator.swift" for how you would generally design your application.
