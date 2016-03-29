latex input:        mmd-article-header
Title:              C++ Notes
Author:             Ethan C. Petuchowski
Base Header Level:  1
latex mode:         memoir
Keywords:           syntax, language, C++, OOP, old school garbage
CSS:                http://fletcherpenney.net/css/document.css
xhtml header:       <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
Copyright:          2016 Ethan Petuchowski
latex input:        mmd-natbib-plain
latex input:        mmd-article-begin-doc
latex footer:       mmd-memoir-footer

### References

* *C++ the Core Language*, by Gregory Satir & Doug Brown

## Not Specific to Classes

### Function/Method Overloading

* C++ allows more than one function with the same name as long as their
  signatures [i.e. the set of parameters in the definition] differ
    * **This is unlike C**.
* They *can**not*** *just* differ in their **return** types
* They *can __just__* differ in whether a particular parameter is `const`

### I/O

#### Print using cout

```c++
#include <iostream.h>
std::cout << myInt;
std::cout << myFloat;
std::cout << "a string\n";
std::cout << "sqrt: " << sqrt(myInt) << std::endl;

// print to standard error
std::cerr << "negative number passed\n";
```

#### How to make this work for your custom class

Making this work for your own class is like overriding `toString()` in Java. It
is done by overloading the `<<` operator *outside* of the `class` definition.

First, we may want to give that operator overload access to our privates

```c++
class MyDate {
    /* fields go here */
public:
    /* other methods go here */
    friend ostream& operator<<(ostream& os, const MyDate& dt);
}
```

Now, in a global function (I guess), we overload the operator

```c++
ostream& operator<<(ostream& os, const Date& dt) {
    os << dt.mo << '/' << dt.da << '/' << dt.yr;
    return os;
}
```

