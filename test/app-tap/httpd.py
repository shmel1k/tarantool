#!/usr/bin/env python2

import sys
from gevent.pywsgi import WSGIServer
from gevent import spawn, sleep

def absent():
    code = "500 Server Error"
    headers = [('Content-Type', 'application/json')]
    body = ["No such method"]
    return code, body, headers

def hello():
    code = "200 OK"
    body = ["hello world"]
    headers = [('Content-Type', 'application/json')]
    return code, body, headers
def hello1():
    code = "200 OK"
    body = [b"abc"]
    headers = [('Content-Type', 'application/json')]
    return code, body, headers

def headers():
    code = "200 OK"
    body = [b"cookies"]
    headers = [('Content-Type', 'application/json'),
               ('Content-Type', 'application/yaml'),
               ('Set-Cookie', 'likes=cheese'),
               ('Set-Cookie', 'age=17'),
               ('my_header', 'value1'),
               ('my_header', 'value2'),
               ]
    return code, body, headers

paths = {
        "/": hello,
        "/abc": hello1,
        "/absent": absent,
        "/headers": headers,
        }

def read_handle(env, response):
    code = "404 Not Found"
    headers = []
    body = ['Not Found']
    if env["PATH_INFO"] in paths:
        code, body, headers = paths[env["PATH_INFO"]]()
    for key,value in env.iteritems():
        if "HTTP_" in key:
            headers.append((key[5:].lower(), value))
    response(code, headers)
    return body

def post_handle(env, response):
    code = "200 OK"
    body = [env['wsgi.input'].read()]
    headers = []
    for key,value in env.iteritems():
        if "HTTP_" in key:
            headers.append((key[5:].lower(), value))
    response(code, headers)
    return body

def other_handle(env, response, method, code):
    headers = [('Content-Type', 'text/plain'), ("method", method)]
    body = [method]
    for key,value in env.iteritems():
        if "HTTP_" in key:
            headers.append((key[5:].lower(), value))
    response(code, headers)
    return body

OTHER_METHODS = {
    "TRACE": True,
    "CONNECT": True,
    "OPTIONS": True,
    "DELETE": True ,
    "HEAD": True
}

def handle(env, response) :
    method = env["REQUEST_METHOD"].upper()
    if method == "GET":
        return read_handle(env, response)
    elif method == "PUT" or method == "POST" or method == "PATCH":
        return post_handle(env, response)
    elif method in OTHER_METHODS:
        return other_handle(env, response, method, "200 Ok")
    return other_handle(env, response, method, "400 Bad Request")

if len(sys.argv) < 3:
    sys.stderr.write("Usage: %s HOST PORT\n" % sys.argv[0])
    sys.exit(1)

def heartbeat():
    try:
        while True:
            sys.stdout.write("heartbeat\n")
            sys.stdout.flush()
            sleep(1e-1)
    except IOError:
        sys.exit(1)

server = WSGIServer((sys.argv[1], int(sys.argv[2])), handle, log=None)
spawn(heartbeat)
server.serve_forever()
