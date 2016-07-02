//
//  samplesUserLoginViewController.m
//  Microsoft Tasks
//
//  Created by Brandon Werner on 4/20/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "samplesUserLoginViewController.h"
#import "samplesWebAPIConnector.h"
#import "samplesUseViewController.h"
#import "samplesPolicyData.h"
#import <Foundation/Foundation.h>
#import "samplesTaskItem.h"
#import "samplesPolicyData.h"
#import "NXOAuth2.h"
#import "samplesApplicationData.h"


@implementation samplesUserLoginViewController

NSString *scopes = @"openid";
NSString *authURL = @"https://login.microsoftonline.com/common/oauth2/v2.0/authorize";
NSString *loginURL = @"https://login.microsoftonline.com/common/login";
NSString *bhh = @"urn:ietf:wg:oauth:2.0:oob?code=";
NSString *tokenURL = @"https://login.microsoftonline.com/common/oauth2/v2.0/token";
NSString *keychain = @"com.microsoft.azureactivedirectory.samples.graph.QuickStart";
static NSString * const kIDMOAuth2SuccessPagePrefix = @"session_state=";
NSURL *myRequestedUrl;
NSURL *myLoadedUrl;
bool loginFlow = FALSE;
bool isRequestBusy;
NSURL *authcode;


- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    self.loginView.delegate = self;
    [self setupOAuth2AccountStore];
    [self requestOAuth2Access];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

- (void)resolveUsingUIWebView:(NSURL *)URL {
    
    // We get the auth token from a redirect so we need to handle that in the webview.
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(resolveUsingUIWebView:) withObject:URL waitUntilDone:YES];
        return;
    }
    
    NSURLRequest *hostnameURLRequest = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    isRequestBusy = YES;
    [self.loginView loadRequest:hostnameURLRequest];
    
    NSLog(@"resolveUsingUIWebView ready (status: UNKNOWN, URL: %@)", self.loginView.request.URL);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"webView:shouldStartLoadWithRequest: %@ (%li)", request.URL, (long)navigationType);
    
    // The webview is where all the communication happens. Slightly complicated.
    
    myLoadedUrl = [webView.request mainDocumentURL];
    NSLog(@"***Loaded url: %@", myLoadedUrl);
    
    //if the UIWebView is showing our authorization URL or consent URL, show the UIWebView control
    if ([request.URL.absoluteString rangeOfString:authURL options:NSCaseInsensitiveSearch].location != NSNotFound) {
        self.loginView.hidden = NO;
    } else if ([request.URL.absoluteString rangeOfString:loginURL options:NSCaseInsensitiveSearch].location != NSNotFound) {
        //otherwise hide the UIWebView, we've left the authorization flow
        self.loginView.hidden = NO;
    } else if ([request.URL.absoluteString rangeOfString:bhh options:NSCaseInsensitiveSearch].location != NSNotFound) {
        //otherwise hide the UIWebView, we've left the authorization flow
        self.loginView.hidden = YES;
        [[NXOAuth2AccountStore sharedStore] handleRedirectURL:request.URL];
    }
    else {
        self.loginView.hidden = NO;
        //read the Location from the UIWebView, this is how Microsoft APIs is returning the
        //authentication code and relation information. This is controlled by the redirect URL we chose to use from Microsoft APIs
        //continue the OAuth2 flow
        // [[NXOAuth2AccountStore sharedStore] handleRedirectURL:request.URL];
    }
    
    return YES;
    
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // The webview is where all the communication happens. Slightly complicated.
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupOAuth2AccountStore {
    

    
    SamplesApplicationData* data = [SamplesApplicationData getInstance];
    samplesPolicyData *aPolicy = [[samplesPolicyData alloc]init];
    
    aPolicy.policyID = data.currentPolicyId;
    
  //  authURL = [NSString stringWithFormat:@"%@", authURL, data.graphApiUrlString, data.apiversion];
    
    NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithDictionary:[[NXOAuth2AccountStore sharedStore] configurationForAccountType:@"myB2CService"]];
    NSDictionary *customHeaderFields = [NSDictionary dictionaryWithObject:data.currentPolicyId forKey:@"p"];
    [configuration setObject:customHeaderFields forKey:kNXOAuth2AccountStoreConfigurationAdditionalAuthenticationParameters];
    [[NXOAuth2AccountStore sharedStore] setConfiguration:configuration forAccountType:@"myB2CService"];
    
    
    [[NXOAuth2AccountStore sharedStore] setClientID:data.clientId
                                             secret:nil
                                              scope:[NSSet setWithObject:scopes]
                                   authorizationURL:[NSURL URLWithString:authURL]
                                           tokenURL:[NSURL URLWithString:tokenURL]
                                        redirectURL:[NSURL URLWithString:data.redirectUriString]
                                      keyChainGroup: keychain
                                     forAccountType:@"myB2CService"];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {
                                                      if (aNotification.userInfo) {
                                                          //account added, we have access
                                                          //we can now request protected data
                                                          NSLog(@"Success!! We have an access token.");
                                                          dispatch_async(dispatch_get_main_queue(),^ {
                                                              
                                                              samplesUseViewController* samplesUseViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimsView"];
                                                              [self.navigationController pushViewController:samplesUseViewController animated:YES];
                                                          });
                                                      } else {
                                                          //account removed, we lost access
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {
                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      NSLog(@"Error!! %@", error.localizedDescription);
                                                  }];
}




-(void)requestOAuth2Access {
    //in order to login to Mircosoft APIs using OAuth2 we must show an embedded browser (UIWebView)
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"myGraphService"
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
                                       //navigate to the URL returned by NXOAuth2Client
                                       
                                       NSURLRequest *r = [NSURLRequest requestWithURL:preparedURL];
                                       [self.loginView loadRequest:r];
                                   }];
}




@end
