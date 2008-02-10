/*
*  Proxy
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.utils {
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.display.DisplayObjectContainer;
	
	public class Proxy {
		
		public static function create( target:*, ev:Event = null, targ:* = null, eventType:String=null ) : * {
			var funcs:Array;
			if( ev != null )
				funcs = ev.currentTarget.STYLE.events[ev.type];
			else 
				funcs = targ["STYLE"].events[ eventType ]; 
			
			var tar:*;
			if(targ == null) 
				tar = ev.currentTarget as DisplayObjectContainer;
			else 
				tar = targ;
			
			for each( var func:Object in funcs ) {
				Proxy[ func.type.toLowerCase() + "Method" ]( target, tar, func );
			}
			
		}
		
		public static function rootMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			if( func.args && func.args.length != 0 ) { return target[ func.method ].apply( target[ func.method ], Proxy.cleanArgs( target, targ, func.args ) ); }
			else { return target[ func.method ]( ); }
		}
		
		public static function documentMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			if( func.args && func.args.length != 0 ) { return target.main.document[ func.method ].apply( target.main.document[ func.method ], Proxy.cleanArgs( target, targ, func.args ) ); }
			else { return target.main.document[ func.method ]( ); }
		}
		
		public static function singletonMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			var classInstance:Class = ApplicationDomain.currentDomain.getDefinition( func["class"] ) as Class;
			if( func.args && func.args.length != 0){ return classInstance.instance[ func.method ].apply( classInstance.instance[ func.method ], Proxy.cleanArgs( target, targ, func.args ) ); }
			else { return classInstance.instance[ func.method ](); }
		}
		
		public static function classMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			var classInstance:Class = ApplicationDomain.currentDomain.getDefinition( func["class"] ) as Class;
			if( func.args && func.args.length != 0 ){ return new classInstance( Proxy.cleanArgs( target, targ, func.args ) ); }
			else { return new classInstance(); } /*  this isn't right it needs to do something like an apply for the args, you can only send an array now */
		}
		
		public static function instanceMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			var classInstance:Class = ApplicationDomain.currentDomain.getDefinition( func["class"] ) as Class;
			var classRef:* = new classInstance( );
			if( func.args && func.args.length != 0 ) { return classRef[ func.method ].apply( classRef[ func.method ], Proxy.cleanArgs( target, targ, func.args ) ); }
			else { return classRef[ func.method ]( ); }
		}
		
		public static function staticMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			var classInstance:Class = ApplicationDomain.currentDomain.getDefinition( func["class"] ) as Class;
			if( func.args && func.args.length != 0 ) { return classInstance[ func.method ].apply( classInstance, Proxy.cleanArgs( target, targ, func.args ) ); }
			else{ return classInstance[ func.method ](); }
		}
		
		public static function javascriptMethod( target:*, targ:DisplayObjectContainer, func:Object ) : * {
			return ExternalInterface.call.apply( func.method, func.args );
		}
		
		public static function cleanArgs( target:*, targ:*, args:Array ) :Array {
			var n:Array = new Array();
			for each( var arg:* in args ){
				if( typeof(arg) == "object" ){
					if( arg["type"] != null && ( arg["method"] != null || arg["class"] != null ) ){
						if( arg["method"].toLowerCase() == "this" ){
							n.push( targ );
						}else{
							n.push( Proxy[ arg.type.toLowerCase() + "Method" ]( target, targ, arg ) );
						}
					}else{ n.push( arg ); }
				}else{ n.push( arg ); }
			}
			return n;
		}

	}

}
