# 1 "yakc.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "yakc.c"
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
# 2 "yakc.c" 2





unsigned YKIdleCount = 0;
struct TCB TCBArray[15];
struct YKSEM YKSEMArray[30];
struct YKQ YKQArray[15];
struct YKEVENT YKEVENTArray[15];
unsigned int YKSEMNextFree = 0;

int IdleStk[2048];
int isRunning = 0;
unsigned int YKCtxSwCount;
unsigned ISRDepth = 0;
unsigned YKTickNum = 1;
unsigned deltaDelay = 0;
unsigned returnToLocation;

TCB * runningTCB;
TCB * nextTCB;

extern void dispatcher();
extern void dispatchHelperFirst();
extern void initializeStack();

TCB * readyListHead = ((void *) 0);
TCB * pendingListHead = ((void *) 0);
TCB * delayListHead = ((void *) 0);
TCB * queuePendingListHead = ((void *) 0);

static void printDelayCounts(){
 TCB * itr = delayListHead;
 while(1){
  if(itr == ((void *) 0)){
   break;

  }
  printString("id=");
    printInt(itr->id);
  printString(" and count=") ;
  printInt(itr->delayCount);

  printString(", ") ;
  itr = itr->nextTCB;
 }
  printString("\r\n") ;

}



static void printReadyList(){
 TCB * itr = readyListHead;
 while(1){
  if(itr == ((void *) 0)){
   break;

  }
  printString("id: ");
  printInt(itr->id);
  printString(" ip: ") ;
  printInt(itr->ip);
  printString(" dc: ") ;
  printInt(itr->delayCount);
  printString(" pri: ") ;
  printInt(itr->taskPriority);
  printString(", ") ;
  itr = itr->nextTCB;
 }
  printString("\r\n") ;

}



static void firstDispatch(int calledFromISR){



 YKCtxSwCount++;
 nextTCB = readyListHead;
 runningTCB = readyListHead;
 dispatchHelperFirst();
 YKExitMutex();
 return;
}


void YKInitialize(){
 int i = 0;
 YKEnterMutex();
 for(i= 0; i < 15 ; i++){
  TCBArray[i].inUse = 0;
  TCBArray[i].id = i;
 }
 for(i = 0; i < 15; i++){
  YKQArray[i].inUse = 0;
  YKQArray[i].id = i;
  YKQArray[i].start = ((void *) 0);
  YKQArray[i].semaphore = YKSemCreate(0);
  YKQArray[i].front = 0;
  YKQArray[i].rear = 0;
  YKQArray[i].numberPendingOn = 0;
 }
 for(i= 0; i < 15 ; i++){
  YKEVENTArray[i].inUse = 0;
  YKEVENTArray[i].id = i;
  YKEVENTArray[i].eventPendingListHead = ((void *) 0);
 }
 YKNewTask(YKIdleTask, (void *)&IdleStk[2048] , 100);
 YKExitMutex();
}

void YKNewTask(void(*task)(void), void * taskStack, unsigned char priority){
 int i = 0;
 TCB* itr = readyListHead;
 TCB* temp;



 YKEnterMutex();
 for(i = 0; i < 15; i++){
  if(!TCBArray[i].inUse){
   break;
  }
 }






 TCBArray[i].taskPriority = priority;
 TCBArray[i].taskStack = taskStack;
 TCBArray[i].ip = (unsigned int)task;
 TCBArray[i].taskState = running;
 TCBArray[i].delayCount = 0;
 TCBArray[i].inUse = 1;
 TCBArray[i].sp = (unsigned)(taskStack);
 TCBArray[i].bp = (unsigned)(taskStack);

 temp = runningTCB;
 runningTCB = &(TCBArray[i]);
 initializeStack();
 runningTCB = temp;


 if(readyListHead == ((void *) 0)){
  readyListHead = &TCBArray[i];
  readyListHead->prevTCB = ((void *) 0);
  readyListHead->nextTCB = ((void *) 0);
  if(isRunning){
   YKScheduler(0);
  }
  YKExitMutex;
  return;
 }

 while(1){
  if(itr->taskPriority >= TCBArray[i].taskPriority){
   if(itr == readyListHead){

    itr->prevTCB = &TCBArray[i];
    TCBArray[i].nextTCB = itr;
    TCBArray[i].prevTCB = ((void *) 0);
    readyListHead = &TCBArray[i];
    break;

   }else{
    temp = itr->prevTCB;
    itr->prevTCB = &TCBArray[i];
    TCBArray[i].nextTCB = itr;
    TCBArray[i].prevTCB = temp;
    temp->nextTCB = &TCBArray[i];
    break;
   }
  }

  if(itr->nextTCB == ((void *) 0)){
   itr->nextTCB = &TCBArray[i];
   TCBArray[i].prevTCB = itr;
   TCBArray[i].nextTCB = ((void *) 0);
   break;

  }
  itr = itr->nextTCB;
 }
 if(isRunning){
  YKScheduler(0);
 }
 if(isRunning){
  YKExitMutex();
 }
}

