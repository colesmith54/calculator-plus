import Foundation

enum AngleMode {
    case degrees
    case radians
}

enum Operator: String {
    case add = "+"
    case subtract = "-"
    case unaryMinus = "_"
    case multiply = "⋅"
    case divide = "÷"
    case openParenthesis = "("
    case closeParenthesis = ")"
    case constantPi = "π"
    case constantE = "e"
    case constantANS = "(ans)"
    case scientificE = "E"
    case exponent = "^"
    case squareRoot = "√"
    case variableX = "x"
    
    var precedence: Int {
        switch self {
        case .add, .subtract:
            return 1
        case .multiply, .divide:
            return 2
        case .exponent:
            return 3
        case .unaryMinus, .squareRoot:
            return 4
        case .openParenthesis, .closeParenthesis, .constantPi, .constantE, .constantANS, .variableX:
            return 5
        case .scientificE:
            return 6
        }
    }
}
    
enum Function: String {
    case sin, cos, tan, csc, sec, cot, asin, acos, atan, acsc, asec, acot, log, ln, abs, floor, ceil, round, logb, root, mod, hypot, nPr, nCr
    
    var argumentCount: Int {
        switch self {
        case .logb, .root, .mod, .hypot, .nPr, .nCr:
            return 2
        default:
            return 1
        }
    }
}

indirect enum Expression {
    case number(Double)
    case variable(String)
    case operation(Operator)
    case unaryOperation(Operator, Expression)
    case binaryOperation(Expression, Operator, Expression)
    case function(Function, Expression)
    case twoArgumentFunction(Function, Expression, Expression)
    case error(ParsingError)
}

enum ParsingError: Error {
    case unexpectedToken
    case unmatchedParenthesis
    case evaluationError
}

class CalculatorModel: ObservableObject {
    var cursorPosition = 0
    var display = ""
    var history: [String] = []
    var lastResult = ""
    var isGraphing = true
    var graphingLines: [[[Double]]] = []
    var graphingPoints: [Double: Double] = [:]
    var angleMode: AngleMode = .radians
    
    let answerIndicator = "(ans)"
    
    func indexAt(position: Int) -> String.Index {
        return display.index(display.startIndex, offsetBy: position)
    }
    
    func updateAngleUnit(unit: Int) {
        switch unit {
        case 0:
            angleMode = .radians
        case 1:
            angleMode = .degrees
        default:
            break
        }
    }
    
    func updateGraphing(value: Bool) {
        isGraphing = value
        updateUI()
    }
    
    func moveCursor(by offset: Int) {
        cursorPosition = max(0, min(display.count, cursorPosition + offset))
        updateUI()
    }
    
    func insertCharacter(_ character: String) {
        let leftSide = String(display[..<indexAt(position: cursorPosition)])
        let rightSide = String(display[indexAt(position: cursorPosition)...])
        display = "\(leftSide)\(character)\(rightSide)"
        cursorPosition += character.count
        updateUI()
    }
    
    func insertOperation(_ operation: String) {
        insertCharacter(operation)
        if operation.contains("(") && operation.contains(")") && !operation.contains("ans") {
            moveCursor(by: -1)
        }
        if operation.contains(",") {
            moveCursor(by: -1)
        }
    }
    
    func input(number: Int) {
        insertCharacter("\(number)")
    }
    
    func addDecimal() {
        insertCharacter(".")
    }
    
    func deleteLastCharacter() {
        guard cursorPosition > 0 else { return }
        let leftSide = String(display[..<indexAt(position: cursorPosition - 1)])
        let rightSide = String(display[indexAt(position: cursorPosition)...])
        display = "\(leftSide)\(rightSide)"
        cursorPosition -= 1
        updateUI()
    }
    
    func clearDisplay() {
        if display.isEmpty {
            history = []
        }
        display = ""
        cursorPosition = 0
        updateUI()
    }
    
