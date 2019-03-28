Class {
	#name : #DnsSdClientTest,
	#superclass : #TestCase,
	#category : #'Net-Protocols-DNS-Tests'
}

{ #category : #tests }
DnsSdClientTest >> test01Creation [

	| dnssd |
	dnssd := DNSServiceDiscovery new.
	self assert: (dnssd isKindOf: DNSServiceDiscovery)
]

{ #category : #tests }
DnsSdClientTest >> test01bServiceRecordsAvailable [
	"http://pig.made-it.com/cups-dns-sd.html"
	| dnssd services|
	
	dnssd := DNSServiceDiscovery new.
	dnssd resolver: (
		(NameResolver new)
			servers: { #(8 8 8 8) asByteArray};
			shouldCache: false;
			flushCache;
			yourself
	).

	"Is a Browsable DNS Service Discovery avaiable?"
	"dig @8.8.8.8 b._dns-sd._udp.dns-sd.org PTR"
	services := dnssd servicesType: 'b._dns-sd._udp' domain: 'dns-sd.org'.
	self assert: services size > 0.

	"Is a Legacy Browsable DNS Service Discovery avaiable?"
	"dig @8.8.8.8 lb._dns-sd._udp.dns-sd.org PTR"
	services := dnssd servicesType: 'lb._dns-sd._udp' domain: 'dns-sd.org'.
	self assert: services size > 0.


]

{ #category : #tests }
DnsSdClientTest >> test02ResolutionSuccess [

	| dnssd services |
	dnssd := DNSServiceDiscovery new.
	dnssd resolver: (
		(NameResolver new)
			servers: { #(8 8 8 8) asByteArray};
			shouldCache: false;
			flushCache;
			yourself
	).

	"dig @8.8.8.8 _http._tcp.dns-sd.org PTR"
	services := dnssd servicesType: '_http._tcp' domain: 'dns-sd.org'.
	self assert: (services size = 16).
	self assert: (services allSatisfy: [ :each | each isKindOf: DNSServiceDiscoveryService]).

	"dig @8.8.8.8 _ssh._tcp.dns-sd.org PTR"
	services := dnssd servicesName: 'Rose' type: '_ssh._tcp' domain: 'dns-sd.org'.
	self assert: (services size = 1).
	self assert: (services allSatisfy: [ :each | each isKindOf: DNSServiceDiscoveryService]).

	services:= dnssd servicesName: 'Fail' type: '_ssh._tcp' domain: 'dns-sd.org'.
	self assert: (services size = 0).

]

{ #category : #tests }
DnsSdClientTest >> test03ResolutionFail [

	| dnssd servicesFred exThrown |
	dnssd := DNSServiceDiscovery new.
	dnssd resolver: (
		(NameResolver new)
			servers: { #(8 8 8 8) asByteArray};
			shouldCache: false;
			flushCache;
			yourself
	).
	[
		servicesFred := dnssd servicesType: '_fred._tcp' domain: 'dns-sd.org'.
		self assert: (servicesFred size = 0)
	]
		on: NameResolverLookupFailure
		do: [ :ex | exThrown := true. ex resume].
	self assert: (exThrown notNil).

]

{ #category : #tests }
DnsSdClientTest >> test04ResolutionSuccessSingle [

	| dnssd servicesHttp service |
	dnssd := DNSServiceDiscovery new.
	dnssd resolver: (
		(NameResolver new)
			servers: { #(8 8 8 8) asByteArray};
			shouldCache: false;
			flushCache;
			yourself
	).
	servicesHttp := dnssd servicesName: ' * Zeroconf' type: '_http._tcp' domain: 'dns-sd.org'.
	self assert: (servicesHttp size = 1).
	self assert: (servicesHttp allSatisfy: [ :each | each isKindOf: DNSServiceDiscoveryService]).
	service := servicesHttp anyOne.
	self assert: ( ( service txtAt: 'path' ifAbsent: [nil]) = '/').
	self assert: ( ( service txtAt: 'fail' ifAbsent: [nil]) isNil).
	self assert: (service serviceTarget = 'zeroconf.org').
	self assert: (service servicePort = 80).
	
	


]

{ #category : #tests }
DnsSdClientTest >> test05ResolutionSuccessMulti [

	| dnssd servicesHttp service count success |
	dnssd := DNSServiceDiscovery new.
	dnssd resolver: (
		(NameResolver new)
			servers: { #(8 8 8 8) asByteArray};
			shouldCache: false;
			flushCache;
			yourself
	).
	servicesHttp := dnssd servicesName: ' * CNN, World news' type: '_http._tcp' domain: 'dns-sd.org'.
	self assert: (servicesHttp size = 1).
	self assert: (servicesHttp allSatisfy: [ :each | each isKindOf: DNSServiceDiscoveryService]).
	service := servicesHttp anyOne.
	count := 0.
	success := service
		alternativesDoUntilTrue: [ :target :port :sd |
			count := count + 1.
			self assert: (target isKindOf: String).
			self assert: (port isKindOf: Integer).
			self assert: (sd isKindOf: DNSServiceDiscoveryService).
			self assert: ( ( sd txtAt: 'path' ifAbsent: [nil]) = '/').
			self assert: ( ( sd txtAt: 'fail' ifAbsent: [nil]) isNil).
			false
		].
	self deny: success.

	count := 0.
	success := service
		alternativesDoUntilTrue: [ :target :port :sd |
			count := count + 1.
			count = 1
		].
	self assert: success.



	


]

{ #category : #tests }
DnsSdClientTest >> test06ManualService [

	| service success count | 
	service := (DNSServiceDiscoveryService new)
		serviceName: ' * Zeroconf';
		serviceType: '_http._tcp';
		serviceDomain: 'dns-sd.org';
		resolver: (
		(NameResolver new)
			servers: { #(8 8 8 8) asByteArray};
			shouldCache: false;
			flushCache;
			yourself);
		yourself.
	count := 0.
	success := service alternativesDoUntilTrue: [ :a :b :c |
		count := count + 1.
		count = 1.
	].
	self assert: (success).
	self assert: (service serviceTarget asLowercase = 'zeroconf.org').
	self assert: (service servicePort  = 80).
	self assert: (service txtAt: 'path' ifAbsent: [nil]) = '/'.
	


]
