/*
*  TextBox
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.draw {
	
	import flash.text.*;
	import flash.display.Sprite;
	
	public class TextBox extends TextField {	
		
		public var STYLE:Object;
		
		public function TextBox( target:*, txt:String, ssheet:StyleSheet, s:Object, type:String = null ) {
			
			STYLE = target.STYLE;
			name = "textBox";
			if( s.multiline == "false" ) multiline = false;
			else multiline = true;
			if( s.wordWrap == "false" ) wordWrap = false;
			else this.wordWrap = true;
			if( s.antiAliasType == "normal" ) antiAliasType = "normal";
			else antiAliasType = "advanced";
			if( s.border == "true" ) border = true;
			if(!STYLE.scrollRect) autoSize = TextFieldAutoSize.LEFT;
			this.x = STYLE.padding.l + STYLE.margin.l;
			this.y = STYLE.padding.t + STYLE.margin.t;
			width = target.width - STYLE.padding.l - STYLE.padding.r - STYLE.margin.l - STYLE.margin.r;
			height = target.height - STYLE.padding.t - STYLE.padding.b - STYLE.margin.t - STYLE.margin.b;
			if( s.condenseWhite == "false" ) condenseWhite = false;
			else condenseWhite = true;
			
			if( type == "input" ){
				type = "input"; 
				var f:TextFormat = new TextFormat();
				if( s.kerning == "true") f.kerning = true;
				if( s.lineHeight ) f.leading = s.lineHeight.split("px").join("");
				if( s.letterSpacing ) f.letterSpacing = s.letterSpacing.split("px").join("");
				f.rightMargin = s.padding.r;
				f.leftMargin = s.padding.l;

				if( s.displayAsPassword == "true" ) displayAsPassword = true;
				f.font = s.fontFamily.split('"').join("");
				f.color = Number("0x"+s.color.split("#").join(""));
				f.size = s.fontSize.split("px").join("");
				f.align = s.textAlign;
				defaultTextFormat = f;
			} else {
				if( s.selectable == "false" ) selectable = false;
				else selectable = true;
				styleSheet = ssheet;
				embedFonts = true;
			}
			htmlText = txt;
			
			target.addChild( this );

		}
		
		public function make() : void {
			width = this.parent.width - this.parent["STYLE"].padding.l - this.parent["STYLE"].padding.r - STYLE.margin.l - STYLE.margin.r;
			height = this.parent.height - this.parent["STYLE"].padding.t - this.parent["STYLE"].padding.b - STYLE.margin.t - STYLE.margin.b;
			this.parent["make"]();
		}

	}

}
