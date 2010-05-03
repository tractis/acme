// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function toggleLink(link) {
  link = $(link);

  var inactiveText = link['neg:inactiveText'] || link.getAttribute('neg:inactiveText');
  
  if(!inactiveText) {
    link['neg:inactiveText'] = link.innerHTML;
    inactiveText = link.innerHTML;
  }

  var activeText = link.getAttribute('neg:activeText');

  if(link['neg:active']) {
    link.innerHTML = inactiveText;
    link['neg:active'] = false;
  } else {
    link.innerHTML = activeText;
    link['neg:active'] = true;
  }
}

function showElement(element, options) {
	try{
	  if($(element) && !Element.visible(element)) {
	    options = options || {};
	    new Effect.BlindDown(element, {duration: 0.3,
	      afterFinish: function() {
	        //Element.undoClipping(element)
	        $(element).style.width = "auto";
	        $(element).style.height = "auto";
	        if(options.afterFinish) options.afterFinish();
	      }});
		}
	}catch(e){ }
}

function hideElement(element, options) {
	try{
	  if($(element) && Element.visible(element)) {
	    options = options || {};
	    new Effect.BlindUp(element, {duration: 0.3,
	      afterFinish: function() {
	        //Element.undoClipping(element)
	        Element.hide(element);
	        if(options.afterFinish) options.afterFinish();
	      }});
	  }
	}catch(e){}
}

var Alerts = Class.create();

Alerts = {
  show_alert: function(alert_type, title, msgs) {
    Alerts.container = $('alerts');
    Event.observe(Alerts.container, 'click', Alerts.hide);
    Alerts.remove();
  	if (Alerts.timer) {
			clearTimeout(Alerts.timer);
		}
    Alerts.container.show();
    alert_box = $(document.createElement('div'));
    Element.addClassName(alert_box, 'action-alerts');
    Element.addClassName(alert_box, 'alert'+alert_type);
    h4 = $(document.createElement('h4'));
    h4.update(title);
    alert_box.appendChild(h4);
    $A(msgs).each(function(msg){
      p = $(document.createElement('p'));
      p.update(msg);
      alert_box.appendChild(p);
    });
    Alerts.container.appendChild(alert_box);
    Alerts.timer = setTimeout(Alerts.hide,15000);
  },
  
  initial: function(func) {
    shown = $('alerts-shown');
    if ($F(shown) == 'true') {
      return;
    }
    shown.value = 'true';
    func();
  },
  
  warning: function(title, msgs) {
    this.show_alert('warning', title, msgs);
  },
  
  notice: function(title, msgs) {
    this.show_alert('notice', title, msgs);
  },
  
  error: function(title, msgs) {
    this.show_alert('error', title, msgs);
  },

  mailed: function(title, msgs) {
    this.show_alert('mailed', title, msgs);
  },
  
  show_spinner: function(text){
    if(Alerts.spinner == null) {
      Alerts.initialize_spinner();
    }
    if(text) {
      Element.addClassName(Alerts.spinner, 'spinner-with-message');
      Alerts.spinner.update(text);
    } else {
      Element.addClassName(Alerts.spinner, 'spinner-without-message');
    }
    center = Alerts.spinner.getWidth() / 2;
    Alerts.spinner.setStyle({
      marginLeft: '-'+center+'px'
    });
    Alerts.spinner.show();
  },
  
  hide_spinner: function(){
    Alerts.spinner.hide();
    Element.removeClassName(Alerts.spinner, 'spinner-with-message');
    Element.removeClassName(Alerts.spinner, 'spinner-without-message');
    Alerts.spinner.update('');
  },
  
  initialize_spinner: function(){
    bod = document.getElementsByTagName('body')[0];
  	sp = document.createElement('div');
  	sp.id	= 'spinner';
  	sp.style.display="none";
  	bod.appendChild(sp);
  	Alerts.spinner = $('spinner');
  },
  
  hide: function(){
    hideElement(Alerts.container, {afterFinish: function() {
      Alerts.remove();
    }});
  },
  
  remove: function(){
    elements = $$('#alerts div');
    if(elements) {
      elements.invoke('remove');
    }
  }
};

Ajax.Responders.register({
	onCreate: function() {
	  Alerts.show_spinner();
  	Ajax.activeRequestCount++;
	},

	onComplete: function() {
		Ajax.activeRequestCount--;
		if (Ajax.activeRequestCount == 0) {
			Alerts.hide_spinner();
		}
		if (navigator.appVersion.match(/\bMSIE\b/)) {
			pngfix();
		}
	}
});
