"
I am CNAMERecord.
I am a DNSRecord.

I hold a canonical or primary name which is an alias.
"
Class {
	#name : #CNAMERecord,
	#superclass : #DNSRecord,
	#instVars : [
		'cname'
	],
	#category : #'Neo-DNS-Core-Messages'
}

{ #category : #accessing }
CNAMERecord class >> type [
	^ 5
]

{ #category : #resolving }
CNAMERecord >> addressUsing: resolver [

	^ resolver addressByName: cname
]

{ #category : #resolving }
CNAMERecord >> addressesUsing: resolver [

	^ resolver addressesByName: cname
]

{ #category : #accessing }
CNAMERecord >> cname [
	"Answer the value of cname"

	^ cname
]

{ #category : #accessing }
CNAMERecord >> cname: anObject [
	"Set the value of cname"

	cname := anObject
]

{ #category : #printing }
CNAMERecord >> printOn: aStream [
	aStream nextPutAll: name; nextPutAll: ': CNAME '; nextPutAll: cname
]

{ #category : #'reading/writing' }
CNAMERecord >> readFrom: aStream [
	super readFrom: aStream.
	aStream skip: 2.
	cname := self class readNameFrom: aStream
]
