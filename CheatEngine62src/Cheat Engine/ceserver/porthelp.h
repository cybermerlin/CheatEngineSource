/*
 * porthelp.h
 *
 *  Created on: Jul 21, 2011
 *      Author: erich
 */

#ifndef PORTHELP_H_
#define PORTHELP_H_

typedef unsigned int HANDLE; //just an int, in case of a 32-bit ce version and a 64-bit linux version I can not give pointers, so use ID's for handles
typedef unsigned int DWORD;

#define TH32CS_SNAPPROCESS  0x2

#define PAGE_NOACCESS 1
#define PAGE_READONLY 2
#define PAGE_READWRITE 4
#define PAGE_WRITECOPY 8
#define PAGE_EXECUTE 16
#define PAGE_EXECUTE_READ 32
#define PAGE_EXECUTE_READWRITE 64

typedef enum {htEmpty=0, htProcesHandle, htThreadHandle, htTHSProcess, htTHSModule} handleType;
typedef int BOOL;

#define TRUE 1
#define FALSE 0


int CreateHandleFromPointer(void *p, handleType type);
void *GetPointerFromHandle(int handle);
handleType GetHandleType(int handle);
void RemoveHandle(int handle);

#endif /* PORTHELP_H_ */