void YKRun(){
 isRunning = 1;
 firstDispatch(0);
}


void YKIdleTask(){
int i;
 while(1){

  YKEnterMutex();
  YKIdleCount++;
  YKExitMutex();
 }
}


void YKScheduler(int calledFromISR){
 nextTCB = readyListHead;
# 231 "yakc.c"
 if(nextTCB == runningTCB){
  if(!calledFromISR){
   YKExitMutex();
  }
  return;
 }
 YKCtxSwCount++;
 dispatcher();







 YKExitMutex();
 return;

}

void YKDelayTask(unsigned count){
 TCB* itr = delayListHead;
 TCB* temp;
 if(count == 0){
  YKExitMutex();
  return;
 }
# 268 "yakc.c"
 YKEnterMutex();
 runningTCB->delayCount = count;





 if(runningTCB == readyListHead){
  readyListHead = runningTCB->nextTCB;
  readyListHead->prevTCB = ((void *) 0);
 }else if(runningTCB->nextTCB == ((void *) 0)){
  runningTCB->prevTCB->nextTCB = ((void *) 0);
 }else{
  runningTCB->prevTCB->nextTCB = runningTCB->nextTCB;
  runningTCB->nextTCB->prevTCB = runningTCB->prevTCB;
 }




 if(delayListHead == ((void *) 0)){
  delayListHead = runningTCB;
  delayListHead->prevTCB = ((void *) 0);
  delayListHead->nextTCB = ((void *) 0);
  YKScheduler(0);
  return;
 }



 while(1){
  if(itr == ((void *) 0)){
   deltaDelay = 0;
   break;
  }
  if(itr == delayListHead){
   itr = itr->nextTCB;
   continue;
  }
  itr->delayCount -= deltaDelay;
  itr = itr->nextTCB;
 }


 itr = delayListHead;
 while(1){
  if(itr->delayCount >= runningTCB->delayCount){

   if(itr == delayListHead){
    itr->prevTCB = runningTCB;
    runningTCB->nextTCB = itr;
    runningTCB->prevTCB = ((void *) 0);
    delayListHead = runningTCB;
    break;

   }else{
    temp = itr->prevTCB;
    itr->prevTCB = runningTCB;
    runningTCB->nextTCB = itr;
    runningTCB->prevTCB = temp;
    temp->nextTCB = runningTCB;
    break;
   }
  }

  if(itr->nextTCB == ((void *) 0)){
   itr->nextTCB = runningTCB;
   runningTCB->prevTCB = itr;
   runningTCB->nextTCB = ((void *) 0);
   break;

  }
  itr = itr->nextTCB;
 }
 YKScheduler(0);
}

void YKEnterISR(){
 ISRDepth++;
}

void YKExitISR(){
 ISRDepth--;
 if(ISRDepth == 0){
  YKScheduler(1);
 }
}



