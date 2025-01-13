# Faruki Language

A simple programming language with clean syntax and basic programming constructs.

## Overview
Faruki is a statically-typed language that uses the prefix 'f' for type declarations. It supports basic programming features with straightforward syntax.

## Key Features

### Types
- `fint` - numbers (integers/floats)
- `ffloat` - floats
- `fchar` - characters
- `fstring` - strings

**Example:**
```faruki
fint x = 10.
ffloat y = 3.14.
fchar c = 'A'.
fstring message = "Hello, Faruki!".
```

### Variables & Constants
- `f@int` - constants
- `f@float` - constants
- `f@char` - constants
- `f@string` - constants

**Example:**
```faruki
f@int MAX_SIZE = 100.
```

### Control Structures
- If-else: `_Check`, `_orelse`, `_else`
- Switch: `_match`
- Loops: `_Repeat`, `until`

**If-else Example:**
```faruki
_Check [x > 5] then {
    fstring result = "x is greater than 5".
}
_orelse [x == 5] then {
    result = "x equals 5".
}
_else {
    result = "x is less than 5".
}
```

**Switch Example:**
```faruki
_match [x] {
    [1] {
        fstring msgs = "One".
    }
    [2] {
        msgs = "Two".
    }
    [default] {
        msgs = "Other".
    }
}
```

**Loop Examples:**
- For loop:
```faruki
_Repeat fint i from 0 to 10 with 1 {
    fint square = i * i.
}
```
- While loop:
```faruki
until [x > 0] {
    x = x - 1.
}
```

### Arrays
```faruki
fint numbers(5, 0).             // Array of size 5
fint sequence(5) = (1,2,3,4,5). // Initialized array
```

### Functions
**Function with return type:**
```faruki
faruki fint add(fint a, fint b) {
    emit a + b.
}
```

**Void function:**
```faruki
faruki void printMessage(fstring msg) {
    fint x = 10.
    emit msg.
}
```

### Comments
- Use `@@` for single line comments
```faruki
@@ This is a sample Faruki program
```
- Use `@ .......@` for multiline comments
```faruki
@ This is a multiline comment
   spanning multiple lines. @
```

## Conclusion
Faruki Language is designed to be intuitive and accessible for both new and experienced developers. Its clean syntax and essential programming constructs make it a great choice for learning and building simple applications. With its unique approach to type declarations and control structures, Faruki offers a fresh perspective in the realm of programming languages.

