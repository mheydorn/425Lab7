#include "yakk.h"

//#define DEBUG
//#define EVENT_DEBUG

#define IDLE_STACK_SIZE 2048
unsigned YKIdleCount = 0;
struct TCB TCBArray[NUMBER_OF_TCBs];
struct YKSEM YKSEMArray[NUMBER_OF_SEMAPHORES];
struct YKQ YKQArray[NUMBER_OF_QUEUES];
struct YKEVENT YKEVENTArray[NUMBER_OF_EVENTS];
unsigned int YKSEMNextFree = 0;

int IdleStk[IDLE_STACK_SIZE];
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

TCB * readyListHead = NULL;
TCB * pendingListHead = NULL;
TCB * delayListHead = NULL;
TCB * queuePendingListHead = NULL;

static void printDelayCounts(){
	TCB * itr = delayListHead;
	while(1){
		if(itr == NULL){
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
		if(itr == NULL){
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
	//printString("First dispatch to task ");
	//printInt(readyListHead->id);	
	//printString("\r\n");
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
	for(i= 0; i < NUMBER_OF_TCBs ; i++){
		TCBArray[i].inUse = 0;
		TCBArray[i].id = i;
	}
	for(i = 0; i < NUMBER_OF_QUEUES; i++){
		YKQArray[i].inUse = 0;
		YKQArray[i].id = i;
		YKQArray[i].start = NULL;
		YKQArray[i].semaphore = YKSemCreate(0);
		YKQArray[i].front = 0;
		YKQArray[i].rear = 0;
		YKQArray[i].numberPendingOn = 0;
	}
	for(i= 0; i < NUMBER_OF_EVENTS ; i++){
		YKEVENTArray[i].inUse = 0;
		YKEVENTArray[i].id = i;
		YKEVENTArray[i].eventPendingListHead = NULL;
	}
	YKNewTask(YKIdleTask, (void *)&IdleStk[IDLE_STACK_SIZE] , 100);
	YKExitMutex();
}

void YKNewTask(void(*task)(void), void * taskStack, unsigned char priority){
	int i = 0;
	TCB* itr = readyListHead;
	TCB* temp;
	
	
	//Get the next avaliable TCB
	YKEnterMutex();
	for(i = 0; i < NUMBER_OF_TCBs; i++){
		if(!TCBArray[i].inUse){
			break;
		}
	}
	/*
	printString("Creating task ");
	printInt(i);
	printString("\r\n");
	*/

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

	//Put the tcb in the right spot in the ready list
	if(readyListHead == NULL){
		readyListHead = &TCBArray[i];
		readyListHead->prevTCB = NULL;
		readyListHead->nextTCB = NULL;
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
				TCBArray[i].prevTCB = NULL;		
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

		if(itr->nextTCB == NULL){
			itr->nextTCB = &TCBArray[i];
			TCBArray[i].prevTCB = itr;
			TCBArray[i].nextTCB = NULL;
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

//Should only be called in a mutex
void YKScheduler(int calledFromISR){
	nextTCB	= readyListHead;
	
	//////if(nextTCB != runningTCB){
	/*
	printString("About to disbatch task ");
	printInt(nextTCB->id);	
	printString(" from task ");
	printInt(runningTCB->id);	
	printString("Ready list ");printReadyList();
	printString("\r\n");
	*/
	

//}
	if(nextTCB == runningTCB){
		if(!calledFromISR){//Don't exit mutex if we're going back to an ISR!
			YKExitMutex();
		}
		return;
	}
	YKCtxSwCount++;
	dispatcher();
	/*
	printString("Using dipatcher\r\n");

	printString("Task  ");
	printInt(runningTCB->id);	
	printString(" is running\r\n");
	*/
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

	
	//printString("Delay called ");
	//printDelayCounts();
	/*
	printString("Delay called from ");
	printInt(runningTCB->id);
	printString("\r\n");
	*/

	YKEnterMutex();
	runningTCB->delayCount = count;
	
	//Get this TCB out of the ready list!
	//if(runningTCB->nextTCB == NULL && runningTCB->prevTCB == NULL){
	//	printString("IDLE task should not call delay!\r\n)");
	//	exit(0);
	if(runningTCB == readyListHead){
		readyListHead = runningTCB->nextTCB;
		readyListHead->prevTCB = NULL;
	}else if(runningTCB->nextTCB == NULL){
		runningTCB->prevTCB->nextTCB = NULL;
	}else{
		runningTCB->prevTCB->nextTCB = runningTCB->nextTCB;
		runningTCB->nextTCB->prevTCB = runningTCB->prevTCB;
	}



	//Put task in delay list
	if(delayListHead == NULL){
		delayListHead = runningTCB;
		delayListHead->prevTCB = NULL;
		delayListHead->nextTCB = NULL;
		YKScheduler(0);
		return;
	}


	//Decrement everything in delay task exept for the head
	while(1){
		if(itr == NULL){
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
				runningTCB->prevTCB = NULL;		
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

		if(itr->nextTCB == NULL){
			itr->nextTCB = runningTCB;
			runningTCB->prevTCB = itr;
			runningTCB->nextTCB = NULL;
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
	//for(i = 0; i < 100; i++){

		//i++;

	//}

	YKEnterMutex();
	YKTickNum++;
	/*
	printString("Here's the delay list ");
	printDelayCounts();
	if(delayListHead == NULL){
		YKExitMutex();
		return;
	}
	*/

	delayListHead->delayCount--;
	deltaDelay++;
	if(delayListHead->delayCount != 0){
		YKExitMutex();
		return;
	}
	//The head has expired

	//While the head is still expired
	while(1){
		itr = delayListHead;
		moveOutOfDelayList = delayListHead;

		if(delayListHead->nextTCB != NULL){
			delayListHead = delayListHead->nextTCB;
			delayListHead->prevTCB = NULL;
			itr = delayListHead;
			while(1){
				itr->delayCount -= deltaDelay;
				if(itr->nextTCB == NULL){
					deltaDelay = 0;
					break;
				}
				itr = itr->nextTCB;
			}
		}else{
			delayListHead = NULL;
			deltaDelay = 0;
			keepGoing = 0;
		}



		//Put the tcb in the right spot in the ready list
		if(readyListHead == NULL){
			readyListHead = moveOutOfDelayList;
			readyListHead->prevTCB = NULL;
			readyListHead->nextTCB = NULL;

			YKExitMutex;
			return;
		}

		itr = readyListHead;
		while(1){
			if(itr->taskPriority >= moveOutOfDelayList->taskPriority){
				if(itr == readyListHead){

					itr->prevTCB = moveOutOfDelayList;
					moveOutOfDelayList->nextTCB = itr;
					moveOutOfDelayList->prevTCB = NULL;		
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
			if(itr->nextTCB == NULL){
				itr->nextTCB = moveOutOfDelayList;
				moveOutOfDelayList->prevTCB = itr;
				moveOutOfDelayList->nextTCB = NULL;
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
	/*
	printString("Task ");
	printInt(runningTCB->id);
	printString(" is PENDING\r\n");
	*/
	
	if(semaphore->value > 0){
		semaphore->value--;
		YKExitMutex();	
		return;
	}

	runningTCB->pendingOn = semaphore;

	//Get this TCB out of the ready list!
	if(runningTCB->nextTCB == NULL && runningTCB->prevTCB == NULL){
		printString("IDLE task should not call YKSemPend!\r\n)");
		exit(0);
	}else if(runningTCB == readyListHead){
		readyListHead = runningTCB->nextTCB;
		readyListHead->prevTCB = NULL;
	}else if(runningTCB->nextTCB == NULL){
		runningTCB->prevTCB->nextTCB = NULL;
	}else{
		runningTCB->prevTCB->nextTCB = runningTCB->nextTCB;
		runningTCB->nextTCB->prevTCB = runningTCB->prevTCB;
	}

	//Put task in pending list
	if(pendingListHead == NULL){
		pendingListHead = runningTCB;
		pendingListHead->prevTCB = NULL;
		pendingListHead->nextTCB = NULL;
		
		YKScheduler(0);
		semaphore->value--;	
		YKExitMutex();	
		return;
	}

	while(1){
		if(itr->nextTCB == NULL){
			itr->nextTCB = runningTCB;
			runningTCB->prevTCB = itr;
			runningTCB->nextTCB = NULL;
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

	/*
	printString("Task ");
	printInt(runningTCB->id);
	printString(" is POSTING\r\n");
	*/
	semaphore->value++;

	//Iterrate through pending list to remove TCBs pending and put them in ready list
	
	if(pendingListHead == NULL){
		YKExitMutex();	
		return;
	}
	//For each time through pending list
	while(1){
		itr = pendingListHead;
		while(1){
			if(itr == NULL){
				done = 1;
				break;			
			}
			if(itr->pendingOn->value > 0){
				//Get this TCB out of the pending list!
				if(itr->nextTCB == NULL && itr->prevTCB == NULL){
					pendingListHead = NULL;
				}else if(itr == pendingListHead){
					pendingListHead = itr->nextTCB;
					pendingListHead->prevTCB = NULL;
				}else if(itr->nextTCB == NULL){
					itr->prevTCB->nextTCB = NULL;
				}else{
					itr->prevTCB->nextTCB = itr->nextTCB;
					itr->nextTCB->prevTCB = itr->prevTCB;
				}
				//And put it into the ready list!
				temp2 = itr;
				itr2 = readyListHead;
				while(1){
					if(itr2->taskPriority >= itr->taskPriority){
						if(itr2 == readyListHead){
							itr2->prevTCB = itr;
							itr->nextTCB = itr2;
							itr->prevTCB = NULL;		
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
					if(itr2->nextTCB == NULL){
						itr2->nextTCB = itr;
						itr->prevTCB = itr2;
						itr->nextTCB = NULL;
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
	//Get next avaliable queue
	for(i = 0; i < NUMBER_OF_QUEUES; i++){
		if(!YKQArray[i].inUse){
			YKQArray[i].inUse = 1;
			break;
		}
	}
	YKQArray[i].size = size;
	YKQArray[i].start = start;
	#ifdef QUEUE_DEBUG
		printString("Creating Queue id is ");
		printInt((int)i);
		printString("\r\n");
	#endif
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
		//Queue is empty
		return 1;
	}else{
		return 0;
	}
}	
static void writeToAddress(void* data, void * addr){

	int volatile * const p_reg = (int*)addr;
	#ifdef QUEUE_DEBUG
		printString("Writing to address ");
		printInt((int)addr);
		printString(" the data ");
		printInt(*(int*)data);
		printString("\r\n");
	#endif
	*p_reg = data;

}

static int readFromAddress(int addr){
	int *p = (int*)addr;
	return *p;

}

//success 1 means not full, 0 means full 
static void pushOnQueue(YKQ* queue, int* success, void* message){
	if(addIndex(queue->rear, queue->size) == queue->front){
		//Queue is full
		*success = 0;
		return;
	}
	//Put data in at rear
	writeToAddress(message, (int)queue->start + queue->rear*sizeof(void*));

	queue->rear = addIndex(queue->rear, queue->size);
	*success = 1;
	return;
}

//success 1 means not empty, 0 means empty 
static void popOffQueue(YKQ* queue, int* success, void** result){
	int* temp;
	if(queue->front == queue->rear){
		//Queue is empty
		*success = 0;
		return;
	}
	//Return data at front
	*result = (void*)readFromAddress((int)queue->start + queue->front*sizeof(void*));
	#ifdef QUEUE_DEBUG
		printString("Just read from address ");
		printInt((int)queue->start + queue->front*sizeof(void*));
		printString(" the data ");
		printInt((int)*result);
		printString("\r\n");
	#endif
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
	#ifdef QUEUE_DEBUG
		printString("Pend called\r\n");
		printQueue(queue);
	#endif
	if(!queue->inUse){
		printString("Trying to use a non initialized queue!!!!\r\n");
			exit(0);
	}
	popOffQueue(queue, &success, &tempMessage);	
	//If queue is empty
	if(!success){
		#ifdef QUEUE_DEBUG
			printString("Yo queue is empty!\r\n");
			//Queue was empty, pend until queue is avaliable
			printString("queue is emptyo\r\n");
		#endif
		queue->numberPendingOn++;	
		YKSemPend(queue->semaphore);
		popOffQueue(queue, &success, &tempMessage);	
		if(!success){
			printString("Failed to pop even after pending!!!!\r\n");
			exit(0);
		}
	}
	//What if two tasks pend on a queue?

	YKExitMutex();
	return tempMessage;

}

int YKQPost(YKQ *queue, void *msg){
	//Start here!!
	//Push to queue
	//TODO check mutex's here
	int success;	
	YKEnterMutex();
	#ifdef QUEUE_DEBUG
		printString("Posting ");
		printInt((int)msg);
		printString(" to ");
		printQueue(queue);
	#endif
	if(!queue->inUse){
		printString("Trying to use a non initialized queue!!!!\r\n");
			exit(0);
	}
	pushOnQueue(queue, &success, msg);
	if(success){
		//Post to semaphore if anyone is pending on it
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
	//Get next avaliable event object
	for(i = 0; i < NUMBER_OF_EVENTS; i++){
		if(!YKEVENTArray[i].inUse){
			YKEVENTArray[i].inUse = 1;
			break;
		}
	}
	YKEVENTArray[i].value = initialValue;
	return &YKEVENTArray[i];
}

static int meetsConditions(YKEVENT* event, unsigned eventMask, int waitMode){
	unsigned valueAfterMask	= event->value & eventMask;
	int conditionMet;
	switch(waitMode){
		case EVENT_WAIT_ALL:
			conditionMet = valueAfterMask == eventMask;
		break;
		case EVENT_WAIT_ANY:
			conditionMet = valueAfterMask;
		break;
		default:
			printString("Reached default in switch\r\n");
			exit(0);
		break;
	}
	//If conditions are met 
	return conditionMet;


}

//Not called from ISRs
unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode){
	TCB* itr;
	#ifdef EVENT_DEBUG
		printString("YKEventPend called\r\n");
	#endif
	YKEnterMutex();
	if(meetsConditions(event, eventMask, waitMode)){
		#ifdef EVENT_DEBUG
			printString("Events already set that were needed\r\n");
		#endif
		YKExitMutex();
		return event->value;
	}
	runningTCB->eventMask = eventMask;
	runningTCB->waitMode = waitMode;

	//Pend until condition are met
	//Get out of ready list
	if(runningTCB == readyListHead){
		readyListHead = runningTCB->nextTCB;
		readyListHead->prevTCB = NULL;
	}else if(runningTCB->nextTCB == NULL){
		runningTCB->prevTCB->nextTCB = NULL;
	}else{
		runningTCB->prevTCB->nextTCB = runningTCB->nextTCB;
		runningTCB->nextTCB->prevTCB = runningTCB->prevTCB;
	}
	
	
	//Get in eventPendingList for this event(doesn't matter where)
	if(event->eventPendingListHead == NULL){
		event->eventPendingListHead = runningTCB;
		event->eventPendingListHead->prevTCB = NULL;
		event->eventPendingListHead->nextTCB = NULL;
		if(isRunning){
			YKScheduler(0);
		}
		YKExitMutex();
		return event->value;
	}
	itr = event->eventPendingListHead;
	while(1){
		if(itr->nextTCB == NULL){
			itr->nextTCB = runningTCB;
			runningTCB->prevTCB = itr;
			runningTCB->nextTCB = NULL;
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

	#ifdef EVENT_DEBUG
		printString("YKEventSet called\r\n");
	#endif

	//Set all bits that are set in eventMask
	event->value = event->value | eventMask;

	//Go through this events pending TCBs, take them out and put them in ready list
	if(event->eventPendingListHead == NULL){
		#ifdef EVENT_DEBUG
			printString("No pending TCBs\r\n");
		#endif		
		if(ISRDepth == 0){
			//Not in ISR
			YKScheduler(0);
			YKExitMutex();	
			return;
		}
		YKExitMutex();	
		return;
	}
	//For each time through this events pending list (we restart everytime we take one out and we may have to take multiple out)
	while(1){
		itr = event->eventPendingListHead;
		while(1){
			removedOne = 0;
			if(itr == NULL){
				done = 1;
				break;			
			}
			//If this is one we should pull off pending list
			if(meetsConditions(event, itr->eventMask, itr->waitMode)){
				//Get this TCB out of the pending list!
				if(itr->nextTCB == NULL && itr->prevTCB == NULL){
					event->eventPendingListHead = NULL;
				}else if(itr == event->eventPendingListHead){
					event->eventPendingListHead = itr->nextTCB;
					event->eventPendingListHead->prevTCB = NULL;
				}else if(itr->nextTCB == NULL){
					itr->prevTCB->nextTCB = NULL;
				}else{
					itr->prevTCB->nextTCB = itr->nextTCB;
					itr->nextTCB->prevTCB = itr->prevTCB;
				}
				//And put it into the ready list!
				temp2 = itr;
				itr2 = readyListHead;
				while(1){
					if(itr2->taskPriority >= itr->taskPriority){
						if(itr2 == readyListHead){
							itr2->prevTCB = itr;
							itr->nextTCB = itr2;
							itr->prevTCB = NULL;		
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
					if(itr2->nextTCB == NULL){
						itr2->nextTCB = itr;
						itr->prevTCB = itr2;
						itr->nextTCB = NULL;
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
	#ifdef EVENT_DEBUG
		printString("YKEventReset called\r\n");
	#endif
	event->value = event->value & (~eventMask);
	YKExitMutex();
}



















