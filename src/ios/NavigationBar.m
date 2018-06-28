//
//  NavigationBar.h
//  Cordova Plugin
//
//  Created by Lifetime.com.eg Technical Team (Amr Hossam / Emad ElShafie) on 6 January 2016.
//  Copyright (c) 2016 Lifetime.com.eg. All rights reserved.
//

#import "NavigationBar.h"
#import <UIKit/UITabBar.h>
#import <QuartzCore/QuartzCore.h>

// For older versions of Cordova, you may have to use: #import "CDVDebug.h"
//#import <Cordova/CDVDebug.h>

@implementation NavigationBar
#ifndef __IPHONE_3_0
    @synthesize webView;
#endif
    @synthesize navBarController, drawervisible, draweritems, draweritemscount;
    
- (void)applyNavBarConstraints:(CGFloat)width height:(CGFloat)height
    {
        if (width == 0 || height == 0) {
            return;
        }
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:width];
        [heightConstraint setActive:TRUE];
        [widthConstraint setActive:TRUE];
    }
    
- (void) pluginInitialize {
    UIWebView *uiwebview = nil;
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        uiwebview = ((UIWebView*)self.webView);
    }
    // -----------------------------------------------------------------------
    // This code block is the same for both the navigation and tab bar plugin!
    // -----------------------------------------------------------------------
    
    // The original web view frame must be retrieved here. On iPhone, it would be 0,0,320,460 for example. Since
    // Cordova seems to initialize plugins on the first call, there is a plugin method init() that has to be called
    // in order to make Cordova call *this* method. If someone forgets the init() call and uses the navigation bar
    // and tab bar plugins together, these values won't be the original web view frame and layout will be wrong.
    originalWebViewFrame = uiwebview.frame;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    //if (isAtLeast8) navBarHeight = 44.0f;
    navBarHeight = 44.0f;
    tabBarHeight = 49.0f;
    navbartrans = FALSE;
    rightbuttonshown = FALSE;
    reshowrightbutton = FALSE;
    // -----------------------------------------------------------------------
    
}
    
- (void) orientationChanged:(NSNotification *)note
    {
        UIDevice * device = note.object;
        switch(device.orientation)
        {
            case UIDeviceOrientationPortrait:
            NSLog(@"NavBar Orientation Changed to portrait");
            [self correctWebViewFrame];
            break;
            
            case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"NavBar Orientation Changed to upsidedown");
            [self correctWebViewFrame];
            break;
            
            default:
            NSLog(@"NavBar Orientation Changed to landscape");
            float statusBarHeight = 20.0f;
            [self correctWebViewFrame];
            break;
        };
        
    }
    
    // NOTE: Returned object is owned
-(UIBarButtonItem*)backgroundButtonFromImage:(NSString*)imageName title:(NSString*)title fixedMarginLeft:(float)fixedMarginLeft fixedMarginRight:(float)fixedMarginRight target:(id)target action:(SEL)action
    {
        UIButton *backButton = [[UIButton alloc] init];
        UIImage *imgNormal = [UIImage imageNamed:imageName];
        
        // UIImage's resizableImageWithCapInsets method is only available from iOS 5.0. With earlier versions, the
        // stretchableImageWithLeftCapWidth is used which behaves a bit differently.
        if([imgNormal respondsToSelector:@selector(resizableImageWithCapInsets)])
        imgNormal = [imgNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0, fixedMarginLeft, 0, fixedMarginRight)];
        else
        imgNormal = [imgNormal stretchableImageWithLeftCapWidth:MAX(fixedMarginLeft, fixedMarginRight) topCapHeight:0];
        
        [backButton setBackgroundImage:imgNormal forState:UIControlStateNormal];
        
        backButton.titleLabel.textColor = [UIColor whiteColor];
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0f]}];
        
        float buttonWidth = MAX(imgNormal.size.width, textSize.width + fixedMarginLeft + fixedMarginRight);//imgNormal.size.width > (textSize.width + fixedMarginLeft + fixedMarginRight)
        //? imgNormal.size.width : (textSize.width + fixedMarginLeft + fixedMarginRight);
        backButton.frame = CGRectMake(0, 0, buttonWidth, imgNormal.size.height);
        
        CGFloat marginTopBottom = (backButton.frame.size.height - textSize.height) / 2;
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(marginTopBottom, fixedMarginLeft, marginTopBottom, fixedMarginRight)];
        
        [backButton setTitle:title forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        // imgNormal is autoreleased
        
        return backButtonItem;
    }
    
