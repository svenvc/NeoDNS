"
I am DNSRecord, also known as a Resource Record.
I am an abstract, my subclasses implement specific concrete types.
UnrecognizedRecord is a catch all subclass for when no specific subclass exists.

RR Type Registry at http://www.iana.org/assignments/dns-parameters as of 2010-02-05

Registry Name: Resource Record (RR) TYPEs 
Reference: [RFC5395][RFC1035]
Range        
Decimal
Hexadecimal    Registration Procedures                                         Notes
-------------  --------------------------------------------------------------  --------------
0              RRTYPE zero is used as a special indicator for the SIG RR
0x0000         [RFC2931], [RFC4034] and in other circumstances and must never
               be allocated for ordinary use.
1-127          DNS RRTYPE Allocation Policy                                    data TYPEs
0x0001-0x007F
128-255        DNS RRTYPE Allocation Policy                                    Q TYPEs, Meta TYPEs
0x0080-0x00FF
256-61439      DNS RRTYPE Allocation Policy                                    data RRTYPEs
0x0100-0xEFFF
61440-65279    IETF Review
0xF000-0xFEFF  
65280-65534    Reserved for Private Use
0xFF00-0xFFFE
65535          Reserved (Standards Action)
0xFFFF

Registry:
TYPE         Value and meaning                              Reference
-----------  ---------------------------------------------  ---------
A            1 a host address                               [RFC1035]
NS           2 an authoritative name server                 [RFC1035]
MD           3 a mail destination (Obsolete - use MX)       [RFC1035]
MF           4 a mail forwarder (Obsolete - use MX)         [RFC1035]
CNAME        5 the canonical name for an alias              [RFC1035]
SOA          6 marks the start of a zone of authority       [RFC1035]
MB           7 a mailbox domain name (EXPERIMENTAL)         [RFC1035]
MG           8 a mail group member (EXPERIMENTAL)           [RFC1035]
MR           9 a mail rename domain name (EXPERIMENTAL)     [RFC1035]
NULL         10 a null RR (EXPERIMENTAL)                    [RFC1035]
WKS          11 a well known service description            [RFC1035]
PTR          12 a domain name pointer                       [RFC1035]
HINFO        13 host information                            [RFC1035]
MINFO        14 mailbox or mail list information            [RFC1035]
MX           15 mail exchange                               [RFC1035]
TXT          16 text strings                                [RFC1035]
RP           17 for Responsible Person                      [RFC1183]
AFSDB        18 for AFS Data Base location                  [RFC1183]
X25          19 for X.25 PSDN address                       [RFC1183]
ISDN         20 for ISDN address                            [RFC1183]
RT           21 for Route Through                           [RFC1183]
NSAP         22 for NSAP address, NSAP style A record       [RFC1706]
NSAP-PTR     23 for domain name pointer, NSAP style         [RFC1348] 
SIG          24 for security signature                      [RFC4034][RFC3755][RFC2535]
KEY          25 for security key                            [RFC4034][RFC3755][RFC2535]
PX           26 X.400 mail mapping information              [RFC2163]
GPOS         27 Geographical Position                       [RFC1712]
AAAA         28 IP6 Address                                 [RFC3596]
LOC          29 Location Information                        [RFC1876]
NXT          30 Next Domain - OBSOLETE                      [RFC3755][RFC2535]
EID          31 Endpoint Identifier                         [Patton]
NIMLOC       32 Nimrod Locator                              [Patton]
SRV          33 Server Selection                            [RFC2782]
ATMA         34 ATM Address                                 [ATMDOC]
NAPTR        35 Naming Authority Pointer                    [RFC2915][RFC2168]
KX           36 Key Exchanger                               [RFC2230]
CERT         37 CERT                                        [RFC4398]
A6           38 A6 (Experimental)                           [RFC3226][RFC2874]
DNAME        39 DNAME                                       [RFC2672]
SINK         40 SINK                                        [Eastlake]
OPT          41 OPT                                         [RFC2671]
APL          42 APL                                         [RFC3123]
DS           43 Delegation Signer                           [RFC4034][RFC3658]
SSHFP        44 SSH Key Fingerprint                         [RFC4255]
IPSECKEY     45 IPSECKEY                                    [RFC4025]
RRSIG        46 RRSIG                                       [RFC4034][RFC3755]
NSEC         47 NSEC                                        [RFC4034][RFC3755]
DNSKEY       48 DNSKEY                                      [RFC4034][RFC3755]
DHCID        49 DHCID                                       [RFC4701]
NSEC3        50 NSEC3                                       [RFC5155]
NSEC3PARAM   51 NSEC3PARAM                                  [RFC5155]
Unassigned   52-54
HIP          55 Host Identity Protocol                      [RFC5205]
NINFO        56 NINFO                                       [Reid]
RKEY         57 RKEY                                        [Reid]
Unassigned   58-98
SPF          99                                             [RFC4408]
UINFO        100                                            [IANA-Reserved]
UID          101                                            [IANA-Reserved]
GID          102                                            [IANA-Reserved]
UNSPEC       103                                            [IANA-Reserved]
Unassigned   104-248
TKEY         249 Transaction Key                            [RFC2930]
TSIG         250 Transaction Signature                      [RFC2845]
IXFR         251 incremental transfer                       [RFC1995]
AXFR         252 transfer of an entire zone                 [RFC1035]
MAILB        253 mailbox-related RRs (MB, MG or MR)         [RFC1035]
MAILA        254 mail agent RRs (Obsolete - see MX)         [RFC1035]
*            255 A request for all records                  [RFC1035]
Unassigned   256-32767
TA           32768   DNSSEC Trust Authorities               [Weiler]           2005-12-13
DLV          32769   DNSSEC Lookaside Validation            [RFC4431]
Unassigned   32770-65279  
Private use  65280-65534
Reserved     65535 

