"
I am PTRRecord.
I am a DNSRecord.

I point to other information in the DNS name space.
"
Class {
	#name : #PTRRecord,
	#superclass : #DNSRecord,
	#instVars : [
		'cname'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #accessing }
PTRRecord class >> type [
	^ 12
]

{ #category : #accessing }
PTRRecord >> cname [
	^cname
]

{ #category : #printing }
PTRRecord >> printOn: aStream [
	aStream nextPutAll: name; nextPutAll: ': PTR '; print: cname
]

{ #category : #'reading/writing' }
PTRRecord >> readFrom: aStream [
	super readFrom: aStream.
	aStream skip: 2.
	cname := self class readNameFrom: aStream
]
