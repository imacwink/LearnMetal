//
//  CameraEngine.m
//  Camera-ObjC
//
//  Created by 王云刚 on 2020/7/18.
//
//
//
//                 .-~~~~~~~~~-._       _.-~~~~~~~~~-.
//             __.'              ~.   .~              `.__
//           .'//                  \./                  \\`.
//         .'//                     |                     \\`.
//       .'// .-~"""""""~~~~-._     |     _,-~~~~"""""""~-. \\`.
//     .'//.-"                 `-.  |  .-'                 "-.\\`.
//   .'//______.============-..   \ | /   ..-============.______\\`.
// .'______________________________\|/______________________________`.
//

#import "CameraEngine.h"

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface CameraEngine() <AVCaptureVideoDataOutputSampleBufferDelegate> {
    BOOL hasStarted;
}

@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) AVCaptureSession *avCaptureSession;
@property (nonatomic) dispatch_queue_t dataOutputQueue;
@property (nonatomic) AVCaptureDevice *videoDevice;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureVideoDataOutput *videoDataOutput;

@end

@implementation CameraEngine

- (instancetype)initCE {
    if ( self = [super init] ) {
        self.avCaptureSession = [[AVCaptureSession alloc] init];
        self.dataOutputQueue = dispatch_queue_create( "data output queue", DISPATCH_QUEUE_SERIAL );
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (status) {
            case AVAuthorizationStatusAuthorized:
                break;
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if ( ! granted ) {
                        self.setupResult = AVCamSetupResultCameraNotAuthorized;
                    }
                }];
                break;
            }
            default: {
                self.setupResult = AVCamSetupResultCameraNotAuthorized;
                break;
            }
        }
        
        [self configureSession];
    }
    return self;
}

- (void)configureSession {
    if ( AVCamSetupResultSuccess != self.setupResult ) {
        return;
    }
    
    [self.avCaptureSession beginConfiguration];
//    [self.avCaptureSession setSessionPreset: AVCaptureSessionPresetHigh];
    [self.avCaptureSession setSessionPreset: AVCaptureSessionPreset1280x720];
    self.videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    NSError *error = nil;
    if ( ! self.videoDevice ) {
        NSLog(@"front true depth camera not available");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.avCaptureSession commitConfiguration];
        return;
    }
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    if ( ! self.videoDeviceInput ) {
        NSLog( @"Could not create video device input: %@", error );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.avCaptureSession commitConfiguration];
        return;
    }
    
    if ( [self.avCaptureSession canAddInput:self.videoDeviceInput] ) {
        [self.avCaptureSession addInput:self.videoDeviceInput];
    } else {
        NSLog( @"Could not add video device input to the session" );
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.avCaptureSession commitConfiguration];
        return;
    }
    
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.dataOutputQueue];
    if([self.avCaptureSession canAddOutput:self.videoDataOutput]){
        [self.avCaptureSession addOutput:self.videoDataOutput];
    } else {
        NSLog( @"Could not add video data output to the session");
        self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        [self.avCaptureSession commitConfiguration];
        return;
    }
    
    AVCaptureConnection *videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [videoConnection setVideoMirrored: YES];
    
    [self.avCaptureSession commitConfiguration];
}

- (void)startCE {
    switch (self.setupResult) {
        case AVCamSetupResultSuccess: {
            if (![self.avCaptureSession isRunning] && !hasStarted) {
                hasStarted = YES;
                [self.avCaptureSession startRunning];
                NSLog(@"AVCamSetupResultSuccess");
            }
            break;
        }
        case AVCamSetupResultCameraNotAuthorized: {
            NSLog(@"AVCamSetupResultCameraNotAuthorized");
            break;
        }
            
        default: {
            NSLog(@"configurationFailed");
            break;
        }
    }
}

- (void)stopCE {
    hasStarted = NO;
    if ([self.avCaptureSession isRunning]) {
        [self.avCaptureSession stopRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if( [self.delegate respondsToSelector:@selector(didOutputVideoBuffer:)] ) {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if ( pixelBuffer != nil) {
            [self.delegate didOutputVideoBuffer:pixelBuffer];
        }
    }
}

@end
