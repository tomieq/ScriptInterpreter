import Foundation

public enum ScriptInterpreterError: Error {
    case runtimeError(description: String)
}

extension ScriptInterpreterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .runtimeError(let info):
            return NSLocalizedString("RuntimeError: \(info)", comment: "IoTEngineError")
        }
    }
}

public class ScriptInterpreter {
    private let functionRegistry: ExternalFunctionRegistry
    private let variableRegistry: VariableRegistry
    private var parser: Parser?

    public init() {
        self.functionRegistry = ExternalFunctionRegistry()
        self.variableRegistry = VariableRegistry()
    }

    public func registerFunc(name: String, function: @escaping () throws -> ()) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }

    public func registerFunc(name: String, function: @escaping () throws -> Value) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }

    public func registerFunc(name: String, function: @escaping ([Value]) throws -> ()) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }

    public func registerFunc(name: String, function: @escaping ([Value]) throws -> Value) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }

    public func setupVariable(name: String, value: Value) throws {
        try self.variableRegistry.registerVariable(name: name, variable: .primitive(value))
    }

    public func setupConstant(name: String, value: Value) throws {
        try self.variableRegistry.registerConstant(name: name, variable: .primitive(value))
    }

    public func exec(code: String) throws -> Value? {
        do {
            let lexer = try Lexer(code: code)
            self.parser = Parser(tokens: lexer.tokens, externalFunctionRegistry: self.functionRegistry, variableRegistry: self.variableRegistry)
            let result = try self.parser?.execute() ?? .finished
            switch result {
            case .finished, .break:
                return nil
            case .return(let value):
                return value
            }
        } catch {
            throw ScriptInterpreterError.runtimeError(description: error.localizedDescription)
        }
    }

    public func memoryDump() -> [String: Value] {
        return self.variableRegistry.memoryDump()
    }

    public func clearMemory() {
        self.variableRegistry.clearMemory()
    }

    public func abort(reason: String) {
        self.parser?.abort(reason: reason)
    }
}
