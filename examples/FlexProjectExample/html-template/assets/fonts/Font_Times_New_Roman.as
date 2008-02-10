
//
//  EmbedFonts
//
//  Created by Tyler Larson on 2007-05-14.
//  Copyright©2007 0in1 Inc. All rights reserved.
//  http://0in1.com/
//

package {

    import flash.display.Sprite;

    public class Font_Times_New_Roman extends Sprite {

		[Embed(
			source='/Users/talltyler/Desktop/converted_fonts/Times_New_Roman_Bold_Italic.ttf', 
			source='/Users/talltyler/Desktop/converted_fonts/Times_New_Roman_Bold.ttf', 
			source='/Users/talltyler/Desktop/converted_fonts/Times_New_Roman_Italic.ttf', 
			source='/Users/talltyler/Desktop/converted_fonts/Times_New_Roman.ttf', 
			fontName='Times_New_Roman', fontWeight='Bold', fontWeight='Italic', mimeType='application/x-font', 
			unicodeRange='U+0020-U+002F,U+0030-U+0039,U+003A-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E')]
        public static var Times_New_Roman:Class;

    }

}


/*
To make this work you must do a few things.

Making you font swf
1. name the class the Font_fontName and then make sure the fontName and the variable are named the same thing
2. use only ttf fonts
3. make sure you are compiling the right thing, the build.xml file need to have the right base class

Making your application
1. add a property to your css called font-file with- url("path to the swf"); , this can be in any style and only needs to be done once
2. then use the fontName in your style like any other font - font-family: "MankSans";

#cool {
	font-file: url("assets/fonts/MankSans.swf");
	font-family: "MankSans";
}
#cool-style1 {
	font-family: "MankSans";
}
#cool-style2 {
	font-family: "MankSans";
}

if you would like you can also use this syntax for the embeds but sometimes it is easy to just find the file
//[Embed(systemFont='MankSans', fontName='MankSans', mimeType='application/x-font')]

*/