Ref: [msdn](https://msdn.microsoft.com/en-us/library/1z2f6c2k.aspx)

### Default parameters

The following can be called with *or* without 3rd parameter '`t`'.

```c++
int fctn(int p1, int p2, char t='n') {...}
```

### use new & delete instead malloc & free

I'm not sure what the specific differences in semantics are, but note that the
C++ versions are simpler for the programmer.

* Single float
    
    ```c
    // C
    float *fp = malloc(sizeof(float));
    free(fp);
    ```
    ```c++
    // C++
    float *fp = new float;
    delete fp;
    ```

* Float array        
   
    ```c
    // C
    float *fa = malloc(sizeof(float) * 10);
    free(fa);
    ```
    
    ```c++
    // C++
    float *fa = new float[10];
    delete[] fa;
    ```
        
* Class instance

    ```c
    // C
    // there are no classes in C...
    ```

    ```c++
    // C++
    Bar *bp = new Bar;
    delete bp;
    ```

### "References"

#### Declaration

```c
// C (there are no "references" in C)
void plus_5(int *ip) {
  *ip = *ip + 5;
}
```

```c++
// C++
void plus_5(int &ip) { // note the inclusion of an ampersand
  ip = ip + 5; // no asterix, even though this is NOT a local variable 
}
```

#### Usage

```c
// C
int n = 3;
plus_5(&n);
```

```c++
// C++
int n = 3;
plus_5(n);  // no &amp
```

### Const

**Makes a value or pointer un-modify-able** (to help you reason about it).

For more info, see [stove](http://stackoverflow.com/questions/455518/) and the
links therein.

### Casting
* You are free to cast between _any_ two types
* Some types are implicitly casted to other types (e.g. `int` \\(\to\\) `long`)
  when necessary
* Like C, you can *implicitly* cast **to** a `void*`

    ```c++
    void* v;
    Foo* f;
    v = f;
    ```

* **Unlike C**, you __must__ *explictly* cast **from** a `void*`

    ```c++
    void* v;
    Foo* f;
    f = (Foo*) v;
    ```

### Globals

* **Unlike C**, you *can* use a *dynamic* expression to initialize a
  *global* variable
    
    ```c++
    int global1 = my_func();
    int global2 = 2 * global1;

    main() { ... }
    ```

* These are dynamically **initialized *before* `main()` is entered**.
* This can lead to nasty bugs when linking against other files, so
  be-keahfo.

### Some keywords

* **volatile** --- does "less optimizations", for when a variable might
  be used by another thread or a memory-mapped device or something. (I
  don't actually understand this)
* **inline** --- *hint* to the compiler that the function should be
  expanded in-place "like a macro"
    * More "powerful" than macros because inlining is performed by the
      compiler rather than the preprocessor
        * Although I don't know what 'power' _is_ in that context

## Classes
 
#### Class vs Struct

The _default_ access level for classes is `private`, and for structs is
`public`. Other than that there is _no_ difference. One could believe the main
difference is one of humano-cognitive perceptual semantics.

### Basic Class Example

```c++
class Stack {

public:
    void push(int i);
    int pop();
    Stack();   // instead of init(Stack *s) in C
    ~Stack();  // instead of cleanup(Stack *s) in C

private:
    int items[STACKSIZE];
    int top;

};
```

### Constructors & Destroyers

* Functions like `ABC()` and `~ABC()` get the compiler to handle object
  initialization and cleanup for you.
* The **constructor** is called when an object of `class ABC` is *declared*
    * Can be overloaded just like any other function
    * You don't specify a `return` type (similar to Java and Scala)
* The **destructor** is called when the object *leaves scope*

#### Copy constructor

```c++
ABC(ABC & existing_instance);
```

__Note:__ the declaration/definition does __not__ state a return type.

Allows you to say (not sure this is correct)

```c++
ABC a1;
ABC a2 = a1;
```

Now `a1` has the same __value(s)__ as `a2`, but does _not_ point to the same
block of memory.

### "Member functions" (i.e. methods)

They can be defined *inside* or *outside* the class definition

```c++
class ABC {
public:
    void definedInside(int i) { cout << i + 1; }
    void definedOutside(int i);
}

// i.e. declare "scope" of the function to be class
void ABC::definedOutside(int i) { cout << i + 2; }
```
   

### Access Modifiers/Levels

* **public** --- can be accessed by any code
* **protected** --- can be accessed within subclasses only
* **private** --- can only be accessed by the class’s own member functions
  (and *"friends"*)
* One object ***can*** access the `private` members of another object
  from the same `class`, but **can _not_** access `private` members of
  the `class` it subclasses.

#### Member variables

##### static

Only one copy of the data is maintained for all objects of the class
(just like Java)


### Inheritance ("derived classes")

#### Access levels

* You define it right before you say which class you are deriving from.
* The *default* is `private`

    ```c++
    class A 
    {
    public:
        int x;
    protected:
        int y;
    private:
        int z;
    };

    class B : public A
    {
        // x is public
        // y is protected
        // z is not accessible from B
    };

    class C : protected A
    {
        // x is protected
        // y is protected
        // z is not accessible from C
    };

    class D : private A    // 'private' is default for classes
    {
        // x is private
        // y is private
        // z is not accessible from D
    };
    ```
        
    ([ref](http://stackoverflow.com/questions/860339))

### Overloading operators

* E.g. the `assignment operator`

    ```c++
    // in class declaration
    void operator=(ABC &other); 
    
    // then we define
    void ABC::operator=(ABC &other) { /* code */ }
    ```


### Virtual Functions

* **Virtual functions** behave according to the *run-time* type of
  the object they are called on
    1. Declare a pointer to the *base* class `ABC`
    2. Point it to an instance of the *derived* class `DEF`
    3. Call the *virtual* function, it will call the version as defined
       on the *derived* class `DEF::virtualFunction()`
* **Non-virtual functions** behave according to the *static* type
  of the object they are called on
* The **syntax** is like so

        virtual void virtualFunction();
        
    * The **syntax is *required*** in the *declaration* in the
      *base class* `ABC`
    * The **syntax is *optional*** in the *derived class* `DEF`
