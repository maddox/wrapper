/*
*  Element
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.draw {
	
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import com.base.utils.Proxy;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	//import com.senocular.display.TransformTool;
	
	public class Element extends Sprite {
		
		// ORIGINAL_STYLE is a place to hold what was put defined in the stylesheet
		public var ORIGINAL_STYLE:Object;
		// public variable to save styles before they are converted so that we can do percentages and access the values later
		public var BASE_STYLE:Object;
		// STYLE is where everything goes into after it has been converted, this is public so that other elements can be relitive.
		public var STYLE:Object;
		public var parentTarget:*;
		internal var target:*;
		internal var isImg:Boolean = false;
		
		public function Element( t:*, style:Object, r:* ) { //t = this elements target, r = root
			ORIGINAL_STYLE = style;
			BASE_STYLE = style;
			parentTarget = t;
			target = r;
			parentTarget.addChild( this );
			make();
			applyFilters();
			applyActions();
		}
		
/*		public function clone(obj:Object):* {
		    var copier:ByteArray = new ByteArray();
		    copier.writeObject(obj);
		    copier.position = 0;
		    return(copier.readObject());
		}*/
		
		// on make we call update, it asks it's paraent if it's contents are bigger then it self.
		public function update() : void {
			if( this.parent.name != "root1" ){
				var lastElement:* = this.parent.getChildAt( this.parent.numChildren - 1);
				var orgH:* = this.parent["ORIGINAL_STYLE"].base.h;
				var mar_pad:int = lastElement["STYLE"].margin.b + this.parent["STYLE"].padding.b;
				
				// there is a little bit of a hack here, because of the fact that if you rotate something it's real height is bigger then it's properties hight I'm trying this getBounds stuff, it is still not picking everything up so there is a 15 in there to make if from farting to much but it is'nt good.
				if( Math.floor(this.parent.height - ( this.getBounds(this).height - this.height ) ) - 14 > Math.floor((this.parent["STYLE"].base.h + this.parent["STYLE"].margin.t) + (this.getBounds(this).height - this.height))  && !this.parent["STYLE"].scrollRect ) { // get bigger if needed
					
					//trace(this.parent.name, Math.abs(this.parent.height + this.getBounds(this).height - this.height), Math.floor((this.parent["STYLE"].base.h + this.parent["STYLE"].margin.t) - (this.getBounds(this).height - this.height)) - 1)
					
					if( typeof( orgH ) != "string" ){ // if not percentage
						this.parent["BASE_STYLE"].base.h = this.parent.height + mar_pad; 
						this.parent["make"]();
					}else{
						if( this.parent.parent.name == "root1" ) {
							this.parent["BASE_STYLE"].base.h = ( this.parent.parent.height * ( int(orgH.substring( orgH.length - 1, orgH.length )) / 100 ) ) - ( mar_pad ); 
							this.parent["make"]();
						}else{
							this.parent["BASE_STYLE"].base.h = this.parent.height + mar_pad; //( this.parent.parent.height * ( int(orgH.substring( orgH.length - 1, orgH.length )) / 100 ) ) - ( mar_pad ); 
							this.parent["make"]();
						}
					}
				} else if( this.parent.height > orgH && !this.parent["STYLE"].scrollRect ) {  // make parent smaller if needed
					if( typeof( orgH ) == "string" ){ // if percentage
						//var firstElement:* = this.parent.getChildAt( 0 );
						this.parent["BASE_STYLE"].base.h = this.parent.height + mar_pad; 
						this.parent["make"]();
					}
				}else if( this.parent.height < orgH ){
					this.parent["BASE_STYLE"].base.h = orgH + mar_pad; 
					this.parent["make"]();
				}
			} else {
				if(this.parent.height > 1 && this.parent.height > 1 && this.parent.height < 4000 ) ExternalInterface.call('resize', this.parent.height );
			}
			
		}
		
		public function make() : void {
			makeStyle(); 
			drawElement();
			positionElement();
			if( STYLE.events[ "init" ] ) { Proxy.create( target, null, this, "init" );  }
			update();
		}
		
		public function redraw() : void {
			drawElement();
			positionElement();
			update();
		}
		
		public function setSTYLE( obj:Object ) : void {
			BASE_STYLE = obj;
			target.main.document.updateStage(this);
		}
		
		internal function makeStyle() : void {
			STYLE = cleanStyle( parentTarget, ORIGINAL_STYLE );
			if( parentTarget.name != "root1" ){ STYLE = Position[ parentTarget[ "STYLE" ].base.position.toUpperCase() ]( parentTarget, STYLE, this ); }
		}
		internal function drawElement() : void {
			this.graphics.clear();
			Border[ STYLE.border.type ]( this, STYLE.border, STYLE.base.w, STYLE.base.h ); 
			Fill[ STYLE.fill.type ]( this, STYLE, target ); 
		}
		internal function applyFilters() : void {
			if( STYLE.filters ) new Filters( this, STYLE.filters );
		}
		internal function positionElement() : void {
			for( var p:String in STYLE.base) { if( p != "h" && p != "w" && p != "position") this[ p ] = STYLE.base[p]; }
			if(STYLE.scrollRect){ this.scrollRect = new Rectangle(0, 0, STYLE.base.w, STYLE.base.h); }
			
		}
		internal function applyActions() :void {
			for( var p:String in STYLE.events ){ 
				if( p == "init" ) { Proxy.create( target, null, this, "init" );  }
				else { this.addEventListener( p, evCaller ); } 
			}
		}
		
		internal function evCaller(ev:Event) : void { Proxy.create(target, ev); }
		
		internal function cleanStyle( t:*, style:Object ) : Object {
			var n:Object = new Object();
			for( var p:String in style ) {
				if( p != "events" ) {
					if( typeof( style[ p ] ) == "object" ) {
						n[ p ] = cleanStyleObj( t, style[ p ] );
					}else if( typeof( style[ p ] ) == "string" ) {
						n[ p ] = cleanTextValues( t, style[ p ], p, style );
					}else {
						n[ p ] = style[ p ];
					}
				}else { n[ p ] = style[ p ]; }
			}
		    return n;
		}
		
		internal function cleanStyleObj( t:*, style:Object ) : Object {
			var n:Object = new Object();
			for( var p:* in style ) {
				if( typeof( style[ p ] ) == "string" ) {
					n[ p ] = cleanTextValues( t, style[ p ], p, style );
				}else{
					n[ p ] = style[ p ];
				}
			} 
			return n;
		}
		
		internal function cleanTextValues( t:*, txt:*, p:String, style:Object ) :* {
			var num:*;
			if(typeof(txt) != "string" ){ return txt; } // if it is a number already.
			switch ( txt.toLowerCase() ) {
			    case "left": 	num = BASE_STYLE.margin.l; break;
			    case "right":  	num = t.STYLE.base.w - BASE_STYLE.base.w - BASE_STYLE.margin.r; break;
				case "top":  	num = BASE_STYLE.margin.t; break;
				case "bottom":  num = t.STYLE.base.h - BASE_STYLE.base.h - BASE_STYLE.margin.b; break;
				case "center": { 
					if(this.numChildren){ if(this.getChildAt(0) is Loader) isImg = true; } // might be a better way to deal with this
					if( p != "y" ){ 
						if( typeof( BASE_STYLE.base.w ) == "string" ) {
							num = ( t.width * .5 ) - ( percent( target, "w", BASE_STYLE.base.w.split("%")[0] ) * .5 ); break;
						}else{
							num = ( t.width * .5 ) - ( BASE_STYLE.base.w * .5 ); break; 
						}
					}else{ 
						if( typeof( BASE_STYLE.base.h ) == "string" ){
							num = ( t.height * .5 ) - ( percent( target, "h", BASE_STYLE.base.h.split("%")[0] ) * .5 ); break; 
						}else{
							num = ( t.height * .5 ) - ( BASE_STYLE.base.h * .5 ); break; } 
						}
					}
				default: {
					if( txt.substr( ( txt.length - 1 ), txt.length ) == "%" ) { num = percent(t, p, txt.split("%")[0]); break; }
					else if( txt.search( /\d+/ ) == 0 ){ num = Number(txt); break; }
					else { num = txt; break; }
				}
			}
			return num;
		}
		
		internal function percent( t:*, p:String, num:String ):int {
			var val:int; 
			var parentW:int = 0; var parentH:int = 0; 
			var plusLR:int; var plusTB:int;
			if( t.name == "root1" ){ 
				parentW = t.stage.stageWidth; 
				parentH = t.stage.stageHeight; 
				plusLR = 0; 
				plusTB = 0;
			}else{
				parentW = t["STYLE"].base.w - t["STYLE"].padding.l - t["STYLE"].padding.r; 
				parentH = t["STYLE"].base.h - t["STYLE"].padding.t - t["STYLE"].padding.b;
				plusLR = BASE_STYLE.margin.l + BASE_STYLE.margin.r; 
				plusTB = BASE_STYLE.margin.t + BASE_STYLE.margin.b;
			}
			if ( p == "x" || p == "w" || p == "l" || p == "r" ) { val = ( parentW * ( int(num) / 100 ) ) - ( plusLR ); }
			else if( p == "y" || p == "h" || p == "t" || p == "b" ) { val = ( parentH * ( int(num) / 100 ) ) - ( plusTB ); }
			else if( p == "alpha" || p == "scalex" || p == "scaley" || p == "rotation" ) { val = int(num); }
			else { val = int(num); trace( "can't use %'s on this style property", p, "used on this object", this.name ); }
			return val;
			
		}
		
	}
	
}
