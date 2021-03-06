//
//  HTTPConfigData.swift
//  PullServer
//
//  Created by AugustRush on 1/5/17.
//
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        // Respond with a simple message.
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: "<html><title>Pull!</title><body>Hello, world 你好啊 2017!</body></html>")
        // Ensure that response.completed() is called when your processing is done.
        response.completed()
    }
}

func handlerV1(data: [String:Any]) throws -> RequestHandler {
    
    let handler: RequestHandler = { (request, response) in
        response.setHeader(.contentType, value: "text/html")

        PSSpider.crawlHTML(fromURL: "http://www.hahao.cn/", completion: { (content) in
            response.appendBody(string: content)
            response.completed()
        }, failed: {(err) in
            response.appendBody(string: err.description())
            response.completed()
        })
    }
    
    return handler
}

func handlerPost(data: [String:Any]) throws -> RequestHandler {
    
    let handler: RequestHandler = {
        request, response in
        // Respond with a simple message.
        response.setHeader(.contentType, value: "text/html")
        response.appendBody(string: request.params().description)
        // Ensure that response.completed() is called when your processing is done.
        response.completed()
    }
    
    return handler
}

let confData = [
    "servers": [
        // Configuration data for one server which:
        //	* Serves the hello world message at <host>:<port>/
        //	* Serves static files out of the "./webroot"
        //		directory (which must be located in the current working directory).
        //	* Performs content compression on outgoing data when appropriate.
        [
            "name":"localhost",
            "port":port1,
            "routes":[
                ["method":"get", "uri":"/", "handler":handler],
                ["method":"get", "uri":"/v1/*", "handler":handlerV1],
                ["method":"post", "uri":"/post", "handler":handlerPost],
                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
                 "documentRoot":"./webroot",
                 "allowResponseFilters":true]
            ],
            "filters":[
                [
                    "type":"response",
                    "priority":"high",
                    "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                    ]
            ]
        ],
        // Configuration data for another server which:
        //	* Redirects all traffic back to the first server.
        [
            "name":"localhost",
            "port":port2,
            "routes":[
                ["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
                 "base":"http://localhost:\(port1)"]
            ]
        ]
    ]
]