void YKTickHandler(){
 TCB* itr = delayListHead;
 TCB* moveOutOfDelayList;
 TCB* temp;
 int keepGoing = 1;

 int i = 0;






 YKEnterMutex();
 YKTickNum++;
# 382 "yakc.c"
 delayListHead->delayCount--;
 deltaDelay++;
 if(delayListHead->delayCount != 0){
  YKExitMutex();
  return;
 }



 while(1){
  itr = delayListHead;
  moveOutOfDelayList = delayListHead;

  if(delayListHead->nextTCB != ((void *) 0)){
   delayListHead = delayListHead->nextTCB;
   delayListHead->prevTCB = ((void *) 0);
   itr = delayListHead;
   while(1){
    itr->delayCount -= deltaDelay;
    if(itr->nextTCB == ((void *) 0)){
     deltaDelay = 0;
     break;
    }
    itr = itr->nextTCB;
   }
  }else{
   delayListHead = ((void *) 0);
   deltaDelay = 0;
   keepGoing = 0;
  }




  if(readyListHead == ((void *) 0)){
   readyListHead = moveOutOfDelayList;
   readyListHead->prevTCB = ((void *) 0);
   readyListHead->nextTCB = ((void *) 0);

   YKExitMutex;
   return;
  }

  itr = readyListHead;
  while(1){
   if(itr->taskPriority >= moveOutOfDelayList->taskPriority){
    if(itr == readyListHead){

     itr->prevTCB = moveOutOfDelayList;
     moveOutOfDelayList->nextTCB = itr;
     moveOutOfDelayList->prevTCB = ((void *) 0);
     readyListHead = moveOutOfDelayList;
     break;

    }else{
     temp = itr->prevTCB;
     itr->prevTCB = moveOutOfDelayList;
     moveOutOfDelayList->nextTCB = itr;
     moveOutOfDelayList->prevTCB = temp;
     temp->nextTCB = moveOutOfDelayList;
     break;
    }
   }
   if(itr->nextTCB == ((void *) 0)){
    itr->nextTCB = moveOutOfDelayList;
    moveOutOfDelayList->prevTCB = itr;
    moveOutOfDelayList->nextTCB = ((void *) 0);
    break;

   }
   itr = itr->nextTCB;
  }
  if(delayListHead->delayCount > 0 || !keepGoing){
   break;
  }
 }

 YKExitMutex;
}

YKSEM* YKSemCreate(int initialValue){
 YKSEM* returnValue;
 YKEnterMutex();
 YKSEMArray[YKSEMNextFree].value = initialValue;
 YKSEMNextFree++;
 returnValue = (YKSEM*)&(YKSEMArray[YKSEMNextFree - 1]);
 YKExitMutex();
 return returnValue;

}


void YKSemPend(YKSEM *semaphore){
 TCB* itr = pendingListHead;
 YKEnterMutex();






 if(semaphore->value > 0){
  semaphore->value--;
  YKExitMutex();
  return;
 }

 runningTCB->pendingOn = semaphore;


 if(runningTCB->nextTCB == ((void *) 0) && runningTCB->prevTCB == ((void *) 0)){
  printString("IDLE task should not call YKSemPend!\r\n)");
  exit(0);
 }else if(runningTCB == readyListHead){
  readyListHead = runningTCB->nextTCB;
  readyListHead->prevTCB = ((void *) 0);
 }else if(runningTCB->nextTCB == ((void *) 0)){
  runningTCB->prevTCB->nextTCB = ((void *) 0);
 }else{
  runningTCB->prevTCB->nextTCB = runningTCB->nextTCB;
  runningTCB->nextTCB->prevTCB = runningTCB->prevTCB;
 }


 if(pendingListHead == ((void *) 0)){
  pendingListHead = runningTCB;
  pendingListHead->prevTCB = ((void *) 0);
  pendingListHead->nextTCB = ((void *) 0);

  YKScheduler(0);
  semaphore->value--;
  YKExitMutex();
  return;
 }

 while(1){
  if(itr->nextTCB == ((void *) 0)){
   itr->nextTCB = runningTCB;
   runningTCB->prevTCB = itr;
   runningTCB->nextTCB = ((void *) 0);
   break;
  }
  itr = itr->nextTCB;
 }

 YKScheduler(0);
 semaphore->value--;
 YKExitMutex();
}

void YKSemPost(YKSEM *semaphore){
 TCB* itr;
 TCB* itr2;
 TCB* temp;
 TCB* temp2;
 int done = 0;
 YKEnterMutex();






 semaphore->value++;



 if(pendingListHead == ((void *) 0)){
  YKExitMutex();
  return;
 }

 while(1){
  itr = pendingListHead;
  while(1){
   if(itr == ((void *) 0)){
    done = 1;
    break;
   }
   if(itr->pendingOn->value > 0){

    if(itr->nextTCB == ((void *) 0) && itr->prevTCB == ((void *) 0)){
     pendingListHead = ((void *) 0);
    }else if(itr == pendingListHead){
     pendingListHead = itr->nextTCB;
     pendingListHead->prevTCB = ((void *) 0);
    }else if(itr->nextTCB == ((void *) 0)){
     itr->prevTCB->nextTCB = ((void *) 0);
    }else{
     itr->prevTCB->nextTCB = itr->nextTCB;
     itr->nextTCB->prevTCB = itr->prevTCB;
    }

    temp2 = itr;
    itr2 = readyListHead;
    while(1){
     if(itr2->taskPriority >= itr->taskPriority){
      if(itr2 == readyListHead){
       itr2->prevTCB = itr;
       itr->nextTCB = itr2;
       itr->prevTCB = ((void *) 0);
       readyListHead = itr;
       break;

      }else{
       temp = itr2->prevTCB;
       itr2->prevTCB = itr;
       itr->nextTCB = itr2;
       itr->prevTCB = temp;
       temp->nextTCB = itr;
       break;
      }
     }
     if(itr2->nextTCB == ((void *) 0)){
      itr2->nextTCB = itr;
      itr->prevTCB = itr2;
      itr->nextTCB = ((void *) 0);
      break;

     }
     itr2 = itr2->nextTCB;
    }
    itr = temp2;
   }
   itr = itr->nextTCB;
  }
  if(done){
   break;
  }
 }

 if(ISRDepth == 0){
  YKScheduler(0);
  YKExitMutex();
  return;

 }
 YKExitMutex();
}


