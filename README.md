# zBoxer 🥊

## Introduction

zBoxer is a fork of Bozer, a simple library that allows for easy cross-platform creation of message boxes / alerts / what have you.

## Example

macOS:

![macOS](https://user-images.githubusercontent.com/1409522/213894782-72c37b24-bdb3-4b29-a847-cbff7748b1fe.png)

Windows:

![Windows](https://user-images.githubusercontent.com/1409522/213894790-55cf2be8-bcc0-4867-95e0-7741993f07eb.png)

Linux:

![Linux](https://user-images.githubusercontent.com/1409522/213894798-1bb1c279-5190-4108-b49c-08a28c7dfc29.png)

## Language

zBoxer is written in C, Obj-C and Zig.

## Compiling zBoxer

zBoxer is set up to be built with CMake.

To generate a static library, execute CMake with the root of the repo as the source directory. Additionally, the example program can be built by enabling the BOXER_BUILD_EXAMPLES option.

On Linux, zBoxer requires the gtk+-3.0 package to compile, but does not directly link against it.

## Including zBoxer

Wherever you want to use zBoxer, just include the header:

```c++
#include <boxer/boxer.h>
```

## Linking Against zBoxer

### Static

If zBoxer was built statically, just link against the generated static library.

## Using Boxer

To create a message box using zBoxer, call the 'boxerShow' C method and provide a message, title, style, and buttons:

```c
boxerShow("Simple message boxes are very easy to create.", "Simple Example", kBoxerDefaultStyle, kBoxerDefaultButtons);
```

Different styles / buttons may be specified, and the user's selection can be determined from the function's return value:

```c
BoxerSelection sel = boxerShow("Make a choice:", "Decision", BoxerStyleWarning, BoxerButtonsYesNo);
```

Calls to 'show' are blocking - execution of your program will not continue until the user dismisses the message box.

### Encoding

zBoxer accepts strings encoded in UTF-8:

```c
boxerShow(u8"Boxer accepts UTF-8 strings. 💯", u8"Unicode 👍", kBoxerDefaultStyle, kBoxerDefaultButtons);
```

On Windows, `UNICODE` needs to be defined when compiling zBoxer to enable UTF-8 support:

```cmake
if (WIN32)
   target_compile_definitions(Boxer PRIVATE UNICODE)
endif (WIN32)
```
