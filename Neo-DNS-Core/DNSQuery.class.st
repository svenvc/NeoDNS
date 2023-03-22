"
I am DNSQuery.

The question section is used to carry the ""question"" in most queries,
i.e., the parameters that define what is being asked.  The section
contains QDCOUNT (usually 1) entries, each of the following format:

                                    1  1  1  1  1  1
      0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                                               |
    /                     QNAME                     /
    /                                               /
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                     QTYPE                     |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
    |                     QCLASS                    |
    +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

where:

QNAME           a domain name represented as a sequence of labels, where
                each label consists of a length octet followed by that
                number of octets.  The domain name terminates with the
                zero length octet for the null label of the root.  Note
                that this field may be an odd number of octets; no
                padding is used.

QTYPE           a two octet code which specifies the type of the query.
                The values for this field include all codes valid for a
                TYPE field, together with some more general codes which
                can match more than one type of RR.

QCLASS          a two octet code that specifies the class of the query.
                For example, the QCLASS field is IN for the Internet.
"
Class {
	#name : #DNSQuery,
	#superclass : #Object,
	#instVars : [
		'name',
		'type',
		'dclass'
	],
	#category : #'Neo-DNS-Core-Messages'
}

{ #category : #'instance creation' }
DNSQuery class >> name: aString type: anInteger class: bInteger [
	^ self new
		name: aString;
		type: anInteger;
		dclass: bInteger;
		yourself
]

{ #category : #'instance creation' }
DNSQuery class >> readFrom: aStream [
	^ self 
		name: (DNSRecord readNameFrom: aStream) 
		type: (aStream nextNumber: 2) 
		class: (aStream nextNumber: 2)
]

{ #category : #comparing }
DNSQuery >> = aDNSQuery [
	^ self class = aDNSQuery class
		and: [ type = aDNSQuery type and: [ name = aDNSQuery name and: [ dclass = aDNSQuery dclass ] ] ]
]

{ #category : #accessing }
DNSQuery >> dclass [
	^ dclass
]

{ #category : #accessing }
DNSQuery >> dclass: anInteger [
	dclass := anInteger
]

{ #category : #comparing }
DNSQuery >> hash [
	^ name hash + type + dclass
]

{ #category : #accessing }
DNSQuery >> name [
	^ name
]

{ #category : #accessing }
DNSQuery >> name: aString [
	name := aString
]

{ #category : #printing }
DNSQuery >> printOn: aStream [
	aStream
		nextPutAll: name; nextPutAll: ': ';
		nextPutAll: (DNSRecord rrTypeNameFor: type);
		nextPut: $?
]

{ #category : #accessing }
DNSQuery >> type [
	^ type
]

{ #category : #accessing }
DNSQuery >> type: anInteger [
	type := anInteger
]

{ #category : #'reading/writing' }
DNSQuery >> writeNameOn: aStream [
	(name findTokens: '.')
		do: [:each |
			each size > 63 ifTrue: [self error: 'invalid name'].
			aStream nextPut: each size; nextPutAll: each asByteArray].
	aStream nextPut: 0
]

{ #category : #'reading/writing' }
DNSQuery >> writeOn: aStream [
	self writeNameOn: aStream.
	aStream nextNumber: 2 put: type; nextNumber: 2 put: dclass
]
