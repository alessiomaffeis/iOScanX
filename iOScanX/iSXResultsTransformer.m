//
//  iSXResultsTransformer.m
//  iOScanX
//
//  Created by Alessio Maffeis on 01/10/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXResultsTransformer.h"

@implementation iSXResultsTransformer

+ (Class)transformedValueClass
{
    return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    NSLog(@"Ciao");
    NSMutableAttributedString *formattedResults = [[[NSMutableAttributedString alloc] init] autorelease];
    
    for (NSString *evalID in value) {
        [formattedResults appendAttributedString:[[[NSAttributedString alloc]
                                                   initWithString:evalID
                                                   attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:11]}] autorelease]];
        [formattedResults appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": \t%@\n",[value objectForKey:evalID]]] autorelease]];
    }
    return formattedResults;
}


@end
