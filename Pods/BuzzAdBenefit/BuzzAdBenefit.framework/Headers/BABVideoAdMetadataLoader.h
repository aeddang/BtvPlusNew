//
//  BABVideoAdMetadataLoader.h
//  BAB
//
//  Created by Jaehee Ko on 17/01/2019.
//  Copyright © 2019 Buzzvil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BABError;
@class BABCreative;

@interface BABVideoAdMetadataLoader : NSObject

- (instancetype)initWithVideoCreative:(BABCreative *)videoCreative;
- (void)loadMetadataWithOnSuccess:(void (^)(void))onSuccess onFailure:(void (^)(BABError *error))onFailure;

@end

NS_ASSUME_NONNULL_END
