xquery version "1.0-ml";

declare default function namespace "local";
import module namespace u = "http://www.github.com/robwhitby/ml-api/util" at "util.xqy";

declare variable $nsname := xdmp:get-request-field("nsname");
declare variable $q := xdmp:get-request-field("q");
declare variable $nameOnly := xs:boolean(xdmp:get-request-field("n") = "true");

declare variable $ns := fn:substring-before($nsname, ":");
declare variable $name := fn:substring-after($nsname, ":");

declare function format-title($s as xs:string) as xs:string
{
	fn:string-join(
		for $word in fn:tokenize($s, "_")
		return fn:concat(fn:upper-case(fn:substring($word, 1, 1)), fn:substring($word, 2))
	)
};

declare function render-html($node as node()) as element(div)
{
	let $title := format-title(fn:local-name($node))
	where fn:data($node) != ''
	return
		<div class="section x-tab" title="{$title}">
			<h2>{$title}</h2>
			{$node}
		</div>
};


let $fn := cts:search(//apidoc:function, cts:and-query((
		$u:VERSION-QUERY,
		cts:element-attribute-range-query($u:QN-FUNCTION, $u:QN-LIB, "=", $ns),
		cts:element-attribute-range-query($u:QN-FUNCTION, $u:QN-NAME, "=", $name)
	)), "unfiltered")[1]
let $full-name := $fn/@lib || ":" || $fn/@name
return 
	<div class="function-detail">
		<h1><a class="icon-collapse" href="#{$full-name}" onclick="Ext.getCmp('content').toggleItem(this); return false;">{$full-name}(</a></h1>
		<ul>
			{
				for $param in $fn/apidoc:params/apidoc:param
				let $optional := xs:boolean($param/@optional)
				return
					<li>
						{ if ($optional) then '[' else () }
						<strong>{$param/@name/fn:string()}</strong> as {$param/@type/fn:string()}
						{ if ($optional) then ']' else () }
					</li>
			}
		</ul>
		<h1 class="returns">) <span>as {$fn/apidoc:return}</span></h1>
		
		{
			let $summary := <p class="summary">{$fn/apidoc:summary/node()}</p>
			return
				if ($nameOnly) then $summary
				else cts:highlight($summary, cts:word-query($q), <span class="hi">{$cts:text}</span>)
		}
		
		<div class="tab-container">
			<div class="section" title="Parameters">
				<h2>Parameters</h2>
				<table>
					{
					for $param in $fn/apidoc:params/apidoc:param
					return
						<tr>
							<td style="width:220px"><strong>{$param/@name/fn:string()}</strong> as {$param/@type/fn:string()}</td>
							<td>{$param/node()}</td>
						</tr>
					}
				</table>
			</div>
			{
				render-html($fn/apidoc:usage),
				for $node in $fn/node()
				return
					typeswitch($node)
					case $node as element(apidoc:summary) return ()
					case $node as element(apidoc:return) return ()
					case $node as element(apidoc:params) return ()
					case $node as element(apidoc:usage) return ()
					default return render-html($node)
			}
		</div>
	</div>
	
	
	

	
