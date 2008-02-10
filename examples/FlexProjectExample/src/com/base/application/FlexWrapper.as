/*
*  Wrapper
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.application {

	import com.base.parse.Html;
	
	import flash.display.*;
	import flash.events.Event;
	
	import mx.core.Container;
	import mx.events.FlexEvent;
	
	public class FlexWrapper extends Container {
		
		public var htmlPath:String = "sample.html";
		public var doc:Html;
		internal var target:Sprite;
		
		public function FlexWrapper() { 
			target = new Sprite();
			target.name = "root1";
			rawChildren.addChild(target);
			doc = new Html( target, htmlPath );
			target.addEventListener( "finished", onComplete );
			addEventListener( Event.RESIZE, onResize );
		}
		
		internal function onComplete( evt:Event ) : void {
			width = target.width;
			height = target.height;
		}
		
		internal function onResize( ev:Event ) : void {
			doc.updateStage( target );
		}
	}
}
