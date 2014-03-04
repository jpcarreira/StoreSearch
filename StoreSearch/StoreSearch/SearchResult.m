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
        return NSLocalizedString(@"Album", @"Localized kind: Album");
    }
    else if([self.kind isEqualToString:@"audiobook"])
    {
         return NSLocalizedString(@"Audio Book", @"Localized kind: Audio Book");
    }
    else if([self.kind isEqualToString:@"book"])
    {
         return NSLocalizedString(@"Book", @"Localized kind: Book");
    }
    else if([self.kind isEqualToString:@"ebook"])
    {
         return NSLocalizedString(@"E-Book", @"Localized kind: E-Book");
    }
    else if([self.kind isEqualToString:@"feature-movie"])
    {
         return NSLocalizedString(@"Movie", @"Localized kind: Movie");
    }
    else if([self.kind isEqualToString:@"music-video"])
    {
        return NSLocalizedString(@"Music Video", @"Localized kind: Music Video");
    }
    else if([self.kind isEqualToString:@"software"])
    {
         return NSLocalizedString(@"App", @"Localized kind: Software");
    }
    else if([self.kind isEqualToString:@"song"])
    {
         return NSLocalizedString(@"Song", @"Localized kind: Song");
    }
    else if([self.kind isEqualToString:@"tv-episode"])
    {
         return NSLocalizedString(@"TV Episode", @"Localized kind: TV Episode");
    }
    else
    {
        return self.kind;
    }
}

@end
