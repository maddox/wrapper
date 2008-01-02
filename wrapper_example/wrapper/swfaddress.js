/**
 * SWFAddress v1.1: Deep linking for Flash - http://www.asual.com/swfaddress/
 *
 * SWFAddress is (c) 2006 Rostislav Hristov and is released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */

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
    var js = 'swfaddress.js';
    var html = 'swfaddress.html';
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