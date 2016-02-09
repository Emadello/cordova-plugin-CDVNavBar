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
@synthesize navBarController;

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
    UIApplication *app = [UIApplication sharedApplication];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            float statusBarHeight = 0;
            if(!app.statusBarHidden)
                statusBarHeight = MIN(app.statusBarFrame.size.width, app.statusBarFrame.size.height);
            
            originalWebViewFrame = CGRectMake(originalWebViewFrame.origin.y,
                                              originalWebViewFrame.origin.x,
                                              originalWebViewFrame.size.height + statusBarHeight,
                                              originalWebViewFrame.size.width - statusBarHeight);
            break;
        }
        default:
            NSLog(@"Unknown orientation: %d", orientation);
            break;
    }
    
    //if (isAtLeast8) navBarHeight = 44.0f;
    navBarHeight = 64.0f;
    tabBarHeight = 49.0f;
    // -----------------------------------------------------------------------
    
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
    backButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    CGSize textSize = [title sizeWithFont:backButton.titleLabel.font];
    
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
    if(!navBar)
        return;
    
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
    
    CGFloat left = originalWebViewFrame.origin.x;
    CGFloat right = left + originalWebViewFrame.size.width;
    CGFloat top = originalWebViewFrame.origin.y;
    CGFloat bottom = top + originalWebViewFrame.size.height;
    
    if(navBar.hidden == NO) {
        
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
    
    CGRect webViewFrame = CGRectMake(left, top, right - left, bottom - top);
    
    [self.webView setFrame:webViewFrame];
    
    // -----------------------------------------------------------------------------
    
    // NOTE: Following part again for navigation bar plugin only
    
    if(navBar.hidden == NO)
    {
        if(tabBarAtBottom)
            [navBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y, right - left, navBarHeight)];
        else
            [navBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y + tabBarHeight - 20.0f, right - left, navBarHeight)];
    }
}

-(void) init:(CDVInvokedUrlCommand*)command
{
    // Dummy function, see initWithWebView
}

-(void) create:(CDVInvokedUrlCommand*)command
{
    NSLog(@"HRERE");
    if(navBar)
        return;
    
    navBarController = [[CDVNavigationBarController alloc] init];
    navBar = (UINavigationBar*)[navBarController view];
    
    navBar.barStyle = UIBarStyleBlackTranslucent;
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setBackgroundColor:[UIColor colorWithRed:218.0/255.0 green:33.0/255.0 blue:39.0/255.0 alpha:1.0]];
    //[navBar setBackgroundImage:[UIImage imageNamed:@"bg_new.png"] forBarMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:131.0/255.0 green:23.0/255.0 blue:78.0/255.0 alpha:1.0];
    shadow.shadowOffset = CGSizeMake(0, 2);
    shadow.shadowBlurRadius = 5;
    [navBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     //shadow, NSShadowAttributeName,
                                     [UIFont fontWithName:@"Helvetica" size:18.0], NSFontAttributeName, nil]];
    
    
    [navBarController setDelegate:self];
    
    [[navBarController view] setFrame:CGRectMake(0, 0, originalWebViewFrame.size.width, navBarHeight)];
    [[[self webView] superview] addSubview:[navBarController view]];
    [navBar setHidden:YES];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
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
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        uiwebview = ((UIWebView*)self.webView);
    }
    
    NSString * jsCallBack = @"navbar.leftButtonTapped();";
    [uiwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
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
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        uiwebview = ((UIWebView*)self.webView);
    }
    NSString * jsCallBack = @"navbar.rightButtonTapped();";
    [uiwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
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
            if ((![title  isEqual: @"Back"])) {
                
                return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:actionOnSelf ];
                
                
            } else {
                
                NSDictionary *attrs = @{ NSFontAttributeName : [UIFont systemFontOfSize:9] };
                
                UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 15.0f, 20.0f)];
                UIImage *backImage = [UIImage imageNamed:@"back2.png"];
                [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
                //[backButton setTitle:@"Back" forState:UIControlStateNormal];
                [backButton setContentMode:UIViewContentModeScaleAspectFit];
                //[backButton setBackgroundColor:[UIColor blackColor]];
                [navBar addSubview:backButton];
                
                [backButton addTarget:self action:actionOnSelf forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *thenewbutton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
                [thenewbutton setTitleTextAttributes:attrs forState:UIControlStateNormal];
                return thenewbutton;
                
                
                //return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:actionOnSelf ];
                
            }
            //
            
            
        }
    }
    else if (imageName && [imageName length] > 0)
    {
        UIBarButtonSystemItem systemItem = [NavigationBar getUIBarButtonSystemItemForString:imageName];
        
        if(systemItem != -1)
            return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:actionOnSelf];
        else
            return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStylePlain target:self action:actionOnSelf];
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

@end