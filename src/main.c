extern int print(const char *format, ...);

#include <stdio.h>

int
main()
{
        print("test: %b %o %d %x %s%c %s %u\n", 5, 8, 21313, 65, 
                        "careful: error ahead", '!', "here-->", 123);

        printf("test: %o %d %x %s%c %s %s\n", 8, 21313, 65, 
                        "careful: error ahead", '!', "here-->", "actually, it is printf()...");

        return 0;
}
