/*   Copyright 2014 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "ANAdResponseInfo.h"




@interface ANAdFetcherResponse : NSObject

@property (nonatomic, readonly, assign, getter=isSuccessful) BOOL successful;
@property (nonatomic, readonly, strong, nonnull) id  adObject;
@property (nonatomic, readonly, strong, nullable) id  adObjectHandler;
@property (nonatomic, readonly, strong, nullable) NSError *error;

@property (nonatomic, readwrite, strong, nullable)  ANAdResponseInfo  *adResponseInfo;


//
+ (nonnull ANAdFetcherResponse *)responseWithError:(nonnull NSError *)error;

+ (nonnull ANAdFetcherResponse *)responseWithAdObject: (nonnull id)adObject
                           andAdObjectHandler: (nullable id)adObjectHandler;

//
- (nonnull instancetype)initAdResponseFailWithError:(nonnull NSError *)error;

- (nonnull instancetype)initAdResponseSuccessWithAdObject: (nonnull id)adObject
                               andAdObjectHandler: (nullable id)adObjectHandler;


@end