-(void)correctWebViewFrame
    {
        //if(!navBar)
        //return;
        currentDeviceOrientation = [[UIDevice currentDevice] orientation];
        BOOL isLandscape = [UIApplication sharedApplication].statusBarOrientation == (UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
        BOOL isPortrait = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait;
        
        const bool navBarShown = !navBar.hidden;
        bool tabBarShown = false;
        bool tabBarAtBottom = true;
        
        UIView *parent = [navBar superview];
        for(UIView *view in parent.subviews)
        if([view isMemberOfClass:[UITabBar class]])
        {
            tabBarShown = !view.hidden;
            
            // Tab bar height is customizable
            if(tabBarShown)
            {
                tabBarHeight = view.bounds.size.height;
                
                // Since the navigation bar plugin plays together with the tab bar plugin, and the tab bar can as well
                // be positioned at the top, here's some magic to find out where it's positioned:
                tabBarAtBottom = true;
                if([view respondsToSelector:@selector(tabBarAtBottom)])
                tabBarAtBottom = [view performSelector:@selector(tabBarAtBottom)];
            }
            
            break;
        }
        
        // -----------------------------------------------------------------------------
        // IMPORTANT: Below code is the same in both the navigation and tab bar plugins!
        // -----------------------------------------------------------------------------
        
        CGFloat left, right, top, bottom;
        
        left = [UIScreen mainScreen].bounds.origin.x;
        right = left + [UIScreen mainScreen].bounds.size.width;
        
        if (!navBar || navbartrans) {
            
            top = 0;
            bottom = top + [UIScreen mainScreen].bounds.size.height;
            
        } else {
            
            if (@available(iOS 11.0, *)) {
                top = [UIScreen mainScreen].bounds.origin.y + [[self webView] superview].safeAreaInsets.top;
                if (isPortrait) bottom = top + [UIScreen mainScreen].bounds.size.height - [[self webView] superview].safeAreaInsets.top;
                else bottom = top + [UIScreen mainScreen].bounds.size.height;
            } else {
                
                top = [UIScreen mainScreen].bounds.origin.y + 20.0f;
                bottom = top + [UIScreen mainScreen].bounds.size.height - 20.0f;
            }
            
        }
        
        
        if(navBar && navBar.hidden == NO && !navbartrans) {
            
            top += navBarHeight;
            NSLog(@"NAVBAR IS SHOWN");
            
        } else {
            
            top = 0;
            NSLog(@"NAVBAR IS HIDDEN");
        }
        
        if(tabBarShown)
        {
            if(tabBarAtBottom)
            bottom -= tabBarHeight;
            else
            top += tabBarHeight;
        }
        
        CGRect webViewFrame;
        
        if (@available(iOS 11.0, *)) {
            webViewFrame = CGRectMake(left, top, right - left, bottom - top - [[self webView] superview].safeAreaInsets.bottom);
        } else {
            webViewFrame = CGRectMake(left, top, right - left, bottom - top);
        }
        
        [self.webView setFrame:webViewFrame];
        
        // -----------------------------------------------------------------------------
        
        // NOTE: Following part again for navigation bar plugin only
        
        if(navBar.hidden == NO)
        {
            
            if(tabBarAtBottom) {
                
                if (@available(iOS 11.0, *)) {
                    if (isPortrait) [navBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y + [[self webView] superview].safeAreaInsets.top, right - left, navBarHeight)];
                    else [navBar setFrame:CGRectMake(left, originalWebViewFrame.origin.x, right - left, navBarHeight)];
                    NSLog(@"iOS 11");
                } else {
                    if (isPortrait) [navBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y + 20.0f, right - left, navBarHeight)];
                    else [navBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y, right - left, navBarHeight)];
                    NSLog(@"not iOS 11");
                }
                
            } else {
                
                if (@available(iOS 11.0, *)) {
                    if (isPortrait) [navBar setFrame:CGRectMake(0, originalWebViewFrame.origin.y + tabBarHeight - 20.0f, right - left, navBarHeight)];
                    else [navBar setFrame:CGRectMake(0, originalWebViewFrame.origin.y + tabBarHeight + 20.0f, right - left, navBarHeight)];
                } else {
                    if (isPortrait) [navBar setFrame:CGRectMake(0, originalWebViewFrame.origin.y + tabBarHeight - 20.0f, right - left, navBarHeight)];
                    else [navBar setFrame:CGRectMake(0, originalWebViewFrame.origin.y + tabBarHeight + 20.0f, right - left, navBarHeight)];
                }
            }
            
        }
        
        if (@available(iOS 11.0, *)) {
            navBar.insetsLayoutMarginsFromSafeArea = true;
        }
    }
    
-(void) init:(CDVInvokedUrlCommand*)command
    {
        // Dummy function, see initWithWebView
    }
    
-(void) create:(CDVInvokedUrlCommand*)command
    {
        
        if(navBar)
        return;
        
        navBarController = [[CDVNavigationBarController alloc] init];
        navBar = (UINavigationBar*)[navBarController view];
        
        navBar.barStyle = UIBarStyleBlackTranslucent;
        [navBar setTintColor:[UIColor whiteColor]];
        [navBar setBackgroundColor:[UIColor colorWithRed:218.0/255.0 green:133.0/255.0 blue:39.0/255.0 alpha:1.0]];
        //[navBar setBackgroundImage:[UIImage imageNamed:@"bg_new.png"] forBarMetrics:UIBarMetricsDefault];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:131.0/255.0 green:23.0/255.0 blue:78.0/255.0 alpha:1.0];
        shadow.shadowOffset = CGSizeMake(0, 2);
        shadow.shadowBlurRadius = 5;
        [navBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                         //shadow, NSShadowAttributeName,
                                         [UIFont fontWithName:@"Vodafone Rg Bold" size:16.0], NSFontAttributeName, nil]];
        
        
        [navBarController setDelegate:self];
        //[navBar safeAreaLayoutGuide];
        
        [[navBarController view] setFrame:CGRectMake(0, 0, originalWebViewFrame.size.width, navBarHeight)];
        [[[self webView] superview] addSubview:[navBarController view]];
        [navBar setHidden:YES];
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
    }
    
    
    ///////////
    // Title //
    ///////////
    
