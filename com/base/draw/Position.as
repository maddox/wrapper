/*
*  Position
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.draw {
	
	import flash.display.Sprite;
	
	public class Position {
		
		public static function AUTO( par:*, sty:Object, tar:* ) :Object { 
			
			var n:Object = sty;
			if( par.numChildren != 0 ){
				if( par.getChildIndex( tar ) == 0 ){
					n.base.x = n.base.x + par.STYLE.padding.l + n.margin.l;
					n.base.y = n.base.y + par.STYLE.padding.t + n.margin.t;
				}else{
					var lastChild:* = par.getChildAt( par.getChildIndex( tar ) - 1 );
					if( lastChild.name == "textBox" ) {
						n.base.x = 0;
						n.base.y = 0;
					}else {
						if( ( par.STYLE.base.w - par.STYLE.padding.l - par.STYLE.padding.r ) - ( lastChild.STYLE.base.w + lastChild.x ) >= n.base.w + n.margin.l + n.margin.r ){
							n.base.x = lastChild.STYLE.base.w + lastChild.x + lastChild.STYLE.margin.r + n.margin.l;
							n.base.y = lastChild.y + n.margin.t;
						}else{ 
							// move to below last item
							n.base.x = par.STYLE.padding.l + n.margin.l; 
							n.base.y = lastChild.y + lastChild.STYLE.base.h + lastChild.STYLE.margin.b + n.margin.t;
						}
						
					}
					
				}

			}
			return n;
		}
		
		public static function RELATIVE( p:Sprite, s:Object, tar:* ) :Object {
			return s; // default flash positioning
		}
		
/*		public static function ABSOLUTE( p:Sprite, s:Object, tar:* ) :Object {
			var clickPoint:Point = new Point(square.mouseX, square.mouseY);
			trace("display object coordinates:", clickPoint);
			trace("stage coordinates:", square.localToGlobal(clickPoint));
			return s; // TODO: need to make
		}
		
		public static function FIXED( p:Sprite, s:Object, tar:* ) :Object {
			return s; // ?
		}*/

	}

}

