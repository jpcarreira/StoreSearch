//
//  SearchResult.h
//  StoreSearch
//
//  Created by João Carreira on 19/02/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

// these properties use 'copy' instead of 'strong' as we're dealing with NSString
// (a 'copy' will first make a copy of the object and then will treat it as 'strong')
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *artistName;
@property(nonatomic, copy) NSString *artworkURL60;
@property(nonatomic, copy) NSString *artworkURL100;
@property(nonatomic, copy) NSString *storeURL;
@property(nonatomic, copy) NSString *kind;
@property(nonatomic, copy) NSString *currency;
@property(nonatomic, copy) NSDecimalNumber *price;
@property(nonatomic, copy) NSString *genre;

-(NSComparisonResult)compareName:(SearchResult *)other;

@end
