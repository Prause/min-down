#!/usr/bin/python3
# coding=utf-8

from os import path, makedirs
import shutil
import json

from bottle import Bottle, template, static_file, request, redirect, TEMPLATE_PATH



class DownApp (Bottle):

    def __init__(self):
        super(DownApp, self).__init__()
        self.ROOT_DIR = path.abspath(path.dirname(__file__))
        self.REQUIRE_LOGIN = False

        # config
        self.config = {}
        if path.isfile( path.join( self.ROOT_DIR, 'config.json' )):
            with open( path.join( self.ROOT_DIR, 'config.json' ), 'r' ) as fh:
                self.config = json.loads( fh.read() )

        # var paths
        if not path.isdir( path.join( self.ROOT_DIR, 'var/down/' )):
            makedirs( path.join( self.ROOT_DIR, 'var/down/' ))
        if not path.isdir( path.join( self.ROOT_DIR, 'var/olddown/' )):
            makedirs( path.join( self.ROOT_DIR, 'var/olddown/' ))


    def initRoutes(self, root='/'):
        self.url_root = root
        self.url_base = root
        if root[-1] != '/':
            self.url_base += '/'

        self.route( root, callback=self.down_main)
        self.get( path.join(root, 'file/<filename>'), callback=self.down_file)
        self.route( path.join(root, 'delete/<filename>'), callback=self.delete_file)
        self.post( path.join(root, 'upload'), callback=self.upload_data)
        self.route( path.join(root, '<resource_type>/<filename>'), callback=self.static)


    def down_main(self):
        print( 'down: main' )
        return template( 'templates/down.tpl', down_root=self.ROOT_DIR, doc_root=self.url_base )


    def down_file(self, filename):
        print( 'down: requesting ' + filename )
        return static_file(filename, root=path.join( self.ROOT_DIR, 'var/down/'))


    def delete_file(self, filename):
        loggedin = request.get_cookie( "loggedin", secret=self.config.get('login_signature', '') )
        if loggedin != "yes" and self.REQUIRE_LOGIN:
            redirect("/login")
        else:
            print( 'down: deleting ' + filename )
            if( path.isfile( path.join(self.ROOT_DIR, 'var/down/', filename) )):
                shutil.move( path.join(self.ROOT_DIR, 'var/down/', filename),
                    path.join(self.ROOT_DIR, 'var/olddown/', filename))
            redirect( self.url_root )


    def static(self, resource_type, filename):
        return static_file( filename,
                root=path.join( self.ROOT_DIR, 'static', resource_type ))


    def upload_data(self):
        print( 'down: uploading file' )
        uploads = request.files.getall('upload')
        for upload in uploads:
            print( "  " + upload.filename )
            upload.save( path.join( self.ROOT_DIR, 'var/down/')) # appends upload.filename automatically
        return "OK";



if __name__ == '__main__':
    app = DownApp()
    app.initRoutes()
    app.run(
        host=app.config.get('host', '0.0.0.0'),
        port=app.config.get('port', 8899 )
    )

    #print( "Started down" )
    #server = WSGIServer(("0.0.0.0", 8081), app,
    #                    handler_class=WebSocketHandler)
    #server.serve_forever()

else:
    TEMPLATE_PATH.append( path.dirname(__file__) )

