# ScriptInterpreter

ScriptInterpreter is a library that interprets and executes code passed at runtime.
The library is written in pure Swift, but it accepts scripts in Swift and JavaScript.

Some sample scenario is that you delploy your Swift app to the server and listen for incoming scripts. When one arrives it is parsed and executed.

## Can I expose my Swift functions to the script?

Yes, that's core functionality. All the functions you want to expose to the script must be registered first:
```
class Handler {
    func turnOnLight() {
        // logic goes here
    }
    func turnOffLight() throws {
        // logic goes here
    }
    func setTemperature(_ arguments: [Value]) throws {
        guard let temperature = arguments.first, temperature.isInteger else {
            throw ScriptInterpreterError.runtimeError(description: "setTemperature(_) accepts only integers!")
        }
        // logic goes here
    }
    func print(_ arguments: [Value]) {
        Swift.print(arguments)
    }
}

let myHandler = Handler()

let engine = ScriptInterpreter()
try engine.registerFunc(name: "lightMeUp", function: myHandler.turnOnLight)
try engine.registerFunc(name: "makeDarkness", function: myHandler.turnOnLight)
try engine.registerFunc(name: "setTemperature", function: myHandler.setTemperature)
try engine.registerFunc(name: "print", function: myHandler.print)

```
From now on, all the scripts that will be passed to `engine.exec(code:)` may invoke `lightMeUp()` function and the ScriptInterpreter will call `myHandler.turnOnLight()`.
You can register functions that accept parameters or without.

The script passed to ScriptInterpreter may look like this:
```
let hour = 11
if(hour > 17) {
    lightMeUp()
    setTemperature(18)
}
```

## Can I work with variables?

Yes, ScriptInterpreter creates namespaces in which you can create and update variables. It supports strings, integers, boolean and float. There are variables and constants.
Sample script:
```
var counter = 0
let isBroken = true
if (isBroken) {
    counter++
} else {
    counter = 10
}
```
Swift-like namespaces:
```
var amount = 3
print(amount)
{
    var amount = 10
    print(amount)
    amount++
    print(amount)
}
amount--
print(amount)
```
Above code run in ScriptInterpreter will print: 3, 10, 11, 2

Look at the `ParserTests` - you will find more examples

## Does ScriptInterpreter supports loops?

Yes! Both while and for(JavaScript-style)
Sample while-script:
```
var counter = 0
while(counter <= 3) {
    counter++
    rotate()
}
```
Sample for-script:
```
var i = 90
for(var i = 0; i < 3; i++) {
    rotate()
}
print(i) <- this will print 90, as `i` in main loop is in different namespace than `i` in for-loop
```
Above scripts will call `rotate` function 3 times
