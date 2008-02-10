/*
*  Wrapper
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.application {

	import com.base.parse.Html;
	import com.base.browser.SWFAddress;
	import flash.display.*;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	public class Wrapper {
		
		public var document:Html;
		internal var target:DisplayObjectContainer;
		
		public function Wrapper( targ:DisplayObjectContainer ) {
			
			target = targ;
			target.stage.scaleMode = StageScaleMode.NO_SCALE;
			target.stage.align = StageAlign.TOP_LEFT;
			target.stage.addEventListener( Event.RESIZE, onResize );
			
			SWFAddress.onChange = function() : void {  
				
				if( document ) document.renderURL( SWFAddress.getValue() );
				else{
					trace(target.root.loaderInfo.parameters.content_url)
					if( target.root.loaderInfo.parameters.content_url ) {
						document = new Html( target, target.root.loaderInfo.parameters.content_url ); 
					}else{
						document = new Html( target, SWFAddress.getLocation() );
					}
				}
			}
			
		}
		
		internal function onResize( ev:Event ) : void {
			document.updateStage( target );
		}
		
	}
	
}