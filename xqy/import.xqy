xquery version "1.0-ml";
declare default function namespace "local";

declare variable $version := xdmp:get-request-field("version", "6");
declare variable $import := xdmp:get-request-field("import", "false") cast as xs:boolean;

declare variable $default-dir := fn:concat("/Users/rob/Downloads/MarkLogic_", $version, "_pubs/pubs/raw/apidoc");
declare variable $dir := xdmp:get-request-field("dir", $default-dir);


declare function import() as element(ol)
{
  <ol>
  {
		for $path in xdmp:filesystem-directory($dir)//dir:pathname
		let $file := fn:tokenize($path, "/")[fn:last()]
		let $uri := fn:concat("/apidoc/", $version, "/", $file)
		where fn:ends-with($file, ".xml")
		return (
			xdmp:document-load($path, 
				<options xmlns="xdmp:document-load">
					<uri>{$uri}</uri>
					<format>xml</format>
					<collections>
      			<collection>/apidoc/{$version}</collection>
      		</collections>
					<permissions>{xdmp:default-permissions()}</permissions>
				</options>),
			<li>imported: {$uri}</li>
		)
	}
	</ol>
};


declare function show-form() as element(form) 
{
	<form method="get">
		<input type="hidden" name="import" value="true"/>
		Source dir <input type="text" name="dir" value="{$dir}" style="width:600px"/><br/>
		API Version <input type="text" name="version" value="{$version}" style="width:50px"/><br/>
		<input type="submit" value="Import"/>
	</form>
};

xdmp:set-response-content-type("text/html"),
<html>
	<head>
	  <title>Import API</title>
	</head>
	<body>
	  <h1>Import API from raw apidocs xml</h1>
	  {
	  	show-form(),
	  	if ($import) then 
	  	  try { import() }
	  	  catch ($e) { <pre>{xdmp:quote($e)}</pre> }
	  	else ()
		}
	</body>
</html>

