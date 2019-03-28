"
I am NeoSimplifiedDNSClient.

I resolve fully qualified hostnames into low level IP addresses.

  NeoSimplifiedDNSClient default addressForName: 'stfx.eu'.

I use the UDP DNS protocol.
I handle localhost and dot-decimal notation.

I can be used to resolve Multicast DNS addresses too.

  NeoSimplifiedDNSClient new useMulticastDNS; addressForName: 'zappy.local'.

Implementation

I execute requests sequentially and do not cache results.
This means that only one request can be active at any single moment.
It is technically not really necessary to use my default instance as I do not hold state.


"
Class {
	#name : #NeoSimplifiedDNSClient,
	#superclass : #Object,
	#instVars : [
		'access',
		'servers',
		'port'
	],
	#classInstVars : [
		'default'
	],
	#category : #'Net-Protocols-DNS-Experimental'
}

{ #category : #accessing }
NeoSimplifiedDNSClient class >> default [
	^ default ifNil: [ default := self new ]
]

{ #category : #accessing }
NeoSimplifiedDNSClient class >> getSystemDNS [
	"Return the DNS resolver as defined by the operating system.
	Get this information from /etc/resolve.conf
	See also https://en.wikipedia.org/wiki/Resolv.conf
	This won't work on Windows."
	
	"self getSystemDNS"

	| resolveConfContents nameserverLines |
	resolveConfContents := '/etc/resolv.conf' asFileReference contents.
	nameserverLines := resolveConfContents lines 
		select: [ :line | line beginsWith: 'nameserver' ].
	nameserverLines do: [ :each | 
		([ SocketAddress fromDottedString: ($ split: each) second ] on: Error do: [ nil ])
			ifNotNil: [ :socketAddress | ^ socketAddress ] ].
	NotFound signal: 'Cannot determine Operating System DNS resolver'
]

{ #category : #private }
NeoSimplifiedDNSClient >> addressByName: hostname [
	^ self addressForName: hostname
]

{ #category : #public }
NeoSimplifiedDNSClient >> addressForName: hostname [
	"Look up and return the IP address for hostname with a DNS server"

	hostname = self loopbackName 
		ifTrue: [ ^ self loopbackAddress ].
	(self dotDecimalNotationOrNil: hostname)
		ifNotNil: [ :address | ^ address ].
	^ [ self 
			executeQuery: (DNSMessage addressByName: hostname) 
			andDo: [ :response | (response answers first addressUsing: self) asSocketAddress ] ]
		on: Error
		do: [ NameLookupFailure signalFor: hostname ]
]

{ #category : #private }
NeoSimplifiedDNSClient >> addressesByName: hostname [
	^ #()
]

{ #category : #public }
NeoSimplifiedDNSClient >> anyRecordsForName: hostname [
	"Look up and return all known records for hostname with a DNS server"

	^ [ self 
			executeQuery: (DNSMessage anyRecordsFor: hostname) 
			andDo: [ :response | response ] ]
		on: Error
		do: [ NameLookupFailure signalFor: hostname ]
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> beThreadSafe [
	"Configure me so that I can be safely used from multiple threads/processes
	during important operations. Note that this slows down these operations."
	
	access := Monitor new
]

{ #category : #private }
NeoSimplifiedDNSClient >> critical: block [
	"Execute block optionally protected by access"
	
	^ access
		ifNil: block
		ifNotNil: [ access critical: block ]
]

{ #category : #accessing }
NeoSimplifiedDNSClient >> dnsReplyTimeout [
	"Number of seconds to wait for an UDP DNS server reply"
	
	^ NeoDNSTimeout value
]

{ #category : #accessing }
NeoSimplifiedDNSClient >> dnsServerAddress [
	"Return a SocketAddress of a DNS server to use, selected at random from our list of configured servers"
	
	^ servers atRandom
]

{ #category : #accessing }
NeoSimplifiedDNSClient >> dnsServerPort [
	"Standard DNS server port, unless configured otherwise"
	
	^ port ifNil: [ port := 53 ]
]

{ #category : #private }
NeoSimplifiedDNSClient >> dotDecimalNotationOrNil: string [
	"Either convert string from a dot-decimal notation to a socket address, or return nil"

	^ [ self parseDotDecimalNotation: string ]
		on: Error
		do: [ nil ]
]

{ #category : #private }
NeoSimplifiedDNSClient >> executeQuery: query andDo: block [
	| response socket |
	socket := Socket newUDP.
	^ [ 
		response := self request: query on: socket.
		response checkResponseCodeDo: [ :code :errorMessage | 
			"Will be catched and resignalled higher up anyway"
			self error: ('DNS query failed: {1} [{2}]' format: { errorMessage. code }) ].
		block value: response ]
			ensure: [ socket closeAndDestroy ]
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> initialize [
	super initialize.
	self useCloudflareDNS.
	self beThreadSafe
]

{ #category : #accessing }
NeoSimplifiedDNSClient >> loopbackAddress [
	"Return the socket address of the loop back network interface"
	
	^ #[127 0 0 1] asSocketAddress
]

{ #category : #accessing }
NeoSimplifiedDNSClient >> loopbackName [
	"Return the hostname of the loop back network interface"
	
	^ 'localhost'
]

{ #category : #public }
NeoSimplifiedDNSClient >> nameForAddress: address [
	"Look up and return the name for address with a DNS server"

	address = self loopbackAddress
		ifTrue: [ ^ self loopbackName ].
	^ [ self 
			executeQuery: (DNSMessage reverseLookup: address) 
			andDo: [ :response | response answers first cname ] ]
		on: Error
		do: [ NameLookupFailure signalFor: address ]
]

{ #category : #private }
NeoSimplifiedDNSClient >> parseDotDecimalNotation: string [
	"Try to parse string assuming it is an IPv4 address in dot-decimal notation.
	Return the socket address else fail."
	
	| elements |
	elements := $. split: string.
	^ (elements collect: #asNumber) asByteArray asSocketAddress
	
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> port: integer [
	port := integer
]

{ #category : #private }
NeoSimplifiedDNSClient >> receiveUDPDataFrom: socket [
	"Receive a UDP datagram from socket, return a 3-element array:
	{ contents. source host address. source port }"

	| buffer result |
	buffer := ByteArray new: 512.
	socket waitForDataFor: self dnsReplyTimeout.
	result := socket receiveUDPDataInto: buffer.
	^ Array 
		with: (buffer copyFrom: 1 to: result first) 
		with: result second 
		with: result third
]

{ #category : #private }
NeoSimplifiedDNSClient >> request: request on: socket [
	"Send request to socket and return the parsed result"
	
	| response |
	socket 
		sendUDPData: request asByteArray 
		toHost: self dnsServerAddress 
		port: self dnsServerPort.
	response := self receiveUDPDataFrom: socket.
	response := DNSMessage readFrom: response first readStream.
	^ response
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> servers: collectionOfSocketAddresses [
	servers := collectionOfSocketAddresses 
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> useCloudflareDNS [
	"Use Cloudflare's DNS Servers"
	
	self servers: #( #[1 1 1 1] #[1 0 0 1] )
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> useGoogleDNS [
	"Use Google's DNS Servers"
	
	self servers: #( #[8 8 8 8] #[8 8 4 4] )
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> useMulticastDNS [
	"Use the standard Multicast DNS server"
	
	self servers: #( #[224 0 0 251] ).
	self port: 5353
]

{ #category : #initialization }
NeoSimplifiedDNSClient >> useSystemDNS [
	"Use the DNS resolver as defined by the operating system.
	Get this information from /etc/resolve.conf
	See also https://en.wikipedia.org/wiki/Resolv.conf
	This won't work on Windows."

	self servers: { self class getSystemDNS }
]
