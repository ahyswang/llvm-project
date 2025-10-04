// RUN: cc %s -o %t
// RUN: %t | grep -e "hello lit"
#include <stdio.h> 

int main()
{
    printf("hello lit");
    return 0; 
}