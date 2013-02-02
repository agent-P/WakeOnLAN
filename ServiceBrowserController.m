/**
 * @file ServiceBrowserController.m
 * 
 * @author Perry Spagnola
 * @date 2/19/11 - created
 * @version 1.0
 * @brief Class file for the ServiceBrowserController class.
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

#import "ServiceBrowserController.h"



@implementation ServiceBrowserController

@synthesize browser;
@synthesize services;
@synthesize foundServices;
//@synthesize isConnected;
@synthesize connectedService;
@synthesize resolvedService;
@synthesize serviceCount;

/**
 * Initialize state information being loaded from the Interface Builder archive (nib file).
 */
-(void)awakeFromNib {
    services = [NSMutableArray new];
    foundServices = [NSMutableArray new];
    self.browser = [[NSNetServiceBrowser new] autorelease];
    self.browser.delegate = self;
}

/**
 * Implementation of <code>dealloc</code>, to release the retained variables.
 */
-(void)dealloc {
	[browser stop];
    self.browser = nil;
    [services release];
    [foundServices release];
    [super dealloc];
}


/**
 * Performs the scan action for the Bonjour service browser. Retrievs the 
 * type of service to scan for from the service types browser. Note, starts
 * the progress indicator for the scan.
 * @param sender  the object that sent the action
 * @see IBAction
 * @return the IBAction object
 */
-(IBAction)scan:(id)sender {
	// DEBUG: NSLog(@"Scanning for Bonjour services...");
	
	/**
	 * Set the service count to zero, and start animating the progress
	 * indicator. Note, the service count is only used to support the
	 * progress indicator. See comments in the other methods for description
	 * of the closed loop functionality.
	 */
	serviceCount = 0;
	[scanProgressIndicator startAnimation:self];
	
	/**
	 * Retrieve the selected service type. The type identifier required
	 * for scanning needs to be built for two members of the service
	 * object.
	 */
	NSArray *selected = [serviceTypes selectedObjects];
	
	/**
	 * Get the service name and append a "." to terminate it.
	 */
	NSString *serviceName = [[[selected valueForKey:@"name"] objectAtIndex:0]stringByAppendingString:@"."];
	
	/**
	 * Get the service network protocol and append it to the service name. Note,
	 * have to trim the domain from the protocol to make a usable identifier.
	 * Gets only the first five (5) characters of the service type.
	 */
	NSString *serviceProtocol = [[[selected valueForKey:@"type"] objectAtIndex:0] substringToIndex:5];
	NSString *serviceType = [serviceName stringByAppendingString:serviceProtocol];
	
    // DEBUG: NSLog(@"Type to scan for: %@", serviceType);
	
	/**
	 * To allow for multiple scans with the same or different type of serice,
	 * stop the browser and clear the arrays populated by the services.
	 */
	[self.browser stop];	
	[foundServices removeAllObjects];
	[[servicesController content] removeAllObjects];
	
	/**
	 * Start the browser to search for the selected service type.
	 */
	[self.browser searchForServicesOfType:serviceType inDomain:@""];
}


#pragma mark Net Service Browser Delegate Methods
/**
 * Browser delegate response when a service is found. Adds the service to the found services array.
 * Sets the browser controller object as the service delegate, and attempts to resolve the service.
 * @param aBrowser Sender of this delegate message
 * @param aService Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
 * @param moreComing YES when netServiceBrowser is waiting for additional services. NO when there are no additional services.
 */
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
	
	/**
	 * Add the service to the <code>foundServices</code> array.
	 */
	[foundServices addObject:aService];
	// DEBUG: NSLog(@"Service: %@.%@ found.", [aService name], [aService domain]);

	/**
	 * Set the service delegate to <code>self</code>.
	 */
	[aService setDelegate: self];
	
	/**
	 * Attempt to resolve the service. Set the resolve timeout to 2 seconds.
	 */
	[aService resolveWithTimeout:2];
	
	/**
	 * Found a service. Increment the service count.
	 */
	serviceCount++;
	// DEBUG: NSLog(@"more services coming... count = %d", serviceCount);

}