-(void) setTitle:(CDVInvokedUrlCommand*)command
    {
        if(!navBar)
        return;
        
        NSLog(@"Set the title");
        NSString  *title = [command.arguments objectAtIndex:0];
        [navBarController navItem].title = title;
        
        // Reset otherwise overriding logo reference
        [navBarController navItem].titleView = NULL;
    }
    
    //////////////
    // BG COLOR //
    //////////////
    
-(void) setBGhex:(CDVInvokedUrlCommand*)command
    {
        if(!navBar)
        return;
        
        NSLog(@"Set BG hex color");
        NSString *bghex = [command.arguments objectAtIndex:0];
        
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        
        if ([bghex  isEqual: @"transparent"]) {
            
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.shadowImage = [UIImage new];
            navBar.translucent = YES;
            self.navBarController.view.backgroundColor = [UIColor clearColor];
            navBar.backgroundColor = [UIColor clearColor];
            navbartrans = TRUE;
            [self correctWebViewFrame];
            navBar.layer.zPosition = 99;
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.tintColor = [UIColor clearColor];
                statusBar.backgroundColor = [UIColor clearColor];
            }
            
        } else {
            
            if (([bghex isEqual: @"#008fb3"])) {
                navbartrans = TRUE;
                navBar.shadowImage = [UIImage new];
            } else navbartrans = FALSE;
            
            [self correctWebViewFrame];
            UIColor *BGcolor = [self colorWithHexString:bghex alpha:1];
            [navBar setBarTintColor:BGcolor];
            [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
            [navBar setTranslucent:NO];
            
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            
            if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
                statusBar.tintColor = BGcolor;
                statusBar.backgroundColor = BGcolor;
            }
            
        }
        
        
        
    }
    
    /////////////////
    // Title COLOR //
    /////////////////
    
-(void) setTitlehex:(CDVInvokedUrlCommand*)command
    {
        if(!navBar)
        return;
        
        NSLog(@"Set Title hex color");
        NSString *titlehex = [command.arguments objectAtIndex:0];
        UIColor *Titlecolor = [self colorWithHexString:titlehex alpha:1];
        [navBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:Titlecolor}];
        
    }
    
    //////////////////////
    // Title Attributes //
    //////////////////////
    
-(void) setTitleAttr:(CDVInvokedUrlCommand*)command
    {
        if(!navBar)
        return;
        
        
        NSString *titlehex = [command.arguments objectAtIndex:0];
        NSString *titlefont = [command.arguments objectAtIndex:1];
        CGFloat titlesize = [[command.arguments objectAtIndex:2] floatValue];
        
        if (!titlefont) titlefont = @"VodafoneRg-Bold";
        
        NSArray *families = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSMutableString *fonts = [NSMutableString string];
        for (int i = 0; i < [families count]; i++) {
            [fonts appendString:[NSString stringWithFormat:@"\n%@:\n", families[i]]];
            NSArray *names = [UIFont fontNamesForFamilyName:families[i]];
            for (int j = 0; j < [names count]; j++) {
                [fonts appendString:[NSString stringWithFormat:@"\t%@\n", names[j]]];
            }
        }
        NSLog(@"%@", fonts);
        
        
        
        NSLog(@"Set Title Attributes Color: %@", titlehex);
        NSLog(@"Set Title Attributes Font: %@", titlefont);
        NSLog(@"Set Title Attributes Size: %f", titlesize);
        
        UIColor *Titlecolor = [self colorWithHexString:titlehex alpha:1];
        
        [navBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                         Titlecolor, NSForegroundColorAttributeName,
                                         [UIFont fontWithName:titlefont size:titlesize], NSFontAttributeName, nil]];
        
    }
    
    ///////////////////
    // Buttons COLOR //
    ///////////////////
    
-(void) setButtonshex:(CDVInvokedUrlCommand*)command
    {
        if(!navBar)
        return;
        
        NSLog(@"Set Buttons hex color");
        NSString *colorhex = [command.arguments objectAtIndex:0];
        UIColor *buttonscolor = [self colorWithHexString:colorhex alpha:1];
        [navBar setTintColor:buttonscolor];
        
    }
    
- (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range{
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:str_HEX];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha_range];
    
}
    
    /////////////
    // Buttons //
    /////////////
    
- (void)hideLeftButton:(CDVInvokedUrlCommand*)command
    {
        //NSLog(@"hereeee");
        //const NSDictionary *options = [command.arguments objectAtIndex:0];
        //bool animated = [[options objectForKey:@"animated"] boolValue];
        
        [[navBarController navItem] setLeftBarButtonItem:nil animated:YES];
    }
    
