# 1 "lab4_app.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "lab4_app.c"






# 1 "clib.h" 1



void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
# 8 "lab4_app.c" 2
# 1 "yakk.h" 1
# 1 "clib.h" 1



void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
# 2 "yakk.h" 2
# 1 "/usr/lib/gcc/x86_64-redhat-linux/5.3.1/include/stdint.h" 1 3 4
# 9 "/usr/lib/gcc/x86_64-redhat-linux/5.3.1/include/stdint.h" 3 4
# 1 "/usr/include/stdint.h" 1 3 4
# 25 "/usr/include/stdint.h" 3 4
# 1 "/usr/include/features.h" 1 3 4
# 365 "/usr/include/features.h" 3 4
# 1 "/usr/include/sys/cdefs.h" 1 3 4
# 410 "/usr/include/sys/cdefs.h" 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 411 "/usr/include/sys/cdefs.h" 2 3 4
# 366 "/usr/include/features.h" 2 3 4
# 389 "/usr/include/features.h" 3 4
# 1 "/usr/include/gnu/stubs.h" 1 3 4
# 10 "/usr/include/gnu/stubs.h" 3 4
# 1 "/usr/include/gnu/stubs-64.h" 1 3 4
# 11 "/usr/include/gnu/stubs.h" 2 3 4
# 390 "/usr/include/features.h" 2 3 4
# 26 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/bits/wchar.h" 1 3 4
# 27 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 28 "/usr/include/stdint.h" 2 3 4
# 36 "/usr/include/stdint.h" 3 4

# 36 "/usr/include/stdint.h" 3 4
typedef signed char int8_t;
typedef short int int16_t;
typedef int int32_t;

typedef long int int64_t;







typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;

typedef unsigned int uint32_t;



typedef unsigned long int uint64_t;
# 65 "/usr/include/stdint.h" 3 4
typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef int int_least32_t;

typedef long int int_least64_t;






typedef unsigned char uint_least8_t;
typedef unsigned short int uint_least16_t;
typedef unsigned int uint_least32_t;

typedef unsigned long int uint_least64_t;
# 90 "/usr/include/stdint.h" 3 4
typedef signed char int_fast8_t;

typedef long int int_fast16_t;
typedef long int int_fast32_t;
typedef long int int_fast64_t;
# 103 "/usr/include/stdint.h" 3 4
typedef unsigned char uint_fast8_t;

typedef unsigned long int uint_fast16_t;
typedef unsigned long int uint_fast32_t;
typedef unsigned long int uint_fast64_t;
# 119 "/usr/include/stdint.h" 3 4
typedef long int intptr_t;


typedef unsigned long int uintptr_t;
# 134 "/usr/include/stdint.h" 3 4
typedef long int intmax_t;
typedef unsigned long int uintmax_t;
# 10 "/usr/lib/gcc/x86_64-redhat-linux/5.3.1/include/stdint.h" 2 3 4
# 3 "yakk.h" 2
# 15 "yakk.h"

# 15 "yakk.h"
extern unsigned YKIdleCount;

extern unsigned int nextTask;

extern unsigned int YKCtxSwCount;

extern unsigned ISRDepth;

extern unsigned YKTickNum;

typedef enum tasks{running,delayed,suspended} taskStates;

typedef struct YKSEM{
 int value;
}YKSEM;

typedef struct YKQ{
 void** start;
 unsigned size;
 unsigned inUse;
 unsigned id;
 YKSEM* semaphore;
 int front;
 int rear;
 int numberPendingOn;
}YKQ;

typedef struct TCB{
 unsigned int ip;

 unsigned int sp;
 unsigned int bp;

 unsigned ax;
 unsigned bx;
 unsigned cx;
 unsigned dx;
 unsigned si;
 unsigned di;
 unsigned es;
 unsigned ds;

 void * taskStack;
 unsigned int taskPriority;
 taskStates taskState;
 unsigned int id;
 unsigned int delayCount;
 struct TCB * nextTCB;
 struct TCB * prevTCB;
 unsigned inUse;
 YKSEM* pendingOn;
 unsigned eventMask;
 int waitMode;

}TCB;


