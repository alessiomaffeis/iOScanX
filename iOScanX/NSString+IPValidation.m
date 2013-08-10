//
//  NSString+IPValidation.m
//  iOScanX
//
//  Created by Alessio Maffeis on 10/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "NSString+IPValidation.h"

#include <arpa/inet.h>

@implementation NSString (IPValidation)

- (BOOL)isValidIPAddress
{
    const char *utf8 = [self UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);    
    return (success == 1 ? YES : NO);
}

@end