YKQ *YKQCreate(void **start, unsigned size){
 int i;

 for(i = 0; i < 15; i++){
  if(!YKQArray[i].inUse){
   YKQArray[i].inUse = 1;
   break;
  }
 }
 YKQArray[i].size = size;
 YKQArray[i].start = start;





 return &YKQArray[i];
}


static int subIndex(int index, unsigned size){
 if((index - 1) < 0){
  return size - 1;
 }
 return index - 1;
}

static int addIndex(int index, unsigned size){
 if((index + 1) >= size){
  return 0;
 }
 return index + 1;
}

static int isQueueEmpty(YKQ* queue){
 if(addIndex(queue->front, queue->size) == queue->rear){

  return 1;
 }else{
  return 0;
 }
}
static void writeToAddress(void* data, void * addr){

 int volatile * const p_reg = (int*)addr;







 *p_reg = data;

}

static int readFromAddress(int addr){
 int *p = (int*)addr;
 return *p;

}


static void pushOnQueue(YKQ* queue, int* success, void* message){
 if(addIndex(queue->rear, queue->size) == queue->front){

  *success = 0;
  return;
 }

 writeToAddress(message, (int)queue->start + queue->rear*sizeof(void*));

 queue->rear = addIndex(queue->rear, queue->size);
 *success = 1;
 return;
}


static void popOffQueue(YKQ* queue, int* success, void** result){
 int* temp;
 if(queue->front == queue->rear){

  *success = 0;
  return;
 }

 *result = (void*)readFromAddress((int)queue->start + queue->front*sizeof(void*));







 queue->front = addIndex(queue->front, queue->size);
 *success = 1;
 return;
}

static void printQueue(YKQ * queue){
 printString("Queue contents: id: ");
 printInt(queue->id);
 printString(" size: ");
 printInt(queue->size);
 printString(" front: ");
 printInt(queue->front);
 printString(" rear: ");
 printInt(queue->rear);
 printString(" inUse: ");
 printInt(queue->inUse);
 printString(" Data: ");
 printInt((int)queue->start);
 printString("\r\n");
}

void *YKQPend(YKQ *queue){
 void * tempMessage;
 int success;
 YKEnterMutex();




 if(!queue->inUse){
  printString("Trying to use a non initialized queue!!!!\r\n");
   exit(0);
 }
 popOffQueue(queue, &success, &tempMessage);

 if(!success){





  queue->numberPendingOn++;
  YKSemPend(queue->semaphore);
  popOffQueue(queue, &success, &tempMessage);
  if(!success){
   printString("Failed to pop even after pending!!!!\r\n");
   exit(0);
  }
 }


 YKExitMutex();
 return tempMessage;

}

int YKQPost(YKQ *queue, void *msg){



 int success;
 YKEnterMutex();






 if(!queue->inUse){
  printString("Trying to use a non initialized queue!!!!\r\n");
   exit(0);
 }
 pushOnQueue(queue, &success, msg);
 if(success){

  if(queue->numberPendingOn > 0){
   queue->numberPendingOn--;
   YKSemPost(queue->semaphore);
  }
  if(ISRDepth == 0){
   YKScheduler(0);
  }
  return 1;
 }

 if(ISRDepth == 0){
  YKScheduler(0);
 }
 return 0;
}

YKEVENT *YKEventCreate(unsigned initialValue){
 int i;

 for(i = 0; i < 15; i++){
  if(!YKEVENTArray[i].inUse){
   YKEVENTArray[i].inUse = 1;
   break;
  }
 }
 YKEVENTArray[i].value = initialValue;
 return &YKEVENTArray[i];
}

