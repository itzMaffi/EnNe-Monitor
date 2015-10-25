//
//  MainViewController.h
//  EnNeMonitor
//
//  Created by Michele Maffei on 13/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *mailButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UISlider *rateSlider;
@property (strong, nonatomic) IBOutlet UILabel *rateLabel;

- (IBAction)start:(UIButton *)sender;
- (IBAction)stop:(UIButton *)sender;
- (IBAction)deleteFile:(UIButton *)sender;
- (IBAction)sendFile:(UIButton *)sender;
- (IBAction)sliderValueChanged:(UISlider *)sender;



@end
