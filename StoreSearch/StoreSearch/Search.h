//
//  Search.h
//  StoreSearch
//
//  Created by João Carreira on 02/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <Foundation/Foundation.h>

// block that will allow this object to communicate with SearchViewController
// (this block returns void and accepts one parameter, the boolean)
typedef void (^SearchBlock)(BOOL success);

@interface Search : NSObject

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, readonly, strong) NSMutableArray *searchResults;

-(void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;

@end
