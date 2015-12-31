//
//  TPWValueObserver.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.01.13.
//
//

#import "TPWValueObserver.h"

@implementation NSObject (TPWValueObserving)

- (TPWValueObserver*)observeValueForKeyPath:(NSString *)keyPath onChange:(TPWObservationCallback)callback {
	TPWValueObserver *observerProxy = [[TPWValueObserver alloc] init];
	[observerProxy observeValueForKeyPath:keyPath ofObject:self onChange:callback];
	return observerProxy;
}

@end



@implementation TPWValueObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	self.observationCallback(change);
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(NSObject*)object onChange:(TPWObservationCallback)callback {
	self.observedObject = object; //retain strong reference to make sure, object still exists until observer is deallocated
	self.observedKeyPath = keyPath;
	self.observationCallback = callback;
	[self.observedObject addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)stopObserving {
	[self.observedObject removeObserver:self forKeyPath:self.observedKeyPath];
}

- (void)dealloc {
	[self stopObserving];
	//[super dealloc]; done by ARC
}

@end
