//
//  PaymentService.h
//  PaymentService
//
//  Created by Peter Qiu on 10/5/14.
//  Copyright (c) 2014 Peter Qiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionVO.h"
#import "GeneralInfoVO.h"

@interface PaymentService : NSObject
- (void)InsertTransaction:(TransactionVO *)transaction :(GeneralInfoVO*) info;
@end