- (void)hideRightButton:(CDVInvokedUrlCommand*)command
    {
        //const NSDictionary *options = [command.arguments objectAtIndex:0];
        //bool animated = [[options objectForKey:@"animated"] boolValue];
        rightbuttonshown = FALSE;
        reshowrightbutton = FALSE;
        [[navBarController navItem] setRightBarButtonItem:nil animated:YES];
        
    }
    
- (void)showLeftButton:(CDVInvokedUrlCommand*)command
    {
        //const NSDictionary *options = [command.arguments objectAtIndex:0];
        //bool animated = [[options objectForKey:@"animated"] boolValue];
        
        [[navBarController navItem] setLeftBarButtonItem:[navBarController leftButton] animated:YES];
    }
    
- (void)showRightButton:(CDVInvokedUrlCommand*)command
    {
        //const NSDictionary *options = [command.arguments objectAtIndex:0];
        //bool animated = [[options objectForKey:@"animated"] boolValue];
        rightbuttonshown = TRUE;
        [[navBarController navItem] setRightBarButtonItem:[navBarController rightButton] animated:YES];
    }
    
- (void)setupLeftButton:(CDVInvokedUrlCommand*)command
    {
        NSLog(@"SetupLeftButton");
        
        NSString * title = [command argumentAtIndex:0];
        NSString * imageName = [command argumentAtIndex:1];
        NSDictionary *options = [command argumentAtIndex:2];
        
        UIBarButtonItem *newButton = [self makeButtonWithOptions:options title:title imageName:imageName actionOnSelf:@selector(leftButtonTapped)];
        navBarController.navItem.leftBarButtonItem = newButton;
        navBarController.leftButton = newButton;
    }
    
-(void) leftButtonTapped
    {
        UIWebView *uiwebview = nil;
        WKWebView *wkwebview = nil;
        
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            uiwebview = ((UIWebView*)self.webView);
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            wkwebview = ((WKWebView*)self.webView);
        }
        
        NSString * jsCallBack = @"navbar.leftButtonTapped();";
        [uiwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
        [wkwebview evaluateJavaScript:jsCallBack completionHandler:nil];
    }
    
- (void)setupRightButton:(CDVInvokedUrlCommand*)command
    {
        
        NSLog(@"SetupLeftButton");
        
        NSString * title = [command argumentAtIndex:0];
        NSString * imageName = [command argumentAtIndex:1];
        NSDictionary *options = [command argumentAtIndex:2];
        
        UIBarButtonItem *newButton = [self makeButtonWithOptions:options title:title imageName:imageName actionOnSelf:@selector(rightButtonTapped)];
        navBarController.navItem.rightBarButtonItem = newButton;
        navBarController.rightButton = newButton;
    }
    
-(void) rightButtonTapped
    {
        UIWebView *uiwebview = nil;
        WKWebView *wkwebview = nil;
        
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            uiwebview = ((UIWebView*)self.webView);
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            wkwebview = ((WKWebView*)self.webView);
        }
        
        NSString * jsCallBack = @"navbar.rightButtonTapped();";
        [uiwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
        [wkwebview evaluateJavaScript:jsCallBack completionHandler:nil];
    }
    
    // NOTE: Returned object is owned
