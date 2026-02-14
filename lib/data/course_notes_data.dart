
final Map<String, String> courseNotes = {
  "C": """
# C Programming Notes

**Introduction:**
C is a general-purpose, procedural computer programming language supporting structured programming, lexical variable scope, and recursion, with a static type system. By design, C provides constructs that map efficiently to typical machine instructions.

**Key Concepts:**
- **Variables & Data Types:** int, float, double, char, void.
- **Operators:** Arithmetic, Relational, Logical, Bitwise, Assignment.
- **Control Flow:** if-else, switch, for, while, do-while loops.
- **Functions:** Modular code, pass by value (and reference using pointers).
- **Arrays & Strings:** Contiguous memory locations, null-terminated strings.
- **Pointers:** Memory addresses, pointer arithmetic, pointers to pointers.
- **Structures & Unions:** User-defined types, grouping variables.
- **File Handling:** fopen, fclose, fprintf, fscanf for persistent storage.

**Example:**
```c
#include <stdio.h>
int main() {
    printf("Hello, World!");
    return 0;
}
```
""",
  "C++": """
# C++ Programming Notes

**Introduction:**
C++ is a general-purpose programming language created by Bjarne Stroustrup as an extension of the C programming language, or "C with Classes". It supports object-oriented, generic, and functional features.

**Key Concepts:**
- **OOPs Concepts:** Classes, Objects, Inheritance, Polymorphism, Encapsulation, Abstraction.
- **Constructors & Destructors:** Initialization and cleanup.
- **Standard Template Library (STL):** Vectors, Lists, Maps, Algorithms (sort, search).
- **Exception Handling:** try, catch, throw.
- **Templates:** Generic programming for functions and classes.
- **Memory Management:** new and delete operators.

**Example:**
```cpp
#include <iostream>
using namespace std;
int main() {
    cout << "Hello, C++!" << endl;
    return 0;
}
```
""",
  "Java": """
# Java Programming Notes

**Introduction:**
Java is a high-level, class-based, object-oriented programming language that is designed to have as few implementation dependencies as possible. It is intended to let application developers "write once, run anywhere" (WORA).

**Key Concepts:**
- **JVM, JRE, JDK:** Understanding the runtime environment.
- **OOPs:** Object-Oriented principles are central to Java.
- **Collections Framework:** ArrayList, HashMap, HashSet, LinkedList.
- **Multithreading:** Thread class, Runnable interface, synchronization.
- **Exception Handling:** Checked and Unchecked exceptions.
- **File I/O:** Streams, Readers, Writers.
- **Lambda Expressions:** Functional programming introduced in Java 8.

**Example:**
```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, Java!");
    }
}
```
""",
  "Python": """
# Python Notes

**Introduction:**
Python is an interpreted, high-level, general-purpose programming language. Its design philosophy emphasizes code readability with the use of significant indentation.

**Key Concepts:**
- **Data Types:** Dynamic typing (int, float, str, bool).
- **Data Structures:** Lists, Tuples, Sets, Dictionaries.
- **Control Flow:** if, elif, else, for (iterators), while.
- **Functions:** def, lambda functions, args/kwargs.
- **Modules & Packages:** Import system, pip.
- **OOP:** Classes, inheritance, dunder methods (__init__).
- **Error Handling:** try, except, finally.

**Example:**
```python
print("Hello, Python!")
```
""",
  "JavaScript": """
# JavaScript Notes

**Introduction:**
JavaScript (JS) is a lightweight, interpreted, or just-in-time compiled programming language with first-class functions. It is well-known as the scripting language for Web pages.

**Key Concepts:**
- **Variables:** var, let, const.
- **Functions:** Arrow functions, callbacks, closures.
- **DOM Manipulation:** Selecting and modifying HTML elements.
- **Asynchronous JS:** Promises, async/await, fetch API.
- **ES6+ Features:** Destructuring, template literals, spread operator.
- **Event Handling:** Click, submit, hover events.

**Example:**
```javascript
console.log("Hello, JavaScript!");
```
""",
  "Kotlin": """
# Kotlin Notes

**Introduction:**
Kotlin is a cross-platform, statically typed, general-purpose programming language with type inference. It is designed to interoperate fully with Java, and the JVM version of Kotlin's standard library depends on the Java Class Library.

**Key Concepts:**
- **Null Safety:** Safe calls (?.), Elvis operator (?:).
- **Variables:** val (immutable) vs var (mutable).
- **Functions:** Top-level functions, default arguments.
- **Data Classes:** Concise way to create classes holding data.
- **Coroutines:** Asynchronous programming made easy.
- **Extensions:** Adding functions to existing classes without inheritance.

**Example:**
```kotlin
fun main() {
    println("Hello, Kotlin!")
}
```
""",
  "Dart": """
# Dart Notes

**Introduction:**
Dart is a client-optimized language for fast apps on any platform. It is creating by Google and is the language used for Flutter.

**Key Concepts:**
- **Strong & Dynamic Typing:** var, dynamic, final, const.
- **Classes & Mixins:** Single inheritance, interfaces, mixins for reuse.
- **Async Programming:** Future, async, await, Stream.
- **Null Safety:** Built-in sound null safety.
- **Collections:** List, Set, Map.
- **Constructors:** Named constructors, factory constructors.

**Example:**
```dart
void main() {
    print('Hello, Dart!');
}
```
""",
  "PHP": """
# PHP Notes

**Introduction:**
PHP is a popular general-purpose scripting language that is especially suited to web development and can be embedded into HTML.

**Key Concepts:**
- **Syntax:** Embedded in HTML using <?php ... ?>.
- **Variables:** Start with \$, dynamic typing.
- **Arrays:** Associative and indexed arrays are powerful.
- **Superglobals:** \$_GET, \$_POST, \$_SESSION, \$_SERVER.
- **Database Interaction:** PDO, mysqli for connecting to MySQL.
- **OOP:** Classes, interfaces, traits.

**Example:**
```php
<?php
echo "Hello, PHP!";
?>
```
""",
  "SQL": """
# SQL Notes

**Introduction:**
Structured Query Language (SQL) is a domain-specific language used in programming and designed for managing data held in a relational database management system (RDBMS).

**Key Concepts:**
- **DDL (Data Definition):** CREATE, ALTER, DROP tables.
- **DML (Data Manipulation):** INSERT, UPDATE, DELETE.
- **DQL (Data Query):** SELECT, FROM, WHERE, ORDER BY, GROUP BY.
- **Joins:** INNER, LEFT, RIGHT, FULL OUTER joins.
- **Constraints:** PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE.
- **Aggregates:** COUNT, SUM, AVG, MAX, MIN.

**Example:**
```sql
SELECT * FROM Users WHERE age > 18;
```
""",
  "Swift": """
# Swift Notes

**Introduction:**
Swift is a powerful and intuitive programming language for iOS, iPadOS, macOS, tvOS, and watchOS. Writing Swift code is interactive and fun, the syntax is concise yet expressive.

**Key Concepts:**
- **Safety:** Optionals, type inference.
- **Constants & Variables:** let and var.
- **Control Flow:** if, guard, switch, for-in.
- **Structs & Classes:** Value types vs Reference types.
- **Closures:** Self-contained blocks of functionality.
- **Protocols & Extensions:** Defining blueprints and extending functionality.
- **SwiftUI:** Declarative UI framework.

**Example:**
```swift
import Swift
print("Hello, Swift!")
```
"""
};
