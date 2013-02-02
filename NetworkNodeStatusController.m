/**
 * @file NetworkNodeStatusController.m
 * 
 * @author Perry Spagnola
 * @date 3/7/11 - created
 * @version 1.0
 * @brief Class file for the NetworkNodeStatusController class.
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

#import "NetworkNodeStatusController.h"


@implementation NetworkNodeStatusController

@synthesize managedObjectContext;

/**
 * Initialize state information being loaded from the Interface Builder archive (nib file).
 */
-(void)awakeFromNib {
	
	managedObjectContext = [networkNodes managedObjectContext];
	
	/**
	 * Create a fetch request to retrieve the "Service" entity objects for this context
	 * if they exist.
	 */
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Service" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	/**
	 * Create the predicate for the fetch request that retrieves all of
	 * the Service objects.
	 */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier >  %@)", @""];
	// DEBUG: NSLog(@"predicate: %@", predicate);
	[request setPredicate:predicate];
	
	/**
	 * Attempt to fetch the Service managed objects.
	 */
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	// DEBUG: NSLog(@"array: %@", array);

	NSNetServiceBrowser *serviceBrowser;

	/**
	 * Iterate through the array of Service types.
	 */
	for (int i=0; i<[array count]; i++) {
		
		// DEBUG: NSLog(@"Service name: %@", [[array objectAtIndex:i]valueForKey:@"identifier"]);

		/**
		 * Create and initialize a service browser for each service type.
		 */
		serviceBrowser = [[NSNetServiceBrowser alloc] init];
		[serviceBrowser setDelegate:self];
		
		/**
		 * Start the browser for the service type.
		 */
		[serviceBrowser searchForServicesOfType:[[array objectAtIndex:i]valueForKey:@"identifier"] inDomain:@""];
		  
	}
	
}

/**
 * Implementation of <code>dealloc</code>, to release the retained variables.
 */
-(void)dealloc {
	[managedObjectContext release];
	[super dealloc];
}


/**
 * Retrieves a managed object for the specified service if it exists. This is a
 * convenience method for finding the managed object that has experienced a
 * change in status or availability
 * @param the NSNetService that has changed its status
 * @return the <code>NSManagedObject</code>, if it was found, <code>nil</code>, if not
 */
-(NSManagedObject *)managedObjectForService:(NSNetService *)aService {
	
	/**
	 * Initialize the return value to <code>nil</code>. If the managed object
	 * is not found, and it falls through, this is returned.
	 */
	NSManagedObject *managedObject = nil;
	
	/**
	 * Create a fetch request to retrieve the "NetworkNode" entity object for this service
	 * if it exists.
	 */
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"NetworkNode" inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	/**
	 * Create the predicate for the fetch request that retrieves the managed object
	 * that corresponds to the found Service.
	 */
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(host = %@)", [aService name]];
	// DEBUG: NSLog(@"predicate: %@", predicate);
	[request setPredicate:predicate];
	
	/**
	 * Attempt to fetch the NetworkNode managed object.
	 */
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	// DEBUG: NSLog(@"array: %@", array);
	if ([array count] == 1) {
		/**
		 * The fetch request returned a single object. This is the managed object associated
		 * with the service. Set the return value, a pointer to this object.
		 */
		managedObject = [array objectAtIndex:0];
	}
	
	/**
	 * Finally, return the found object, or <code>nil</code>, if it was not found.
	 */
	return managedObject;
}


#pragma mark Net Service Browser Delegate Methods
/**
 * Browser delegate response when a service is found. Sets the managed object associated
 * with the service to "1" or TRUE.
 * @param aBrowser Sender of this delegate message
 * @param aService Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
 * @param moreComing YES when netServiceBrowser is waiting for additional services. NO when there are no additional services.
 */
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
	// DEBUG: NSLog(@"Found Service: %@", [aService name]);
	
	NSManagedObject *managedObject = [self managedObjectForService:aService];
	if (managedObject) {
		[managedObject setValue:[NSNumber numberWithBool:1] forKey:@"status"];
	}
}

/**
 * Browser delegate response when a service is removed. Sets the managed object associated
 * with the service to "0" or FALSE.
 * @param aBrowser Sender of this delegate message
 * @param aService Network service found by netServiceBrowser. The delegate can use this object to connect to and use the service.
 * @param moreComing YES when netServiceBrowser is waiting for additional services. NO when there are no additional services.
 */
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
	// DEBUG: NSLog(@"Remove Service: %@", [aService name]);
	
	NSManagedObject *managedObject = [self managedObjectForService:aService];
	if (managedObject) {
		[managedObject setValue:[NSNumber numberWithBool:0] forKey:@"status"];
	}
}

/**
 * Network service delegate response when a service is resolved. Shouldn't do anything. 
 * No attempt is made to resolve the browsed services. Calling of this method is an error,
 * and the attempt is simply logged.
 * @param aService the service that was resolved
 */
-(void)netServiceDidResolveAddress:(NSNetService *)aService {
	NSLog(@"Service: %@, resolved.", [aService name]);

}

/**
 * Network service delegate response when a service is not resolved. Shouldn't do anything. 
 * No attempt is made to resolve the browsed services. Calling of this method is an error,
 * and the attempt is simply logged.
 * @param aService the service that was resolved
 */
-(void)netService:(NSNetService *)aService didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Could not resolve: %@, error: %@", [aService name], errorDict);
}

@end
