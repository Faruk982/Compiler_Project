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

### Variables & Constants
- `f@int` - constants
- `f@float` - constants
- `f@char` - constants
- `f@string` - constants

### Control Structures
- If-else: `_Check`, `_orelse`, `_else`
- Switch: `_match`
- Loops: `_Repeat`, `until`

### Arrays
```faruki
fint numbers(5, 0).             // Array of size 5
fint sequence(5) = (1,2,3,4,5). // Initialized array
```

### Functions
```faruki
faruki fint add(fint a, fint b) {
    emit a + b.
}
```

### Comments
- Use `@@` for single line comments
- `@ .......@` for multiline comments

## Conclusion
Faruki Language is designed to be intuitive and accessible for both new and experienced developers. Its clean syntax and essential programming constructs make it a great choice for learning and building simple applications. With its unique approach to type declarations and control structures, Faruki offers a fresh perspective in the realm of programming languages.

