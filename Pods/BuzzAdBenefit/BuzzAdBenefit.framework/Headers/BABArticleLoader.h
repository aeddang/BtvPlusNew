//
//  BABArticleLoader.h
//  BAB
//
//  Created by Jaehee Ko on 18/03/2019.
//  Copyright © 2019 Buzzvil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BABArticle.h"

@class BABError;

NS_ASSUME_NONNULL_BEGIN

@interface BABArticleLoader : NSObject

@property (nonatomic, copy, readonly) NSString *unitId;
@property (nonatomic, strong, nullable) NSArray<BABArticleCategoryName> *categories;
@property (nonatomic, readonly) BOOL isLoading;

- (instancetype)initWithUnitId:(NSString *)unitId;
- (void)loadArticlesWithSize:(NSUInteger)size onSuccess:(void (^)(NSArray<BABArticle *> *articles))onSuccess onFailure:(void (^)(BABError *error))onFailure;
- (void)loadNextArticlesWithSize:(NSUInteger)size onSuccess:(void (^)(NSArray<BABArticle *> *articles))onSuccess onFailure:(void (^)(BABError *error))onFailure;

@end

NS_ASSUME_NONNULL_END
