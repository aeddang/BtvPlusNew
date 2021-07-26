//
//  BABLogger.h
//  BAB
//
//  Created by Jaehee Ko on 16/11/2018.
//  Copyright © 2018 Jaehee Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BuzzAdBenefit.h"

#define BABLog(fmt, ...) if (BuzzAdBenefit.sharedInstance.config.logging) NSLog(@"[BuzzAdBenefit] %@", [NSString stringWithFormat:(fmt), ##__VA_ARGS__]);