    private func formatResult(_ result: Double) -> String {
        let tolerance = 3e-8
        let roundedResult = abs(result - round(result)) < tolerance && result > 0.01 ? round(result) : result
        
        if abs(roundedResult) >= 1e8 || (abs(roundedResult) > 0 && abs(roundedResult) < 1e-8) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.positiveFormat = "#.######E0"
            formatter.negativeFormat = "-#.######E0"
            return formatter.string(from: NSNumber(value: roundedResult))!
        } else {
            let resultAsInt = Int(roundedResult)
            if Double(resultAsInt) == roundedResult {
                return String(resultAsInt)
            } else {
                let len = String(round(roundedResult)).count
                var display = String(format: "%.\(12-len)f", roundedResult)
                while display.last == "0" {
                    display.removeLast()
                }
                if display.last == "." {
                    display.removeLast()
                }
                return display
            }
        }
    }
    
    func evaluateAndGraphExpression() {
        graphingPoints.removeAll()
        do {
            var tokens = try generateTokens(from: display)
            let expression = parseExpression(from: &tokens)
            if case .error(_) = expression {
                if !isGraphing {
                    display = "Error1"
                }
            } else {
                for i in stride(from: -10.0, through: 10.0, by: 0.001) {
                    if let y = evaluateExpression(expression, xValue: i) {
                        graphingPoints[i] = y
                    }
                }
            }
        } catch {
            print("graphing, ignore")
        }
    }
    
    private func calculateExpression() {
        display = display.replacingOccurrences(of: "ans", with: lastResult)
        let originalInput = display
        do {
            var tokens = try generateTokens(from: display)
            let expression = parseExpression(from: &tokens)
            if case .error(_) = expression {
                display = "Error1"
            } else if let result = evaluateExpression(expression, xValue: 0.0) {
                display = formatResult(result)
            }
        } catch {
            display = "\(error)"
        }
        if originalInput == display {
            if Double(originalInput) == nil {
                display = "Error2"
            }
        }
        history.append("\(originalInput) = \(display)")
        lastResult = display
        cursorPosition = display.count
        evaluateAndGraphExpression()
    }
    
    
    func performOperation(_ operation: String) {
        if operation != "=" {
            insertOperation(operation)
        } else {
            calculateExpression()
        }
        updateUI()
    }
    
    private func checkForSyntaxErrors(tokens: [Expression]) -> Bool {
        var stack = [Expression]()
        var prevExpression: Expression?
        
        for token in tokens {
            switch token {
            case .operation(let op):
                switch op {
                case .subtract, .add, .multiply, .divide:
                    if case .operation(let prevOp)? = prevExpression {
                        switch prevOp {
                        case .subtract, .add, .multiply, .divide, .openParenthesis:
                            return false
                        default:
                            break
                        }
                    }
                case .openParenthesis:
                    stack.append(token)
                case .closeParenthesis:
                    if case .operation(let prevOp)? = prevExpression, prevOp == .openParenthesis {
                        return false
                    }
                    if let last = stack.last, case .operation(let stackOp) = last, stackOp == .openParenthesis {
                        stack.removeLast()
                    } else {
                        return false
                    }
                default:
                    break
                }
            default:
                break
            }
            prevExpression = token
        }
        return stack.isEmpty
    }
    
    private func generateTokens(from input: String) throws -> [Expression] {
        var input = Array(input)
        var tokens: [Expression] = []
        var numberString = ""
        var previousToken: Expression?
        
        while !input.isEmpty {
            let character = input.removeFirst()
            if character.isNumber || character == "." || (character == "-" && !numberString.isEmpty && numberString.last == "E") || character == "E" {
                numberString.append(character)
            } else if character.isLetter && character != "e" && character != "π" && character != "x" {
                if !numberString.isEmpty || previousTokenImplicitMulti(previousToken) {
                    if let number = Double(numberString) {
                        tokens.append(Expression.number(number))
                    }
                    numberString = ""
                    tokens.append(Expression.operation(.multiply))
                }
                
                var functionName = ""
                functionName.append(character)
                while !input.isEmpty && input.first!.isLetter {
                    functionName.append(input.removeFirst())
                }
                
                if !input.isEmpty && input.first == "(" {
                    input.removeFirst() // remove the opening parenthesis
                    if let function = Function(rawValue: functionName) {
                        var innerExpressions = [String]()
                        var openParenthesesCount = 1
                        var currentExpression = ""
                        while !input.isEmpty && openParenthesesCount > 0 {
                            if input.first == "(" {
                                openParenthesesCount += 1
                            } else if input.first == ")" {
                                openParenthesesCount -= 1
                            }
                            if openParenthesesCount > 0 {
                                currentExpression.append(input.removeFirst())
                            }
                            if openParenthesesCount == 1 && input.first == "," {
                                input.removeFirst() // remove comma
                                innerExpressions.append(currentExpression)
                                currentExpression = ""
                            }
                        }
                        
                        if openParenthesesCount != 0 {
                            throw ParsingError.unexpectedToken
                        } else {
                            input.removeFirst() // remove the closing parenthesis
                        }
                        
                        innerExpressions.append(currentExpression)
                        if innerExpressions.count != function.argumentCount {
                            throw ParsingError.unexpectedToken
                        }
                        
                        let functionExpressions: [Expression] = try innerExpressions.map { innerExpression in
                            var tokens = try generateTokens(from: innerExpression)
                            return parseExpression(from: &tokens)
                        }
                        
                        let functionExpression: Expression
                        if function.argumentCount == 2 {
                            functionExpression = .twoArgumentFunction(function, functionExpressions[0], functionExpressions[1])
                        } else {
                            functionExpression = .function(function, functionExpressions[0])
                        }
                        tokens.append(functionExpression)
                        previousToken = functionExpression
                    } else {
                        throw ParsingError.unexpectedToken
                    }
                } else {
                    throw ParsingError.unexpectedToken
                }
            } else {
                if !numberString.isEmpty {
                    if let number = Double(numberString) {
                        let token = Expression.number(number)
                        tokens.append(token)
                        previousToken = token
                    }
                    numberString = ""
                }
                
                guard let operation = Operator(rawValue: String(character)) else {
                    throw ParsingError.unexpectedToken
                }
                
                switch (previousToken, operation) {
                case (.some(.number(_)), .openParenthesis),
                    (.some(.number(_)), .squareRoot),
                    (.some(.number(_)), .constantPi),
                    (.some(.number(_)), .constantE),
                    (.some(.number(_)), .variableX),
                    (.some(.operation(.closeParenthesis)), .openParenthesis),
                    (.some(.operation(.closeParenthesis)), .squareRoot),
                    (.some(.operation(.closeParenthesis)), .constantPi),
                    (.some(.operation(.closeParenthesis)), .constantE),
                    (.some(.operation(.closeParenthesis)), .variableX),
                    (.some(.operation(.constantPi)), .openParenthesis),
                    (.some(.operation(.constantPi)), .squareRoot),
                    (.some(.operation(.constantPi)), .constantE),
                    (.some(.operation(.constantPi)), .constantPi),
                    (.some(.operation(.constantPi)), .variableX),
                    (.some(.operation(.constantE)), .openParenthesis),
                    (.some(.operation(.constantE)), .squareRoot),
                    (.some(.operation(.constantE)), .constantPi),
                    (.some(.operation(.constantE)), .constantE),
                    (.some(.operation(.constantE)), .variableX),
                    (.some(.operation(.variableX)), .openParenthesis),
                    (.some(.operation(.variableX)), .squareRoot),
                    (.some(.operation(.variableX)), .constantPi),
                    (.some(.operation(.variableX)), .variableX),
                    (.some(.operation(.variableX)), .constantE):
                    tokens.append(Expression.operation(.multiply))
                default:
                    break
                }
                
                if operation == .subtract {
                    switch previousToken {
                    case .some(.operation(.add)), .some(.operation(.subtract)), .some(.operation(.multiply)), .some(.operation(.divide)), .some(.operation(.openParenthesis)), .some(.operation(.exponent)), .some(.operation(.squareRoot)), .none:
                        tokens.append(Expression.operation(.unaryMinus))
                    default:
                        tokens.append(Expression.operation(operation))
                    }
                } else {
                    tokens.append(Expression.operation(operation))
                }
                
                previousToken = Expression.operation(operation)
            }
        }
        
        if !numberString.isEmpty, let number = Double(numberString) {
            tokens.append(Expression.number(number))
        }
        if !checkForSyntaxErrors(tokens: tokens) && !isGraphing {
            throw ParsingError.unexpectedToken
        }
        
        return tokens
    }
    
    private func previousTokenImplicitMulti(_ token: Expression?) -> Bool {
        if let token = token {
            switch token {
            case .number(_):
                return true
            case .operation(let op):
                return op == .constantPi || op == .constantE || op == .variableX || op == .closeParenthesis
            case .function:
                return true
            case .twoArgumentFunction:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    private func parseExpression(from tokens: inout [Expression]) -> Expression {
        var left = parseTerm(from: &tokens)
        while let op = tokens.first {
            switch op {
            case .operation(let operation) where operation.precedence == 1:
                tokens.removeFirst()
                let right = parseTerm(from: &tokens)
                left = .binaryOperation(left, operation, right)
            default:
                return left
            }
        }
        return left
    }
    
    private func parseTerm(from tokens: inout [Expression]) -> Expression {
        var term = parseFactor(from: &tokens)
        while let op = tokens.first {
            switch op {
            case .operation(let operation) where operation.precedence == 2:
                tokens.removeFirst()
                let right = parseFactor(from: &tokens)
                term = .binaryOperation(term, operation, right)
            default:
                return term
            }
        }
        return term
    }
    
    private func parseBase(from tokens: inout [Expression]) -> Expression {
        guard let first = tokens.first else {
            return .error(.unexpectedToken)
        }
        switch first {
        case .function(let function, let expression):
            tokens.removeFirst() // remove 'func' and expression
            return Expression.function(function, expression)
        case .twoArgumentFunction(let function, let firstOperand, let secondOperand):
            tokens.removeFirst() // remove 'func' and its arguments
            return Expression.twoArgumentFunction(function, firstOperand, secondOperand)
        case .operation(let op) where op == .openParenthesis:
            tokens.removeFirst() // remove open parenthesis
            let expr = parseExpression(from: &tokens) // parse until close parenthesis
            if tokens.isEmpty {
                return .error(.unmatchedParenthesis)
            } else if case .operation(let op) = tokens.removeFirst(), op == .closeParenthesis {
                // successfully parsed parentheses
                return expr
            } else {
                return .error(.unmatchedParenthesis) // unmatched parenthesis, return error
            }
        case .operation(let op) where op == .scientificE:
            tokens.removeFirst() // remove 'E'
            guard let exp = tokens.first, case .number(let expValue) = exp else {
                return .error(.unexpectedToken)
            }
            tokens.removeFirst() // remove exponent
            return .number(pow(10, expValue))
        case .number(let value):
            tokens.removeFirst() // remove number
            return .number(value)
        case .operation(let op) where op == .constantPi:
            tokens.removeFirst()
            return .number(Double.pi)
        case .operation(let op) where op == .constantE:
            tokens.removeFirst()
            return .number(M_E)
        case .operation(let op) where op == .variableX:
            tokens.removeFirst()
            return .variable("x")
        case .operation(let op) where op == .unaryMinus:
            tokens.removeFirst() // remove unary minus
            let operand = parseBase(from: &tokens)
            return .unaryOperation(op, operand)
        case .operation(let op) where op == .squareRoot:
            tokens.removeFirst() // remove square root operator
            let operand = parseBase(from: &tokens)
            return .unaryOperation(op, operand)
        default:
            return .error(.unexpectedToken) // unexpected token
        }
    }
    
    private func parseFactor(from tokens: inout [Expression]) -> Expression {
        var factor = parseBase(from: &tokens)
        while let nextToken = tokens.first, case .operation(let op) = nextToken, op == .exponent {
            tokens.removeFirst() // remove exponent operator
            let rightOperand = parseFactor(from: &tokens) // parse right-associatively
            factor = .binaryOperation(factor, op, rightOperand)
        }
        return factor
    }
    
    private func evaluateExpression(_ expression: Expression, xValue: Double) -> Double? {
        switch expression {
        case .variable:
            return xValue
        case .number(let value):
            return value
        case .binaryOperation(let left, let operation, let right):
            guard let leftValue = evaluateExpression(left, xValue: xValue),
                  let rightValue = evaluateExpression(right, xValue: xValue) else {
                return nil
            }
            switch operation {
            case .add:
                return leftValue + rightValue
            case .subtract:
                return leftValue - rightValue
            case .multiply:
                return leftValue * rightValue
            case .divide:
                return rightValue == 0 ? nil : leftValue / rightValue
            case .exponent:
                return pow(leftValue, rightValue)
            default:
                return nil
            }
        case .unaryOperation(let operation, let operand):
            guard let operandValue = evaluateExpression(operand, xValue: xValue) else {
                return nil
            }
            switch operation {
            case .unaryMinus:
                return -operandValue
            case .scientificE:
                return pow(10, operandValue)
            case .squareRoot:
                return operandValue < 0 ? nil : sqrt(operandValue)
            default:
                return nil
            }
        case .function(let functionName, let operand):
            guard let value = evaluateExpression(operand, xValue: xValue) else {
                return nil
            }
            
            let epsilon = 1e-10
            let angleValue = (angleMode == .degrees) ? value * .pi / 180.0 : value
            
            func isNearZero(forAngle angle: Double) -> Bool {
                let angle = angle.truncatingRemainder(dividingBy: .pi * 2)
                return abs(angle - .pi) < epsilon
            }
            
            func isNearHalfPi(forAngle angle: Double) -> Bool {
                let angle = angle.truncatingRemainder(dividingBy: .pi * 2)
                return abs(angle - .pi / 2.0) < epsilon
            }
            
            func isNearThreeHalfPi(forAngle angle: Double) -> Bool {
                let angle = angle.truncatingRemainder(dividingBy: .pi * 2)
                return abs(angle - 3 * .pi / 2) < epsilon
            }
            
            switch functionName {
            case .sin:
                return isNearZero(forAngle: angleValue) ? 0.0 : sin(angleValue)
            case .cos:
                return (isNearHalfPi(forAngle: angleValue) || isNearThreeHalfPi(forAngle: angleValue)) ? 0.0 : cos(angleValue)
            case .tan:
                if isNearZero(forAngle: angleValue) {
                    return 0.0
                }
                if isNearHalfPi(forAngle: angleValue) {
                    return nil
                }
                return tan(angleValue)
            case .csc:
                if isNearZero(forAngle: angleValue) {
                    return nil
                }
                return 1/sin(angleValue)
            case .sec:
                if isNearHalfPi(forAngle: angleValue) {
                    return nil
                }
                return 1/cos(angleValue)
            case .cot:
                if isNearZero(forAngle: angleValue) {
                    return nil
                }
                if isNearHalfPi(forAngle: angleValue) {
                    return 0
                }
                return 1/tan(angleValue)
            case .asin:
                if abs(angleValue) > 1.0 {
                    return nil
                }
                return asin(angleValue)
            case .acos:
                if abs(angleValue) > 1.0 {
                    return nil
                }
                return acos(angleValue)
            case .atan:
                return atan(angleValue)
            case .acsc:
                if abs(angleValue) < 1.0 {
                    return nil
                }
                return asin(1.0/angleValue)
            case .asec:
                if abs(angleValue) < 1.0 {
                    return nil
                }
                return acos(1.0/angleValue)
            case .acot:
                return .pi/2 - atan(angleValue)
            case .ln:
                if value < 0 {
                    return nil
                }
                return log(value)
            case .log:
                return log10(value)
            case .abs:
                return abs(value)
            case .floor:
                return floor(value)
            case .ceil:
                return ceil(value)
            case .round:
                return round(value)
            default:
                return nil
            }
            
        case .twoArgumentFunction(let functionName, let firstOperand, let secondOperand):
            guard let firstValue = evaluateExpression(firstOperand, xValue: xValue),
                  let secondValue = evaluateExpression(secondOperand, xValue: xValue) else {
                return nil
            }
            switch functionName {
            case .logb:
                if firstValue <= 0.0 || secondValue == 1.0 || secondValue <= 0.0 {
                    return nil
                }
                return log(firstValue) / log(secondValue)
            case .root:
                return pow(firstValue, 1.0/Double(secondValue))
            case .mod:
                return firstValue.truncatingRemainder(dividingBy: secondValue)
            case .hypot:
                return sqrt(firstValue * firstValue + secondValue * secondValue)
            case .nPr:
                if firstValue < 0.0 || secondValue < 0.0 || secondValue > firstValue {
                    return 0.0
                }
                return Double(factorial(Int(firstValue)) / factorial(Int(firstValue) - Int(secondValue)))
            case .nCr:
                return Double(factorial(Int(firstValue)) / (factorial(Int(secondValue)) * factorial(Int(firstValue) - Int(secondValue))))
            default:
                return nil
            }
        case .operation(let op):
            switch op {
            case .constantPi:
                return Double.pi
            case .constantE:
                return M_E
            case .variableX:
                return xValue
            default:
                return nil
            }
        case .error(_):
            return nil
        }
    }
        
    func factorial(_ n: Int) -> Int {
        return (n <= 1) ? 1 : n * factorial(n - 1)
    }
    
    func updateUI() {
        evaluateAndGraphExpression()
        self.objectWillChange.send()
    }
}
