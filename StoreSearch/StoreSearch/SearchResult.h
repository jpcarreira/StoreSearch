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

@end
