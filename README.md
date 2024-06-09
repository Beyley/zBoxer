# zBoxer 🥊

## Introduction

zBoxer is a fork of Boxer, a simple library that allows for easy cross-platform creation of message boxes / alerts / what have you.

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

zBoxer is set up to be built with Zig.

Just run `zig build` in the project root, can cross compile from/to all supported platforms, and no external deps are needed

## Including zBoxer

`build.zig`:

```zig
const zboxer = b.dependency("zBoxer", .{
   .target = target,
   .optimize = optimize,
});
const zboxer_lib = zboxer.artifact("boxer");
exe.linkLibrary(zboxer_lib);

try exe.root_module.include_dirs.appendSlice(b.allocator, zboxer_lib.root_module.include_dirs.items);
try exe.root_module.lib_paths.appendSlice(b.allocator, zboxer_lib.root_module.lib_paths.items);
```

`build.zig.zon`:

```zig
.{
   .name = "APPNAME",
   .version = "0.0.0",
   .dependencies = .{
      .zBoxer = .{
         .url = "git+https://github.com/Beyley/zBoxer#LATEST_COMMIT_HASH_HERE",
      },
   },
}
```

Then when it complains that the hash is wrong, add the corrosponding `.hash = "HASHHERE",` into the `zBoxer` dependency

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

zBoxer accepts strings encoded in UTF-8
