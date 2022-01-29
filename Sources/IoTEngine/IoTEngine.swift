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
    private let valueRegistry: ValueRegistry
    
    public init() {
        self.functionRegistry = ExternalFunctionRegistry()
        self.valueRegistry = ValueRegistry()
    }
    
    public func registerFunc(name: String, function: @escaping ()->()) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }
    
    public func registerFunc(name: String, function: @escaping ([Value])->()) throws {
        try self.functionRegistry.registerFunc(name: name, function: function)
    }
    
    public func setupVariable(name: String, value: Value) {
        self.valueRegistry.registerValue(name: name, value: value)
    }
    
    public func exec(code: String) throws {
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: self.functionRegistry, valueRegistry: self.valueRegistry)
            try parser.execute()
        } catch {
            throw IoTEngineError.runtimeError(description: error.localizedDescription)
        }
    }
}
