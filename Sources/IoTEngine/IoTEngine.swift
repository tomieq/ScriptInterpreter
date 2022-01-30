import Foundation

public enum IoTEngineError: Error {
    case runtimeError(description: String)
}

extension IoTEngineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .runtimeError(let info):
            return NSLocalizedString("RuntimeError: \(info)", comment: "IoTEngineError")
        }
    }
}

public class IoTEngine {
    private let functionRegistry: ExternalFunctionRegistry
    private let variableRegistry: VariableRegistry
    
    public init() {
        self.functionRegistry = ExternalFunctionRegistry()
        self.variableRegistry = VariableRegistry()
    }
    
    public func registerFunc(name: String, function: @escaping ()->()) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }
    
    public func registerFunc(name: String, function: @escaping ([Value])->()) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }
    
    public func setupVariable(name: String, value: Value) throws {
        try self.variableRegistry.registerValue(name: name, value: value)
    }
    
    public func setupConstant(name: String, value: Value) throws {
        try self.variableRegistry.registerConstant(name: name, value: value)
    }
    
    public func exec(code: String) throws -> Value? {
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: self.functionRegistry, variableRegistry: self.variableRegistry)
            let result = try parser.execute()
            switch result {
            case .finished, .break:
                return nil
            case .return(let value):
                return value
            }
        } catch {
            throw IoTEngineError.runtimeError(description: error.localizedDescription)
        }
    }
}
