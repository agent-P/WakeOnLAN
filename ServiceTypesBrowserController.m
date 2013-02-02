/**
 * @file ServiceTypesBrowserController.m
 * 
 * @author Perry Spagnola
 * @date 3/5/11 - created
 * @version 1.0
 * @brief Class file for the ServiceTypesBrowserController class.
 *
 * @copyright Copyright 2011 Perry M. Spagnola. All rights reserved.
 *
 * @section LICENSE
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details at
 * http://www.gnu.org/copyleft/gpl.html
 */

#import "ServiceTypesBrowserController.h"


@implementation ServiceTypesBrowserController

@synthesize browser;
@synthesize services;

/**
 * Initialize state information being loaded from the Interface Builder archive (nib file).
 */
-(void)awakeFromNib {
    services = [NSMutableArray new];
    self.browser = [[NSNetServiceBrowser new] autorelease];
    self.browser.delegate = self;
	
	[self.browser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@"local."];

}

/**
 * Implementation of <code>dealloc</code>, to release the retained variables.
 */
-(void)dealloc {
    self.browser = nil;
    [services release];
    [super dealloc];
}


#pragma mark Net Service Browser Delegate Methods
/**
 * Browser delegate response when a service is found. Adds the service to the service types array
 * controller, and sets the browser types controller object as the service delegate.
 * @param aBrowser Sender of this delegate message
 * @param aService Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
 * @param moreComing YES when netServiceBrowser is waiting for additional services. NO when there are no additional services.
 */
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    [serviceTypesController addObject:aService];
	// DEBUG: NSLog(@"service: %@, name: %@, domain: %@, type: %@", aService, [aService name], [aService domain], [aService type]);
}

/**
 * Browser delegate response when a service becomes unavailable. Removes the service from the service types array
 * controller.
 * @param aBrowser Sender of this delegate message
 * @param aService Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
 * @param moreComing YES when netServiceBrowser is waiting for additional services. NO when there are no additional services.
 */
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    [serviceTypesController removeObject:aService];
}

/**
 * Network service delegate response when a service is resolved. Doesn't do anything, yet. Nothing
 * really required for simply browsing the service types available in the <code>local</code>. domain.
 * @param aService the service that was resolved
 */
-(void)netServiceDidResolveAddress:(NSNetService *)aService {

}

/**
 * Network service delegate response when a service is not resolved. Simply logs the error.
 */
-(void)netService:(NSNetService *)aService didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Could not resolve: %@", errorDict);
}

@end
