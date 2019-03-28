"
Main entry point class for normal usage of the DNS.  

| nr |
nr := NameResolver default.
nr servers: {  #(69 93 127 10)  }. 
nr anyRecordsFor: 'example.com'.

| nr |
nr := NameResolver default.
nr servers: {  #(8 8 8 8) }. 
nr addressesByName: 'example.com'.

Structure:
 servers 		SeqColl of ByteArray(4) -- Each ByteArray is an IP addr of a server.	
 cache 			Dictionary of DNSMessages -- keyed by DNSQuery
 protocolPolicy 	Symbol -- Either #both, #udp or #tcp.  Controls which protocols get used in resolution
 shouldCache 	Boolean -- Control if the cache is used to resolve queries
 udpTimeout 	Integer or Nil -- Seconds until a UDP timeout occcurs when querying.

Any further useful comments about the general approach of this implementation.
"
Class {
	#name : #NameResolver,
	#superclass : #Object,
	#instVars : [
		'servers',
		'cache',
		'protocolPolicy',
		'shouldCache',
		'udpTimeout'
	],
	#classVars : [
		'Default'
	],
	#category : #'Net-Protocols-DNS-NameResolver'
}

{ #category : #accessing }
NameResolver class >> default [
	^ Default ifNil: [self forceNewDefault]
]

{ #category : #accessing }
NameResolver class >> forceNewDefault [
	^ Default := self new
]

{ #category : #resolving }
NameResolver >> addressByName: hostName [
"
Example (put the address of a name server):
	NameResolver default servers: #((xxx xxx xxx xxx))
	NameResolver default addressByName: 'squeak.org'
"
	^ (self request: (DNSMessage addressByName: hostName)) answers first addressUsing: self
]

{ #category : #resolving }
NameResolver >> addressesByName: hostName [
"
Example (put the address of a name server):
	NameResolver default servers: #((xxx xxx xxx xxx))
	NameResolver default addressesByName: 'squeak.org'
"
	| answers flattened |
	answers :=  (self request: (DNSMessage addressByName: hostName)) answers.
	flattened := Set new.
	answers 
		do: [ :each | flattened addAll: (each addressesUsing: self) ].
	^ flattened
]

{ #category : #resolving }
NameResolver >> addressesByName: domain port: port do: block [
	"Support method for the SRV lookup."

	| shouldStop addrs addr  |
	shouldStop := false.
	addrs := ReadStream on: (self addressesByName: domain) asArray.
	[addrs atEnd or: [shouldStop]]
		whileFalse: [
			addr := addrs next.
			shouldStop := block value: addr value: port
		].
	^shouldStop

]

{ #category : #'tcp test' }
NameResolver >> addressesByNameTCP: hostName [
"
Example (put the address of a name server):
	NameResolver default servers: #((xxx xxx xxx xxx))
	NameResolver default addressesByName: 'squeak.org'
"
	| answers flattened |
	answers :=  (self tcpRequest: (DNSMessage addressByName: hostName)) answers.
	flattened := Set new.
	answers 
		do: [ :each | flattened addAll: (each addressesUsing: self) ].
	^ flattened
]

{ #category : #resolving }
NameResolver >> anyRecordsFor: srvName [ 

	^ (self request: (DNSMessage anyRecordsFor: srvName)) answers

]

{ #category : #accessing }
NameResolver >> flushCache [

	cache := Dictionary new.
]

{ #category : #'initialize-release' }
NameResolver >> initialize [

	self shouldCache: true.
	self protocolPolicy: #both.  "other options are #udp and #tcp"
]

{ #category : #resolving }
NameResolver >> mailExchangerFor: domain [
	^ (self mailExchangersFor: domain) first mx
]

{ #category : #resolving }
NameResolver >> mailExchangersFor: domain [
	^ (self request: (DNSMessage mailExchangerFor: domain)) answers sorted: [:a :b | a priority <= b priority]
]

{ #category : #resolving }
NameResolver >> nameServerAddressesFor: domain [
	"NameResolver default nameServerAddressesFor: 'example.com'."

	| addresses nss |
	nss := self nameServersFor: domain.
	addresses := OrderedCollection new.
	nss
		do: [ :eachNS | addresses addAll: (self addressesByName: eachNS) ].
	^addresses
]

{ #category : #resolving }
NameResolver >> nameServersFor: domain [
	^ (self request: (DNSMessage nameServersFor: domain)) answers collect: [:each | each ns]
]

{ #category : #accessing }
NameResolver >> protocolPolicy [
	"Answer the value of protocolPolicy"

	^ protocolPolicy
]

{ #category : #accessing }
NameResolver >> protocolPolicy: anObject [
	"Set the value of protocolPolicy"

	(#(both tcp udp) includes: anObject asSymbol)
		ifFalse: [self error: 'Invalid protocolPolicy for NameResolver'].
	protocolPolicy := anObject
]

{ #category : #resolving }
NameResolver >> ptrRecordsFor: srvName [ 

	^ (self request: (DNSMessage ptrRecordsFor: srvName)) answers

]

{ #category : #resolving }
NameResolver >> replyServicesFor: srvName [ 

	^ (self request: (DNSMessage servicesFor: srvName))
]

{ #category : #'resolving-private' }
NameResolver >> request: aDNSMessage [

	| cached |
	^self shouldCache
		ifTrue: [
			((cached := cache at: aDNSMessage questions ifAbsent: []) isNil or: [cached timedOut])
				ifTrue: [cached := self sendRequest: aDNSMessage.
						cache at: aDNSMessage questions put: cached].
			cached
		]
		ifFalse: [ self sendRequest: aDNSMessage ]
]

{ #category : #resolving }
NameResolver >> reverseLookup: address [
	^ (self request: (DNSMessage reverseLookup: address asByteArray)) answers first cname
]

{ #category : #'tcp test' }
NameResolver >> reverseLookupTCP: address [
	^ (self tcpRequest: (DNSMessage reverseLookup: address asByteArray)) answers first cname
]

{ #category : #resolving }
NameResolver >> rfc2782servicesFor: service protocol: proto  domain: domain do: block [
	"This is an attempt to carry out the ordering documented in the Usage Rules section of RFC 2782 "
	"The block should return a boolean indicating if the block was successful and the process
	of resolution should stop and exit"
	"This is incomplete, eventually it will replace the cheat method with a proper impl of 2782."

	| bins srvName bin priorities srvReply srvs shouldStop addrs addr |
	srvName := '_', service , '._' , proto , '.' , domain.
	srvReply :=  (self request: (DNSMessage servicesFor: srvName)) .
	((srvReply responseCode = 0) and: [srvReply answers size >0])
		ifTrue: [
			srvs :=  srvReply answers.
			((srvs size = 1) and: [srvs first target = '.'])
				ifTrue: [^self].
			bins := Dictionary new.
			srvs
				do: [ :eachSRV |
					bin := bins at: eachSRV priority ifAbsent: [OrderedCollection new].
					bin add: eachSRV.
					bins at: eachSRV priority  put:  eachSRV .
				]. 
			priorities := bins keys sorted: [:a :b | a  <= b ].
			bins := Dictionary new.
			bins.
			priorities







		]
		ifFalse: [
			shouldStop := false.
			addrs := ReadStream on: (self addressesByName: domain).
			[addrs atEnd or: [shouldStop]]
				whileFalse: [
					addr := addrs next.
					shouldStop := block value: addr value: nil
				]
		]	


]

{ #category : #'resolving-private' }
NameResolver >> sendRequest: aDNSMessage [
	servers allButLast do: [:each |
		[^ self sendRequest: aDNSMessage server: each] on: ConnectionTimedOut do: []].
	^ self sendRequest: aDNSMessage server: servers last
]

{ #category : #'resolving-private' }
NameResolver >> sendRequest: request server: server [

	| response |
	self useUdp
		ifTrue: [ response := self sendUdpRequest: request server: server].
	self useTcp
		ifTrue: [
			(self useUdp not or: [response truncated])
				ifTrue: [
					response := self sendTcpRequest: request server: server
				].
		].
	^response
]

{ #category : #'tcp test' }
NameResolver >> sendTcpRequest: aDNSMessage [
	servers allButLast do: [:each |
		[^ self sendTcpRequest: aDNSMessage server: each] on: ConnectionTimedOut do: []].
	^ self sendTcpRequest: aDNSMessage server: servers last
]

{ #category : #'resolving-private' }
NameResolver >> sendTcpRequest: request server: server [
	
	| stream outData inLen inData response outMessage |
	stream := SocketStream openConnectionToHost: server asByteArray port: 53.
	 [
		outData := WriteStream on: (ByteArray new).
		outMessage := request asByteArray.
		outData nextNumber: 2 put: outMessage size.
		outData nextPutAll: outMessage.
		stream nextPutAll: outData contents.
		stream flush.
		inLen := (stream next: 2) asByteArray.
		inLen := ((inLen at: 1) * 256) +(inLen at: 2).
		inData := stream next: inLen.
	]
		ensure: [	stream close ].
	response := DNSMessage readFrom: (inData) readStream.
	response checkResponseCodeDo: [ :code :errorMessage | ].
	^ response
]

{ #category : #'resolving-private' }
NameResolver >> sendUdpRequest: request server: server [
	| sock receiveBuf count response |
	sock := Socket newUDP.
	[sock setPeer: server asByteArray port: 53.
	receiveBuf := String new: 512.
	sock sendData: request asByteArray.
	sock waitForDataFor: self udpTimeout.
	count := sock receiveDataInto: receiveBuf.
	response := DNSMessage readFrom: (receiveBuf copyFrom: 1 to: count) readStream] ensure: [sock close; destroy].
	response checkResponseCodeDo: [ :code :errorMessage | 
		NameResolverLookupFailure new errorCode: code; hostName: request; signal: errorMessage ].
	^ response
]

{ #category : #accessing }
NameResolver >> servers [
	^ servers
]

{ #category : #accessing }
NameResolver >> servers: aCollection [
	servers := aCollection.
	self flushCache.
]

{ #category : #resolving }
NameResolver >> servicesFor: srvName [
	"crude reordering, see #servicesFor:protocol:domain:do:"

	^ (self replyServicesFor: srvName)
		answers
		shuffled
		sorted: [:a :b | a priority <= b priority]
]

{ #category : #resolving }
NameResolver >> servicesFor: service protocol: proto  domain: domain do: block [
	"This is an attempt to carry out the ordering documented in the Usage Rules section
	of RFC 2782 "
	"The block should return a boolean indicating if the block was successful and
	the process of resolution should stop and exit"
	"Actually this is a cheat...we shuffle the servers then sort by priority to ensure that
	the weight ordering is scrambled and have equal chances of being chosen.
	This isn't perfect but will  do until the sorting rules are re-implemented."
	"If we gat a dotted IP as input, skip the SRV lookup process."

	| srvName srvReply srvs shouldStop eachSRV |
	(NetNameResolver addressFromString: domain)
		ifNotNilDo: [ :dottedIp |
			^block value: dottedIp value: nil
		].
	shouldStop := false.
	srvName := '_', service , '._' , proto , '.' , domain.
	[srvReply :=  self replyServicesFor: srvName ]
		on: NameResolverLookupFailure
		do: [ :ex | ex resume  ].
	((srvReply responseCode = 0) and: [srvReply answers size >0])
		ifTrue: [
			srvs :=  srvReply answers.
			((srvs size = 1) and: [srvs first target = '.'])
				ifTrue: [^false].
			srvs := (srvs shuffled sorted: [:a :b | a priority <= b priority ]) readStream.
			[srvs atEnd or: [shouldStop]]
				whileFalse: [
					eachSRV  := srvs next.
					shouldStop := self addressesByName: eachSRV target port: eachSRV port do: block
				].
		]
		ifFalse: [
			shouldStop := self addressesByName: domain port: nil  do: block
		].	
	^shouldStop
]

{ #category : #accessing }
NameResolver >> shouldCache [
	"Answer the value of shouldCache"

	shouldCache and: [ cache = nil ifTrue: [self flushCache] ].
	^ shouldCache
]

{ #category : #accessing }
NameResolver >> shouldCache: anObject [
	"Set the value of shouldCache"

	shouldCache := anObject
]

{ #category : #'tcp test' }
NameResolver >> tcpRequest: aDNSMessage [

	| cached |
	^self shouldCache
		ifTrue: [
			((cached := cache at: aDNSMessage questions ifAbsent: []) isNil or: [cached timedOut])
				ifTrue: [cached := self sendTcpRequest: aDNSMessage.
						cache at: aDNSMessage questions put: cached].
			cached
		]
		ifFalse: [self sendTcpRequest: aDNSMessage].

]

{ #category : #resolving }
NameResolver >> txtRecordsFor: domain [
	^ (self request: (DNSMessage txtRecordsFor: domain)) answers
]

{ #category : #accessing }
NameResolver >> udpTimeout [
	^udpTimeout ifNil: [Socket standardTimeout].
]

{ #category : #accessing }
NameResolver >> udpTimeout: anObject [
	udpTimeout := (anObject ifNil: [Socket standardTimeout]).
]

{ #category : #accessing }
NameResolver >> useTcp [
	"Answer the value of useTcp"

	^(protocolPolicy == #both) or: [protocolPolicy == #tcp]
]

{ #category : #accessing }
NameResolver >> useUdp [
	"Answer the value of useUdp"

	^(protocolPolicy == #both) or: [protocolPolicy == #udp]
]