Note: In [RFC1002], two types are defined.  It is not clear that these
are in use, though if so their assignment does conflict with those above.
	NB	32	NetBIOS general Name Service
	NBSTAT	33	NetBIOS NODE STATUS



"
Class {
	#name : #DNSRecord,
	#superclass : #Object,
	#instVars : [
		'name',
		'dclass',
		'ttl',
		'timestamp'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #'instance creation' }
DNSRecord class >> name: aString type: anInteger class: bInteger [
	self subclassesDo: [ :each |
		each type = anInteger
			ifTrue: [ ^ each new name: aString; dclass: bInteger ] ].
	^ UnrecognizedRecord new 
		name: aString; 
		type: anInteger; 
		dclass: bInteger;
		yourself
]

{ #category : #'instance creation' }
DNSRecord class >> readFrom: aStream [
	^ (self 
			name: (self readNameFrom: aStream) 
			type: (aStream nextNumber: 2) 
			class: (aStream nextNumber: 2)) readFrom: aStream
]

{ #category : #'instance creation' }
DNSRecord class >> readNameFrom: aStream [
	| length outputStream offset pos |
	outputStream := '' writeStream.
	[(length := aStream next asInteger) > 0]
		whileTrue:
			[outputStream position = 0 ifFalse: [outputStream nextPut: $.].
			length >= 16rC0
				ifTrue: [offset := (length bitAnd: 16r3F) * 256 + aStream next asInteger.
						pos := aStream position.
						aStream position: offset.
						outputStream nextPutAll: (self readNameFrom: aStream).
						aStream position: pos.
						^ outputStream contents]
				ifFalse: [outputStream nextPutAll: (aStream next: length) asString]].
	^ outputStream contents
]

{ #category : #accessing }
DNSRecord class >> rrTypeNameFor: typeCode [

	^#(
		A NS MD MF CNAME
		SOA MB MG MR NULL
		WKS PTR HINFO MINFO MX
		TXT RP  AFSDB X25 ISDN
		RT NSAP #'NSAP-PTR' SIG KEY
		PX GPOS AAAA LOC NXT
		EID NIMLOC SRV ATMA NAPTR
		KX CERT A6 DNAME SINK
		OPT APL DS SSHFP IPSECKEY
		RRSIG NSEC DNSKEY DHCID NSEC3
		NSEC3PARAM rr52 rr53 rr54 HIP
		NINFO RKRY rr58 rr59 rr60
		rr61 rr62 rr63 rr64 rr65
		rr66 rr67 rr68 rr69 rr70
		rr71 rr72 rr73 rr74 rr75
		rr76 rr77 rr78 rr79 rr80
		rr81 rr82 rr83 rr84 rr85
		rr86 rr87 rr88 rr89 rr90
		rr91 rr92 rr93 rr94 rr95
		rr96 rr97 rr98 SPF UINFO
		UID GID UNSPEC rr104 rr105
		rr106 rr107 rr108 rr109 rr110
	)
		at: typeCode
		ifAbsent: [
			typeCode = 32768 ifTrue: [ ^#TA].
			typeCode = 32769 ifTrue: [ ^#DLV].
			^#(TKEY TSIG IXFR AXFR MAILB MAILA #'*' ) at: (typeCode - 248)
				ifAbsent: [ typeCode printString]
		]
]

{ #category : #accessing }
DNSRecord class >> type [
	^ nil
]

{ #category : #accessing }
DNSRecord >> dclass [
	^ dclass ifNil: [1]
]

{ #category : #accessing }
DNSRecord >> dclass: anInteger [
	dclass := anInteger
]

{ #category : #accessing }
DNSRecord >> name [
	^ name ifNil: ['']
]

{ #category : #accessing }
DNSRecord >> name: aString [
	name := aString
]

{ #category : #printing }
DNSRecord >> printOn: aStream [
	aStream
		nextPutAll: name; nextPutAll: ': ';
		nextPutAll: (self class rrTypeNameFor: self type)
]

{ #category : #'reading/writing' }
DNSRecord >> readFrom: aStream [
	ttl := aStream nextNumber: 4.
	timestamp := Time millisecondClockValue
]

{ #category : #testing }
DNSRecord >> timedOut [
	^ (Time millisecondsSince: timestamp) // 1000 > ttl
]

{ #category : #accessing }
DNSRecord >> ttl [
	^ ttl ifNil: [0]
]

{ #category : #accessing }
DNSRecord >> type [
	^ self class type
]

{ #category : #'reading/writing' }
DNSRecord >> writeNameOn: aStream [
	(self name findTokens: '.')
		do: [:each |
			each size > 63 ifTrue: [self error: 'invalid name'].
			aStream nextPut: each size; nextPutAll: each asByteArray].
	aStream nextPut: 0
]

{ #category : #'reading/writing' }
DNSRecord >> writeOn: aStream [
	self writeNameOn: aStream.
	aStream 
		nextNumber: 2 put: self type; 
		nextNumber: 2 put: self dclass; 
		nextNumber: 4 put: self ttl
]
