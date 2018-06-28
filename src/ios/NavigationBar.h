//
//  NavigationBar.h
//  Cordova Plugin
//
//  Created by Lifetime.com.eg Technical Team (Amr Hossam / Emad ElShafie) on 6 January 2016.
//  Copyright (c) 2016 Lifetime.com.eg. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "Cordova/CDV.h"

#import "CDVNavigationBarController.h"
#import "NavigationBarTableViewCell.h"

@interface NavigationBar : CDVPlugin <CDVNavigationBarDelegate, UITableViewDataSource,UITableViewDelegate> {
    UINavigationBar * navBar;
    
    // Represents frame of web view as if started in portrait mode. Coordinates are relative to the superview. With
    // Cordova 2.1.0, frame.origin.y=0 means directly under the status bar, while in older versions it would have been
    // frame.origin.y=20.
    CGRect  originalWebViewFrame;
    
    CGFloat navBarHeight;
    CGFloat tabBarHeight;
    _Bool navbartrans;
    _Bool rightbuttonshown;
    _Bool reshowrightbutton;
    UIView *drawerview;
    CDVNavigationBarController * navBarController;
    UIDeviceOrientation currentDeviceOrientation;
}
    
    @property (nonatomic, retain) CDVNavigationBarController *navBarController;
    @property (nonatomic, assign) NSInteger *drawervisible; // Drawer
    @property (nonatomic, strong) UITableView * tableView; // Drawer
    @property (nonatomic, retain) NSArray * draweritems; // Drawer
    @property (nonatomic, assign) int draweritemscount; // Drawer
    
- (void)create:(CDVInvokedUrlCommand*)command;
- (void)setTitle:(CDVInvokedUrlCommand*)command;
- (void)setBGhex:(CDVInvokedUrlCommand*)command;
- (void)setTitlehex:(CDVInvokedUrlCommand*)command;
- (void)setTitleAttr:(CDVInvokedUrlCommand*)command;
- (void)setButtonshex:(CDVInvokedUrlCommand*)command;
- (void)setLogo:(CDVInvokedUrlCommand*)command;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)hide:(CDVInvokedUrlCommand*)command;
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)setupLeftButton:(CDVInvokedUrlCommand*)command;
- (void)setupRightButton:(CDVInvokedUrlCommand*)command;
- (void)leftButtonTapped;
- (void)rightButtonTapped;
    
    
- (void)showRightButton:(CDVInvokedUrlCommand*)command;
- (void)showLeftButton:(CDVInvokedUrlCommand*)command;
    
- (void)hideRightButton:(CDVInvokedUrlCommand*)command;
- (void)hideLeftButton:(CDVInvokedUrlCommand*)command;
    
- (void)setLeftButtonEnabled:(CDVInvokedUrlCommand*)command;
- (void)setLeftButtonTint:(CDVInvokedUrlCommand*)command;
- (void)setLeftButtonTitle:(CDVInvokedUrlCommand*)command;
    
- (void)setRightButtonEnabled:(CDVInvokedUrlCommand*)command;
- (void)setRightButtonTint:(CDVInvokedUrlCommand*)command;
- (void)setRightButtonTitle:(CDVInvokedUrlCommand*)command;
    
    // New Update for Drawer
- (void)setupDrawer:(CDVInvokedUrlCommand*)command;
- (void)DrawerTapped;
    
    @end

@interface UITabBar (NavBarCompat)
    @property (nonatomic) bool tabBarAtBottom;
    @end
