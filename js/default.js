Ext.BLANK_IMAGE_URL = '/ext-2.2/resources/images/default/s.gif';

Ext.onReady(function() {
	var config = { 
		minQueryLength: 0,
		queryDelay: 500,
		apiVersion: (document.location.search.length > 1)? document.location.search.substring(1) : MLAPI.versions[0]
	};
	
	var search = new Ext.form.FormPanel({
		id : 'search',
		region : 'north',
		height : 90,
		buttonAlign : 'left',
		items: [
			{
				xtype:'trigger',
				id: 'txtSearch',
				anchor : '100%',
				hideLabel : true,
				emptyText : 'enter search term',
				value : document.location.hash.length > 1? document.location.hash.substring(1) : '',
				enableKeyEvents : true,
				currentValue : '',
				listeners : {
					'keyup' : function() { 
						if (Ext.getCmp('autoSearch').checked) {
							var newValue = this.getValue();
							if (this.currentValue != newValue) {
								this.currentValue = newValue;
								search.update(newValue); 
							}
						}
					}
				},
				triggerClass : 'x-form-search-trigger',
				onTriggerClick : function() { search.update(Ext.getCmp('txtSearch').getValue(), true); }
			},
			{
				xtype : 'checkbox',
				id : 'autoSearch',
				checked : true,
				hideLabel : true,
				boxLabel : 'Search as you type',
				listeners : { 'check' : function() { this.blur(); } }
			},
			{
				xtype : 'checkbox',
				id : 'namesOnly',
				hideLabel : true,
				checked : true,
				boxLabel : 'Search function names only',
				listeners : { 'check' : function() { search.update(Ext.getCmp('txtSearch').getValue()); this.blur(); } }
			}
		],
		delayedUpdate : new Ext.util.DelayedTask(),
		update : function(query, ignoreLength) {
			if (ignoreLength || query.length >= config.minQueryLength) {
				search.delayedUpdate.delay(config.queryDelay, 
					function(value) {
						content.store.load({params: {q : value, n : Ext.getCmp('namesOnly').checked}});
						nav.getSelectionModel().clearSelections();
						if (_gaq) _gaq.push(["_trackEvent", "search", query]);
					},
					this, 
					[query]);
			}
		}
	}); 

	var nav = new Ext.tree.TreePanel({
		id : 'nav',
		animate : true,
		containerScroll : true,
		root: new Ext.tree.AsyncTreeNode({
			text : 'All Namespaces',
			expanded : true,
			cls : 'root-node'
		}),
		region : 'center',
		autoScroll : true,
		lines : false,
		loader : new Ext.tree.TreeLoader( {
			dataUrl : '/xqy/navigation.xqy',
			baseParams : { version: config.apiVersion },
			baseAttrs : { leaf : true },
			preloadChildren : true
		})
	});

	nav.getSelectionModel().on({
		'beforeselect' : function(sm, newNode, oldNode){
			return newNode.isRoot || newNode.leaf;
		},
		'selectionchange' : function(sm, node){
			if (node) {
			    content.store.load({params: {ns : node.attributes.ns}});
			     if (_gaq) _gaq.push(["_trackEvent", "browse", node.attributes.ns]);
			}
		}
	});
	
	
	
	var content = new Ext.DataView({
		id : 'content',
		tpl : new Ext.XTemplate.from('contentTpl'),
		itemSelector : 'div.function',
		loadingText : 'Loading...',
		emptyText : '<p id="emptyText">No matching functions</p>',
		store : new Ext.data.Store({
			proxy: new Ext.data.HttpProxy(
				new Ext.data.Connection({
					url: '/xqy/functions.xqy',
					extraParams : { version: config.apiVersion },
					disableCaching : false,
					method : 'POST'
				})
			), 
			reader: new Ext.data.XmlReader(
				{record : 'function'}, 
				[
					{ name : 'name' },
					{ name : 'summary' }
				]
			)
		})
	});
	
	content.store.on('load', captureLinks)
	
	
	content.toggleItem = function(obj){
		var n = Ext.get(obj).parent('div.function', true);	
		var record = content.getRecord(n);
		var divs = Ext.select('div', true, n).elements;
				
		if (divs[1].isDisplayed()) {
			divs[0].setDisplayed('block');
			divs[1].setDisplayed('none');
		}
		else {
			divs[1].setDisplayed('block');
			if (divs[1].hasClass('loaded')) {
				divs[0].setDisplayed('none');
			}
			else {
				Ext.Ajax.request({
					url: '/xqy/function-detail.xqy?',
					params : {
						nsname : record.data.name,
						version : config.apiVersion,
						q : Ext.getCmp('txtSearch').getValue(),
						n : Ext.getCmp('namesOnly').checked
					},
					disableCaching: false,
					success: function(r){
						divs[1].update(r.responseText);
						divs[0].setDisplayed('none');
						divs[1].addClass('loaded');
						
						captureLinks();
						if (_gaq) _gaq.push(["_trackEvent", "detail", record.data.name]);
					},
					failure: function(r){
						divs[1].update('<p class="error">Sorry, function detail unavailable.</p>');
					}
				});
			}
		}
	};
	

	var center = new Ext.Panel({
		id : 'center',
		region : 'center',
		header : false,
		split : true,
		useSplitTips : true,
		margins : '10, 10, 10, 0',
		autoScroll : true,
		items : content
	});
	
	var west = new Ext.Panel({
		id : 'west',
		width : 200,
		split : true,
		useSplitTips: true,
		header : false,
		margins : '10 5 10 10',
		layout : 'border',
		region : 'west',
		items : [search, nav]
	});
	
	var north = new Ext.BoxComponent({
		region: 'north',
		header : false,
		margins:'0 0 0 0',
		border: false,
		el : 'header'
	});
	
	var viewport = new Ext.Viewport({
		id : 'viewport',
		layout : 'border',
		items : [north, west, center]
	});

	search.update(Ext.getCmp('txtSearch').getValue(), true);
	
	//update version specific things
	Ext.get('pageTitle').dom.innerHTML += config.apiVersion;
	document.title += ' ' + config.apiVersion;
	
	if (MLAPI.versions.length > 1) {
		var html = "";
		for (var i=0; i<MLAPI.versions.length; i++) {
			if (MLAPI.versions[i] != config.apiVersion) {
				html += '<a href="/?' + MLAPI.versions[i] + '">' + MLAPI.versions[i] + '</a>';
			}
		}		
		Ext.get('api-versions').update(html);
	}
	

	var docsLink = Ext.get('docsLink').dom;
	docsLink.href = docsLink.href.replace('VERSION', config.apiVersion);
	
	Ext.get('loading').remove();
	Ext.get('loading-mask').fadeOut({remove:true});
	
	function captureLinks() {
		var links = Ext.select(Ext.query('a[@class=""]', 'content'));
		links.each(function(el) {
			el.on('click', function() { 
				Ext.get('txtSearch').dom.value = Ext.isIE? el.dom.innerText : el.dom.textContent;
				search.update(Ext.getCmp('txtSearch').getValue(), true);
			});
		});
	}
	
});