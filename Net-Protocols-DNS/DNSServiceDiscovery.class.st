Class {
	#name : #DNSServiceDiscovery,
	#superclass : #Object,
	#instVars : [
		'resolver'
	],
	#classVars : [
		'Default',
		'ServiceTypes'
	],
	#category : #'Net-Protocols-DNS-ServiceDiscovery'
}

{ #category : #'as yet unclassified' }
DNSServiceDiscovery class >> default [
	^ Default ifNil: [self forceNewDefault]
]

{ #category : #'as yet unclassified' }
DNSServiceDiscovery class >> forceNewDefault [
	^ Default := self new
]

{ #category : #'as yet unclassified' }
DNSServiceDiscovery class >> servicesType: type domain: domain [

	^self default servicesType: type domain: domain
]

{ #category : #'as yet unclassified' }
DNSServiceDiscovery class >> testOnDemo [
	"self testOnDemo"

	| dnssd dss urlStr |
	dnssd := self default.
	dss := dnssd servicesType: '_http._tcp' domain: 'dns-sd.org'.
	Transcript crShow: 'Found ' , dss size , ' services for testOnDemo' .
	dss
		do: [ :eachDs |
			eachDs
				alternativesDoUntilTrue: [ :target :port :ds |
					urlStr := 'http://' , target , ':' , port , (ds txtAt: 'path').
					Transcript crShow: urlStr.
					false
				].
		].

]

{ #category : #'initialize-release' }
DNSServiceDiscovery >> initialize [

	super initialize.
	resolver := NameResolver default.
]

{ #category : #accessing }
DNSServiceDiscovery >> resolver [
	"Answer the value of resolver"

	^ resolver
]

{ #category : #accessing }
DNSServiceDiscovery >> resolver: anObject [
	"Set the value of resolver"

	resolver := anObject
]

{ #category : #api }
DNSServiceDiscovery >> servicesName: name type: type domain: domain [
	" (DNSServiceDiscovery default) servicesName: '_JohnsDispatcher' type: '_opencobalt-dispatcher._tcp' domain: 'opencobalt.net'   "
	"  (DNSServiceDiscovery default) servicesName: 'Rose' type: '_ssh._tcp' domain: 'dns-sd.org'     "
	| ptrs |
	ptrs := self servicesType: type domain:domain.
	ptrs := ptrs select: [ :eachSd | name = eachSd serviceName ].
	^ptrs
]

{ #category : #api }
DNSServiceDiscovery >> servicesType: type domain: domain [
	"   (DNSServiceDiscovery default) servicesType: '_opencobalt-dispatcher._tcp' domain: 'opencobalt.net'     "
	"   (DNSServiceDiscovery default) servicesType: '_ssh._tcp' domain: 'dns-sd.org'     "

	| ptrs |
	ptrs := self resolver ptrRecordsFor: type , '.' , domain.
	^ptrs
		collect: [ :eachPtr |
			(DNSServiceDiscoveryService new)
				ptr: eachPtr ;
				serviceType: type;
				serviceDomain: domain;
				resolver: (self resolver);
				yourself
		].
]
