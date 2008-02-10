/*
*  Attributes
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.parse {
	
	import com.adobe.serialization.json.JSONDecoder;
	
	public class Attributes {
		
		public function Attributes( ) { }
		public static const onclick: String = "click";
		public static const ondblclick: String = "doubleClick";
		public static const onmousedown: String = "mouseDown";
		public static const onmouseleave: String = "mouseLeave";
		public static const onmousemove: String = "mouseMove";
		public static const onmouseout: String = "mouseOut";
		public static const onmouseover: String = "mouseOver";
		public static const onmouseup: String = "mouseUp";
		public static const onmousewheel: String = "mouseWheel";
		public static const onrollout: String = "rollOut";
		public static const onrollover: String = "rollOver";
		public static const onkeydown: String = "keyDown";
		public static const onkeyup: String = "keyUp";
		public static const onkeypress: String = "keyUp"; // added
		//
		public static const oninit: String = "init";
		public static const onload: String = "load";
		public static const onunload: String = "unload";
  		public static const onaddedtostage: String = "addedToStage";
  		public static const oncomplete: String = "complete";
		public static const onenterframe: String = "enterFrame";
		public static const onfocus: String = "focusIn"; // changed
		public static const onblur: String = "focusOut"; // changed
		public static const onfullscreen: String = "fullScreen";
		public static const onprogress: String = "progress";
		public static const onremoved: String = "removed";
		public static const onscroll: String = "scroll";
		public static const onselect: String = "select";
		public static const onsocketdata: String = "socketData";
		public static const onsync: String = "sync";
		public static const ontabindexchange: String = "tabIndexChange";
		public static const ontextinput: String = "textInput";
		public static const onresize: String = "resize";

		public static function cleanEvent( eventStr:String, json:Object, jsonObjs:Object = null, prop:String=null ) : Array {
			eventStr = eventStr.split( " " ).join( "" ).split("&quot;").join('"');
			var events:Array = eventStr.split(";");
			var func:Array = new Array();
			var decoder:JSONDecoder;
			for each( var evnt:String in events ){
				if( evnt.substr( 0, 5 ) == "json(" ) {
					evnt = evnt.split( "json(" ).join( "" ).split( ")" ).join( "" );
					if( evnt.substr( 0, 1 ) == "{" ){
						decoder = new JSONDecoder( evnt );
						func.push( decoder.getValue() );
					}else{ 
						func.push( json.actions[ evnt.split('"').join("").split("'").join("") ] );
					}
				} else 	if( evnt.substring(0, 5) == "ated(" ){
						var s:String = jsonObjs[ evnt.split(" ").join("").split("ated(").join("").split(")").join("") ];
						if( s.substr( 0, 1 ) == "{" ){
							decoder = new JSONDecoder( s );
							func.push( decoder.getValue() );
						}else{
							for each( var a:String in s.split('"').join("").split("[").join("").split("]").join("").split(" ").join("").split(",") ) {
								func.push( json.actions[ a ] );
							}
							
						}
				}else {
					if( evnt != null && evnt != "" ){
						var args:Array = evnt.split(")").join("").split("(");
						evnt = args[1];
						evnt = evnt.split( "'" ).join( "" ).split( '"' ).join( "" );
						var j:Array = evnt.split(",");
						var obj:Object = new Object( );
						obj["type"] = "javascript";
						obj.classPath = "";
						obj.methodName =  args[0];
						obj.args = j;
						func.push( obj );
					}
					
				}
				
			}
			return func;
		}
		
	}

}
