xquery version "1.0-ml";

import module namespace rest = "http://marklogic.com/appservices/rest" at "/MarkLogic/appservices/utils/rest.xqy"; 

declare variable $options := 
  <options user-params="ignore" xmlns="http://marklogic.com/appservices/rest">
    <request uri="^/$" endpoint="/xqy/redirector.xqy">
      <uri-param name="location">/6</uri-param>
    </request>
    <request uri="^/(.+)/navigation$" endpoint="/xqy/navigation.xqy">
      <uri-param name="version">$1</uri-param>
    </request>
    <request uri="^/(.+)/functions$" endpoint="/xqy/functions.xqy">
      <uri-param name="version">$1</uri-param>
    </request>
    <request uri="^/([^/]+)/?$" endpoint="/xqy/index.xqy">
      <uri-param name="version">$1</uri-param>
    </request>
  </options>;


(rest:rewrite($options), xdmp:get-request-url())[1]
