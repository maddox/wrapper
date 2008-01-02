/*
*  Main
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package {
	
	import com.base.application.Wrapper;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Main extends Sprite {

		public var main:Wrapper;
		
		public function Main() {
			main = new Wrapper( this );
			addEventListener( "finished", onComplete );
		}
		
		internal function onComplete( evt:Event ) : void {
			trace( "Complete!" );
		}

	}

}