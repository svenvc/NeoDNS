"
test cases for the dns client code.  The problem with these is that the data they query is unstable.  So we just try to exercise the code and do lookups on known reasonably stable DNS entries like those for example.com. For convenience sake we usually use the google.com name service.
"
Class {
	#name : #DnsClientTest,
	#superclass : #TestCase,
	#category : #'Net-Protocols-DNS-Tests'
}

{ #category : #tests }
DnsClientTest >> testAddresses [

	| resolver addresses domainName |
	resolver := NameResolver new.
	resolver servers: { #(8 8 8 8) . #(8 8 4 4) }.
	addresses := resolver addressesByName: 'google-public-dns-a.google.com'.
	addresses
		do: [ :eachAddress |
			domainName := resolver reverseLookup: eachAddress.
			self assert: (domainName = 'google-public-dns-a.google.com').	
		].

]

{ #category : #tests }
DnsClientTest >> testMailExchanger [

	| resolver exampleMX |
	resolver := NameResolver new.
	resolver servers: { #(69 93 127 10) }.
	exampleMX := resolver mailExchangersFor: 'example.com'.
	self assert: (exampleMX size = 1).
	self assert: (exampleMX anyOne mx = 'mail.example.com').

]

{ #category : #tests }
DnsClientTest >> testNameServer [

	| resolver exampleNS addresses |
	resolver := NameResolver new.
	resolver servers: { #(8 8 8 8) . #(8 8 4 4) }.
	exampleNS := resolver nameServersFor:'example.com'.
	addresses := OrderedCollection new.
	exampleNS
		do: [ :eachNS | addresses addAll: (resolver addressesByName: eachNS) ].
	
	^addresses
]

{ #category : #tests }
DnsClientTest >> testServices [

	| resolver |
	resolver := NameResolver new.
	resolver servers: { #(8 8 8 8) . #(8 8 4 4) }.

	Transcript crShow: ('jabber.org').
	resolver
		servicesFor: 'xmpp-client'
		protocol: 'tcp'
		domain: 'jabber.org'
		do: [ :addr :port |
			Transcript crShow: ('ap ' , addr printString  , ' ' , port printString).
			false
		].

	Transcript crShow: ('gmail.com').
	resolver
		servicesFor: 'xmpp-client'
		protocol: 'tcp'
		domain: 'gmail.com'
		do: [ :addr :port |
			Transcript crShow: ('ap ' , addr printString  , ' ' , port printString).
			false
		].

]

{ #category : #tests }
DnsClientTest >> testTcpAddresses [

	| resolver addresses domainName |
	resolver := NameResolver new.
	resolver servers: { #(8 8 8 8) . #(8 8 4 4) }.
	addresses := resolver addressesByNameTCP: 'google-public-dns-a.google.com'.
	addresses
		do: [ :eachAddress |
			domainName := resolver reverseLookupTCP: eachAddress.
			self assert: (domainName = 'google-public-dns-a.google.com').	
		].

]
