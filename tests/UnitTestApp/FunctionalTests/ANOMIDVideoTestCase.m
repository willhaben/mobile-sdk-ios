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

#import <XCTest/XCTest.h>
#import "XCTestCase+ANCategory.h"
#import "SDKValidationURLProtocol.h"
#import "ANInstreamVideoAd.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANTestGlobal.h"
#import "ANAdView+PrivateMethods.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "NSURLProtocol+WKWebViewSupport.h"
#import "ANBannerAdView+ANTest.h"

static NSString   *placementID      = @"12534678";
#define  ROOT_VIEW_CONTROLLER  [UIApplication sharedApplication].keyWindow.rootViewController;
@interface ANOMIDVideoTestCase : XCTestCase<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate, SDKValidationURLProtocolDelegate, ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;

//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMIDSupportedExpecation;
@property (nonatomic, strong) XCTestExpectation *OMIDAdSessionStartedExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDGeomentryChangeExpectation;
@property (nonatomic, strong) XCTestExpectation *OMID100PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDImpressionEventExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDAdSessionFinishedExpectation;

@property (nonatomic) BOOL geometryFulfilled;
@property (nonatomic) BOOL oneHundredPercentViewableFulfilled;

@end

@implementation ANOMIDVideoTestCase

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];
}

- (void)tearDown {
    [super tearDown];
    [self.instreamVideoAd removeFromSuperview];
    self.instreamVideoAd = nil;
    [self.banner removeFromSuperview];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    self.banner = nil;
    self.OMIDSupportedExpecation = nil;
    self.OMIDAdSessionStartedExpectation = nil;
    self.OMIDGeomentryChangeExpectation = nil;
    self.OMID100PercentViewableExpectation = nil;
    self.OMIDImpressionEventExpectation = nil;
    self.OMIDAdSessionFinishedExpectation = nil;
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [NSURLProtocol unregisterClass:[SDKValidationURLProtocol class]];
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
}

#pragma mark - Test methods.

- (void)testOMIDBannerVideoInitSuccess
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDSupportedExpecation = [self expectationWithDescription:@"Didn't receive OmidSupported[true]"];
    self.OMIDAdSessionStartedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionStart event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearBannerVideoAd];
}

- (void)testOMIDBannerVideoGeometry
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDGeomentryChangeExpectation = [self expectationWithDescription:@"Didn't receive OMID geometryChange event"];
    self.geometryFulfilled = NO;
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.oneHundredPercentViewableFulfilled = NO;

    [self.banner loadAd];

    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];
    [self clearBannerVideoAd];

}



- (void)testOMIDBannerVideoImpression
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDImpressionEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Impression event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];
    [self clearBannerVideoAd];

}

- (void)testOMIDBannerVideoSessionFinish
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    self.OMIDAdSessionFinishedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionFinish event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    [self clearBannerVideoAd];
}

- (void)testOMIDInstreamVideoInitSuccess
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.OMIDSupportedExpecation = [self expectationWithDescription:@"Didn't receive OmidSupported[true]"];
      self.OMIDAdSessionStartedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionStart event"];
      [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                   handler:^(NSError *error) {
          
      }];
    [self clearInstreamVideoAd];
}

- (void)testOMIDInstreamVideoGeometry
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.OMIDGeomentryChangeExpectation = [self expectationWithDescription:@"Didn't receive OMID geometryChange event"];
    self.geometryFulfilled = NO;
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.oneHundredPercentViewableFulfilled = NO;

    [self.banner loadAd];

    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];
    [self clearInstreamVideoAd];

}



- (void)testOMIDInstreamVideoImpression
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.OMIDImpressionEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Impression event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

                                 }];
    [self clearInstreamVideoAd];

}

- (void)testOMIDInstreamVideoSessionFinish
{
    [self setupInstreamVideoAd];
    [self stubRequestWithResponse:@"OMID_VideoResponse"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.OMIDAdSessionFinishedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionFinish event"];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {

    }];
    [self clearInstreamVideoAd];
}

-(void)setupInstreamVideoAd{
    self.instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
}

-(void) setupBannerVideoAd{
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            placementId:placementID
                                                 adSize:CGSizeMake(300, 250)];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.shouldAllowVideoDemand =  YES;
    self.banner.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.banner];
}

-(void) clearBannerVideoAd{
    [self.banner removeFromSuperview];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    self.banner = nil;
}

-(void) clearInstreamVideoAd{
    [self.instreamVideoAd removeFromSuperview];
    self.instreamVideoAd = nil;
}

# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:responseName
                                                                                        ofType:@"json"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    requestStub.requestURL      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode    = 200;
    requestStub.responseBody    = baseResponse;
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

#pragma mark - ANAdDelegate.

- (void)adDidReceiveAd:(id)ad
{
    UIViewController *controller = ROOT_VIEW_CONTROLLER;
    if ([ad isKindOfClass:[ANInstreamVideoAd class]]) {
        [self.instreamVideoAd playAdWithContainer:controller.view withDelegate:self];
    }
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error
{
}

#pragma mark - ANInstreamVideoAdPlayDelegate.

- (void)adDidComplete:(nonnull id<ANAdProtocol>)ad withState:(ANInstreamVideoPlaybackStateType)state {
    
}


# pragma mark - Intercept HTTP Request Callback

- (void)didReceiveIABResponse:(NSString *)response {
    if ([response containsString:@"OmidSupported"]) {
        [self.OMIDSupportedExpecation fulfill];
    }
    
    if ([response containsString:@"sessionStart"]) {
        [self.OMIDAdSessionStartedExpectation fulfill];
    }
    
    if ([response containsString:@"geometryChange"] && !self.geometryFulfilled) {
        self.geometryFulfilled = YES;
        [self.OMIDGeomentryChangeExpectation fulfill];
        
    }
    
    if ([response containsString:@"percentageInView"] && [response containsString:@"100"] && !self.oneHundredPercentViewableFulfilled) {
        self.oneHundredPercentViewableFulfilled = YES;
        [self.OMID100PercentViewableExpectation fulfill];
        
    }
    
    if ([response containsString:@"impression"]) {
        [self.OMIDImpressionEventExpectation fulfill];
    }
    
    if ([response containsString:@"sessionFinish"]) {
           [self.OMIDAdSessionFinishedExpectation fulfill];
    }
}

@end
