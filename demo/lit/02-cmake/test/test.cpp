// RUN: cc %s -o %t
// RUN: %t | %FILECHECK %s
#include <stdio.h> 

int main()
{
    // 前缀匹配
    // CHECK: hello lit
    printf("hello lit");
    return 0; 
}