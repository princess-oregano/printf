# printf

Simple implementation of standart C language printf() function.

## Table of contents
* [Prerequisites](#prerequisites)
* [Installation and usage](#installation-and-usage)
* [Info](#info)

## Prerequisites
* `git`
* `make`
* `g++`
* `nasm`

Program was built and tested on Linux 6.1.21-1-MANJARO, with x86-64 instruction
set.

## Installation and usage
1. Download all source files into one folder:
```
$ git clone https://github.com/princess-oregano/akinator
```
2. Open the subfolder with source files and build with Make:
```
$ cd printf/
$ make
```
The test program will build and run.

It includes three separate programs: calling custom print() function from C 
language, calling standart printf() function from assembly and print() from
assembly.

To use print() in your code, follow next steps:
1. C language:
Include this line in your C code to declare function:
```
extern int print(const char *format, ...);
```
To compile, compile objective file of your C code and link it with `print.o`.

2. Assembly:
Include this line in your C code to declare function:
```
extern print
```
Just as with C code, compile .o file of your ASM code and link it with `print.o`.

## Info
print() supports next specifiers:
* `%s` - string 
* `%c` - char
* `%b` - binary number
* `%o` - octal number
* `%d` - decimal number(limits are from -2147483648 to +2147483647, otherwise behaviour is not defined)
* `%x` - hexadecimal number.
* `%%` - print %

If any other specifier is encountered, message `ERROR` will be placed instead of
argument.

Example of usage:
```
print("test: %b %o %d %x %s%c %s %u\n", 5, 8, 2147483647, 65, 
                "careful: error ahead", '!', "here-->", 123);
```
It will print following line:
```
test: 101 10 18446744071562067967 41 careful: error ahead! here--> ERROR
```

