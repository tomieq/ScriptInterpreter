# ScriptInterpreter

ScriptInterpreter is a library that interprets and executes code passed at runtime.
The library is written in pure Swift, but it accepts scripts in Swift and JavaScript.

Imagine you have an iOS app that is used by some big clients. For some reason it must be the same app in the AppStore. Clients are very important to you(your company) and they need custom bussiness logic for each of them. What if your app can download business logic(scripts) from the backend? It's insane, but possible with this library. Even more, the logic can be changed on the backend side, so the app will just download it and no build, release or deploy to AppStore is needed. 
As the library supports both Swift and JavaScript syntax, on the backend side you can easily use library like [Google's blocky](https://developers.google.com/blockly)

Another usage scenario is that you have some kind of server app(let's say smart home rules app) that reacts to events. You've coded it well, released, deployed to server and it's working. There is a rule that turns on the kitchen's vent when humidity is over 80%. Your humidity level is a parameter that can be updated with some kind of frontend. It's customizable. After some time you realize, that on the weekends, after 11 p.m. you want the trigger level to be 70. You have to code again, deploy and run. Would it be simpler if the rules can be edited as a script at runtime?

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
try engine.registerFunc(name: "makeDarkness", function: myHandler.turnOffLight)
try engine.registerFunc(name: "setTemperature", function: myHandler.setTemperature)
try engine.registerFunc(name: "print", function: myHandler.print)

```
From now on, all the scripts that will be passed to `engine.exec(code:)` may invoke `lightMeUp()` function and the ScriptInterpreter will call `myHandler.turnOnLight()`.
You can register functions with parameters or without them.

The script passed to ScriptInterpreter may look like this:
```
let hour = 11
if(hour > 17) {
    lightMeUp()
    setTemperature(18)
}
```

## Can I work with variables?

Yes, ScriptInterpreter creates internal namespaces in which you can create and update variables. It supports strings, integers, boolean and float. There are variables and constants.
Constants might be defined with keyword `let` or `const`.
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
Isolated namespaces:
```
var amount = 3;
print(amount);
{
    var amount = 10;
    print(amount);
    amount++;
    print(amount);
}
amount--;
print(amount);
```
Above code run in ScriptInterpreter will print: 3, 10, 11, 2. Notice that you can use semicolons `;` or skip them

Look at the [ParserTests](./Tests/ScriptInterpreterTests/ParserTests.swift) - you will find more examples

## Can I set variable/constant so that are accessible by the script?

Yes, of course. You can register variable or constant that will be visible to the script:
```
let engine = ScriptInterpreter()
try engine.setupConstant(name: "hour", value: .integer(23))
try engine.setupConstant(name: "welcome", value: .string("Hello world"))
try engine.setupVariable(name: "isDone", value: .bool(false))
```

## Does ScriptInterpreter support loops?

Yes! Both while and for(JavaScript-style).
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

## Can I have returned result from executed script?

Yes, if your script returns any value, it will be mapped into `Value` and returned by `exec(_) function`.
Let's say you have script like this:
```
let distance = 50
var speed = 92

if (distance > 100) {
    speed = 90
    return speed
} else {
    return speed
}
```

The returned value can be obtained by calling:
```
let engine = ScriptInterpreter()
let script = // your script here

let result = try engine.exec(code: script)
```

## Does ScriptInterpreter support String interpolation?

Yes, you can use Swift-like String interpolation:
```
var color = "blue"
var text = "The walls are \(color)"
print(text)
let size = 85
let info = "The size is \(size)"
print(info)
```
Above code will produce: "The walls are blue", "The size is 85"

## Can my script define helper functions?

Yes, you can define functions in your script. You can use keyword `func` or `function`.
Example script:
```
var number = 0
func updateNumber(newVal) {
    number = newVal
}
updateNumber(8)
return number
```
Execution of above code will return 8
