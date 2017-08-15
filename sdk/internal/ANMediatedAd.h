/*   Copyright 2013 APPNEXUS INC
 
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

@interface ANMediatedAd : NSObject

@property (nonatomic, readwrite, strong) NSString *className;
@property (nonatomic, readwrite, strong) NSString *param;
@property (nonatomic, readwrite, strong) NSString *width;
@property (nonatomic, readwrite, strong) NSString *height;
@property (nonatomic, readwrite, strong) NSString *adId;
@property (nonatomic, readwrite, strong) NSString *responseURL;
@property (nonatomic, readwrite, strong) NSString *auctionInfo;

@property (nonatomic, readwrite, strong) NSArray<NSString *> *impressionUrls;

@end