static int meetsConditions(YKEVENT* event, unsigned eventMask, int waitMode){
 unsigned valueAfterMask = event->value & eventMask;
 int conditionMet;
 switch(waitMode){
  case 1:
   conditionMet = valueAfterMask == eventMask;
  break;
  case 0:
   conditionMet = valueAfterMask;
  break;
  default:
   printString("Reached default in switch\r\n");
   exit(0);
  break;
 }

 return conditionMet;


}


unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode){
 TCB* itr;



 YKEnterMutex();
 if(meetsConditions(event, eventMask, waitMode)){



  YKExitMutex();
  return event->value;
 }
 runningTCB->eventMask = eventMask;
 runningTCB->waitMode = waitMode;



 if(runningTCB == readyListHead){
  readyListHead = runningTCB->nextTCB;
  readyListHead->prevTCB = ((void *) 0);
 }else if(runningTCB->nextTCB == ((void *) 0)){
  runningTCB->prevTCB->nextTCB = ((void *) 0);
 }else{
  runningTCB->prevTCB->nextTCB = runningTCB->nextTCB;
  runningTCB->nextTCB->prevTCB = runningTCB->prevTCB;
 }



 if(event->eventPendingListHead == ((void *) 0)){
  event->eventPendingListHead = runningTCB;
  event->eventPendingListHead->prevTCB = ((void *) 0);
  event->eventPendingListHead->nextTCB = ((void *) 0);
  if(isRunning){
   YKScheduler(0);
  }
  YKExitMutex();
  return event->value;
 }
 itr = event->eventPendingListHead;
 while(1){
  if(itr->nextTCB == ((void *) 0)){
   itr->nextTCB = runningTCB;
   runningTCB->prevTCB = itr;
   runningTCB->nextTCB = ((void *) 0);
   if(isRunning){
    YKScheduler(0);
   }
   break;

  }
  itr = itr->nextTCB;
 }
 YKExitMutex();
 return event->value;
}

void YKEventSet(YKEVENT *event, unsigned eventMask){
 TCB* itr;
 TCB* temp;
 TCB* temp2;
 TCB* itr2;
 int removedOne;
 int done;
 YKEnterMutex();






 event->value = event->value | eventMask;


 if(event->eventPendingListHead == ((void *) 0)){



  if(ISRDepth == 0){

   YKScheduler(0);
   YKExitMutex();
   return;
  }
  YKExitMutex();
  return;
 }

 while(1){
  itr = event->eventPendingListHead;
  while(1){
   removedOne = 0;
   if(itr == ((void *) 0)){
    done = 1;
    break;
   }

   if(meetsConditions(event, itr->eventMask, itr->waitMode)){

    if(itr->nextTCB == ((void *) 0) && itr->prevTCB == ((void *) 0)){
     event->eventPendingListHead = ((void *) 0);
    }else if(itr == event->eventPendingListHead){
     event->eventPendingListHead = itr->nextTCB;
     event->eventPendingListHead->prevTCB = ((void *) 0);
    }else if(itr->nextTCB == ((void *) 0)){
     itr->prevTCB->nextTCB = ((void *) 0);
    }else{
     itr->prevTCB->nextTCB = itr->nextTCB;
     itr->nextTCB->prevTCB = itr->prevTCB;
    }

    temp2 = itr;
    itr2 = readyListHead;
    while(1){
     if(itr2->taskPriority >= itr->taskPriority){
      if(itr2 == readyListHead){
       itr2->prevTCB = itr;
       itr->nextTCB = itr2;
       itr->prevTCB = ((void *) 0);
       readyListHead = itr;
       break;

      }else{
       temp = itr2->prevTCB;
       itr2->prevTCB = itr;
       itr->nextTCB = itr2;
       itr->prevTCB = temp;
       temp->nextTCB = itr;
       break;
      }
     }
     if(itr2->nextTCB == ((void *) 0)){
      itr2->nextTCB = itr;
      itr->prevTCB = itr2;
      itr->nextTCB = ((void *) 0);
      break;

     }
     itr2 = itr2->nextTCB;
    }
    itr = temp2;
    removedOne = 1;
   }

   itr = itr->nextTCB;
   if(removedOne){
    itr = event->eventPendingListHead;
   }
  }
  if(done){
   break;
  }
 }

 if(ISRDepth == 0){
  YKScheduler(0);
  YKExitMutex();
  return;

 }
 YKExitMutex();
 return;

}

void YKEventReset(YKEVENT *event, unsigned eventMask){
 YKEnterMutex();



 event->value = event->value & (~eventMask);
 YKExitMutex();
}
