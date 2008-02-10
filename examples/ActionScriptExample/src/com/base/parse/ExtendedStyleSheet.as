/*
*  ExtendedStyleSheet
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.parse {

	import flash.text.*;

	public class ExtendedStyleSheet extends StyleSheet {
	
	// this class overrides the transform method in StyleSheet and adds the things that are in text format but not in styleSheets
	
	    public override function transform( s:Object ) : TextFormat { 
	        var f:TextFormat = super.transform( s );
	        for ( var p:String in s ) {
	            switch ( p ) {
					case "lineHeight": f.leading = strip( s[ p ] ); break;
	                case "blockIndent": f.blockIndent = strip( s[ p ] ); break;
	                case "tabStops": f.tabStops = String( s[ p ] ).split( "," ); break;
	                case "bullet": f.bullet = ( s[ p ] == "true" ); break;
	            }

	        }
	        return f;
	    }
	
		internal function strip(t:String) : Number {
	        return Number( t.substr( 0, t.indexOf("p") ) );
	    }

	}
	
}