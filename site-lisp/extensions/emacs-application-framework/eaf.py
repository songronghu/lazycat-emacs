#! /usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2018 Andy Stewart
# 
# Author:     Andy Stewart <lazycat.manatee@gmail.com>
# Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


from PyQt5 import QtCore
from PyQt5.QtCore import QUrl, Qt
from PyQt5.QtGui import QPainter, QImage
from PyQt5.QtWebKitWidgets import QWebView
from PyQt5.QtWidgets import QWidget, QApplication
from dbus.mainloop.glib import DBusGMainLoop
from xutils import get_xlib_display
import dbus
import dbus.service
import functools
import threading
import time

EAF_DBUS_NAME = "com.lazycat.eaf"
EAF_OBJECT_NAME = "/com/lazycat/eaf"

class postGui(QtCore.QObject):
    
    throughThread = QtCore.pyqtSignal(object, object)    
    
    def __init__(self, inclass=True):
        super(postGui, self).__init__()
        self.throughThread.connect(self.onSignalReceived)
        self.inclass = inclass
        
    def __call__(self, func):
        self._func = func
        
        @functools.wraps(func)
        def objCall(*args, **kwargs):
            self.emitSignal(args, kwargs)
        return objCall
        
    def emitSignal(self, args, kwargs):
        self.throughThread.emit(args, kwargs)
                
    def onSignalReceived(self, args, kwargs):
        if self.inclass:
            obj, args = args[0], args[1:]
            self._func(obj, *args, **kwargs)
        else:    
            self._func(*args, **kwargs)

class EAF(dbus.service.Object):
    def __init__(self, args):
        dbus.service.Object.__init__(
            self,
            dbus.service.BusName(EAF_DBUS_NAME, bus=dbus.SessionBus()),
            EAF_OBJECT_NAME)
        
        (self.emacs_xid, self.emacs_width, self.emacs_height) = (map(lambda x: int(x), args))
        self.buffer_dict = {}
        self.view_dict = {}
        
    @dbus.service.method(EAF_DBUS_NAME, in_signature="sss", out_signature="")
    def new_buffer(self, buffer_id, app_type, input_content):
        if app_type == "browser":
            self.buffer_dict[buffer_id] = BrowserBuffer(buffer_id, app_type, input_content, self.emacs_width, self.emacs_height)
            
    @dbus.service.method(EAF_DBUS_NAME, in_signature="s", out_signature="")
    def update_views(self, args):
        view_infos = args.split(",")
        
        # Remove old key from view dict and destroy old view.
        for key in list(self.view_dict):
            if key not in view_infos:
                self.view_dict[key].handleDestroy()
                self.view_dict.pop(key, None)
        
        # Create new view and udpate in view dict.
        if view_infos != ['']:
            for view_info in view_infos:
                if view_info not in self.view_dict:
                    self.view_dict[view_info] = View(self.emacs_xid, view_info)
                    
    @dbus.service.method(EAF_DBUS_NAME, in_signature="s", out_signature="")
    def kill_buffer(self, buffer_id):
        # Kill all view base on buffer_id.
        for key in list(self.view_dict):
            if buffer_id == self.view_dict[key].buffer_id:
                self.view_dict[key].handleDestroy()
                self.view_dict.pop(key, None)
        
        # Clean buffer from buffer dict.
        if buffer_id in self.buffer_dict:
            self.buffer_dict[buffer_id].handleDestroy()
            self.buffer_dict.pop(buffer_id, None)
    
    def update_buffers(self):
        while True:
            for buffer in self.buffer_dict.values():
                buffer.update_content()
                
                for view in self.view_dict.values():
                    if view.buffer_id == buffer.buffer_id:
                        view.qimage = buffer.qimage
                        view.update()
                
            time.sleep(0.05)
        
class Buffer(object):
    def __init__(self, buffer_id, app_type, input_content, emacs_width, emacs_height):
        self.buffer_id = buffer_id
        self.app_type = app_type
        self.input_content = input_content
        self.emacs_width = emacs_width
        self.emacs_height = emacs_height
        
        self.qimage = None
        self.buffer_widget = None
        
    def handleDestroy(self):
        if self.buffer_widget != None:
            self.buffer_widget.destroy()
            
        if self.qimage != None:
            del self.qimage
            
        print("Destroy buffer: %s" % self.buffer_id)
        
    @postGui()    
    def update_content(self):
        if self.buffer_widget != None:
            qimage = QImage(self.emacs_width, self.emacs_height, QImage.Format_ARGB32)
            self.buffer_widget.render(qimage)
            self.qimage = qimage
        
class View(QWidget):
    def __init__(self, emacs_xid, view_info):
        super(View, self).__init__()
        
        # Init widget attributes.
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_X11DoNotAcceptFocus, True)
        self.setContentsMargins(0, 0, 0, 0)
        
        # Init attributes.
        self.view_info = view_info
        (self.buffer_id, self.x, self.y, self.width, self.height) = view_info.split(":")
        self.emacs_xid = int(emacs_xid)
        self.x = int(self.x)
        self.y = int(self.y)
        self.width = int(self.width)
        self.height = int(self.height)
        
        self.qimage = None
        
        # Show and resize.
        self.show()
        self.resize(self.width, self.height)
        
        print("Create view: %s" % self.view_info)
        
    def paintEvent(self, event):
        painter = QPainter(self)
                    
        if self.qimage != None:
            painter.drawImage(QtCore.QRect(0, 0, self.width, self.height), self.qimage)
        
        painter.end()
        
    def showEvent(self, event):
        # NOTE: we must reparent after widget show, otherwise reparent operation maybe failed.
        self.reparent()
        
    def reparent(self):
        xlib_display = get_xlib_display()
        
        view_xid = self.winId().__int__()
        view_xwindow = xlib_display.create_resource_object("window", view_xid)
        emacs_xwindow = xlib_display.create_resource_object("window", self.emacs_xid)
        
        view_xwindow.reparent(emacs_xwindow, self.x, self.y)
        
        xlib_display.sync()
        
    def handleDestroy(self):
        if self.qimage != None:
            del self.qimage
            
        self.destroy()
        
        print("Destroy view: %s" % self.view_info)
        
class BrowserBuffer(Buffer):
    def __init__(self, buffer_id, app_type, input_content, emacs_width, emacs_height):
        Buffer.__init__(self, buffer_id, app_type, input_content, emacs_width, emacs_height)
        
        self.buffer_widget = QWebView()
        self.buffer_widget.resize(emacs_width, emacs_height)
        self.buffer_widget.setUrl(QUrl(input_content))
        
        print("Create buffer: %s" % buffer_id)
        
if __name__ == "__main__":
    import sys
    import signal
    
    DBusGMainLoop(set_as_default=True) # WARING: only use once in one process
    
    bus = dbus.SessionBus()
    if bus.request_name(EAF_DBUS_NAME) != dbus.bus.REQUEST_NAME_REPLY_PRIMARY_OWNER:
        print("EAF process has startup.")
    else:
        app = QApplication(sys.argv)
        
        eaf = EAF(sys.argv[1:])
        
        threading.Thread(target=eaf.update_buffers).start()
        
        print("EAF process start.")
        
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        sys.exit(app.exec_())
