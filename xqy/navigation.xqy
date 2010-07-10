xquery version '1.0-ml';

let $version := (xdmp:get-request-field('version'), '4.1')[1]

let $ns := 
	fn:distinct-values(
		for $module in xdmp:directory(fn:concat('/', $version, '/'), '1')/apidoc:module
		let $name := fn:data($module/@lib)
		order by $name ascending
		return $name
	)
	
let $items :=
	for $item in $ns
	return fn:concat("{ ns: '", $item, "', text: '", $item, ":'}")
		
return fn:concat("[", fn:string-join($items, ","), "]")