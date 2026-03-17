//
//  SMPSkipScreenOptions.h
//  SumupSDK
//
//  Created by Lukas Mollidor on 08.06.17.
//  Copyright (c) 2017 SumUp Payments Limited. All rights reserved.
//

#ifndef SMPSkipScreenOptions_h
#define SMPSkipScreenOptions_h

typedef NS_OPTIONS(NSUInteger, SMPSkipScreenOptions) {
    SMPSkipScreenOptionNone = 0,
    SMPSkipScreenOptionSuccess = 1 << 0,
};

#endif
