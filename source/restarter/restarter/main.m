#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>//NSWorkspace

#define DEFAULT_TIMEOUT 180

@interface Restarter : NSObject
{
	NSString *dataPath;
	NSString *structurePath;
	NSString *applicationPath;
	NSURL *url;
	NSString *urlString;
	NSRunningApplication *application;
	BOOL isReady;
	NSTimeInterval timeout;
}
- (id)initWithProcessInfo:(NSProcessInfo*)processInfo;
- (void)quit;
- (void)start;
- (void)onTimer:(NSTimer *)timer;
- (void)terminate;
- (void)dealloc;
+ (NSString *)pathFromPath:(NSString *)path;
@end

@implementation Restarter

- (void)dealloc
{
	[super dealloc];
}
- (void)terminate
{
	exit(0);
}

+ (NSString *)pathFromPath:(NSString *)path
{
	NSString *pathString = @"";
	NSURL *u = (__bridge NSURL *)CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
																														 (CFStringRef)path,
																														 kCFURLHFSPathStyle, false);
	if(u)
	{
		NSString *s = (__bridge NSString *)CFURLCopyFileSystemPath((CFURLRef)u, kCFURLPOSIXPathStyle);
		pathString = [NSString stringWithString:s];
		[s release];
		[u release];
	}
	return pathString;
}

- (void)start
{
	NSArray *arguments = [NSArray arrayWithObjects:
												@"-a", url,
												@"--args",
												@"--structure", structurePath,
												@"--data", dataPath, nil];
	NSTask *task = [[NSTask alloc]init];
	[task setLaunchPath: @"/usr/bin/open"];
	[task setArguments:arguments];
	[task launch];
	[task release];
	
	[self terminate];
}

- (void)onTimer:(NSTimer *)timer
{
	if([application isTerminated])
	{
		[timer invalidate];
		[self start];
	}
}

- (void)quit
{
	NSTimer *timer = nil;
	
	if(isReady)
	{
		NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
		NSArray *runningApplications = [workspace runningApplications];
		for(NSUInteger i = 0;i < [runningApplications count];++i)
		{
			NSRunningApplication *runningApplication = [runningApplications objectAtIndex:i];
			NSURL *bundleURL = [runningApplication bundleURL];
			if(bundleURL)
			{
				if([[bundleURL absoluteString]caseInsensitiveCompare:urlString] == NSOrderedSame)
				{
					application = runningApplication;
					[application terminate];
					NSLog(@"terminating:%@\n", applicationPath);
					
					timer = [NSTimer scheduledTimerWithTimeInterval:1.0
																														target:self
																													selector:@selector(onTimer:)
																													userInfo:nil
																													 repeats:YES];
					
					[[NSRunLoop currentRunLoop]
					 addTimer:timer
					 forMode:NSDefaultRunLoopMode];
					
					NSLog(@"starting timer:%f\n", timeout);
					
					[[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
					break;
				}
			}
		}//for
		
		if(!timer)
		{
			[self start];
		}
	}else
	{
		[self terminate];
	}

}

- (id)initWithProcessInfo:(NSProcessInfo*)processInfo
{
	if(!(self = [super init])) return self;
	
	timeout = DEFAULT_TIMEOUT;
	
	NSArray *arguments = [processInfo arguments];
	
	for(NSUInteger i = 1;i < [arguments count]-1;++i)
	{
		NSString *argument = [arguments objectAtIndex:i];
		if([argument isEqualToString:@"-a"])
		{
			applicationPath =  [Restarter pathFromPath:[arguments objectAtIndex:i+1]];
			NSLog(@"applicationPath:%@\n", applicationPath);
			
			url = (__bridge NSURL *)CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
																														(CFStringRef)[arguments objectAtIndex:i+1],
																														kCFURLHFSPathStyle, false);
			
			urlString = [url absoluteString];
			NSLog(@"URL:%@\n", urlString);
			
		}else
			if([argument isEqualToString:@"-s"])
			{
				structurePath = [Restarter pathFromPath:[arguments objectAtIndex:i+1]];
				NSLog(@"structurePath:%@\n", structurePath);
			}else
				if([argument isEqualToString:@"-d"])
				{
					dataPath = [Restarter pathFromPath:[arguments objectAtIndex:i+1]];
					NSLog(@"dataPath:%@\n", dataPath);
				}else
					if([argument isEqualToString:@"-t"])
					{
						timeout = [[arguments objectAtIndex:i+1]doubleValue];
						NSLog(@"timeout:%f\n", timeout);
					}
					
	}
	
	isReady = (dataPath && structurePath && applicationPath);
	
	return self;
}
@end

int main(int argc, const char * argv[])
{
	Restarter *restarter = [[Restarter alloc]initWithProcessInfo:[NSProcessInfo processInfo]];
	[restarter quit];
	[restarter release];
	
	return 0;
}
