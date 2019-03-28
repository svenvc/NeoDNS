"
I am NeoDNSClient.
I am a NeoSimplifiedDNSClient.

  NeoDNSClient default addressForName: 'stfx.eu'.

I add caching respecting ttl to DNS requests.
I allow for multiple outstanding requests to be handled concurrently.

Implementation

UDP requests are asynchroneous and unreliable by definition. Since DNS requests can take some time, it should be possible to have multiple in flight at the same time, thus concurrently. Replies will arrive out of order and need to be matched to their outstanding request by id.

If a request has been seen before and its response is not expired, it will be answered from the cache.

Each incoming request is handled by creating a NeoDNSRequest object and adding that to the request queue. This triggers the start up of the backend process, if necessary. The client then waits on the semaphore inside the request object, limited by the timeout.

The backend process loops while there are still outstanding requests that have not expired. It sends all unsent requests at once, and then listens briefly for incoming replies. It cleans up expired requests. When a reply comes in, it is connected to its request by id. The semaphore in the request object is then signalled so that the waiting client can continue and the request is removed from the queue. The process then loops. If the queue is empty, the backend process stops.

"
Class {
	#name : #NeoDNSClient,
	#superclass : #NeoSimplifiedDNSClient,
	#instVars : [
		'requestQueue',
		'cache',
		'idCounter',
		'process',
		'socket'
	],
	#category : #'Net-Protocols-DNS-Experimental'
}

{ #category : #'class initialization' }
NeoDNSClient class >> initialize [
	SessionManager default registerNetworkClassNamed: self name
]

{ #category : #installation }
NeoDNSClient class >> install [
	"Install my default instance in NetNameResolver"
	
	"self install"
	
	NetNameResolver class compile: 'addressForName: hostname
	^ NeoDNSClient default addressForName: hostname'.
	
	NetNameResolver class compile: 'addressForName: hostname timeout: seconds
	^ NeoDNSTimeout value: seconds during: [ NeoDNSClient default addressForName: hostname ]'
]

{ #category : #'system startup' }
NeoDNSClient class >> startUp: isImageStarting [
	(isImageStarting and: [ default notNil ])
		ifTrue: [ self default reset ]
]

{ #category : #process }
NeoDNSClient >> cleanupExpiredRequests [
	requestQueue flushAllSuchThat: [ :dnsRequest | dnsRequest isExpired ]
]

{ #category : #initialization }
NeoDNSClient >> clearCache [
	cache removeAll
]

{ #category : #initialization }
NeoDNSClient >> clearProcessAndSocket [
	| s p |
	s := socket.
	p := process.
	process := socket := nil.	
	s ifNotNil: [ [ s closeAndDestroy ] on: Exception do: [ ] ].
	p ifNotNil: [ [ p terminate ] on: Exception do: [ ] ]
]

{ #category : #initialization }
NeoDNSClient >> clearRequestQueue [
	requestQueue removeAll
]

{ #category : #accessing }
NeoDNSClient >> dnsReplyTimeout [
	^ 1/10
]

{ #category : #process }
NeoDNSClient >> ensureProcess [
	process ifNil: [ self start ]
]

{ #category : #private }
NeoDNSClient >> executeQuery: query andDo: block [
	cache 
		at: query questions first 
		ifPresent: [ :response | 
			response timedOut
				ifTrue: [ cache removeKey: query questions first ]
				ifFalse: [ ^ block value: response ] ].
	^ (self queueQuery: query)
			waitThenDo: [ :response |
				cache at: query questions first put: response.
				block value: response ] 
]

{ #category : #initialization }
NeoDNSClient >> initialize [
	super initialize.
	idCounter := 1000.
	requestQueue := SharedQueue new.
	cache := Dictionary new
]

{ #category : #private }
NeoDNSClient >> nextId [
	^ idCounter := idCounter + 1 \\ 16rFFFF
]

{ #category : #accessing }
NeoDNSClient >> processName [
	^ self class name asString , ' process'
]

{ #category : #private }
NeoDNSClient >> queueQuery: query [
	| dnsRequest |
	query id: self nextId.
	dnsRequest := NeoDNSRequest new.
	dnsRequest requestMessage: query.
	requestQueue nextPut: dnsRequest.
	self ensureProcess.
	^ dnsRequest 
]

{ #category : #process }
NeoDNSClient >> receiveResponse [
	| response |
	response := [ self receiveUDPDataFrom: socket ] 
							on: ConnectionTimedOut
							do: [ ^ self ].
	response := DNSMessage readFrom: response first readStream.
	(requestQueue findFirst: [ :dnsRequest | dnsRequest requestMessage id = response id ])
		ifNotNil: [ :dnsRequest | 
			dnsRequest responseMessage: response.
			dnsRequest markAsReceived ]
]

{ #category : #initialization }
NeoDNSClient >> reset [
	self clearCache.
	self clearRequestQueue.
	self clearProcessAndSocket
]

{ #category : #process }
NeoDNSClient >> sendOpenRequests [
	[ (requestQueue findFirst: [ :dnsRequest | dnsRequest isSent not ])
		ifNil: [ false ]
		ifNotNil: [ :dnsRequest | 
			socket 
				sendUDPData: dnsRequest requestMessage asByteArray 
				toHost: self dnsServerAddress 
				port: self dnsServerPort.
			dnsRequest markAsSent.
			requestQueue nextPut: dnsRequest.
			true ] ] whileFalse
]

{ #category : #process }
NeoDNSClient >> start [
	socket := Socket newUDP.
	process := [ 
		[ 
			[ requestQueue isEmpty ] whileFalse: [ self work ].
		] ensure: [
				self cleanupExpiredRequests.
				self clearProcessAndSocket ]
	] 
		forkAt: Processor lowIOPriority 
		named: self processName
]

{ #category : #process }
NeoDNSClient >> work [
	self 
		sendOpenRequests;
		receiveResponse;
		cleanupExpiredRequests
	
]