- (UIBarButtonItem*)makeButtonWithOptions:(NSDictionary*)options title:(NSString*)title imageName:(NSString*)imageName actionOnSelf:(SEL)actionOnSelf
    {
        NSNumber *useImageAsBackgroundOpt = [options objectForKey:@"useImageAsBackground"];
        float fixedMarginLeft = [[options objectForKey:@"fixedMarginLeft"] floatValue] ?: 13;
        float fixedMarginRight = [[options objectForKey:@"fixedMarginRight"] floatValue] ?: 13;
        bool useImageAsBackground = useImageAsBackgroundOpt ? [useImageAsBackgroundOpt boolValue] : false;
        
        if((title && [title length] > 0) || useImageAsBackground)
        {
            if(useImageAsBackground && imageName && [imageName length] > 0)
            {
                return [self backgroundButtonFromImage:imageName title:title
                                       fixedMarginLeft:fixedMarginLeft fixedMarginRight:fixedMarginRight
                                                target:self action:actionOnSelf];
            }
            else
            {
                
                // New Changes
                if (([title  isEqual: @"Back"])) {
                    
                    NSDictionary *attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:9] };
                    
                    UIButton *backButton;
                    UIImage *backImage;
                    
                    if (@available(iOS 11.0, *)) {
                        
                        backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 47.0f, 23.0f)];
                        backImage = [UIImage imageNamed:@"back2.png"];
                        [backButton setImage:backImage forState:UIControlStateNormal];
                        [backButton setContentMode:UIViewContentModeLeft];
                        backButton.imageEdgeInsets = UIEdgeInsetsMake(12.0f, 0, 11.0f, 47.0f);
                        [navBar addSubview:backButton];
                        
                    } else {
                        
                        backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 17.0f, 23.0f)];
                        backImage = [UIImage imageNamed:@"back2.png"];
                        [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
                        [backButton setContentMode:UIViewContentModeScaleAspectFit];
                        [navBar addSubview:backButton];
                        
                    }
                    
                    [backButton addTarget:self action:actionOnSelf forControlEvents:UIControlEventTouchUpInside];
                    UIBarButtonItem *thenewbutton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
                    [thenewbutton setTitleTextAttributes:attrs forState:UIControlStateNormal];
                    return thenewbutton;
                    
                } else if (([title  isEqual: @"Music"])) {
                    
                    NSDictionary *attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:9] };
                    
                    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 25.0f, 25.0f)];
                    UIImage *backImage = [UIImage imageNamed:@"music.png"];
                    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
                    //[backButton setTitle:@"Back" forState:UIControlStateNormal];
                    [backButton setContentMode:UIViewContentModeScaleAspectFit];
                    //[backButton setBackgroundColor:[UIColor blackColor]];
                    [navBar addSubview:backButton];
                    
                    
                    
                    NSLayoutConstraint * widthConstraint = [backButton.widthAnchor constraintEqualToConstant:25];
                    NSLayoutConstraint * HeightConstraint =[backButton.heightAnchor constraintEqualToConstant:25];
                    [widthConstraint setActive:YES];
                    [HeightConstraint setActive:YES];
                    
                    [backButton addTarget:self action:actionOnSelf forControlEvents:UIControlEventTouchUpInside];
                    
                    
                    UIBarButtonItem *thenewbutton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
                    [thenewbutton setTitleTextAttributes:attrs forState:UIControlStateNormal];
                    return thenewbutton;
                    
                    
                } else {
                    
                    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:actionOnSelf ];
                    
                }
                //
                
                
            }
        }
        else if (imageName && [imageName length] > 0)
        {
            UIBarButtonSystemItem systemItem = [NavigationBar getUIBarButtonSystemItemForString:imageName];
            
            UIImage *image = [UIImage imageNamed:imageName];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:actionOnSelf forControlEvents:UIControlEventTouchUpInside];
            
            if(systemItem != -1)
            return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:actionOnSelf];
            else
            return [[UIBarButtonItem alloc] initWithCustomView:button];
        }
        else
        {
            // Fail silently
            NSLog(@"Invalid setup{Left/Right}Button parameters\n");
            return nil;
        }
    }
    ///////////////////////////////
    // Rest of useless functions //
    ///////////////////////////////
    
+ (UIBarButtonSystemItem)getUIBarButtonSystemItemForString:(NSString*)imageName
    {
        UIBarButtonSystemItem systemItem = -1;
        
        if([imageName isEqualToString:@"barButton:Action"])        systemItem = UIBarButtonSystemItemAction;
        else if([imageName isEqualToString:@"barButton:Add"])           systemItem = UIBarButtonSystemItemAdd;
        else if([imageName isEqualToString:@"barButton:Bookmarks"])     systemItem = UIBarButtonSystemItemBookmarks;
        else if([imageName isEqualToString:@"barButton:Camera"])        systemItem = UIBarButtonSystemItemCamera;
        else if([imageName isEqualToString:@"barButton:Cancel"])        systemItem = UIBarButtonSystemItemCancel;
        else if([imageName isEqualToString:@"barButton:Compose"])       systemItem = UIBarButtonSystemItemCompose;
        else if([imageName isEqualToString:@"barButton:Done"])          systemItem = UIBarButtonSystemItemDone;
        else if([imageName isEqualToString:@"barButton:Edit"])          systemItem = UIBarButtonSystemItemEdit;
        else if([imageName isEqualToString:@"barButton:FastForward"])   systemItem = UIBarButtonSystemItemFastForward;
        else if([imageName isEqualToString:@"barButton:FixedSpace"])    systemItem = UIBarButtonSystemItemFixedSpace;
        else if([imageName isEqualToString:@"barButton:FlexibleSpace"]) systemItem = UIBarButtonSystemItemFlexibleSpace;
        else if([imageName isEqualToString:@"barButton:Organize"])      systemItem = UIBarButtonSystemItemOrganize;
        else if([imageName isEqualToString:@"barButton:PageCurl"])      systemItem = UIBarButtonSystemItemPageCurl;
        else if([imageName isEqualToString:@"barButton:Pause"])         systemItem = UIBarButtonSystemItemPause;
        else if([imageName isEqualToString:@"barButton:Play"])          systemItem = UIBarButtonSystemItemPlay;
        else if([imageName isEqualToString:@"barButton:Redo"])          systemItem = UIBarButtonSystemItemRedo;
        else if([imageName isEqualToString:@"barButton:Refresh"])       systemItem = UIBarButtonSystemItemRefresh;
        else if([imageName isEqualToString:@"barButton:Reply"])         systemItem = UIBarButtonSystemItemReply;
        else if([imageName isEqualToString:@"barButton:Rewind"])        systemItem = UIBarButtonSystemItemRewind;
        else if([imageName isEqualToString:@"barButton:Save"])          systemItem = UIBarButtonSystemItemSave;
        else if([imageName isEqualToString:@"barButton:Search"])        systemItem = UIBarButtonSystemItemSearch;
        else if([imageName isEqualToString:@"barButton:Stop"])          systemItem = UIBarButtonSystemItemStop;
        else if([imageName isEqualToString:@"barButton:Trash"])         systemItem = UIBarButtonSystemItemTrash;
        else if([imageName isEqualToString:@"barButton:Undo"])          systemItem = UIBarButtonSystemItemUndo;
        
        return systemItem;
    }
    
    
    
    
    
    
    
    
    
    
    
