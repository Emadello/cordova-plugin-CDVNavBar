//
//  CDVNavigationBarController.h
//  Cordova Plugin
//
//  Created by Lifetime.com.eg Technical Team (Amr Hossam / Emad ElShafie) on 6 January 2016.
//  Copyright (c) 2016 Lifetime.com.eg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CDVNavigationBarDelegate <NSObject>
-(void)leftButtonTapped;
-(void)rightButtonTapped;
@end 

@interface CDVNavigationBarController : UIViewController{

    IBOutlet UIBarButtonItem * leftButton;
    IBOutlet UIBarButtonItem * rightButton;
    IBOutlet UINavigationItem * navItem;    
    id<CDVNavigationBarDelegate>  delegate;
    
}

@property (nonatomic, retain) UINavigationItem * navItem;
@property (nonatomic, retain) UIBarButtonItem * leftButton;
@property (nonatomic, retain) UIBarButtonItem * rightButton;
@property (nonatomic, retain) id<CDVNavigationBarDelegate>  delegate;

-(IBAction)leftButtonTapped:(id)sender;
-(IBAction)rightButtonTapped:(id)sender;

@end
