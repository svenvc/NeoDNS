"
I am ANYRecord.
I am a DNSRecord.

I represent a request for all records, *
"
Class {
	#name : #ANYRecord,
	#superclass : #DNSRecord,
	#category : #'Neo-DNS-Core-Messages'
}

{ #category : #accessing }
ANYRecord class >> type [
	^ 255
]
