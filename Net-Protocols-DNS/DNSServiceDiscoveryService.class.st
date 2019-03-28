Class {
	#name : #DNSServiceDiscoveryService,
	#superclass : #Object,
	#instVars : [
		'resolver',
		'serviceDomain',
		'serviceType',
		'serviceName',
		'ptr',
		'srvs',
		'txts'
	],
	#category : #'Net-Protocols-DNS-ServiceDiscovery'
}

{ #category : #api }
DNSServiceDiscoveryService >> alternativesDoUntilTrue: block [
	
	| success |
	self lookupSrvsIfNecessary.
	self lookupTxtsIfNecessary.
	success := false.
	srvs
		do: [ :eachSrv |
			success := block value: eachSrv target value: eachSrv port  value: self.
			success ifTrue: [^success].
		].
	^success
]

{ #category : #api }
DNSServiceDiscoveryService >> lookupSrvsIfNecessary [

	srvs ifNotNil: [ ^self].
	[ srvs := self resolver servicesFor: (self serviceFullName) ]
		on: NameResolverLookupFailure
		do: [ :ex | srvs := #()]

]

{ #category : #api }
DNSServiceDiscoveryService >> lookupTxtsIfNecessary [

	txts ifNotNil: [ ^self].
	[ txts := self resolver txtRecordsFor: self serviceFullName ]
		on: NameResolverLookupFailure
		do: [ :ex | txts := #() ].
]

{ #category : #printing }
DNSServiceDiscoveryService >> printOn: s [

	super printOn: s .
	s
		nextPut: $( ;
		nextPutAll: self serviceName ;
		nextPut: $) ;
		yourself
]

{ #category : #accessing }
DNSServiceDiscoveryService >> ptr [
	"Answer the value of ptr"

	^ ptr
]

{ #category : #accessing }
DNSServiceDiscoveryService >> ptr: anObject [
	"Set the value of ptr"

	ptr := anObject
]

{ #category : #accessing }
DNSServiceDiscoveryService >> resolver [

	^resolver ifNil: [NameResolver default]
]

{ #category : #accessing }
DNSServiceDiscoveryService >> resolver: rslv [

	resolver := rslv
]

{ #category : #accessing }
DNSServiceDiscoveryService >> serviceDomain [
	"Answer the value of serviceDomain"

	^ serviceDomain
]

{ #category : #accessing }
DNSServiceDiscoveryService >> serviceDomain: anObject [
	"Set the value of serviceDomain"

	serviceDomain := anObject
]

{ #category : #api }
DNSServiceDiscoveryService >> serviceFullName [

	^ptr
		ifNil: [self serviceName , '.' , self serviceType , '.' , self serviceDomain]
		ifNotNil: [ptr cname]

]

{ #category : #api }
DNSServiceDiscoveryService >> serviceName [

	^serviceName ifNil: [
		serviceName := ptr cname copyFrom: 1 to: (ptr cname indexOf: $.) - 1 .
	]
]

{ #category : #accessing }
DNSServiceDiscoveryService >> serviceName: str [

	serviceName := str
]

{ #category : #api }
DNSServiceDiscoveryService >> servicePort [

	self lookupSrvsIfNecessary.
	^srvs first port
]

{ #category : #api }
DNSServiceDiscoveryService >> serviceTarget [

	self lookupSrvsIfNecessary.
	^srvs first target
]

{ #category : #accessing }
DNSServiceDiscoveryService >> serviceType [
	"Answer the value of serviceType"

	^ serviceType
]

{ #category : #accessing }
DNSServiceDiscoveryService >> serviceType: anObject [
	"Set the value of serviceType"

	serviceType := anObject
]

{ #category : #accessing }
DNSServiceDiscoveryService >> srvs [

	self lookupSrvsIfNecessary.
	^srvs
]

{ #category : #accessing }
DNSServiceDiscoveryService >> srvs: anObject [
	"Set the value of srvs"

	srvs := anObject
]

{ #category : #api }
DNSServiceDiscoveryService >> txtAt: key [

	^self txtAt: key ifAbsent: [''].
]

{ #category : #api }
DNSServiceDiscoveryService >> txtAt: key ifAbsent: block [
	"If the key has an $= in it, it is an invalid key. We just sanitize it first. Should probably throw some exception."

	| lead |
	self lookupTxtsIfNecessary.
	lead := (key copyWithout: $=) asLowercase , '='.
	txts
		do: [ :eachTxt |
			eachTxt strings
				do: [ :eachStr |
					(eachStr asLowercase beginsWith: lead)
						ifTrue: [ ^eachStr copyFrom: (lead size + 1) to: eachStr size]
				]
		].
	^block value
]

{ #category : #api }
DNSServiceDiscoveryService >> txtPresent: key [

	^(self txtAt: key ifAbsent: [nil]) notNil.
]

{ #category : #accessing }
DNSServiceDiscoveryService >> txts [
	"Answer the value of txts"

	self lookupTxtsIfNecessary.
	^ txts
]

{ #category : #accessing }
DNSServiceDiscoveryService >> txts: anObject [
	"Set the value of txts"

	txts := anObject
]
