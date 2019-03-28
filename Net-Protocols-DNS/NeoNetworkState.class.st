"
I am NeoNetworkState.

I can be used to determine if we currentlty seem to have a working internet network connection.

I can be put in airplane mode, so that I assume I have no working internet network connection.

  NeoNetworkState default hasInternetConnection.
  NeoNetworkState default ensureInternetConnection.

  NeoNetworkState default airplaneMode.
  NeoNetworkState default airplaneMode: true.
  NeoNetworkState default airplaneMode: false.

Implementation

The test we use is to contact a well known public DNS provider and ask it to resolve the hostname #domainNameToCheck (pharo.org) with a timeout of #defaultTTL (by default 2 seconds). This is done with UDP networking using a simple/single use/synchroneous DNS client. The caller of #hasInternetConnection will wait for maximally this TTL for a reply. The rest of the image will keep on functioning normally during this check. We cache the result during the configured TTL. Other (presumably networking) code can set the state using #noteWorkingInternetConnection and #noteFailingInternetConnection.
"
Class {
	#name : #NeoNetworkState,
	#superclass : #Object,
	#instVars : [
		'airplaneMode',
		'ttl',
		'lastChecked',
		'internetWorking'
	],
	#classVars : [
		'Default'
	],
	#category : #'Net-Protocols-DNS-Experimental'
}

{ #category : #accessing }
NeoNetworkState class >> default [
	^ Default ifNil: [ Default := self new ]
]

{ #category : #'class initialization' }
NeoNetworkState class >> initialize [
	SessionManager default registerNetworkClassNamed: self name
]

{ #category : #installation }
NeoNetworkState class >> install [
	"Install my default instance in NetNameResolver"
	
	"self install"
	
	NetNameResolver class compile: 'isConnected
	^ NeoNetworkState default hasInternetConnection'
]

{ #category : #'system startup' }
NeoNetworkState class >> startUp: isImageStarting [
	(isImageStarting and: [ Default notNil ])
		ifTrue: [ self default reset ]
]

{ #category : #accessing }
NeoNetworkState >> airplaneMode [
	"Return true when airplane mode is currently active, false otherwise.
	If true, I will assume there is no internet network connection possible and never even test it.
	If false, I will operate normally, testing the internet connection when asked and cache that value for ttl seconds"

	^ airplaneMode 
]

{ #category : #initialization }
NeoNetworkState >> airplaneMode: boolean [
	"Set airplane mode to boolean.
	If true, I will assume there is no internet network connection possible and never even test it.
	If false, I will operate normally, testing the internet connection when asked and cache that value for ttl seconds"
	
	airplaneMode := boolean
]

{ #category : #accessing }
NeoNetworkState >> defaultTTL [
	"Return the default time to live (seconds) that I cache the value of #testInternetConnection. 
	This is also the timeout used to check the internet connection by DNS resolving a specific host name"
	
	^ 2 "seconds"
]

{ #category : #accessing }
NeoNetworkState >> domainNameToCheck [
	"Return the domain name #testInternetConnection will use - the DNS entry for this host *must* exist."
	
	^ 'pharo.org'
]

{ #category : #public }
NeoNetworkState >> ensureInternetConnection [
	"Check if we can reasonably assume we have a working internet connection, 
	if not, signal a NoNetworkError."
	
	self hasInternetConnection ifFalse: [ NoNetworkError signal ]
]

{ #category : #testing }
NeoNetworkState >> hasInternetConnection [
	"Test if we have a working internet connection. This fact is cached for ttl seconds. 
	Airplane mode overrides this to always be false."

	airplaneMode
		ifTrue: [ ^ false ].
	^ self isCachedValueValid
		ifTrue: [ internetWorking ]
		ifFalse: [ self testInternetConnection ]
]

{ #category : #initialization }
NeoNetworkState >> initialize [
	super initialize.
	self airplaneMode: false.
	self ttl: self defaultTTL 
]

{ #category : #private }
NeoNetworkState >> isCachedValueValid [
	^ lastChecked notNil
		and: [ (Time millisecondsSince: lastChecked) < (ttl * 1000) ]
]

{ #category : #public }
NeoNetworkState >> noteFailingInternetConnection [
	"Register the fact that the sender found the internet connection to be failing and cache that for ttl seconds"
	
	self touch.
	^ internetWorking := false
]

{ #category : #public }
NeoNetworkState >> noteWorkingInternetConnection [
	"Register the fact that the sender found the internet connection to be working and cache that for ttl seconds"

	self touch.
	^ internetWorking := true
]

{ #category : #printing }
NeoNetworkState >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	self hasInternetConnection
		ifTrue: [ stream nextPutAll: 'Internet is working' ] 
		ifFalse: [ stream nextPutAll: 'Internet is not working' ].
	self airplaneMode
		ifTrue: [ stream nextPutAll: ', with Airplane mode activated' ].
	stream nextPut: $)
]

{ #category : #initialization }
NeoNetworkState >> reset [
	internetWorking := lastChecked := nil
]

{ #category : #private }
NeoNetworkState >> testInternetConnection [
	"Our key method: use a simple/single use/synchroneous DNS client to resolve a specific domain name in ttl seconds at most and cache the result"
	
	^ NeoDNSTimeout value: ttl during: [ 
		[ 
			NeoSimplifiedDNSClient default addressForName: self domainNameToCheck.
			self noteWorkingInternetConnection ]
				on: Error
				do: [ self noteFailingInternetConnection ] ]
]

{ #category : #private }
NeoNetworkState >> touch [
	lastChecked := Time millisecondClockValue
]

{ #category : #initialization }
NeoNetworkState >> ttl: seconds [
	ttl := seconds
]
