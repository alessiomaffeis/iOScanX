//
//  iSXMetricsTransformer.m
//  iOScanX
//
//  Created by Alessio Maffeis on 03/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXMetricsTransformer.h"

@implementation iSXMetricsTransformer

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
    NSMutableAttributedString *formattedMetrics = [[[NSMutableAttributedString alloc] init] autorelease];
    
    for (NSDictionary *metric in value) {
        [formattedMetrics appendAttributedString:[[[NSAttributedString alloc]
                                                  initWithString:[metric objectForKey:@"name"]
                                                  attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:11]}] autorelease]];
        [formattedMetrics appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": \t%@\n",[metric objectForKey:@"description"]]] autorelease]];
    }
    return formattedMetrics;
}

@end
