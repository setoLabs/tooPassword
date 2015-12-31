//
//  TPWValueObserver.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.01.13.
//
//

#import <Foundation/Foundation.h>

typedef void(^TPWObservationCallback)(NSDictionary *change);

@class TPWValueObserver;


@interface NSObject (TPWValueObserving)
- (TPWValueObserver*)observeValueForKeyPath:(NSString *)keyPath onChange:(TPWObservationCallback)callback;
@end


@interface TPWValueObserver : NSObject

@property (nonatomic, strong) NSObject *observedObject;
@property (nonatomic, strong) NSString *observedKeyPath;
@property (nonatomic, copy) TPWObservationCallback observationCallback;

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(NSObject*)object onChange:(TPWObservationCallback)callback;
- (void)stopObserving;

@end