typedef struct YKEVENT{
 unsigned value;
 int id;
 int inUse;
 TCB * eventPendingListHead;
}YKEVENT;


extern struct TCB TCBArray[15];

extern struct YKSEM YKSEMArray[30];

extern struct YKQ YKQArray[15];

YKQ *YKQCreate(void **start, unsigned size);

void *YKQPend(YKQ *queue);

void YKScheduler(int calledFromISR);

void YKDispatcher();

void dispatchHelper();

void YKEnterMutexHelper();

void YKExitMutexHelper();

void YKIdleTask();

void YKInitialize();

void YKNewTask();

void YKEnterMutex();

void YKExitMutex();

void YKRun();

void YKDelayTask(unsigned count);

void YKEnterISR();

void YKExitISR();

void YKTickHandler();

YKSEM* YKSemCreate(int initialValue);

void YKSemPend(YKSEM *semaphore);

void YKSemPost(YKSEM *semaphore);

int YKQPost(YKQ *queue, void *msg);

YKEVENT *YKEventCreate(unsigned initialValue);

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);

void YKEventSet(YKEVENT *event, unsigned eventMask);

 void YKEventReset(YKEVENT *event, unsigned eventMask);

void YKExitMutexIDLE();
# 9 "lab4_app.c" 2
# 1 "lab7defs.h" 1
# 15 "lab7defs.h"
extern YKEVENT *charEvent;
extern YKEVENT *numEvent;
# 10 "lab4_app.c" 2





YKEVENT *charEvent;
YKEVENT *numEvent;

int CharTaskStk[512];
int AllCharsTaskStk[512];
int AllNumsTaskStk[512];
int STaskStk[512];



void CharTask(void)
{
    unsigned events;

    printString("Started CharTask     (2)\n");

    while(1) {
        events = YKEventPend(charEvent,
                             0x1 | 0x2 | 0x4,
                             0);

        if(events == 0) {
            printString("Oops! At least one event should be set "
                        "in return value!\n");
        }

        if(events & 0x1) {
            printString("CharTask     (A)\n");
            YKEventReset(charEvent, 0x1);
        }

        if(events & 0x2) {
            printString("CharTask     (B)\n");
            YKEventReset(charEvent, 0x2);
        }

        if(events & 0x4) {
            printString("CharTask     (C)\n");
            YKEventReset(charEvent, 0x4);
        }
    }
}


void AllCharsTask(void)
{
    unsigned events;

    printString("Started AllCharsTask (3)\n");

    while(1) {
        events = YKEventPend(charEvent,
                             0x1 | 0x2 | 0x4,
                             1);


        if(events != 0) {
            printString("Oops! Char events weren't reset by CharTask!\n");
        }

        printString("AllCharsTask (D)\n");
    }
}


void AllNumsTask(void)
{
    unsigned events;

    printString("Started AllNumsTask  (1)\n");

    while(1) {
        events = YKEventPend(numEvent,
                             0x1 | 0x2 | 0x4,
                             1);

        if(events != (0x1 | 0x2 | 0x4)) {
            printString("Oops! All events should be set in return value!\n");
        }

        printString("AllNumsTask  (123)\n");

        YKEventReset(numEvent, 0x1 | 0x2 | 0x4);
    }
}


void STask(void)
{
    unsigned max, switchCount, idleCount;
    int tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = (YKIdleCount)/25;
    YKIdleCount = 0;


    YKNewTask(CharTask, (void *) &CharTaskStk[512], 2);
    YKNewTask(AllNumsTask, (void *) &AllNumsTaskStk[512], 1);
    YKNewTask(AllCharsTask, (void *) &AllCharsTaskStk[512], 3);
    while (1)
    {
        YKDelayTask(20);

        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;

        YKExitMutex();
        printInt(YKIdleCount);
        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");

        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}


void main(void)
{
    YKInitialize();

    charEvent = YKEventCreate(0);
    numEvent = YKEventCreate(0);
    YKNewTask(STask, (void *) &STaskStk[512], 0);

    YKRun();
}
