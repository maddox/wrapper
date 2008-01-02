//
//  TweenerPlugin
//
//  Created by tyler larson on 2007-05-17.
//  Copyright (c) 2007 0in1 Inc.. All rights reserved.
//

package {
	
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	
    public class TweenerPlugin extends Sprite {
	
		public var tweener:Tweener;
		private static var instance:TweenerPlugin = new TweenerPlugin();
		
        public function TweenerPlugin() {
			if (instance != null) trace("Public construction of this plugin is not allowed. Use Tweener.getInstance()");
        }
		 
        public static function getInstance() : TweenerPlugin {
			return instance;
        }
    }
}
