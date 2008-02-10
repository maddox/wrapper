/**
 * Wrapper v.0.1 The Flash XHTML render - http://0in1.com/fxhtml
 *
 * This file is a combination of SWFObject, SWFAddress and the Wrapper base JS code.  
 * This is just for simpicity the set upt a little so you dont need to include 4 JS files.
 *
 * SWFObject v1.5: Flash Player detection and embed - http://blog.deconcept.com/swfobject/
 * SWFObject is (c) 2006 Geoff Stearns and is released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * SWFAddress v1.1: Deep linking for Flash - http://www.asual.com/swfaddress/
 * SWFAddress is (c) 2006 Rostislav Hristov and is released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */

var baseUrl = "";
function wrapper( base ) {
	if( base ) baseUrl = base;
	var so = new SWFObject( baseUrl + "main.swf", "wrapper", "100%", "100%", "9", "#FFFFFF");
	so.useExpressInstall( baseUrl + "expressinstall.swf");
	so.addParam("allowScriptAccess", "always");
	so.addVariable("content_url", document.location.href);
	so.write("wrapper");
	document.onresize = windowResize();
}

function windowResize() {
	var frameHeight
	if (self.innerHeight){
		frameHeight = self.innerHeight;
	}else if (document.documentElement && document.documentElement.clientHeight) {
		frameHeight = document.documentElement.clientHeight;
	}else if (document.body){
		frameHeight = document.body.clientHeight;
	}else return;
	if(document.all && !document.getElementById) {
		if( frameHeight > document.all['wrapper'].style.pixelHeight.split("px").join("") ){
			document.all['wrapper'].style.pixelHeight = frameHeight + "px";
		}
	}else{
		if( frameHeight > document.getElementById('wrapper').style.height.split("px").join("") ) {
			document.getElementById('wrapper').style.height = frameHeight + "px";
		}
	}
}

function resize( height ) {
	if(document.all && !document.getElementById) {
		document.all['wrapper'].style.pixelHeight = height + "px";
	}else{
		document.getElementById('wrapper').style.height = height + "px";
	}
}

