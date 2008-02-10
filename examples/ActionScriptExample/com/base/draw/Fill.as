/*
*  Fill
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.draw {
	
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class Fill {
		
		public static function none( element:Sprite, style:Object, t:* = null ) :void { 
			Shape[ style.shape.type ]( element, style );
		}
		
		public static function solid( element:Sprite, style:Object, t:* = null ) :void { 
			element.graphics.beginFill( style.fill.color, style.fill.alpha );
			Shape[ style.shape.type ]( element, style );
		}
		
		public static function gradient( element:Sprite, style:Object, t:* = null ) :void {
			var matrix:Matrix = new Matrix(); // the width and height of the gradients matrix are based on percentages not pixels
			matrix.createGradientBox( ( style.base.w*.01 ) * style.fill.w, ( style.base.h*.01 ) * style.fill.h, ( style.fill.r/180 )*Math.PI, style.fill.tx, style.fill.ty );
			element.graphics.beginGradientFill( style.fill.kind, style.fill.colors, style.fill.alphas, style.fill.ratios, matrix, style.fill.spread, style.fill.interpolation, style.fill.focalpoint );
			Shape[ style.shape.type ]( element, style );
		}

		public static function image( element:Sprite, style:Object, t:* = null ) :void { 
			var s:String = style.fill.url;
			if( !t.main.document.bitmaps[ s ] ) { // load image if not already loaded
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener( "complete", o );
				l.load( new URLRequest( s ));
				function o( ev:Event ) : void {
					var b:BitmapData = new BitmapData(l.width, l.height, false, style.fill.color );
					b.draw( l );
					element.graphics.beginBitmapFill( b );
					Shape[ style.shape.type ]( element, style );
					t.main.document.bitmaps[ s ] = b;
				}
			} else {
				element.graphics.beginBitmapFill( t.main.document.bitmaps[ s ] );
				Shape[ style.shape.type ]( element, style );
			}
			
		}

	}

}

