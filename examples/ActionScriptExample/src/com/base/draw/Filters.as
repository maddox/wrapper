/*
*  Filters
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.draw {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.filters.*;
	
	public class Filters {
		
		public function Filters( element:Sprite, filterArray:* ) {
			if(filterArray.length != 0){
				var arr:Array = new Array();
				for each( var f:Object in filterArray ) {
					arr.push( this[ f.type.toLowerCase() ]( f ) );
				}
				element.filters = arr;
			}
		}
		public function bevel( f:Object ) : BitmapFilter { 
			return new BevelFilter( f.distance, f.angle, f.highlightColor, f.highlightAlpha, f.shadowColor, f.shadowAlpha, f.blurX, f.blurY, f.strength, f.quality, f.fillType, false);
		}
		public function blur( f:Object ) : BitmapFilter { 
			return new BlurFilter( f.blurX, f.blurY, f.quality );
		}
		public function dropshadow( f:Object ) : BitmapFilter { 
			return new DropShadowFilter( f.distance, f.angle, f.color, f.alpha, f.blurX, f.blurY, f.strength, f.quality, f.inner, f.knockout );
		}
		public function glow( f:Object ) : BitmapFilter { 
			return new GlowFilter( f.color, f.alpha, f.blurX, f.blurY, f.strength, f.quality, f.inner, f.knockout );
		}
		public function colormatrix( f:Object ) : BitmapFilter { 
			return new ColorMatrixFilter( f.matrix );
		}

	}

}

