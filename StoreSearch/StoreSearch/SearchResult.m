//
//  SearchResult.m
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

// compares name between 2 SearchResult objects
-(NSComparisonResult)compareName:(SearchResult *)other
{
    return [self.name localizedStandardCompare:other.name];
}

// "translates" 'kind' from iTunes store to user-friendly text
-(NSString *)kindForDisplay
{
    if([self.kind isEqualToString:@"album"])
    {
        return @"Album";
    }
    else if([self.kind isEqualToString:@"audiobook"])
    {
        return @"Audio Book";
    }
    else if([self.kind isEqualToString:@"book"])
    {
        return @"Book";
    }
    else if([self.kind isEqualToString:@"ebook"])
    {
        return @"E-Book";
    }
    else if([self.kind isEqualToString:@"feature-movie"])
    {
        return @"Movie";
    }
    else if([self.kind isEqualToString:@"music-video"])
    {
        return @"Music Video";
    }
    else if([self.kind isEqualToString:@"software"])
    {
        return @"App";
    }
    else if([self.kind isEqualToString:@"song"])
    {
        return @"Song";
    }
    else if([self.kind isEqualToString:@"tv-episode"])
    {
        return @"TV Episode";
    }
    else
    {
        return self.kind;
    }
}

@end
