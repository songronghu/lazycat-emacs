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


import threading
from PyQt5 import QtCore
from PyQt5.QtGui import QPainter, QImage
from PyQt5.QtWebKitWidgets import QWebView, QWebPage
from PyQt5.QtCore import QUrl, Qt
from PyQt5 import QtGui
from PyQt5.QtWidgets import QWidget
from PyQt5.QtCore import Qt, QTimer, QEvent
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import QPainter, QColor
import time
import copy
import functools
from xutils import get_xlib_display, grab_focus
from dbus.mainloop.glib import DBusGMainLoop
import dbus
import dbus.service

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
        
        (self.emacs_xid, self.emacs_x, self.emacs_y, self.emacs_width, self.emacs_height) = (map(lambda x: int(x), args))
        
        print (self.emacs_xid, self.emacs_x, self.emacs_y, self.emacs_width, self.emacs_height)
        
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
                self.view_dict[key].destroy()

                self.view_dict.pop(key)
        
        # Create new view and udpate in view dict.
        if view_infos != ['']:
            for view_info in view_infos:
                if view_info not in self.view_dict:
                    self.view_dict[view_info] = View(self.emacs_xid, view_info)
                    
    @dbus.service.method(EAF_DBUS_NAME, in_signature="s", out_signature="")
    def kill_buffer(self, buffer_id):
        for key in list(self.view_dict):
            (bid, _, _, _, _) = key.split(":")
            if buffer_id == bid:
                print("**********************")
                self.view_dict[key].destroy()
                
                self.view_dict.pop(key)
                print("**********************")
        
        if buffer_id in self.buffer_dict:
            self.buffer_dict[buffer_id].destroy()

            self.buffer_dict.pop(buffer_id)
    
    def update_buffers(self):
        while True:
            for buffer in self.buffer_dict.values():
                buffer.update_content()
                
                for view in self.view_dict.values():
                    if view.buffer_id == buffer.buffer_id:
                        view.view_widget.qimage = buffer.qimage
                        view.view_widget.update()
                
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
        
    def destroy(self):
        print("Destroy buffer: %s" % self.buffer_id)
        
        if self.buffer_widget != None:
            self.buffer_widget.destroy()
        
    @postGui()    
    def update_content(self):
        if self.buffer_widget != None:
            qimage = QImage(self.emacs_width, self.emacs_height, QImage.Format_ARGB32)
            self.buffer_widget.render(qimage)
            self.qimage = qimage
        
class ViewWidget(QWidget):
    def __init__(self, emacs_xid, x, y, w, h):
        super(ViewWidget, self).__init__()

        self.emacs_xid = int(emacs_xid)
        self.x = x
        self.y = y
        self.width = w
        self.height = h
        
        self.setWindowFlags(Qt.FramelessWindowHint)
        # self.setAttribute(Qt.WA_TranslucentBackground, True)
        self.setContentsMargins(0, 0, 0, 0)
        
        self.qimage = None
        
        self.show()
        
    def paintEvent(self, event):
        print("##########################3")
        
        painter = QPainter(self)
                    
        if self.qimage != None:
            painter.drawImage(QtCore.QRect(0, 0, self.width, self.height), self.qimage)
            print("!!!!!!!!!!!!!!!!!!")
        
        painter.end()
        
    def reparent(self):
        xlib_display = get_xlib_display()
        
        view_xid = self.winId().__int__()
        view_xwindow = xlib_display.create_resource_object("window", view_xid)
        emacs_xwindow = xlib_display.create_resource_object("window", self.emacs_xid)
        
        view_xwindow.reparent(emacs_xwindow, self.x, self.y)
        
        xlib_display.sync()
        
class View(object):
    def __init__(self, emacs_xid, view_info):
        self.view_info = view_info
        
        (self.buffer_id, self.x, self.y, self.width, self.height) = view_info.split(":")
        self.x = int(self.x)
        self.y = int(self.y)
        self.width = int(self.width)
        self.height = int(self.height)
        
        self.view_widget = ViewWidget(emacs_xid, self.x, self.y, self.width, self.height)
        self.view_widget.resize(self.width, self.height)
        
        self.view_widget.reparent()
        
        print("Create view: %s" % self.view_info)
        
    def destroy(self):
        print("Destroy view: %s" % self.view_info)
        
        self.view_widget.destroy()
        
class BrowserBuffer(Buffer):
    def __init__(self, buffer_id, app_type, input_content, emacs_width, emacs_height):
        Buffer.__init__(self, buffer_id, app_type, input_content, emacs_width, emacs_height)
        
        self.buffer_widget = QWebView()
        self.buffer_widget.resize(emacs_width, emacs_height)
        self.buffer_widget.setUrl(QUrl("http://www.baidu.com"))
        
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