- (void)setLeftButtonEnabled:(CDVInvokedUrlCommand*)command
    {
        if(navBarController.navItem.leftBarButtonItem)
        {
            id enabled = [command.arguments objectAtIndex:0];
            navBarController.navItem.leftBarButtonItem.enabled = [enabled boolValue];
        }
    }
    
- (void)setLeftButtonTint:(CDVInvokedUrlCommand*)command
    {
        if(!navBarController.navItem.leftBarButtonItem)
        return;
        
        if(![navBarController.navItem.leftBarButtonItem respondsToSelector:@selector(setTintColor:)])
        {
            NSLog(@"setLeftButtonTint unsupported < iOS 5");
            return;
        }
        
        id tint = [command.arguments objectAtIndex:0];
        NSArray *rgba = [tint componentsSeparatedByString:@","];
        UIColor *tintColor = [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                                             green:[[rgba objectAtIndex:1] intValue]/255.0f
                                              blue:[[rgba objectAtIndex:2] intValue]/255.0f
                                             alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
        navBarController.navItem.leftBarButtonItem.tintColor = tintColor;
    }
    
- (void)setLeftButtonTitle:(CDVInvokedUrlCommand*)command
    {
        NSString *title = [command.arguments objectAtIndex:0];
        if(navBarController.navItem.leftBarButtonItem)
        navBarController.navItem.leftBarButtonItem.title = title;
    }
    
    
    
- (void)setRightButtonEnabled:(CDVInvokedUrlCommand*)command
    {
        if(navBarController.navItem.rightBarButtonItem)
        {
            id enabled = [command.arguments objectAtIndex:0];
            navBarController.navItem.rightBarButtonItem.enabled = [enabled boolValue];
        }
    }
    
- (void)setRightButtonTint:(CDVInvokedUrlCommand*)command
    {
        if(!navBarController.navItem.rightBarButtonItem)
        return;
        
        if(![navBarController.navItem.rightBarButtonItem respondsToSelector:@selector(setTintColor:)])
        {
            NSLog(@"setRightButtonTint unsupported < iOS 5");
            return;
        }
        
        id tint = [command.arguments objectAtIndex:0];
        NSArray *rgba = [tint componentsSeparatedByString:@","];
        UIColor *tintColor = [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                                             green:[[rgba objectAtIndex:1] intValue]/255.0f
                                              blue:[[rgba objectAtIndex:2] intValue]/255.0f
                                             alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
        navBarController.navItem.rightBarButtonItem.tintColor = tintColor;
    }
    
- (void)setRightButtonTitle:(CDVInvokedUrlCommand*)command
    {
        NSString *title = [command.arguments objectAtIndex:0];
        if(navBarController.navItem.rightBarButtonItem)
        navBarController.navItem.rightBarButtonItem.title = title;
    }
    
    
    
-(void) show:(CDVInvokedUrlCommand*)command
    {
        NSLog(@"Showing NabBar");
        [self correctWebViewFrame];
        if (!navBar)
        [self create:nil];
        
        if ([navBar isHidden])
        {
            [navBar setHidden:NO];
            [self correctWebViewFrame];
        }
    }
    
    
-(void) hide:(CDVInvokedUrlCommand*)command
    {
        if (navBar && ![navBar isHidden])
        {
            [navBar setHidden:YES];
            [self correctWebViewFrame];
        } else {
            [self correctWebViewFrame];
        }
    }
    
    /**
     * Resize the navigation bar (this should be called on orientation change)
     * This is important in playing together with the tab bar plugin, especially because the tab bar can be placed on top
     * or at the bottom, so the navigation bar bounds also need to be changed.
     */
- (void)resize:(CDVInvokedUrlCommand*)command
    {
        [self correctWebViewFrame];
    }
    
    
    
-(void) setLogo:(CDVInvokedUrlCommand*)command
    {
        NSString *logoURL = [command.arguments objectAtIndex:0];
        UIImage *image = nil;
        
        if (logoURL && ![logoURL  isEqual: @""])
        {
            if ([logoURL hasPrefix:@"http://"] || [logoURL hasPrefix:@"https://"])
            {
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoURL]];
                image = [UIImage imageWithData:data];
            }
            else
            image = [UIImage imageNamed:logoURL];
            
            if (image)
            {
                UIImageView * view = [[UIImageView alloc] initWithImage:image];
                [view setContentMode:UIViewContentModeScaleAspectFit];
                [view setBounds: CGRectMake(0, 0, 100, 30)];
                [[navBarController navItem] setTitleView:view];
            }
        }
    }
    
    
    // New Update for Drawer
    
