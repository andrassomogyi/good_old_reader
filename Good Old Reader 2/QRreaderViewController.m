//
//  QRreaderViewController.m
//  Good Old Reader 2
//
//  Created by András Somogyi on 2015. 05. 26..
//  Copyright (c) 2015. András Somogyi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "QRreaderViewController.h"

@interface QRreaderViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) NSMutableArray *codeObjects;

@end

@implementation QRreaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Debug
    NSLog(@"%@",_articleUrlDict);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AVCaptureSession *) captureSession {
        if (!_captureSession)
        {
            NSError *error = nil;
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

            // Setting autofocus range to near
            if (device.isAutoFocusRangeRestrictionSupported)
            {
                if ([device lockForConfiguration:&error])
                {
                    [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
                    [device unlockForConfiguration];
                }
            }
            AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

            // Input device
            if (deviceInput)
            {
                _captureSession = [[AVCaptureSession alloc] init];
                if ([_captureSession canAddInput:deviceInput])
                {
                    [_captureSession addInput:deviceInput];
                }
            }

            // Output device
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            if ([_captureSession canAddOutput:metadataOutput])
            {
                [_captureSession addOutput:metadataOutput];
                [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            }

            // Camera output layer
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:self.previewLayer];
        }
    return _captureSession;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    self.codeObjects = nil;
    self.codeObjects = [[NSMutableArray alloc] init];
    for (AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataObject *transformedObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        [self.codeObjects addObject:transformedObject];
    }
    [self markAsReadByUrl];
}

- (void)markAsReadByUrl {
    for (AVMetadataObject *object in self.codeObjects)
    {
        AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)object;
        NSString *scannedUrl = codeObject.stringValue;

        // Mark article read on server
        if ([_articleUrlDict objectForKey:scannedUrl] == nil) {
            NSLog(@"Article not found: %@",scannedUrl);
        }
        else {
            NSLog(@"Article %@ found with %@ and marked as read.",scannedUrl, [_articleUrlDict objectForKey:scannedUrl]);

        AFHTTPRequestOperationManager *markAsReadManager = [AFHTTPRequestOperationManager manager];
        [markAsReadManager POST:@"https://theoldreader.com/reader/api/0/edit-tag"
                     parameters:@{@"i":[_articleUrlDict objectForKey:scannedUrl],
                                  @"a": @"user/-/state/com.google/read",
                                  @"output": @"json"}
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            //
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            //
                        }];
        }
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)startRunning
{
    self.codeObjects = nil;
    [self.captureSession startRunning];
}

- (void)stopRunning
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