if(typeof deconcept=="undefined"){var deconcept=new Object();}if(typeof deconcept.util=="undefined"){deconcept.util=new Object();}if(typeof deconcept.SWFObjectUtil=="undefined"){deconcept.SWFObjectUtil=new Object();}deconcept.SWFObject=function(_1,id,w,h,_5,c,_7,_8,_9,_a){if(!document.getElementById){return;}this.DETECT_KEY=_a?_a:"detectflash";this.skipDetect=deconcept.util.getRequestParameter(this.DETECT_KEY);this.params=new Object();this.variables=new Object();this.attributes=new Array();if(_1){this.setAttribute("swf",_1);}if(id){this.setAttribute("id",id);}if(w){this.setAttribute("width",w);}if(h){this.setAttribute("height",h);}if(_5){this.setAttribute("version",new deconcept.PlayerVersion(_5.toString().split(".")));}this.installedVer=deconcept.SWFObjectUtil.getPlayerVersion();if(!window.opera&&document.all&&this.installedVer.major>7){deconcept.SWFObject.doPrepUnload=true;}if(c){this.addParam("bgcolor",c);}var q=_7?_7:"high";this.addParam("quality",q);this.setAttribute("useExpressInstall",false);this.setAttribute("doExpressInstall",false);var _c=(_8)?_8:window.location;this.setAttribute("xiRedirectUrl",_c);this.setAttribute("redirectUrl","");if(_9){this.setAttribute("redirectUrl",_9);}};deconcept.SWFObject.prototype={useExpressInstall:function(_d){this.xiSWFPath=!_d?"expressinstall.swf":_d;this.setAttribute("useExpressInstall",true);},setAttribute:function(_e,_f){this.attributes[_e]=_f;},getAttribute:function(_10){return this.attributes[_10];},addParam:function(_11,_12){this.params[_11]=_12;},getParams:function(){return this.params;},addVariable:function(_13,_14){this.variables[_13]=_14;},getVariable:function(_15){return this.variables[_15];},getVariables:function(){return this.variables;},getVariablePairs:function(){var _16=new Array();var key;var _18=this.getVariables();for(key in _18){_16.push(key+"="+_18[key]);}return _16;},getSWFHTML:function(){var _19="";if(navigator.plugins&&navigator.mimeTypes&&navigator.mimeTypes.length){if(this.getAttribute("doExpressInstall")){this.addVariable("MMplayerType","PlugIn");this.setAttribute("swf",this.xiSWFPath);}_19="<embed type=\"application/x-shockwave-flash\" src=\""+this.getAttribute("swf")+"\" width=\""+this.getAttribute("width")+"\" height=\""+this.getAttribute("height")+"\"";_19+=" id=\""+this.getAttribute("id")+"\" name=\""+this.getAttribute("id")+"\" ";var _1a=this.getParams();for(var key in _1a){_19+=[key]+"=\""+_1a[key]+"\" ";}var _1c=this.getVariablePairs().join("&");if(_1c.length>0){_19+="flashvars=\""+_1c+"\"";}_19+="/>";}else{if(this.getAttribute("doExpressInstall")){this.addVariable("MMplayerType","ActiveX");this.setAttribute("swf",this.xiSWFPath);}_19="<object id=\""+this.getAttribute("id")+"\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\""+this.getAttribute("width")+"\" height=\""+this.getAttribute("height")+"\">";_19+="<param name=\"movie\" value=\""+this.getAttribute("swf")+"\" />";var _1d=this.getParams();for(var key in _1d){_19+="<param name=\""+key+"\" value=\""+_1d[key]+"\" />";}var _1f=this.getVariablePairs().join("&");if(_1f.length>0){_19+="<param name=\"flashvars\" value=\""+_1f+"\" />";}_19+="</object>";}return _19;},write:function(_20){if(this.getAttribute("useExpressInstall")){var _21=new deconcept.PlayerVersion([6,0,65]);if(this.installedVer.versionIsValid(_21)&&!this.installedVer.versionIsValid(this.getAttribute("version"))){this.setAttribute("doExpressInstall",true);this.addVariable("MMredirectURL",escape(this.getAttribute("xiRedirectUrl")));document.title=document.title.slice(0,47)+" - Flash Player Installation";this.addVariable("MMdoctitle",document.title);}}if(this.skipDetect||this.getAttribute("doExpressInstall")||this.installedVer.versionIsValid(this.getAttribute("version"))){var n=(typeof _20=="string")?document.getElementById(_20):_20;n.innerHTML=this.getSWFHTML();return true;}else{if(this.getAttribute("redirectUrl")!=""){document.location.replace(this.getAttribute("redirectUrl"));}}return false;}};deconcept.SWFObjectUtil.getPlayerVersion=function(){var _23=new deconcept.PlayerVersion([0,0,0]);if(navigator.plugins&&navigator.mimeTypes.length){var x=navigator.plugins["Shockwave Flash"];if(x&&x.description){_23=new deconcept.PlayerVersion(x.description.replace(/([a-zA-Z]|\s)+/,"").replace(/(\s+r|\s+b[0-9]+)/,".").split("."));}}else{try{var axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");}catch(e){try{var axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");_23=new deconcept.PlayerVersion([6,0,21]);axo.AllowScriptAccess="always";}catch(e){if(_23.major==6){return _23;}}try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash");}catch(e){}}if(axo!=null){_23=new deconcept.PlayerVersion(axo.GetVariable("$version").split(" ")[1].split(","));}}return _23;};deconcept.PlayerVersion=function(_27){this.major=_27[0]!=null?parseInt(_27[0]):0;this.minor=_27[1]!=null?parseInt(_27[1]):0;this.rev=_27[2]!=null?parseInt(_27[2]):0;};deconcept.PlayerVersion.prototype.versionIsValid=function(fv){if(this.major<fv.major){return false;}if(this.major>fv.major){return true;}if(this.minor<fv.minor){return false;}if(this.minor>fv.minor){return true;}if(this.rev<fv.rev){return false;}return true;};deconcept.util={getRequestParameter:function(_29){var q=document.location.search||document.location.hash;if(q){var _2b=q.substring(1).split("&");for(var i=0;i<_2b.length;i++){if(_2b[i].substring(0,_2b[i].indexOf("="))==_29){return _2b[i].substring((_2b[i].indexOf("=")+1));}}}return "";}};deconcept.SWFObjectUtil.cleanupSWFs=function(){var _2d=document.getElementsByTagName("OBJECT");for(var i=_2d.length;i>0;i--){_2d[i].style.display="none";for(var x in _2d[i]){if(typeof _2d[i][x]=="function"){_2d[i][x]=function(){};}}}};if(deconcept.SWFObject.doPrepUnload){deconcept.SWFObjectUtil.prepUnload=function(){__flash_unloadHandler=function(){};__flash_savedUnloadHandler=function(){};window.attachEvent("onunload",deconcept.SWFObjectUtil.cleanupSWFs);};window.attachEvent("onbeforeunload",deconcept.SWFObjectUtil.prepUnload);}if(Array.prototype.push==null){Array.prototype.push=function(_30){this[this.length]=_30;return this.length;};}var getQueryParamValue=deconcept.util.getRequestParameter;var FlashObject=deconcept.SWFObject;var SWFObject=deconcept.SWFObject;

if(typeof asual == "undefined") var asual = new Object();
if(typeof asual.util == "undefined") asual.util = new Object();
asual.util.Browser = new function() {
    var agent = navigator.userAgent;
    this.supported = false;
    this.ie = false;
    this.gecko = false;
    this.safari = false;
    this.opera = false;
    this.version = -1;
    if (/MSIE/.test(agent)) {
        this.ie = true;
        this.version = parseFloat(agent.substring(agent.indexOf('MSIE') + 4));
        this.supported = this.version >= 6;
    } else if (/AppleWebKit/.test(agent)) {
        this.safari = true;
        this.version = parseFloat(agent.substring(agent.indexOf('Safari') + 7));
        this.supported = this.version >= 312;
    } else if (/Opera/.test(agent)) {
        this.opera = true;
        this.version = parseFloat(navigator.appVersion);
        this.supported = this.version >= 9.02;
    } else if (/Firefox/.test(agent)) {
        this.gecko = true;
        this.version = parseFloat(agent.substring(agent.indexOf('Firefox') + 8));
        this.supported = this.version >= 1;
    } else if (/Camino/.test(agent)) {
        this.gecko = true;
        this.version = parseFloat(agent.substring(agent.indexOf('Camino') + 7));
        this.supported = this.version >= 1;
    } else if (/Netscape/.test(agent)) {
        this.gecko = true;
        this.version = parseFloat(agent.substring(agent.indexOf('Netscape') + 9));
        this.supported = this.version >= 8;
    } else if (/Mozilla/.test(agent) && /rv:/.test(agent)) { //
        this.gecko = true;
        this.version = parseFloat(agent.substring(agent.indexOf('rv:') + 3));
        this.supported = this.version >= 1.8;
    }
    if (!this.supported && top.location.href.indexOf('#') != -1) {
        document.open();
        document.write('<html><head><meta http-equiv="refresh" content="0;url=' + top.location.href.substr(0, top.location.href.indexOf('#')) + '" /></head></html>');
        document.close();
    }
}
asual.util.Functions = new function() {
    this.extend = function(superclass, subclass) {
        function inheritance() {}
        inheritance.prototype = superclass.prototype;
        subclass.prototype = new inheritance();
        subclass.prototype.constructor = subclass;
        subclass.superConstructor = superclass;
        subclass.superClass = superclass.prototype;
        return subclass;
    }
    this.bindAsListener = function(method, object, win) {
        return function(evt) {
            return method.call(object, evt || ((win) ? win.event : window.event));
        }
    }    
}
asual.util.Events = new function() {
    var cache = new Array();
    this.addListener = function (obj, type, listener) {
        if (obj.addEventListener){
            obj.addEventListener(type, listener, false);
        } else if (obj.attachEvent){
            obj.attachEvent('on' + type, listener);
        } else {
            obj['on' + type] = listener;        
        }
        cache.push({o: obj, t: type, l: listener});
    }
    this.removeListener = function (obj, type, listener) {  
        if (obj.removeEventListener){
            obj.removeEventListener(type, listener, false);
        } else if (obj.detachEvent){
            obj.detachEvent('on' + type, listener);
        } else {
            obj['on' + type] = listener;
        }
    }
    var unload = function() {
        for (var i = 0, evt; evt = cache[i]; i++) {
            asual.util.Events.removeListener(evt.o, evt.t, evt.l);
        }
    }
    if (asual.util.Browser.ie || asual.util.Browser.safari) {    
        this.addListener(window, 'unload', asual.util.Functions.bindAsListener(unload, this));    
    }
}
asual.SWFAddress = new function() {
    var browser = asual.util.Browser;
    var supported = browser.supported;
    var iframe, form;
    var swfaddr, swfid, swfupdate = false;
    var swftitle = document.title;
    var swflength = history.length;
    var swfhistory = new Array();
    var js = baseUrl + 'swfaddress.js';
    var html = baseUrl + 'swfaddress.html';
    var getHash = function() {
        var index = top.location.href.indexOf('#');
        if (index != -1) {
            return top.location.href.substring(index);
        }
        return '';
    }
    var hash = getHash();
    var listen = function() {
        if (browser.safari) {
            if (swflength != history.length && !swfupdate) {
                swflength = history.length;
                if (typeof swfhistory[swflength - 1] != 'undefined') {
                    hash = swfhistory[swflength - 1];
                }
                update();
            }        
        } else if (browser.ie) {
            if (hash != getHash()) {
                if (browser.version < 7) {
                    top.location.reload();
                } else {
                    asual.SWFAddress.setValue(getHash().replace(/#/g, ''));
                }
            }
            if (top.document.title != swftitle) {
                asual.SWFAddress.setTitle(swftitle);
            }
        } else {
            if (hash != top.location.hash) {
                hash = top.location.hash;
                update();
            }
        }
    }
    var update = function() {
        var addr = hash.replace(/#/g, '');
        if (addr != swfaddr) {
            swfaddr = addr;
            var obj = document[swfid] || document.getElementById(swfid);        
            if (obj) {
                obj.setSWFAddressValue(addr);
            }
        }
    }
    var loadSuccess = function() {
        if (iframe.contentWindow && iframe.contentWindow.location) {
            var win = iframe.contentWindow;
            win.document.title = top.document.title = swftitle;
            var src = win.location.href;
            if (src.indexOf('?') > -1) {
                hash = '#' + src.substring(src.indexOf('?') + 1);
            } else {
                hash = '#';
            }
            if (hash != getHash()) {
                update();            
                top.location.hash = hash;
            }
        }
    }
    var load = function() {
        if (browser.ie || browser.safari) {
            var content = document.createElement('div');
            content.id = 'swfaddress';
            var scripts = document.getElementsByTagName('script');
            for (var i = 0, s; s = scripts[i]; i++) {
                if (s.src.indexOf(js) > -1) {
                    html = (new String(s.src)).replace(js, html);
                }
            }
            content.innerHTML = '<iframe id="swfaddress-iframe" src="' + html + getHash().replace(/#/g, '?') + '" frameborder="no" scrolling="no"></iframe>';
            document.body.appendChild(content);
            content.style.position = 'absolute';
            content.style.left = content.style.top = '-9999px';
            iframe = content.getElementsByTagName('iframe')[0];
        }
        if (browser.ie) {
            asual.util.Events.addListener(iframe, 'load', asual.util.Functions.bindAsListener(loadSuccess, this));  
        }
        if (browser.safari) {
            form = document.createElement('form');
            form.id = 'swfaddress-form';        
            form.method = 'get';
            content.appendChild(form);
            if (typeof top.document.location.swfaddress == 'undefined') {
                top.document.location.swfaddress = new Object();
            }
            if (typeof top.document.location.swfaddress.history != 'undefined') {
                swfhistory = top.document.location.swfaddress.history.split(',');
            }
        }
        track.call(this);
        update.call(this);
        setInterval(listen, 50);
    }
    var track = function() {
        if (typeof urchinTracker != 'undefined'){
            var path = top.location.pathname + this.getValue();
            path = path.replace(/\/\//, '/');
            path = path.replace(/^\/$/, '');            
            urchinTracker(path);
        }
    }    
    this.getId = function() {
        if (!supported) return null;
        return swfid;
    }
    this.setId = function(id) {
        if (!supported) return null;    
        swfid = id;
    }
    this.getTitle = function() {
        if (!supported) return null;    
        return top.document.title;
    }
    this.setTitle = function(title) {
        if (!supported) return null;
        if (title == 'null') {
            title = '';
        }        
        if (typeof title != 'undefined') {
            swftitle = title;
            top.document.title = swftitle;
        }
    }
    this.getStatus = function() {
        if (!supported) return null;    
        return top.status;
    }
    this.setStatus = function(status) {
        if (!supported) return null;
        if (!browser.safari) {
            if (status == 'null' || typeof status == 'undefined') {
                status = '';
            }        
            var index = top.location.href.indexOf('#');
            if (index == -1) {
                status = top.location.href + '#' + status;
            } else {
                status = top.location.href.substr(0, index) + '#' + status;
            }
            top.status = status;
        }
    }
    this.resetStatus = function() {
        top.status = '';
    }
    this.getValue = function() {
        if (!supported) return null;
        var addr = hash.replace(/#/gi, '');
        return addr;
    }
	this.getLocation = function() {
        return top.location.href;
    }
    this.setValue = function(addr) {
        if (!supported) return null;
        if (addr == 'null') {
            addr = '';
        }
        if (swfaddr == addr) {
            return;
        }
        var checkaddr;
        var obj = document[swfid] || document.getElementById(swfid);
        if (obj) {
            checkaddr = obj.getSWFAddressValue();
            if (checkaddr == 'null') {
                checkaddr = '';
            }
        }
        hash = '#' + addr;
        if (checkaddr == addr) {
            swfaddr = addr;
            update();
        } else {
            update();
            swfaddr = addr;
        }
        if (browser.safari) {
            form.action = hash;
            swfhistory[history.length] = hash;
            top.document.location.swfaddress.history = swfhistory.toString();
            swfupdate = true;
            swflength = history.length + 1;            
            form.submit();
            swfupdate = false;
        } else if (checkaddr == addr) {
            top.location.hash = hash;
        }
        if (browser.ie) {
            var win = iframe.contentWindow;
            var query = '?' + getHash().substring(hash.indexOf('#') + 1);
            win.location.assign(win.location.pathname + query);
        }
        track.call(this);
    }    
    if (!supported) {
        return;
    }
    if (browser.safari) {
        for (var i = 1; i < swflength; i++) {
            swfhistory.push('');
        }
        swfhistory.push(top.location.hash);
    }
    if (browser.ie) {
        if (hash == '') {
            top.location.hash = '#';
        } else {
            top.location.hash = getHash();
        }           
    }
    asual.util.Events.addListener(window, 'load', asual.util.Functions.bindAsListener(load, this));    
    swfaddr = this.getValue();
}
if (typeof deconcept != 'undefined' && deconcept.SWFObject) {
    asual.SWFAddressObject = asual.util.Functions.extend(deconcept.SWFObject, 
        function(swf, id, w, h, ver, c, quality, xiRedirectUrl, redirectUrl, detectKey) {
        asual.SWFAddressObject.superConstructor.apply(this, arguments);
        asual.SWFAddress.setId(id);
    });    
    SWFObject = deconcept.SWFObject = asual.SWFAddressObject;    
}
SWFAddress = asual.SWFAddress;