-(void) setupDrawer:(CDVInvokedUrlCommand *)command
    {
        
        CGRect webViewBounds = self.webView.bounds;
        draweritems = [command.arguments objectAtIndex:0];
        NSString *buttoncolor = [command.arguments objectAtIndex:1];
        
        draweritemscount = draweritems.count;
        
        if (!drawerview) {
            
            if (@available(iOS 11.0, *)) {
                
                if (navbartrans) drawerview = [[UIView alloc] initWithFrame:CGRectMake(-webViewBounds.size.width, originalWebViewFrame.origin.y + [[self webView] superview].safeAreaInsets.top + navBarHeight, webViewBounds.size.width, webViewBounds.size.height)];
                else drawerview = [[UIView alloc] initWithFrame:CGRectMake(-webViewBounds.size.width, originalWebViewFrame.origin.y + [[self webView] superview].safeAreaInsets.top, webViewBounds.size.width, webViewBounds.size.height)];
                
            } else {
                
                if (navbartrans) drawerview = [[UIView alloc] initWithFrame:CGRectMake(-webViewBounds.size.width, originalWebViewFrame.origin.y + 20.0f + navBarHeight, webViewBounds.size.width, webViewBounds.size.height)];
                else drawerview = [[UIView alloc] initWithFrame:CGRectMake(-webViewBounds.size.width, originalWebViewFrame.origin.y + 20.0f, webViewBounds.size.width, webViewBounds.size.height)];
                
            }
            
            
            //drawerview = [[UIView alloc] initWithFrame:CGRectMake(-webViewBounds.size.width, 64, webViewBounds.size.width, webViewBounds.size.height)];
            NSLog(@"Drawer Ready");
            
            // Drawer background
            if (!UIAccessibilityIsReduceTransparencyEnabled()) {
                drawerview.backgroundColor = [UIColor clearColor];
                
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                //always fill the view
                blurEffectView.frame = self.webView.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                [drawerview addSubview:blurEffectView]; //if you have more UIViews, use an insertSubview API to place it where needed
                
            } else {
                drawerview.backgroundColor = [UIColor blackColor];
            }
            
            UIImageView *myImage = [[UIImageView alloc] initWithFrame:CGRectMake(drawerview.bounds.size.width - 140.0f, drawerview.bounds.size.height - 117.0f, 120.0f, 34.0f)];
            myImage.image = [UIImage imageNamed:@"vf.png"];
            [drawerview addSubview:myImage];
            
        }
        
        [self DrawerIconDefault];
        
        
        
        
        if (!_tableView) {
            
            _tableView = [[UITableView alloc] initWithFrame:drawerview.bounds style:UITableViewStylePlain];
            [self.tableView setDelegate:self];
            [self.tableView setDataSource:self];
            [self.tableView setOpaque:NO];
            [self.tableView setBackgroundColor:[UIColor clearColor]];
            self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 0.0f)];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self.tableView setSeparatorColor:[UIColor clearColor]];
            
            //[self.tableView setTableFooterView:myImage];
            
            [drawerview addSubview:self.tableView];
            
        } else [self.tableView reloadData];
        [ [ [ self viewController ] view ] addSubview:drawerview];
    }
    
