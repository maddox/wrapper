/*
*  CSS
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.parse {
	
	import com.base.parse.ExtendedStyleSheet;
	import flash.display.*;
	import flash.net.*;
	import flash.events.Event;
	import flash.text.Font;
	import com.base.parse.Attributes;
	import com.adobe.serialization.json.JSONDecoder;
	
	public class Css {
		
		// TODO: We haven't yet done anything about overflow:auto (scrollbars) or floats or flash things like transforms, and animations
		internal const position:Array = [ "position" ];
		internal const x:Array = [ "x", "left" ]; // might want to add float
		internal const y:Array = [ "y", "top" ];
		internal const w:Array = [ "w", "width" ];
		internal const h:Array = [ "h", "height" ];
		internal const alpha:Array = [ "alpha", "opacity" ];
		internal const rotation:Array = [ "rotation" ];
		internal const scaleX:Array = [ "scaleX" ];
		internal const scaleY:Array = [ "scaleY" ];
		internal const visible:Array = [ "visible" ];
		internal const cacheAsBitmap:Array = [ "cacheAsBitmap" ];
		internal const buttonMode:Array = [ "buttonMode" ];
		internal const blendMode:Array = [ "blendMode" ];
		internal const margin:Array = [ "margin", "marginLeft", "marginRight", "marginTop", "marginBottom" ];
		internal const padding:Array = [ "padding", "paddingLeft", "paddingRight", "paddingTop", "paddingBottom" ];
		internal const fill:Array = [ "fill", "background", "backgroundColor", "backgroundImage", "backgroundOpacity" ];
		internal const shape:Array = [ "shape" ]; // , "borderRadius", "borderTopLeftRadius", "borderTopRightRadius", "borderBottomLeftRadius", "borderBottomRightRadius" 
		internal const border:Array = [ "border", "line", "borderColor" ];
		internal const mask:Array = [ "mask" ];
		internal const scrollRect:Array = [ "overflow", "overflow" ];
		internal const filters:Array = [ "filters" ];
		
		// array of arrays, this array has 12 baseProperties
		internal const baseArray:Array = [ "position", "x", "y", "w", "h", "alpha", "rotation", "scaleX", "scaleY", "visible", "cacheAsBitmap", "buttonMode", "blendMode", "margin", "padding", "fill", "shape", "border", "mask", "scrollRect", "filters" ]; 
		internal const eventsArray:Array = [ "onclick", "ondblclick", "onmousedown", "onmouseleave", "onmousemove", "onmouseout", "onmouseover", "onmouseup", "onmousewheel", "onrollout", "onrollover", "onkeydown", "onkeyup", "onkeypress", "oninit", "onload" ];

		// vars to combine things together so that I dont have to over write the values
		internal var __margin:Object;
		internal var __padding:Object;
		internal var __fill:Object;
		internal var __border:Object;
		internal var __shape:Object;
		
		internal var loader:URLLoader;
		internal var fontLoader:Loader;
		internal var loadedFonts:int = 0;
		internal var jsonObjs:Object = new Object();
		
		public var fonts:Array = new Array();
		
		public var style:ExtendedStyleSheet = new ExtendedStyleSheet();
		
		public var target:DisplayObjectContainer;
		
		public function Css( Target:* ) { target = Target; }
		
		public function loadcss( cssString:String ) :void {
			cssString = parseJSON( cssString );
			try {
				style.parseCSS( cssString );
			} catch(er:Error) {
				trace("Can't parse CSS. \n\n"+ er.message );
				return;
			}
			parse( style );
		}
		
		internal function parseJSON( cssStr:String ) : String {
			if( cssStr.indexOf( "json(" ) != -1 || cssStr.indexOf( "JSON(" ) != -1 ){
				cssStr = cssStr.split("JSON(").join("json(");
				var jsonAmount:int = cssStr.split("json(").length - 1;
				var lastStart:int = 0;
				var lastEnd:int = 0;
				for( var i:int = 0; i < jsonAmount; i++ ) {
					if( cssStr.indexOf( "json(" ) != -1 ) {
						var startIndex:int = cssStr.indexOf( "json(", lastStart ) + 5;
						var endIndex:int = cssStr.indexOf( ")", startIndex );
						var thisObj:String = cssStr.substring( startIndex, endIndex );
						thisObj = thisObj.split("'").join("");
						jsonObjs["obj"+i] = thisObj;
						cssStr = cssStr.split( thisObj ).join( "obj" + i );
						cssStr = cssStr.split( "json('obj"+i+"')" ).join( "ated(obj"+i+")" );
						lastStart = startIndex + 1;
						lastEnd = endIndex + 1;
					}
					
				}
				
			}
			return cssStr;
		}
		
		internal function parse( css:ExtendedStyleSheet ) :void {
			
			var styleNames:Array = css.styleNames;
		    for each( var styleName:String in styleNames ) {
			
				__margin = { t:0, r:0, b:0, l:0 }; 
				__padding = { t:0, r:0, b:0, l:0 }; 
				__border = { type:"none", weight:0, color:0x000000, alpha:100}; 
				__shape = { type:"box", tl:0, tr:0, br:0, bl:0 };
				__fill = { type:"solid", color:0x000000, alpha:100};
				
				var _style:Object = new Object();
	            var styleObject:Object = css.getStyle( styleName );
				
				for each( var eventProp:String in eventsArray ){ // populate the event values in style object
					if( styleObject[eventProp] ){ 
						if( _style.events == null ) { _style.events = new Object(); }
						var eventName:String = Attributes[ eventProp.toLowerCase() ];
						_style.events[eventName] = Attributes.cleanEvent( styleObject[eventProp], target["main"].document.json, jsonObjs, eventProp );
						delete _style[eventProp];
					}
				}
				
	            for ( var propName:String in styleObject ) {
					var populated:Boolean = false;
					var valueObject:Object = cleanStyle( propName, styleObject[propName] );
					var i:int = 0;
					loop : for each( var baseProp:String in baseArray ){ // populate the base values in style object
						if( i == 12 ) break loop;
						if( baseProp == valueObject["prop"] ){ 
							if( _style.base == null ) { _style.base = new Object(); }
							_style.base[baseProp] = valueObject.val; 
							populated = true; 
						}
						i++;
					}
					if( !populated ){ 
						_style[valueObject.prop] = valueObject.val; // everything else
					}
					if( propName == "fontFile" ){ 
						fonts.push( styleObject[propName].split('url(').join("").split(')').join("").split('"').join("").split(";").join("").split("'").join("") );
					}
					
				}
				style.setStyle( styleName, _style ); 
	      	}
			loadFonts();
		}
		
		internal function loadFonts() : void {
			if( loadedFonts == fonts.length ) {
				if( loadedFonts != 0 ) {
					target.dispatchEvent( new Event("CSSLoaded" ) );
				}else{
					target.dispatchEvent( new Event("CSSLoaded" ) );
					trace( "You have loaded no fonts, this means you can write no text." );
				}
			}else{
				fontLoader = new Loader();
				fontLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fontLoaded);
				fontLoader.load( new URLRequest( fonts[ loadedFonts++ ] ) );
				target.dispatchEvent(new Event("Loading_Fonts"));
			}
			
		}
		
		internal function fontLoaded(event:Event) : void {
			const fontPath:Array = fonts[ loadedFonts - 1 ].split("/");
			const fontName:String = fontPath[ fontPath.length - 1 ].split(".swf").join("");
		    var FontLibrary:Class = event.target.applicationDomain.getDefinition( "Font_" + fontName ) as Class;
		    Font.registerFont( FontLibrary[ fontName ] );
			loadFonts();		
		}

		internal function cleanStyle( cssProp:String, cssValue:String ) : Object { 
			var obj:Object = { prop:cssProp, val:cssValue };
			for each( var propNames:String in baseArray){
				for each( var prop:String in this[propNames] ){ 
					if( cssProp == prop ) {	// in val call the method of the clean property name
						obj = { prop:propNames, val:this["_"+ propNames+"_"]( cssValue, prop ) }; 
					}
					
				}
				
			}
			return obj;
		}

		// functions to clean the css values for flash to use, the more complicated ones have variables up top to put things into
		internal function _position_(val:String, prop:String ) : String { return val; }
		internal function _name_( val:String, prop:String ) : String { return val; }
		internal function _x_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _y_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _w_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _h_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _alpha_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _rotation_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _scaleX_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _scaleY_( val:String, prop:String ) : * { return cleanInt( val ); }
		internal function _visible_( val:String, prop:String ) : Boolean { 
			if( val.toLowerCase() == "true" ){ return true; } else { return false; } 
		} 
		internal function _cacheAsBitmap_( val:String, prop:String ) : Boolean { 
			if(val.toLowerCase() == "true"){ return true; }else{ return false; } 
		}
		internal function _buttonMode_( val:String, prop:String ) : Boolean { 
			if(val.toLowerCase() == "true"){ return true; }else{ return false; } 
		}
		internal function _blendMode_( val:String, prop:String ) : String { return val; }
		internal function _margin_( val:String, prop:String ) : Object { 
			if( prop == "margin" ){ 
				var p:Array = val.split(" ");
				if( p.length == 1 ) { 
					__margin.t = __margin.r = __margin.b = __margin.l = cleanInt( val );
				}else{
					__margin.t = cleanInt( p[0] );
					__margin.r = cleanInt( p[1] );
					__margin.b = cleanInt( p[2] );
					__margin.l = cleanInt( p[3] );
				}	
			}
			else if( prop == "marginLeft" ){ __margin.l = cleanInt(val); }
			else if( prop == "marginRight" ){ __margin.r = cleanInt(val);  }
			else if( prop == "marginTop" ){ __margin.t = cleanInt(val); }
			else if( prop == "marginBottom" ){ __margin.b = cleanInt(val); }
			return __margin;
		}
		internal function _padding_( val:String, prop:String ) : Object { 
			if( prop == "padding" ){ 
				var p:Array = val.split(" ");
				if( p.length == 1 ) { 
					__padding.t = __padding.r = __padding.b = __padding.l = cleanInt( val );
				}else{
					__padding.t = cleanInt( p[0] );
					__padding.r = cleanInt( p[1] );
					__padding.b = cleanInt( p[2] );
					__padding.l = cleanInt( p[3] );
				}
			}
			else if( prop == "paddingLeft" ){ __padding.l = cleanInt(val); }
			else if( prop == "paddingRight" ){ __padding.r = cleanInt(val);  }
			else if( prop == "paddingTop" ){ __padding.t = cleanInt(val); }
			else if( prop == "paddingBottom" ){ __padding.b = cleanInt(val); }	
			return __padding;
		}
		internal function _fill_( val:String, prop:String ) : Object {
			var loc_fill:Object;
			if( prop == "background" || prop == "backgroundColor" ){ 
				if( val.substr( 0, 2) == "url" ) { __fill.type = "image"; __fill.url = val.substr( 4, (val.length-1) ); }
				else{ __fill.color = cleanInt( val ); }
				loc_fill = __fill;
			}else if( prop == "backgroundOpacity" ){
				__fill.alpha = cleanInt( val ); 
				loc_fill = __fill;
			}else if( prop == "backgroundImage" ){
				__fill.type = "image"; 
				if( val.toLowerCase() == "no-repeat" ){ __fill.repeat = false; } else { __fill.repeat = true; } 
				if( val.toLowerCase() == "smooth" ){ __fill.smooth = true; } else { __fill.smooth = false; } 
				__fill.url = val.substr( val.indexOf( "url(") + 4, val.indexOf( ")") - 1 ).split('"').join("").split(")").join("");
				loc_fill = __fill;
			}else if( prop == "fill" ){
				loc_fill = parseObjectValue( prop, val );
			}
			return loc_fill;
		}
		internal function _shape_(val:String, prop:String ) : Object {
			if( prop == "shape" ){
				__shape = parseObjectValue( prop, val );
			}
			return __shape;
		}
		internal function _border_(val:String, prop:String ) : Object {
			if( prop == "border" ){
				__border = parseObjectValue( prop, val );
			}else if( prop == "borderColor" ){
				__border.type = "solid"; 
				__border.weight = 1; 
				__border.color = cleanInt(val); 
			}
			return __border;
		}
		internal function _mask_(val:String, prop:String ) : Object {
			return parseObjectValue( prop, val );
		}
		internal function _scrollRect_(val:String, prop:String ) : Object {
			if( prop == "overflow" && ( val == "hidden" || "auto")) { return true; } else { return false; }
		}
		internal function _filters_(val:String, prop:String ) : Array {
			return parseObjectValue( prop, val );
		}
		
		internal function parseObjectValue( prop:String, str:String ) : * {
			var json:*;
			if( str.substring(0, 4) == "ated" ){
				var s:String = jsonObjs[ str.split(" ").join("").split("ated(").join("").split(")").join("") ];
				var d:JSONDecoder = new JSONDecoder( s );  
				if( typeof( d.getValue()) == "string" ){
					json = target["main"].document.json[prop][ d.getValue() ];
				}else{
					json = d.getValue();
				}
			}else{
				trace( "Warning! " + str + "is not a json object." );
			}
			return json;
		}

		// is it a number or not, if so return number
		internal function cleanInt( val:String ) : * { 
			var num:*;
			if( val.search( /\d+/ ) == 0 || ( ( val.substr(0,1) == "." || val.substr(0,1) == "-" ) && val.search( /\d+/ ) == 1 )){ 
				if( val.substr( ( val.length - 1 ), val.length) == "%" ){ num = val; }
				else if( val.substr( ( val.length - 2 ), val.length) == "px" ){ num = int(val.substr(0, val.length - 2)); }
				else if( val.substr( ( val.length - 2 ), val.length) == "em" ){ num = int( val.substr(0, val.length - 2)) * 12; } // 12 is my default font size for now, I could do text resizing if I can set this globally.
				else{ num = Number( val ); }
			}else{
				if( val.substr( 0, 1) == "#" ){ num = uint("0x" + val.substr( 1, val.length) ); } // hex color
				else{ num = val; }
			}
			return num;
		}

	}

}