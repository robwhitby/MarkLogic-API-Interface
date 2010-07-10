xquery version '1.0-ml';

declare function local:formatTitle($s as xs:string) as xs:string
{
		let $words := 
			for $word in fn:tokenize($s, "_")
			return fn:concat(fn:upper-case(fn:substring($word, 1, 1)), fn:substring($word, 2))
		
		return fn:string-join($words, " ")
};

declare function local:renderHtml($node)
{
	let $title := local:formatTitle(fn:local-name($node))
	where fn:data($node) != ''
	return
		<div class="section x-tab" title="{$title}">
			<h2>{$title}</h2>
			{$node}
		</div>
};

let $nsname := xdmp:get-request-field('nsname')	
let $version := (xdmp:get-request-field('version'), '4.1')[1]
let $f := xdmp:directory(fn:concat('/', $version, '/'), '1')/apidoc:module/apidoc:function[@fullname=$nsname]
let $q := xdmp:get-request-field('q')
let $nameOnly := xs:boolean(xdmp:get-request-field('n') = 'true')

return 
	<div class="function-detail">
		<h1><a class="icon-collapse" href="#{data($f/@fullname)}" onclick="Ext.getCmp('content').toggleItem(this); return false;">{data($f/@fullname)}(</a></h1>
		<ul>
			{
				for $param in $f/apidoc:params/apidoc:param
				let $optional := xs:boolean($param/@optional)
				return
					<li>
						{ if ($optional) then '[' else () }
						<strong>{data($param/@name)}</strong> as {data($param/@type)}
						{ if ($optional) then ']' else () }
					</li>
			}
		</ul>
		<h1 class="returns">) <span>as {$f/apidoc:return}</span></h1>
		
		{
			let $summary := <p class="summary">{$f/apidoc:summary/node()}</p>
			return
				if ($nameOnly) then $summary
				else cts:highlight($summary, cts:word-query(cts:tokenize($q)), <span class="hi">{$cts:text}</span>)
		}
		
		<div class="tab-container">
			<div class="section" title="Parameters">
				<h2>Parameters</h2>
				<table>
					{
					for $param in $f/apidoc:params/apidoc:param
					return
						<tr>
							<td style="width:220px"><strong>{data($param/@name)}</strong> as {data($param/@type)}</td>
							<td>{$param/node()}</td>
						</tr>
					}
				</table>
			</div>
			{local:renderHtml($f/apidoc:usage)}
			{
			for $node in $f/node()
			return
				typeswitch($node)
					case $node as element(apidoc:summary) return ()
					case $node as element(apidoc:return) return ()
					case $node as element(apidoc:params) return ()
					case $node as element(apidoc:usage) return ()
					default return local:renderHtml($node)
			}
		</div>
	</div>
	
	
	

	
