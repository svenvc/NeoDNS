"
Tests for NeoNetworkState
"
Class {
	#name : #NeoNetworkStateTests,
	#superclass : #TestCase,
	#category : #'Neo-DNS-Tests'
}

{ #category : #tests }
NeoNetworkStateTests >> testAirplaneMode [
	self deny: NeoNetworkState default airplaneMode.
	
	NeoNetworkState default airplaneMode: true.
	self assert: NeoNetworkState default airplaneMode.
	self deny: NeoNetworkState default hasInternetConnection.
	self should: [ NeoNetworkState default ensureInternetConnection ] raise: NoNetworkError.
	
	NeoNetworkState default airplaneMode: false.
	self deny: NeoNetworkState default airplaneMode
]

{ #category : #tests }
NeoNetworkStateTests >> testEnsureInternetConnection [
	NeoNetworkState default ensureInternetConnection 
]

{ #category : #tests }
NeoNetworkStateTests >> testHasInternetConnection [
	self assert: NeoNetworkState default hasInternetConnection.
	NeoNetworkState default ensureInternetConnection 
]

{ #category : #tests }
NeoNetworkStateTests >> testStateManipulation [
	self assert: NeoNetworkState default hasInternetConnection.
	
	NeoNetworkState default noteFailingInternetConnection.
	self deny: NeoNetworkState default hasInternetConnection.
	
	NeoNetworkState default noteWorkingInternetConnection.
	self assert: NeoNetworkState default hasInternetConnection
]
