extern int print(const char *format, ...);

#include <stdio.h>

int
main()
{
        print("Debugging))))) %x\n", -2147483648);

        return 0;
}
