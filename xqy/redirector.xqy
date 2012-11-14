xquery version "1.0-ml";

declare variable $location := xdmp:get-request-field("location", "");

xdmp:set-response-code(302, "Found"),
xdmp:redirect-response($location)
