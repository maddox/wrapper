/*
*  Border
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.draw {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class Border {
		
		public static function none( element:Sprite, border:Object, w:int, h:int ) :void { }
		
		public static function solid( element:Sprite, border:Object, w:int, h:int ) :void {
			element.graphics.lineStyle( border.weight, border.color, border.alpha );
		}
		
		public static function gradient( element:Sprite, border:Object, w:int, h:int ) :void {
			var matrix:Matrix = new Matrix(); // the width and height of the gradients matrix are based on percentages not pixels
			matrix.createGradientBox( ( w*.01 ) * border.w, ( h*.01 ) * border.h, ( border.r/180 )*Math.PI, border.tx, border.ty );
			element.graphics.lineGradientStyle( border.kind, border.colors, border.alphas, border.ratios, matrix, border.spread, border.interpolation, border.focalpoint );
		}

	}

}