-(void) DrawerIconDefault {
    
    // Drawing the default button of drawer
    UIButton *drawerButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 24.0f, 18.0f)];
    UIImage *backImage = [UIImage imageNamed:@"icon-menu.png"];
    [drawerButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [drawerButton setContentMode:UIViewContentModeScaleAspectFit];
    [navBar addSubview:drawerButton];
    
    UIView *overlay = [[UIView alloc] initWithFrame:[drawerButton frame]];
    
    [drawerButton addSubview:overlay];
    overlay.userInteractionEnabled = NO;
    
    [drawerButton addTarget:self action:@selector(DrawerTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *thenewbutton = [[UIBarButtonItem alloc] initWithCustomView:drawerButton];
    
    [[navBarController navItem] setLeftBarButtonItem:thenewbutton animated:YES];
    //navBarController.navItem.leftBarButtonItem = thenewbutton;
    //navBarController.leftButton = thenewbutton;
    
}
    
-(void) DrawerIconClose {
    
    // Drawing the close button of drawer
    UIButton *drawerButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 24.0f, 18.0f)];
    UIImage *backImage = [UIImage imageNamed:@"drawerclose.png"];
    [drawerButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [drawerButton setContentMode:UIViewContentModeScaleAspectFit];
    [navBar addSubview:drawerButton];
    
    UIView *overlay = [[UIView alloc] initWithFrame:[drawerButton frame]];
    
    [drawerButton addSubview:overlay];
    overlay.userInteractionEnabled = NO;
    
    [drawerButton addTarget:self action:@selector(DrawerTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *thenewbutton = [[UIBarButtonItem alloc] initWithCustomView:drawerButton];
    
    [[navBarController navItem] setLeftBarButtonItem:thenewbutton animated:YES];
    //navBarController.navItem.leftBarButtonItem = thenewbutton;
    //navBarController.leftButton = thenewbutton;
    
}
    
-(void) DrawerTapped
    {
        
        if (drawervisible == 0) [self showDrawer];
        else [self hideDrawer];
        
        
    }
    
-(void) showDrawer
    {
        drawervisible = 1;
        [UIView animateWithDuration:0.3f animations:^{
            drawerview.frame = CGRectOffset(drawerview.frame, self.webView.bounds.size.width, 0);
        }];
        
        [self DrawerIconClose];
        
        UIWebView *uiwebview = nil;
        WKWebView *wkwebview = nil;
        
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            uiwebview = ((UIWebView*)self.webView);
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            wkwebview = ((WKWebView*)self.webView);
        }
        
        if (uiwebview) uiwebview.userInteractionEnabled = NO;
        else wkwebview.userInteractionEnabled = NO;
        
        if (rightbuttonshown) {
            [[navBarController navItem] setRightBarButtonItem:nil animated:YES];
            reshowrightbutton = TRUE;
        }
        
    }
    
-(void) hideDrawer
    {
        drawervisible = 0;
        [UIView animateWithDuration:0.3f animations:^{
            drawerview.frame = CGRectOffset(drawerview.frame, -self.webView.bounds.size.width, 0);
        }];
        
        [self DrawerIconDefault];
        
        UIWebView *uiwebview = nil;
        WKWebView *wkwebview = nil;
        
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            uiwebview = ((UIWebView*)self.webView);
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            wkwebview = ((WKWebView*)self.webView);
        }
        
        if (uiwebview) uiwebview.userInteractionEnabled = YES;
        else wkwebview.userInteractionEnabled = YES;
        
        if (reshowrightbutton) [[navBarController navItem] setRightBarButtonItem:[navBarController rightButton] animated:YES];
    }
    
#pragma mark - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        // Return the number of sections.
        return 1;
    }
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        // Return the number of rows in the section.
        if (draweritemscount > 0) return draweritemscount;
        else return 0;
        
    }
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        if (cell == nil) {
            
            cell = [[NavigationBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            
        }
        
        for (int i = 0; i < [draweritems count]; i++)
        {
            if(indexPath.row == i) {
                
                [cell.textLabel setFont:[UIFont fontWithName:@"VodafoneRg-Bold" size:20.0]];
                
                NSArray *currentitem = [draweritems objectAtIndex: i];
                NSString *itemtitle = [currentitem objectAtIndex:0];
                NSString *itemlogo = [currentitem objectAtIndex:2];
                NSString *itembadge = [currentitem objectAtIndex:3];
                
                [cell.textLabel setText:itemtitle];
                
                // Adding item image
                if (itemlogo == (id)[NSNull null] || itemlogo.length == 0 ) {
                    
                    cell.imageView.image = nil;
                    
                } else {
                    
                    cell.imageView.image = [UIImage imageNamed:itemlogo];
                    
                }
                
                // Adding item badge
                if (itembadge == (id)[NSNull null] || itembadge.length == 0 ) {
                    
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    
                } else {
                    
                    UILabel *accesoryBadge = [[UILabel alloc] init];
                    NSString *string = itembadge;
                    accesoryBadge.text = string;
                    accesoryBadge.textColor = [UIColor whiteColor];
                    accesoryBadge.textAlignment = NSTextAlignmentCenter;
                    accesoryBadge.layer.cornerRadius = 2;
                    //accesoryBadge.backgroundColor = [UIColor redColor];
                    accesoryBadge.clipsToBounds = true;
                    [accesoryBadge setFont:[UIFont fontWithName:@"VodafoneRg-Bold" size:14.0]];
                    
                    accesoryBadge.frame = CGRectMake(0, 0, 50, 20);
                    [accesoryBadge sizeToFit];
                    cell.accessoryView = accesoryBadge;
                    
                }
                
            }
        }
        
        return cell;
    }
    
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}
    
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0;
}
    
#pragma mark - Table view delegate
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        
        UIWebView *uiwebview = nil;
        WKWebView *wkwebview = nil;
        
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            uiwebview = ((UIWebView*)self.webView);
        } else if ([self.webView isKindOfClass:[WKWebView class]]) {
            wkwebview = ((WKWebView*)self.webView);
        }
        
        
        
        
        for (int i = 0; i < [draweritems count]; i++)
        {
            if(indexPath.row == i) {
                
                NSArray *currentitem = [draweritems objectAtIndex: i];
                NSString *itemurl = [currentitem objectAtIndex:1];
                
                NSString * jsCallBack = [NSString stringWithFormat:@"gofade('%@');", itemurl];
                [uiwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
                [wkwebview evaluateJavaScript:jsCallBack completionHandler:nil];
                [self hideDrawer];
                
            }
        }
        
        
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha
    {
        // Convert hex string to an integer
        unsigned int hexint = [self intFromHexString:hexStr];
        
        // Create color object, specifying alpha as well
        UIColor *color =
        [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                        green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                         blue:((CGFloat) (hexint & 0xFF))/255
                        alpha:alpha];
        
        return color;
    }
    
- (unsigned int)intFromHexString:(NSString *)hexStr
    {
        unsigned int hexInt = 0;
        
        // Create scanner
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        
        // Tell scanner to skip the # character
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
        
        // Scan hex value
        [scanner scanHexInt:&hexInt];
        
        return hexInt;
    }
    
    @end
