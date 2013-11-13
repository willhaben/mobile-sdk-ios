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

#import "ANBannerAdView.h"
#import "ANAdFetcher.h"
#import "ANBrowserViewController.h"
#import "ANCustomAdapter.h"
#import "ANBrowserViewController.h"

@interface ANAdView (ANBannerAdView)
- (void)initialize;
- (void)adDidReceiveAd;
- (void)adRequestFailedWithError:(NSError *)error;
- (void)showCloseButtonWithTarget:(id)target
                           action:(SEL)selector
                    containerView:(UIView *)containerView;
- (void)mraidResizeAd:(CGSize)size
          contentView:(UIView *)contentView
    defaultParentView:(UIView *)defaultParentView
   rootViewController:(UIViewController *)rootViewController
             isBanner:(BOOL)isBanner;
@end

@interface ANBannerAdView () <ANBrowserViewControllerDelegate>

@property (nonatomic, strong) UIView *defaultSuperView;

@end


@implementation ANBannerAdView
@synthesize delegate = __delegate;
@synthesize autorefreshInterval = __autorefreshInterval;
@synthesize defaultSuperView = __defaultSuperView;

#pragma mark Initialization

- (void)initialize {
    [super initialize];
	
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    
    // Set default autorefreshInterval
    __autorefreshInterval = kANBannerAdViewDefaultAutorefreshInterval;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	__adSize = self.frame.size;
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId {
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:frame.size];
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size {
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:size];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId {
    self = [self initWithFrame:frame];
    
    if (self != nil) {
        NSAssert([placementId intValue] > 0, @"Placement ID must be a number greater than 0.");
        self.placementId = placementId;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size {
    self = [self initWithFrame:frame placementId:placementId];
    
    if (self != nil) {
        self.adSize = size;
    }
    
    return self;
}

- (void)loadAd {
    if ([self.adFetcher isLoading]) {
        [self.adFetcher stopAd];
    }
    
    [self.adFetcher requestAd];
}

#pragma mark Getter and Setter methods

- (CGSize)adSize {
    ANLogDebug(@"adSize returned %@", NSStringFromCGSize(__adSize));
    return __adSize;
}

- (void)setAdSize:(CGSize)adSize {
    if (!CGSizeEqualToSize(adSize, __adSize)) {
        ANLogDebug(@"Setting adSize to %@", NSStringFromCGSize(adSize));
        __adSize = adSize;
    }
}

- (void)setAutorefreshInterval:(NSTimeInterval)autorefreshInterval {
    // if auto refresh is above the threshold (0), turn auto refresh on
    if (autorefreshInterval > kANBannerAdViewAutorefreshThreshold) {
        // minimum allowed value for auto refresh is (15).
        if (autorefreshInterval < kANBannerAdViewMinimumAutorefreshInterval) {
            __autorefreshInterval = kANBannerAdViewMinimumAutorefreshInterval;
            ANLogWarn(@"setAutorefreshInterval called with value %f, but cannot be less than %f", autorefreshInterval, kANBannerAdViewMinimumAutorefreshInterval);
        }
        
		ANLogDebug(@"Autorefresh interval set to %f seconds", autorefreshInterval);
		__autorefreshInterval = autorefreshInterval;
        
		if ([self.adFetcher isLoading]) {
            [self.adFetcher stopAd];
        }
        
        ANLogDebug(@"New autorefresh interval set. Making ad request.");
        [self.adFetcher requestAd];
    } else {
		ANLogDebug(@"Turning auto refresh off");
		__autorefreshInterval = autorefreshInterval;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    // center the contentview
    CGFloat contentWidth = self.contentView.frame.size.width;
    CGFloat contentHeight = self.contentView.frame.size.height;
    CGFloat centerX = (self.frame.size.width - contentWidth) / 2;
    CGFloat centerY = (self.frame.size.height - contentHeight) / 2;
    [self.contentView setFrame:
     CGRectMake(centerX, centerY, contentWidth, contentHeight)];
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated {
    if (animated) {
        [self willResizeToFrame:frame];
        [UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
            [self setFrame:frame];
        } completion:^(BOOL finished) {
            [self bannerAdViewDidResize];
		}];
    }
    else {
        [self willResizeToFrame:frame];
        [self setFrame:frame];
        [self bannerAdViewDidResize];
    }
}

#pragma mark Implementation of abstract methods from ANAdView

- (NSString *)adType {
    return @"inline";
}

- (void)openInBrowserWithController:(ANBrowserViewController *)browserViewController {
    [self.rootViewController presentViewController:browserViewController animated:YES completion:nil];
}

#pragma mark extraParameters methods

- (NSString *)sizeParameter {
    // if the developer did not specify an adSize, use the frame size
    CGSize sizeToRequest = CGSizeEqualToSize(self.adSize, CGSizeZero) ? self.frame.size : self.adSize;
    
    return [NSString stringWithFormat:@"&size=%dx%d",
            (NSInteger)sizeToRequest.width,
            (NSInteger)sizeToRequest.height];
}

- (NSString *)maximumSizeParameter {
    return [NSString stringWithFormat:@"&max_size=%dx%d",
            (NSInteger)self.frame.size.width,
            (NSInteger)self.frame.size.height];
}

#pragma mark ANAdFetcherDelegate

- (NSArray *)extraParametersForAdFetcher:(ANAdFetcher *)fetcher {
    return [NSArray arrayWithObjects:
            [self sizeParameter],
            [self maximumSizeParameter],
            nil];
}

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response {
    NSError *error;
    
    if ([response isSuccessful]) {
        UIView *contentView = response.adObject;
        
        if ([contentView isKindOfClass:[UIView class]]) {
            // center the contentview
            CGFloat centerX = (self.frame.size.width - contentView.frame.size.width) / 2;
            CGFloat centerY = (self.frame.size.height - contentView.frame.size.height) / 2;
            [contentView setFrame:
             CGRectMake(centerX, centerY,
                        contentView.frame.size.width,
                        contentView.frame.size.height)];
            self.contentView = contentView;
            
            [self adDidReceiveAd];
        }
        else {
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Requested a banner ad but received a non-view object as response.", @"Error: We did not get a viewable object as a response for a banner ad request.")
                                                                  forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:AN_ERROR_DOMAIN
                                        code:ANAdResponseNonViewResponse
                                    userInfo:errorInfo];
        }
    }
    else {
        error = response.error;
    }
    
    if (error) {
        [self adRequestFailedWithError:error];
    }
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size {
    if (!self.defaultSuperView) {
        self.defaultSuperView = self.superview;
    }
    
    [super mraidResizeAd:size
             contentView:self.contentView
       defaultParentView:self
      rootViewController:self.rootViewController
                isBanner:YES];
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action {
	[super showCloseButtonWithTarget:target action:action containerView:self];
}

- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher {
    return self.autorefreshInterval;
}

#pragma mark delegate selector helper method

- (void)willResizeToFrame:(CGRect)frame {
    if ([self.delegate respondsToSelector:@selector(bannerAdView:willResizeToFrame:)]) {
        [self.delegate bannerAdView:self willResizeToFrame:frame];
    }
}

- (void)bannerAdViewDidResize {
    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidResize:)]) {
        [self.delegate bannerAdViewDidResize:self];
    }
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller
{
	UIViewController *presentingViewController = controller.presentingViewController;
	[presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end