"
I am NeoDNSTimeout.
I am a DynamicVariable and a ProcessSpecificVariable.

I can be used to modify the default socket IO timeout for DNS requests on a per process basis, for example:

NeoDNSTimeout 
	value: 1 
	during: [ ^ NeoSimplifiedDNSClient default addressForName: 'stfx.eu' ]
"
Class {
	#name : #NeoDNSTimeout,
	#superclass : #DynamicVariable,
	#category : #'Neo-DNS-Core-Clients'
}

{ #category : #accessing }
NeoDNSTimeout >> default [
	^ 5 "seconds"
]
