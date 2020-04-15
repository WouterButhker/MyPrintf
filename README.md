# MyPrintf
This is a simple implementation of the printf subroutine by Wouter Büthker and Daniël de Weerd in assembly (x86-64) for the course CSE1400 Computer Organisation

## Exercise
Write a simplified printf subroutine that takes a variable amount of arguments. The first argument for your subroutine is the format string. The rest of the arguments are printed instead
of the placeholders (also called format specifiers) in the format string. How those arguments are
printed depends on the corresponding format specifiers. Your printf function has to support any
number of format specifiers in the format string. Note that any number means that you need to
support more than 6 arguments.
Unlike the real printf, your version only has to understand the format specifiers listed below.
If a format specifier is not recognized, it should be printed without modification. Give your printf
function a different name (e.g. my printf) to avoid confusion with the real printf function in the
C library. Please note that for this exercise you are not allowed to use the printf function or
any other C library function. This means you will have to use system calls for the actual printing.
Your function must follow the proper x86-64 calling conventions.
Supported format specifiers:
- %d Print a signed integer in decimal. The corresponding parameter is a 64 bit signed integer.
- %u Print an unsigned integer in decimal. The corresponding parameter is a 64 bit unsigned
integer.
16
- %s Print a null terminated string. No format specifiers should be parsed in this string. The
corresponding parameter is the address of first character of the string.
- %% Print a percent sign. This format specifier takes no argument.

## How to run
`gcc -no-pie -o printbonus printbonus.s && ./printbonus`

## License
MIT License
