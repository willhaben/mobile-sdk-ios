/*   Copyright 2019 APPNEXUS INC
 
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

#import "ANAdFetcherResponse.h"
#import "ANAdProtocol.h"
#import "ANUniversalTagAdServerResponse.h"

//#import "ANAdView.h"
#import "ANNativeAdRequest.h"
#import "ANMultiAdRequest.h"




@interface ANAdFetcherBase : NSObject

@property (nonatomic, readwrite, strong, nullable)  NSMutableArray<id>    *ads;
@property (nonatomic, readwrite, strong, nullable)  NSString              *noAdUrl;

@property (nonatomic, readwrite)                    BOOL  isFetcherLoading;
@property (nonatomic, readwrite, strong, nullable)  id    adObjectHandler;

@property (nonatomic, readwrite, weak, nullable)    id                  delegate;
@property (nonatomic, readwrite, weak, nullable)    ANMultiAdRequest   *fetcherMARManager;
@property (nonatomic, readwrite, weak, nullable)    ANMultiAdRequest   *adunitMARManager;


//
- (nonnull instancetype)init;
- (void)setup;
- (void)requestAd;

- (void)fireResponseURL:(nullable NSString *)responseURLString
                 reason:(ANAdResponseCode)reason
               adObject:(nonnull id)adObject;


- (void)prepareForWaterfallWithAdServerResponseTag: (nullable NSDictionary<NSString *, id> *)ads;

- (void) beginWaterfallWithAdObjects:(nonnull NSMutableArray<id> *)ads;


@end
