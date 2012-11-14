xquery version "1.0-ml";

module namespace util = "http://www.github.com/robwhitby/ml-api/util";

declare variable $QN-FUNCTION := xs:QName("apidoc:function");
declare variable $QN-LIB := xs:QName("lib");
declare variable $QN-NAME := xs:QName("name");

declare variable $VERSION := xdmp:get-request-field("version", "6.0");
declare variable $VERSION-COLLECTION := "/apidoc/" || $VERSION;
declare variable $VERSIONS := cts:collections() ! fn:replace(., "/apidoc/", "");

declare variable $VERSION-QUERY := 
  cts:and-not-query(
    cts:collection-query($VERSION-COLLECTION),
    cts:element-attribute-range-query($QN-FUNCTION, $QN-LIB, "=", ("XXX","manage"))
  );

declare variable $FUNCTION-NAMESPACES as xs:string* := 
  cts:element-attribute-values($QN-FUNCTION, $QN-LIB, (), (), $VERSION-QUERY);

