/**
 * @file ResolvedService.m
 * 
 * @author Perry Spagnola
 * @date 2/20/11 - created
 * @version 1.0
 * @brief Class file for the ResolvedService class.
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

#import "ResolvedService.h"
#import <netinet/in.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import "wol_lib.h"

@implementation ResolvedService

@synthesize host;
@synthesize domain;
@synthesize ipAddr;
@synthesize macAddr;
@synthesize owner;
@synthesize icon;
@synthesize name;
@synthesize type;
@synthesize status;

/**
 * Specialized initializer. Initializes the object with an NSNetService
 * object.
 * @param service the NSNetService object
 * @see ResolvedService
 * @see NSNetService
 * @return a pointer to the created ResolvedService object
 */
-(ResolvedService*) initWithNSNetService: (NSNetService*) service {
	
	self = [super init];
	
	if (self) {
		[self setValue:[NSNumber numberWithBool:YES] forKey:@"status"];
		[self setValue:@"" forKey:@"owner"];
		[self setValue:@"" forKey:@"icon"];

		/**
		 * Create NSString objects for the host name and the domain.
		 */
		host = [[NSString alloc] initWithString:[service name]];
		domain = [[NSString alloc] initWithString:[service domain]];
		type = [[NSString alloc] initWithString:[service type]];
		NSData *address = nil;
		struct sockaddr_in *socketAddress = nil;
		char *ipString = nil;
		int port;
		
		/**
		 * A service is published on ALL network addresses, so addresses
		 * may contain more than one IP. Get the first one.		 
		 */
		if ([[service addresses] count] != 0) {
			address = [[service addresses] objectAtIndex: 0];
			
			/**
			 * IPs are sockaddr_in structures encapsulated in NSData...
			 * Extract the IP string and the port into char arrays.
			 */
			socketAddress = (struct sockaddr_in *) [address bytes];
			ipString = inet_ntoa(socketAddress->sin_addr);
			port = socketAddress->sin_port;
			
			/**
			 * Create an NSString object and copy the IP string char array contents into it.
			 */
			NSString *ipTempStr = [NSString stringWithUTF8String: ipString];
			ipAddr = [[NSString alloc] initWithString:ipTempStr];
			
			/**
			 * Now that we have the IP address, ping it, and get the MAC
			 * address. First, create a small char array to hold the it.
			 */
			char macAddrStr[64] = "";
			
			/**
			 * Ping the IP to make sure that there will be an ARP table entry
			 * for the node. There will be no entry if the ping is not
			 * successful.
			 */
			int pingError = pingIP(ipString);
			if(pingError != 0) {
				NSLog(@"pingIP() failed, error code %d", pingError);
			}
			
			/**
			 * Insert a delay to make sure the ARP table has time to update.
			 */
			[NSThread sleepForTimeInterval:0.2];
			
			/**
			 * Get the MAC address for the IP address of the service.
			 */
			int macError = macForIP(ipString, macAddrStr);
			if (macError != 0) {
				NSLog(@"macForIP() failed, error code %d", macError);
			}
			
			/**
			 * Create an NSString object and copy the char array contents into it.
			 */
			NSString *macTempStr = [NSString stringWithUTF8String: macAddrStr];
			macAddr = [[NSString alloc] initWithString:macTempStr];
						
			// DEBUG: NSLog(@"Service - host: %@, IP: %s, MAC string: %s, MAC: %@", host, ipString, macAddrStr, macAddr);			
			
		} else {
			/**
			 * Log the condition if the address entries are empty.
			 */
			NSLog(@"Service addresses entries empty.");
		}
		
	}
	
	return self;
	
}


@end
