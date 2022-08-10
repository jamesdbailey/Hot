//
//  iokit-bridging-header.h
//  ThermALL
//
//  Created by jdb on 8/10/22.
//

#ifndef iokit_bridging_header_h
#define iokit_bridging_header_h

#import <IOKit/hidsystem/IOHIDEventSystemClient.h>

typedef struct __IOHIDEvent *IOHIDEventRef;
typedef struct __IOHIDServiceClient *IOHIDServiceClientRef;

IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
int IOHIDEventSystemClientSetMatchingMultiple(IOHIDEventSystemClientRef client, CFArrayRef match);
IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef, int64_t , int32_t, int64_t);
CFTypeRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef service, CFStringRef key);
double IOHIDEventGetFloatValue(IOHIDEventRef event, int32_t field);
CFStringRef __CFStringMakeConstantString();

#endif /* iokit_bridging_header_h */
