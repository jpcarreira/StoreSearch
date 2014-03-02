//
//  Search.h
//  StoreSearch
//
//  Created by João Carreira on 02/03/14.
//  Copyright (c) 2014 João Carreira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSObject

@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, readonly, strong) NSMutableArray *searchResults;

-(void)performSearchForText:(NSString *)text category:(NSInteger *)category;

@end
