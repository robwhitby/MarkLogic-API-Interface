xquery version '1.0-ml';

let $version := xdmp:get-request-field('version')
let $base-uri := fn:concat('http://developer.marklogic.com:8040/', $version, 'doc/')
let $import := xdmp:get-request-field('import')

return (
	xdmp:set-response-content-type('text/html'),
	if ($version and $import = 'true') then
		let $fns := xdmp:document-get(fn:concat($base-uri,'functionSummary.xqy'), 
			<options xmlns="xdmp:document-get" xmlns:http="xdmp:http">
				<format>xml</format>
			</options>)

		let $files := distinct-values(
			for $href in $fns//*:a/@href
			where fn:starts-with($href,fn:concat('#display.xqy?fname=http://pubs/', $version, 'doc/apidoc/'))
			return fn:substring-before(fn:substring-after($href, fn:concat('#display.xqy?fname=http://pubs/', $version, 'doc/apidoc/')),'&amp;')
		)
		
		return (
			for $file in $files
			return (
				xdmp:document-load(fn:concat($base-uri, '/apidoc/', $file),
					<options xmlns="xdmp:document-load">
						<uri>{fn:concat('/', $version, '/', $file)}</uri>
						<repair>none</repair>
						<permissions>{xdmp:default-permissions()}</permissions>
					</options>) 
				,
				<p>Imported: {$file}</p>
			),
			<p>Import Finished. <a href="/?{$version}/">View API</a></p>
		)
	else if ($import = 'true') then
		<p>Error importing: Version parameter required<br/><br/><a href="javascript:history.back()">Back</a></p>
	else 
		<div>
		<h2>Mark Logic API</h2>
		<p>
			Download the API from MarkLogic (may take a couple of minutes).
			<form method="get">
				<input type="hidden" name="import" value="true"/>
				API Version<br/><input type="text" name="version" value="4.2"/>
				<input type="submit" value="Import"/>
			</form>
		</p>
		</div>
)


