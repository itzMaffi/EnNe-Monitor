//
//  MainViewController.m
//  EnNeMonitor
//
//  Created by Michele Maffei on 13/10/15.
//  Copyright © 2015 Michele Maffei. All rights reserved.
//

#import "MainViewController.h"
#import "ContentTableViewController.h"


@interface MainViewController ()


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rateSlider.minimumValue = .5f;
    _rateSlider.maximumValue = 20.0f;
    _rateSlider.value = 10.0f;
    _rateLabel.text = @"10.00 s";
    _stopButton.hidden = YES;
    
    ContentTableViewController *cVC = (ContentTableViewController *)self.childViewControllers.lastObject;
    cVC.samplingRate = _rateSlider.value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)start:(UIButton *)sender
{
    for (ContentTableViewController *childVC in self.childViewControllers)
    {
        if ([childVC respondsToSelector:@selector(startMonitoring)])
        {
            [childVC performSelector:@selector(startMonitoring)];
        }
    }
    
    _startButton.hidden = YES;
    _mailButton.hidden = YES;
    _deleteButton.hidden = YES;
    _rateSlider.hidden = YES;
    _stopButton.hidden = NO;
}

- (IBAction)stop:(UIButton *)sender
{
    for (ContentTableViewController *childVC in self.childViewControllers)
    {
        if ([childVC respondsToSelector:@selector(stopMonitoring)])
        {
            [childVC performSelector:@selector(stopMonitoring)];
        }
    }
    
    _startButton.hidden = NO;
    _mailButton.hidden = NO;
    _deleteButton.hidden = NO;
    _rateSlider.hidden = NO;
    _stopButton.hidden = YES;

}

- (IBAction)deleteFile:(UIButton *)sender
{
    for (ContentTableViewController *childVC in self.childViewControllers)
    {
        if ([childVC respondsToSelector:@selector(deleteLog)])
        {
            [childVC performSelector:@selector(deleteLog)];
        }
    }
}

- (IBAction)sendFile:(UIButton *)sender
{
    for (ContentTableViewController *childVC in self.childViewControllers)
    {
        if ([childVC respondsToSelector:@selector(mailLog)])
        {
            [childVC performSelector:@selector(mailLog)];
        }
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    ContentTableViewController *cVC = (ContentTableViewController *)self.childViewControllers.lastObject;
    cVC.samplingRate = _rateSlider.value;
    
    _rateLabel.text = [NSString stringWithFormat:@"%.2f s", _rateSlider.value];
}

@end
