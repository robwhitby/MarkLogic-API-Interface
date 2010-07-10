xquery version '1.0-ml';

declare function local:get-query($q as xs:string, $nameOnly as xs:boolean) as cts:query 
{
	let $words := fn:tokenize($q, ' ')
	return 
		cts:or-query((
			cts:element-attribute-value-query(xs:QName('apidoc:function'), (xs:QName('fullname'), xs:QName('name')), $q, 'exact', 16),
			cts:element-attribute-value-query(xs:QName('apidoc:function'), xs:QName('fullname'), fn:concat('*', $q, '*'), (), 8),
			cts:element-attribute-word-query(xs:QName('apidoc:function'), xs:QName('fullname'), $q, (), 2),
			if ($nameOnly) then () else cts:word-query($words, (), 1)
		))	
};

let $ns := xdmp:get-request-field('ns')	
let $q := xdmp:get-request-field('q')	
let $nameOnly := xs:boolean(xdmp:get-request-field('n') = 'true')
let $version := xdmp:get-request-field('version')

let $query := local:get-query($q, $nameOnly)

let $functions := 
	if ($ns) then 
		for $f in xdmp:directory(fn:concat('/', $version, '/'), '1')/apidoc:module[@lib=$ns]/apidoc:function
		order by $f/@fullname
		return $f
	else if ($q) then
		cts:search(
			xdmp:directory(fn:concat('/', $version, '/'), '1')/apidoc:module/apidoc:function,
			$query,
			'unfiltered'
		)
	else
		for $f in xdmp:directory(fn:concat('/', $version, '/'), '1')/apidoc:module/apidoc:function
		order by $f/@fullname
		return $f

return 
	<functions nameOnly="{$nameOnly}">
		{
		for $f in $functions
        let $summary := xdmp:quote(
            if (fn:not($q)) then $f/apidoc:summary/node()
            else cts:highlight(<span>{$f/apidoc:summary/node()}</span>, $query, <span class="hi">{$cts:text}</span>)/node()
          )
		return 
			<function>
				<name>{data($f/@fullname)}</name>
				<summary>{$summary}</summary>
			</function>
		}
	</functions>
	
