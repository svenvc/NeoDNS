"
I am BaselineOfNeoDSN, a way to load the Neo-DNS code.
I am a BaselineOf.

Experimental in-image DNS implementation for Pharo

https://github.com/svenvc/NeoDNS

https://en.wikipedia.org/wiki/Domain_Name_System
"
Class {
	#name : #BaselineOfNeoDNS,
	#superclass : #BaselineOf,
	#category : #BaselineOfNeoDNS
}

{ #category : #baselines }
BaselineOfNeoDNS >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec
			package: 'Neo-DNS-Core';
			package: 'Neo-DNS-Tests' with: [ spec requires: #('Neo-DNS-Core') ];
			group: 'default' with: #('core' 'tests');
			group: 'core' with: #('Neo-DNS-Core');
			group: 'tests' with: #('Neo-DNS-Tests') ]
]