/**
 * Browser delegate response when a service becomes unavailable. Removes the service from the found services array.
 * @param aBrowser Sender of this delegate message
 * @param aService Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
 * @param moreComing YES when netServiceBrowser is waiting for additional services. NO when there are no additional services.
 */
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
	/**
	 * Remove the service from the <code>foundServices</code> array.
	 */
    [foundServices removeObject:aService];
}


/**
 * Network service delegate response when a service is resolved. Creates a resolved service object.
 * Adds the resolved service to the service browser array controller, and monitors the service
 * to get its device info. Note, stops the progress indicator for the scan.
 * @param aService the service that was resolved
 */
-(void)netServiceDidResolveAddress:(NSNetService *)aService {
    self.connectedService = aService;
	// DEBUG: NSLog(@"Service: %@.%@ resolved.", [aService name], [aService domain]);
	
	/**
	 * Create a <code>ResolvedService</code> object, and initialize it with the resolved service.
	 */
	ResolvedService *rService = [[ResolvedService alloc] initWithNSNetService:aService];
	// DEBUG: NSLog(@"host: %@, domain: %@, IP: %@, MAC: %@", [rService host], [rService domain], [rService ipAddr], [rService macAddr]);
	
	/**
	 * Add the <code>ResolvedService</code> object to the service browser array controller.
	 */
	[servicesController addObject:rService];
	
	/**
	 * Create a new <code>NSNetService</code> object, and initialize it with the "local" domain, the
	 * the <code>_device-info._tcp</code> service type, and the name of the resolved service.
	 */
	aService = [[NSNetService alloc]initWithDomain:@"local." type:@"_device-info._tcp" name:[aService name]];
	
	/**
	 * Set the created service delegate to <code>self</code>, and start monitoring the service.
	 */	
	[aService setDelegate: self];
	[aService startMonitoring];
	
	/**
	 * Decrement the service count. If it is less than or equal to zero,
	 * all the services that are found are either resolved or not, and
	 * the progress indicator can stop animating.
	 */
	if (--serviceCount <= 0) {
		[scanProgressIndicator stopAnimation:self];
	}
}


/**
 * Network service delegate response when a service is not resolved. Decrements
 * the service count, and then simply logs the error.
 */
-(void)netService:(NSNetService *)aService didNotResolve:(NSDictionary *)errorDict {
	
	/**
	 * Decrement the service count so the progress indicator stops when
	 * all the services that are found are either resolved or not.
	 */
	--serviceCount;
	
	/**
	 * Log the error, so we can see if a service is not being resolved.
	 */
    NSLog(@"Could not resolve: %@ %@", [aService name], errorDict);
}


/**
 * Network service delegate response when a service updates its text record. Get the model identifier
 * from the text record, and set the appropriate object record in the array controller.
 * @param aService the service that updated its text record
 * @param data the text record data
 */
-(void)netService:(NSNetService *)aService didUpdateTXTRecordData:(NSData *)data {
	/**
	 * Extract the model identifier from the text record.
	 */
	NSString *model = [[[NSString alloc] initWithData:[[NSNetService dictionaryFromTXTRecordData:data] valueForKey:@"model"] encoding:NSUTF8StringEncoding]autorelease];
	// DEBUG: NSLog(@"%@", model);
	
	/**
	 * Got the model identifier. No need to continue monitoring. So stop the monitoring.
	 */
	[aService stopMonitoring];
	
	/**
	 * Get the array of arranged objects from the array controller.
	 */
	NSArray *rServices = [servicesController arrangedObjects];
	// DEBUG: NSLog(@"%@", [rServices valueForKey:@"host"]);
	
	/** 
	 * Create an <code>NSPredicate</code> object to filter where host equals the updating service's name.
	 * and filter the arranged objects to get the object associated with the updating service.
	 */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(host = %@)", [aService name]];
	NSArray *filtered = [rServices filteredArrayUsingPredicate:predicate];
	// DEBUG: NSLog(@"%@", [filtered valueForKey:@"host"]);
	
	/**
	 * Get the updating service's object, and set its model identifier.
	 */
	ResolvedService *resolved = [filtered lastObject];
	[resolved setValue: model forKey:@"icon"];	

}	
	
	

@end
