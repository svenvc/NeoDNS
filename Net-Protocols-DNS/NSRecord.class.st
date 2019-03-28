"
I am NSRecord.
I am a DNSRecord.

I hold name server information.
"
Class {
	#name : #NSRecord,
	#superclass : #DNSRecord,
	#instVars : [
		'ns'
	],
	#category : #'Net-Protocols-DNS-MessageFormat'
}

{ #category : #accessing }
NSRecord class >> type [
	^ 2
]

{ #category : #accessing }
NSRecord >> ns [
	^ ns
]

{ #category : #printing }
NSRecord >> printOn: aStream [
	aStream nextPutAll: name; nextPutAll: ': NS '; nextPutAll: ns
]

{ #category : #'reading/writing' }
NSRecord >> readFrom: aStream [
	super readFrom: aStream.
	aStream skip: 2.
	ns := self class readNameFrom: aStream
]
