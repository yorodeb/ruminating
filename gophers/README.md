# 🐹 Go Programming Language: Essentials

## 0. Variables & Constants
Go is statically typed but offers concise syntax for declaration.

### Declaration Styles
```go
// Standard Declaration
var a int
var b int = 10

// Type Inference
var c = 20 

// Short-Hand (INSIDE FUNCTIONS ONLY)
d := 30 
```

### Multiple Variables
```go
var x, y int = 1, 2
name, age := "Gopher", 15
```

### Zero Values
Every variable in Go is initialized to its type's "Zero Value."

| Type | Default Value |
| :--- | :--- |
| `int` / `float64` | `0` |
| `string` | `""` (empty string) |
| `bool` | `false` |
| `pointer` / `map` / `slice` / `chan` | `nil` |

---

## 1. Collections

### Arrays
*Fixed size, value type.*
```go
var arr [3]int                  // [0, 0, 0]
nums := [3]int{1, 2, 3}         // Explicit Size
flexible := [...]int{1, 2, 3}   // Compiler Counts Elements
```
> **Note:** Arrays are **Value Types**. Passing an array to a function copies the entire data set.

### Slices
*Dynamic size, reference-like behavior.*
```go
s := []int{1, 2, 3}             // Literal
s = make([]int, 3, 5)           // Length 3, Capacity 5
s = append(s, 4)                // Dynamic Growth
```
> **Pro-Tip:** Slices are headers pointing to an underlying array. Modifying elements inside a function affects the caller.

### Maps
*Key-Value pairs (Hash tables).*
```go
// Must use make() or literal; a nil map will panic on write.
var hash map[string]int         // Nil Map i.e. Not Pointing to Anything

hash := make(map[string]int)

dict := map[string]string{
    "Go":    "Fast",
    "Rust":  "Safe",
}
```

---

## 2. Custom Types: Structs
Structs are the building blocks of Go’s data modeling.

```go
type Vector3 struct {
    X, Y, Z int
}

// Initialization
v1 := Vector3{X: 10, Y: 20}      // Z defaults to 0
v2 := new(Vector3)               // Returns a pointer (*Vector3)
v2 = &Vector3{x: 10, Y: 30, Z: 20}
```

---

## 3. Functions vs. Methods

### Functions
Standalone Logic.
```go
func Add(a, b int) int {
    return a + b
}
```

### Methods
Functions attached to a **Receiver Type**.
```go
// Value Receiver: Operates on a copy
func (v Vector3) Magnitude() int {
    return v.X + v.Y + v.Z
}

// Pointer Receiver: Can modify the original struct
func (v *Vector3) Scale(f int) {
    v.X *= f
}
```

---

## 4. Scope & Visibility
Go uses **Capitalization** to handle exports (Public vs. Private).

| Visibility | Naming | Scope |
| :--- | :--- | :--- |
| **Public** | `ExportedName` | Accessible by any package. |
| **Private** | `unexportedName` | Only accessible within the same package. |

### Shadowing Pitfall
Be careful with the `:=` operator in nested blocks.
```go
x := 10
if true {
    x := 20 // This is a NEW variable, shadowing the outer 'x'
}
fmt.Println(x) // Outputs 10
```

---

## 5. Packages: Public vs. Private
In Go, visibility is determined by **Capitalization**.

* **Public (Exported):** Starts with UpperCase. Visible to other packages.
* **Private (Unexported):** Starts with lowerCase. Visible only within the same package.

**Access Rules:**
| Access Level | From Same Package | From Other Package |
| :--- | :---: | :---: |
| `func add()` | ✔ | ❌ |
| `func Add()` | ✔ | ✔ |

---

## 6. Memory Behavior Summary

| Type | Category | Copy Behavior | Mutates Caller? |
| :--- | :--- | :--- | :---: |
| `int`, `bool`, `float` | Basic | Full value copy | ❌ |
| `array` | Aggregate | Full value copy | ❌ |
| `struct` | Aggregate | Full value copy | ❌* |
| `slice` | Reference | Header copy (points to same data) | ✔ |
| `map` | Reference | Header copy | ✔ |
| `chan` | Reference | Pointer to internal structure | ✔ |
| `pointer` | Pointer | Address copy | ✔ |

*\*Unless passed as a pointer (e.g., `*MyStruct`)*
