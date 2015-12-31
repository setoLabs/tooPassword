//
//  TPWHtmlScreen.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 05.02.13.
//
//

#import "TPWProgressHUD.h"

#import "TPWHtmlScreen.h"

@interface TPWHtmlScreen () <UIWebViewDelegate>
@property (nonatomic, strong) NSString *localizedHtmlPath;
@property (nonatomic, assign) BOOL showsWebViewLoadHud;
@end

@implementation TPWHtmlScreen

- (id)initWithTitle:(NSString *)title htmlPathName:(NSString *)htmlPathName {
	if (self = [super initWithUniversalNibName:@"TPWHtmlScreen"]) {
		self.title = title;
		self.localizedHtmlPath = [[NSBundle mainBundle] pathForResource:htmlPathName ofType:@"html"];
		
		//webview takes a bit longer on first use, so show hud
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[TPWProgressHUD show];
			self.showsWebViewLoadHud = YES;
		});
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//webview
	self.webview.delegate = self;
	self.webview.backgroundColor = [UIColor clearColor];
	self.webview.opaque = NO;
	for (UIView *subview in self.webview.scrollView.subviews) {
		if ([subview isKindOfClass:UIImageView.class]) {
			subview.hidden = YES;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSData *localizedHtmlData = [NSData dataWithContentsOfFile:self.localizedHtmlPath];
	NSURL *bundleBaseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	[self.webview loadData:localizedHtmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:bundleBaseUrl];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (self.showsWebViewLoadHud) {
		[TPWProgressHUD dismiss];
		self.showsWebViewLoadHud = NO;
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if (self.showsWebViewLoadHud) {
		[TPWProgressHUD dismiss];
		self.showsWebViewLoadHud = NO;
	}
}

-(BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
	if (inType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[inRequest URL]];
		return NO;
	}
	return YES;
}

@end
