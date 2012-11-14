xquery version "1.0-ml";
import module namespace u = "http://www.github.com/robwhitby/ml-api/util" at "util.xqy";

let $ns-json := $u:FUNCTION-NAMESPACES ! fn:concat('{ "ns": "', ., '", "text": "', ., ':"}')
return fn:concat("[", fn:string-join($ns-json, ","), "]")
