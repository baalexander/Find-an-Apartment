#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    int retVal;
    //HOME_FINDER or FIND_AN_APARTMENT defined in the target's GCC_PREPROCESSOR_DEFINITIONS
    #ifdef HOME_FINDER
        retVal = UIApplicationMain(argc, argv, nil, @"HomeFinderAppDelegate");
    #else
        retVal = UIApplicationMain(argc, argv, nil, @"FindAnApartmentAppDelegate");
    #endif
    
    [pool release];

    return retVal;
}
