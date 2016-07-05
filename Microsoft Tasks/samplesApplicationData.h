//
//  samplesApplicationData.h
//  Microsoft Tasks for Consumers
//
//  Created by Brandon Werner on 9/14/15.
//  Copyright © 2015 Microsoft. All rights reserved.
//

#ifndef samplesApplicationData_h
#define samplesApplicationData_h

#import <Foundation/Foundation.h>
#import "samplesTaskItem.h"
#import "samplesPolicyData.h"
#import "NXOAuth2.h"

@interface SamplesApplicationData : NSObject

@property (strong) NSString* taskWebApiUrlString;
@property (strong) NSString* authority;
@property (strong) NSString* token;
@property (strong) NSString* login;
@property (strong) NSString* keychain;
@property (strong) NSString* clientId;
@property (strong) NSString* resourceId;
@property NSMutableArray* scopes;
@property NSMutableArray* additionalScopes;
@property (strong) NSString* redirectUriString;
@property (strong) NSString* correlationId;
@property (strong) NSString* faceBookSignInPolicyId;
@property (strong) NSString* emailSignInPolicyId;
@property (strong) NSString* emailSignUpPolicyId;
@property BOOL fullScreen;
@property BOOL showClaims;
@property (strong) NSString* currentPolicyId;

+(id) getInstance;

@end


#endif /* samplesApplicationData_h */
