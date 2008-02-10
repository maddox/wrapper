/*
*  HTML
* 	  http://code.google.com/p/htmlwrapper
*    Copyright©2007 Motion & Color Inc.
*/

package com.base.parse {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import com.base.parse.*;
	import com.base.draw.*;
	import flash.text.TextField;
	import com.base.utils.Proxy;
	import com.base.browser.SWFAddress;
	import flash.errors.IllegalOperationError;
	import com.adobe.serialization.json.JSONDecoder;
	
	
	public class Html {
		
		public var target:DisplayObjectContainer;
		public var location:String;
		public var html:*;
		public var css:Css;
		public var json:Object;
		public var bitmaps:Object = new Object();
		public var forms:Object = new Object();
		public var anchors:Object = new Object();
		
		internal var htmlLoader:URLLoader;
		internal var links:int;
		internal var linkCount:int = 0;
		internal var styleTxt:String = "";
		internal var objectTxt:String = "";
		internal var linkLoader:URLLoader;
		internal var formElement:*;
		internal var assetLoader:Loader;
		internal var formTarget:*;
		internal var urlPath:String = "";
		internal var finished:Boolean = false;
		internal var org_html:*;
		public var newTar:DisplayObjectContainer;
		
		public function Html( tar:DisplayObjectContainer, urlStr:String = null ) {
			target = tar;
			location = urlStr;
			loadHTML( location, onCompleteHTML );
		}
		
		public function loadHTML( location:String, completeFunc:Function = null ) : void {
			htmlLoader = new URLLoader();
			if( completeFunc == null ) completeFunc = onCompleteNewHTML;
			htmlLoader.addEventListener( Event.COMPLETE, completeFunc );
			htmlLoader.load( new URLRequest( location ) );
		}
		
		internal function onCompleteNewHTML(  ev:Event ) : void {
			var txt:String = "<xml>" + htmlLoader.data + "</xml>";
			txt = cleanLinks( txt );
			var newhtml:XML = new XML( txt );
			//if( newTar == null ) newTar == target;
			parse( newTar, newhtml ); 
			finished = true;
			target.dispatchEvent( new Event("finished") );
		}
		
		internal function onCompleteHTML( ev:Event ) :void {
			try {
				// Take out doctypes and dtd info, there is some kind of bug in adobe's xml parser that adds junk to the xml and makes it unaccessible 
				var hd:String = htmlLoader.data;
				hd = cleanLinks( hd );
				hd = hd.split( hd.substring(0, hd.indexOf("<head>") ) ).join("<html>");
				hd = cleanHTML( hd );
				org_html = hd;
				html = new XML( hd );
				loadStyles();
			} catch( err:Error ) {
				fixHtml( err );
				return;
			}

		}
		
		internal function cleanHTML( t:String ) :String {
			/* these are not right
			t = t.replace(/<img [^>]* \/>/i, RegExp(/<img * \/>/i)); 
			t = t.replace(/<img.[^<>]+>/i, /<img.[^<>]\/+>/i); 
			t = t.replace(/<br.[^<>]+>/i, /<br.[^<>]\/+>/i); 
			t = t.replace(/<input.[^<>]+>/i, /<input.[^<>]\/+>/i); 
			t = t.replace(/<link.[^<>]+>/i, /<link.[^<>]\/+>/i); 
			*/
			t = t.replace("<br>","<br />");
			t = t.replace("<strong>","<b>");
			t = t.replace("</strong>","</b>");
			t = t.replace("<em>","<i>");
			t = t.replace("</em>","</i>");
			
			return t;
			
		}
		
		internal function cleanLinks( htmlTxt:String ) : String {
			// htmlTxt = htmlTxt.split('<a href="/').join('<a href="event:/');
			// htmlTxt = htmlTxt.split('<a href="'+ location.substring(0, 12)).join('<a href="event:'+location.substring(0, 12));
			return htmlTxt;
		}
		
		internal function fixHtml( err:Error ) : void {
			trace("___________________________________________________________________\n", org_html, "\n___________________________________________________________________");
			throw new IllegalOperationError( "Your HTML is not well formed, check this out for help...\nhttp://infohound.net/tidy/ \n\n" + err.message );
			// loop through and fix the broken tag send back to html // make my own cleaner.
			//if( err.message == 'Error #1085: The element type "link" must be terminated by the matching end-tag "</link>"' ){ }
		}

		internal function linkProxy( ev:TextEvent ) : void {
			var txt:Array = ev.text.split("|");
			linkCall( txt[0], txt[1] );
		}
		internal function linkCall( url:String, id:String = null ) : void {
			urlPath += '/id='+id+'&url='+url+'/|/';
			SWFAddress.setValue( urlPath );
		}
		
		public function renderURL( p:String ) : void {
			if( urlPath.length > p.length ) {
				var idPath:String = urlPath.substring( urlPath.lastIndexOf("id=") + 3, urlPath.lastIndexOf( "&url=" ) );
				clear( getElementById( idPath ) );
				try{
					if(getXMLById( idPath ).toXMLString() != "") parse( getElementById( idPath ), getXMLById( idPath ).toXMLString() );
				}catch(er:Error){
					trace( "already loaded?" );
					return;
				}
				
			}
			for( var i:int = 0; i < p.split("id").length; i++ ) {
				var id:String = p.substring( p.indexOf( "id=" ) + 3, p.indexOf( "&url=" ) );
				var u:String = p.substring( p.indexOf( "&url=" ) + 5, p.indexOf( "/|/" ) );	
				linker( u, id );
				p = p.substring( p.indexOf("/|/")+3, p.length );
			}
		}
		
		internal function linker( url:String, id:String = null ):void {
			if(id == null || id == "" ){ 
				clear( target.getChildByName( "root1" ) );
				newTar = target;
			}else{
				var targ:DisplayObjectContainer = getElementById( id ) as DisplayObjectContainer;
				clear( targ );
				newTar = targ;
			}
			loadHTML( url, onCompleteNewHTML );

		}
		
		internal function loadStyles() :void {
			links = html.head.link.length() - 1;
			//if( links == 0 ){ throw new IllegalOperationError( "Please include at least one style sheet. Thanks. \n\n" ); }
			loadLink( html.head.link[ 0 ] );
		}
		
		internal function loadLink( link:XML ) :void {
			if( link.@href ) {
				if( link.@rel.toLowerCase() == "plugin" ) { // load swf or something
					var loader:Loader = new Loader();
					var context:LoaderContext = new LoaderContext();
					context.applicationDomain = ApplicationDomain.currentDomain;
					try{
						loader.contentLoaderInfo.addEventListener( Event.COMPLETE, linkLoaded );
						loader.load( new URLRequest( link.@href ) , context);
					}catch(er:Error){
						trace("ClassLoader can’t load= "+ er.message );
						return;
					}
				} else if( link.@rel.toLowerCase() == "stylesheet" || link.@rel.toLowerCase() == "objects") { // load as text
					linkLoader = new URLLoader();
					linkLoader.addEventListener( Event.COMPLETE, linkLoaded );
					linkLoader.load( new URLRequest( link.@href ) );
				}else{
					finishLinks();
				}
			}else{
				loadLink( html.head.link[ linkCount++ ] );
			}
			
		}
		
		internal function linkLoaded( ev:Event ) : void {
			var loadedData:String = linkLoader.data;
			if( loadedData.substring(0, 1).toLowerCase() == "{" ){ 
				objectTxt += loadedData;
			}else{ // CSS
				styleTxt += loadedData;
			}
			linkLoader.data = "";
			finishLinks();
		}
		
		internal function finishLinks() :void {
			if( linkCount == links ){
				if( objectTxt != "" ){
					var decoder:JSONDecoder = new JSONDecoder( objectTxt );
					json = decoder.getValue();
				}
				css = new Css( target );
				target.addEventListener( "CSSLoaded", render );
				css.loadcss( styleTxt );
			}else if( html.head.link[ linkCount+1 ] ){
				loadLink( html.head.link[ linkCount++ ] );
			}
		}
		
		public function render( ev:Event ) :void {
			//parse( ev.target, html.body.div.div ); 
			var style:Object = styleElement( html.body, ev.target );
			var root:Element = new Element( ev.target, style, target );			
			//var root:Element = make( ev.target, html, html.body );
			parse( root, html.body ); 
			loadNextAsset(); // load all external images and swf
			ev.target.dispatchEvent( new Event("finished") );
		}
		
		
		internal function parse( targ:*, node:* ) : void {
			
			const CONTAINER_NODE_TYPES:Array = [ "div", "ul", "form", "a", "input"];  // nodes that can have children
			const END_NODE_TYPES:Array = ["img", "object", "embed", "li"];
			
			for each ( var child:* in node.children() ) {
				var made:Boolean = false;
				var thisNodeType:String = child.localName().toLowerCase();
				loop1: for each ( var n:String in CONTAINER_NODE_TYPES ) {
					if( n == thisNodeType ) { 
						make( targ, node, child, !child.hasSimpleContent(), false );
						made = true;
						break loop1; 
					} 
				}
				if( !made ){ // node was not in NODETYPES list
					loop2: for each ( var nodetype:String in END_NODE_TYPES ) {
						if ( thisNodeType == nodetype ) {
							make( targ, node, child, false, false ); 
							made = true;
							break loop2;
						}
						
					}
					
				} // the node is ether text or it's unknown
				if( !made ) make( targ, node, child, false, true );
			}
			
		}
		
		internal function make( targ:*, parent:*, node:*, children:Boolean = false, text:Boolean = false ) : void {
			var style:Object = styleElement( node, targ ); 								// get styles based on this node
			if( text || node.@type == "text" ){ 									// width and height are set in text container
				var txt:TextBox; 
				if( node.@type == "text" ) { 
					txt = new TextBox( targ, "<span class='"+node.@["class"]+"'>"+node.@value+"</span>", css.style, style, "input" ); // id's dont work on flash text fields id='"+node.@id+"'
					txt.type = "input"; 
					txt.name = node.@name;
					
/*					if(node.@clearTextOnFocus){
						txt.addEventListener("focusIn", txtfocusin); 
						txt.addEventListener("focusOut", txtfocusout); 
					}
*/					//input( targ, txt, style, node, parent );
					// txt.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusChangeListener); 
					// txt.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, focusChangeListener);
				}else { 
					txt = new TextBox( targ, node.toXMLString(), css.style, style ); 
					txt.addEventListener( TextEvent.LINK, linkProxy);
				}
			}else{
				var l:String = node.localName();
				var element:Element = new Element( targ, style, target );			
				this[ l ]( targ, element, style, node, parent ); 						// do the special things based on what type of node it is
				if( children ) parse( element, node );	 								// if the node has children give it back to the parser
				else element.update();
			} 	
			if( l != "img" && l != "embed" && l != "object" ) if(style.events["load"]) Proxy.create( target, null, element, "load" );
			
			//node.@element = element;													// put the element back into the xml

		}

		internal function styleElement( node:*, targ:* ) : Object {
			
			// Get element styles
			/*
				first get the styles for the node ( div, img, etc );
				then if node has a class or multiple classes get them and add them to the style, 
				overwrite any style that was made before with the same name
				if the node has an id put give the element this name and ad the styles for this id to styles
				skip style attribute styles for now but they will one day be added to styles
				and then return the object
			*/
			
			var styles:Object = new Object();
			
			var nodeStyle:Object = css.style.getStyle( node.localName() );
			if( nodeStyle != null ){
				for( var nodePropName:String in nodeStyle ) { 
					if( typeof( nodeStyle[nodePropName] ) == "object" ){
						if( styles[nodePropName] == null ){ styles[nodePropName] = new Object(); }
						for( var nodeObjProp:String in nodeStyle[nodePropName] ) { 
							styles[nodePropName][nodeObjProp] = nodeStyle[nodePropName][nodeObjProp]; 
						}
					}else{
						styles[nodePropName] = nodeStyle[nodePropName]; 
					}
				}
			}

			if( node.@["class"] != undefined ) { 
				for each( var classStyleName:String in node.@["class"].split(" ") ){ 
					var classStyleObject:Object = css.style.getStyle( "." + classStyleName );
					if( classStyleObject != null ){
						for( var classPropName:String in classStyleObject ) { 
							if( typeof( classStyleObject[classPropName] ) == "object" ){
								if( styles[classPropName] == null ){ styles[classPropName] = new Object(); }
								for( var classObjPropName:String in classStyleObject[classPropName] ) { 
									styles[classPropName][classObjPropName] = classStyleObject[classPropName][classObjPropName]; 
								}
							}else{
								styles[classPropName] = classStyleObject[classPropName]; 
							}
						}
					}
				}
			}
			
			if( node.@id != undefined ) { 
				if( styles.base == null ){ styles.base = new Object(); }
				styles.base.name = node.@id;
				var idStyleName:Object = css.style.getStyle( "#" + node.@id ); 
				if( idStyleName != null ){
					for( var propName:String in idStyleName ) { 
						if( typeof( idStyleName[propName] ) == "object" ){
							if( styles[propName] == null ){ styles[propName] = new Object(); }
							for( var propObjName:String in idStyleName[propName] ) { 
								styles[propName][propObjName] = idStyleName[propName][propObjName];
							}
						}else{
							styles[propName] = idStyleName[propName];
						} 
					}
				}
			}
			
			// TODO: I'll need to parse the styles in the css class before this would work, but I dont know if the syntax will work
/*			if( node.@style ) { 
				var elementStylesStyles:Array = node.@style.split(" ").join("").split(";");
				for (var style:String in elementStylesStyles) { 
					styles[style.split(":")[0]] = css.style[style.split(":")[1]]; 
				} 
			}
*/			
			
			// inline defined attributes
			var definedAttributes:Object = { width:"w", height:"h" };
			for( var attri:String in definedAttributes ) {
				if(node.@[attri] && node.@[attri] != undefined && node.@[attri] != ""){
					if( styles.base == null ){ styles.base = new Object(); }
					styles.base[definedAttributes[attri]] = node.@[attri];
				} 
			}
						
			// inline elements
			if(node.localName().toLowerCase() == "a"){ // inline elements need a width of nothing to start with because there children determine there size
				var inlineBaseObjs:Object = { x:0, y:0, w:1, h:1, position:"auto" };
				for( var b:String in inlineBaseObjs ) {
					if( styles.base[b] == null ) styles.base[b] = inlineBaseObjs[b];
				}
			}
			
			// needed styles and defaults
			var objs:Object = { base:{ x:0, y:0, w:"100%", h:1, position:"auto" }, shape:{ type:"box" }, border:{ type:"none" }, fill:{ type:"none" }, margin:{ l:0, r:0, t:0, b:0 }, padding:{ l:0, r:0, t:0, b:0 } };
			for( var prop:String in objs ) {
				if( styles[prop] == null ){ 
					/*
					if( targ.name != "root1" ){
						if( targ.BASE_STYLE[prop] == null ) styles[prop] = objs[prop];
						else styles[prop] = targ.BASE_STYLE[prop];
						styles[prop] = objs[prop];
					}else{
						styles[prop] = objs[prop];
					}
					*/
					styles[prop] = objs[prop];
				}
			}
			
			var baseObjs:Object = { x:0, y:0, w:"100%", h:1, position:"auto" };
			for( var p:String in baseObjs ) {
				if( styles.base[p] == null ) styles.base[p] = baseObjs[p];
			}

			// populate events
			if( styles.events == null ) { styles.events = new Object(); } 
			for each(var att:XML in node.@*) {
				var a:String = String(att.name()).toLowerCase();
				if( a.substr(0, 2) == "on" ){
					styles.events[ Attributes[ a ] ] = Attributes.cleanEvent( att.toXMLString(), json );
				}
			}
			
			return styles;	
		}
		
		internal function div( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void {
			
		}
		internal function a( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void {
			anchors[element.name] = { href:node.@href, target:node.@target };
			if( node.@href != "" && node.@href ){
				Sprite( element ).buttonMode = true;
				element.addEventListener( "click", anchorLink );
			} 
		}
		internal function img( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void { 
			if(style.events["load"]) addAssetLoader( element, node.@src ); 
			else simpleLoader( element, node.@src );
		}
		internal function object( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void { 
			if(style.events["load"]) addAssetLoader( element, node.@value );
			else simpleLoader( element, node.@src );
		}
		internal function embed( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void { 
			if(style.events["load"]) addAssetLoader( element, node.@src );
			else simpleLoader( element, node.@src );
		}
		internal function ul( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void {
			
		}
		internal function li( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void { 
			
		}
		internal function form( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void {
			forms[element.name] = { method:node.@method, action:node.@action, targ:node.@target };
			if( node.@onsubmit != "" ) element.addEventListener( "submit", submitForm );  
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, onStageKeyDown);
		}
		internal function input( targ:DisplayObject, element:DisplayObjectContainer, style:Object, node:*, parent:* ) : void { 
			if( node.@type == "hidden" ){ element.visible = false; element["STYLE"].inputField = true; element["STYLE"].value = node.@value; }
			if( node.@type == "submit" ){ Element( element ).buttonMode = true; Element( element ).mouseChildren = false; element.addEventListener( "click", submitForm ); }
		}
		internal function submitForm( ev:Event ) : void {
			
			formTarget = forms[ ev.target.parent.name ].targ;
			formElement = ev.target.parent;
	
		  	var serverRequest:URLRequest = new URLRequest( forms[ ev.target.parent.name ].action );
		  	var variables:URLVariables = new URLVariables();

			for (var i:uint=0; i < ev.target.parent.numChildren; i++) {
		        const child:* = ev.target.parent.getChildAt(i);
				if( child is TextField ) { variables[child.name] = child.text; }
				else if( child["STYLE"].inputField ){ variables[child.name] = child["STYLE"].value; }
		    }
			
		  	serverRequest.data = variables;
			if( formTarget.toLowerCase() == "_self" || formTarget.toLowerCase() == "_blank" || formTarget.toLowerCase() == "_parent" ) 
				navigateToURL( serverRequest, formTarget );
			else {
				newTar = getElementById( formTarget ) as DisplayObjectContainer;
			  	var loader:URLLoader = new URLLoader();
			  	loader.addEventListener( Event.COMPLETE, handleComplete );
			  	loader.load( serverRequest );
			}
			
		}
        
		internal function handleComplete( ev:Event ) : void {
		  	htmlLoader = URLLoader( ev.target );
			onCompleteNewHTML( new Event("submit") );
		}
		
		internal function anchorLink( ev:Event ) : void {
			var tar:String = "_self";
			if(anchors[ev.currentTarget.name].target) tar = anchors[ev.currentTarget.name].target;
			link( anchors[ev.currentTarget.name].href, tar );
		}
		
		// Sequencial Asset Loader
		internal var assetsToLoad:Array = [];
		internal var loadedAssetCount:uint = 0;
		internal function addAssetLoader( _element:DisplayObjectContainer, _assetURL:String ) : void {
			assetsToLoad.push( { element:_element, assetURL:_assetURL} );
		}
		internal function loadNextAsset():void {
			if( loadedAssetCount != assetsToLoad.length ) loadAsset( assetsToLoad[ loadedAssetCount++ ] );
			else updateStage();
		}
		internal function loadAsset( assetObject:Object ) : void {
			assetLoader = new Loader();
			assetLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, assetLoaded );
			assetLoader.load( new URLRequest( assetObject.assetURL ));
			assetObject.element.addChild( assetLoader );
		}
		internal function assetLoaded( ev:Event ) : void {
			//trace("assetLoaded", assetsToLoad[ loadedAssetCount - 1 ].element);
			Proxy.create( target, null, assetsToLoad[ loadedAssetCount - 1 ].element, "load" );
			loadNextAsset();
		}
		internal var loaderElementContext:Object = new Object();
		internal function simpleLoader( element:DisplayObjectContainer, assetURL:String ) : void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, simpleLoaderComplete );
			loader.contentLoaderInfo.addEventListener( Event.INIT, simpleLoaderInit );
			loader.load( new URLRequest( assetURL ));
			var refURLName:String = assetURL.split('\\').join('').split(' ').join('');
			loaderElementContext[ refURLName.substr( refURLName.length-7, refURLName.length) ] = element;
			element.addChild( loader );
		}
		internal function simpleLoaderInit(ev:Event):void {
			var loader:Loader = Loader(ev.target.loader);
			var info:LoaderInfo = LoaderInfo(loader.contentLoaderInfo);
			var refURLName:String = String(info.url).split('\\').join('').split(' ').join('');
			var element:Element = loaderElementContext[refURLName.substr( refURLName.length-7, refURLName.length)];
			if(element.BASE_STYLE.base.h == 0) {
				element.BASE_STYLE.base.w = info.width;
				element.BASE_STYLE.base.h = info.height;
				element.update();
				updateStage();
			}
		}
		internal function simpleLoaderComplete(ev:Event):void {
			var loader:Loader = Loader(ev.target.loader);
			var info:LoaderInfo = LoaderInfo(loader.contentLoaderInfo);
			var refURLName:String = String(info.url).split('\\').join('').split(' ').join('');
			var element:Element = loaderElementContext[refURLName.substr( refURLName.length-7, refURLName.length)];
			if(element.BASE_STYLE.base.h == 0 ) {
				element.BASE_STYLE.base.w = ev.target.width;
				element.BASE_STYLE.base.h = ev.target.height;
				element.update();
				updateStage();
			}
		}
		internal function txtfocusin(ev:Event):void {
			ev.target.text = "";
		}
		internal function txtfocusout(ev:Event):void {
			
		}
		
		//
		// Public Runtime Methods
		//
		public function link( urlStr:String, tar:String = "_self" ) :void {
			tar = tar.toLowerCase();
			if( tar == "" ) tar = "_self";
			if( tar == "_self" || tar == "_blank" ) navigateToURL( new URLRequest( urlStr ), tar );
			else loadPage( getElement(tar), urlStr );
		}
		public function append( t:*, urlStr:String ) :void {
			newTar = t;
			loadHTML( urlStr, onCompleteNewHTML );
		}
		public function loadPage( t:*, urlStr:String ) :void {
			clear( t );
			newTar = t;
			loadHTML( urlStr, onCompleteNewHTML );
		}
		public function clear( t:* ) :void {
			if( t is DisplayObjectContainer ) {
				var i:int = t.numChildren; 
				if( t.numChildren != 0 ) while(i--){ t.removeChildAt(i); }
			}
		}
		
		//
		// Document Utils
		//
		public function updateStage( container:DisplayObjectContainer = null ) : void {
			if( container == null ){ container = target; }
			var child:*;
		    for (var i:uint=0; i < container.numChildren; i++) {
		        child = container.getChildAt(i);
				if( child is Element ) { // if not Bitmap
					child.make();
				}
				if( child is TextBox ) {
					child.make();
				}
		        if( child is DisplayObjectContainer ) {
		            updateStage(DisplayObjectContainer(child));
		        }
		    }
		}
		
		public function getElementById( n:String, c:DisplayObjectContainer = null ) : DisplayObject {
			if( c == null ) { c = target; }
			var returnValue:DisplayObject;
			if( c.name == n ){
				returnValue = target;
			}else{
				if( c.getChildByName( n ) ) { returnValue = c.getChildByName( n ); }
				else{ loop( n, c ); }
			}
			function loop( id:String, container:DisplayObjectContainer ) : * {
				for (var i:uint=0; i < container.numChildren; i++) {
			        const child:* = container.getChildAt(i);
					if( container.getChildAt(i) is DisplayObjectContainer ) {
						if( child.getChildByName( id ) ){ returnValue = child.getChildByName( id ); break; }
						else{ loop( id, DisplayObjectContainer(child) ); }
			        }
					
			    }
			}
			return returnValue;
		}
		
		public function getXMLById( n:String, node:* = null ) : * {
			if( node == null ){ node = org_html; }
			return node.descendants().( "@id" == n );
		}
		
		public function getElement( path:String, thisElement:DisplayObjectContainer = null ) : DisplayObject {
			var pathArray:Array = path.split(".");
			var baseElement:*;
			
			if( pathArray[0] == "root" ) baseElement = target;
			else if( pathArray[0] == "this" ) baseElement = thisElement;
			else if( pathArray[0] == "parent" ) baseElement = thisElement.parent;

			var pathObject:* = baseElement;
			var currentPart:int = 1;
			loop();
			function loop() : void {
				if( currentPart != pathArray.length ){
					if( pathArray[0] == "parent" ) pathObject = pathObject.parent;
					else pathObject = pathObject.getChildByName( pathArray[currentPart++] );
					loop();
				}	
			}
			return pathObject;
		}
		
		public function traceDisplayObject( container:DisplayObjectContainer = null, indentString:String = "" ) : void {
			if( container == null ){ container = target; }
			var child:DisplayObject;
		    for (var i:uint=0; i < container.numChildren; i++) {
		        child = container.getChildAt(i);
		        trace( indentString, child.name, String(child).split("[object ").join("").split("]").join("") );
		        if( container.getChildAt(i) is DisplayObjectContainer ) {
		            traceDisplayObject(DisplayObjectContainer(child), indentString + "    ")
		        }

		    }

		}
		
		public function styleToString( styles:Object = null ) : String {
			if(!styles){ styles = css.style; } 
			var str:String = new String();
			for ( var propName:String in styles ) {
				if(typeof(styles[propName]) == "object"){
					str += propName + " {" + "\n";
					for ( var prop:String in styles[propName] ) {
						str += "  " + prop + ": " + styles[propName][prop] + "; \n";
					}
				}else{ str += propName + " { " + styles[propName] + "; "; }
				str += "}\n";
			}
			return str;
		}
		
	}
	
}