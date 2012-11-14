xquery version "1.0-ml";
import module namespace u = "http://www.github.com/robwhitby/ml-api/util" at "util.xqy";
declare default function namespace "local";
declare namespace s = "http://www.w3.org/2009/xpath-functions/analyze-string";

declare variable $namespace := xdmp:get-request-field("ns", "");
declare variable $q := xdmp:get-request-field("q", "");
declare variable $query-name-only := xdmp:get-request-field("n") = "true";
declare variable $options := ("unstemmed", "case-insensitive", "punctuation-sensitive");


declare function search-query() as cts:query
{
	let $query-string := fn:analyze-string($q, "^([a-z]{2,10}):(.*$)")
	let $prefix := $query-string/s:match/s:group[1]/fn:string()
	let $name := if ($prefix) then $query-string/s:match/s:group[2]/fn:string() else $q
	return
		cts:and-query((	
			if ($prefix)
			then cts:element-attribute-range-query($u:QN-FUNCTION, $u:QN-LIB, "=", $prefix)
			else (),
			cts:or-query((
				cts:element-attribute-range-query($u:QN-FUNCTION, $u:QN-LIB, "=", $name),
				cts:element-attribute-range-query($u:QN-FUNCTION, $u:QN-NAME, "=", 
					cts:element-attribute-value-match($u:QN-FUNCTION, $u:QN-NAME, "*" || $name || "*")
				),
				cts:element-attribute-word-query($u:QN-FUNCTION, $u:QN-NAME, $name, $options),
				if ($query-name-only) then () else cts:word-query($name, $options)		
			))
		))
};

declare function summary($summary as element(apidoc:summary)?)
{
	xdmp:quote(
    if ($q eq "" or $query-name-only) then $summary/node()
    else cts:highlight(<span>{$summary/node()}</span>, cts:tokenize($q), <span class="hi">{$cts:text}</span>)/node()
  )
};


let $query := 
	cts:and-query((
		$u:VERSION-QUERY,
		if ($namespace ne "") then cts:element-attribute-range-query($u:QN-FUNCTION, $u:QN-LIB, "=", $namespace)
		else if ($q ne "") then search-query()
		else ()
	))

return 
	<functions nameOnly="{$query-name-only}">
	{
		for $fn in cts:search(//apidoc:function, $query, "unfiltered")
    let $summary := summary($fn/apidoc:summary)
    let $full-name := $fn/@lib || ":" || $fn/@name
    order by 1[$q = ($full-name, $fn/@name)], $full-name ascending
		return 
			<function>
				<name>{$full-name}</name>
				<summary>{$summary}</summary>
			</function>
	}
	</functions>
	
