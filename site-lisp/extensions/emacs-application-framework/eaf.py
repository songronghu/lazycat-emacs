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
from PyQt5 import QtGui
from PyQt5.QtWidgets import QWidget
from PyQt5.QtCore import Qt, QTimer, QEvent
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import QPainter, QColor
import time
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
            EAF_OBJECT_NAME            
        )
        
        self.event_window = EventWindow(map(lambda x: int(x), args))
        self.event_window.show()
        self.event_window.reparent_to_emacs()
        
class EventWindow(QWidget):
    def __init__(self, args):
        super(EventWindow, self).__init__()
        
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground, True)
        self.setAttribute(Qt.WA_TransparentForMouseEvents, True)
        self.setAttribute(Qt.WA_ShowWithoutActivating, True)
        self.setContentsMargins(0, 0, 0, 0)
        self.setFocusPolicy(Qt.NoFocus)
        
        (self.emacs_xid, self.emacs_x, self.emacs_y, self.emacs_width, self.emacs_height) = args
        
        print(self.emacs_xid, self.emacs_x, self.emacs_y, self.emacs_width, self.emacs_height)
        
    def reparent_to_emacs(self):
        self.resize(self.emacs_width, self.emacs_height)
        
        xlib_display = get_xlib_display()

        event_xwindow = xlib_display.create_resource_object("window", self.winId().__int__())
        emacs_xwindow = xlib_display.create_resource_object("window", self.emacs_xid)
        
        event_xwindow.reparent(emacs_xwindow, self.emacs_x, self.emacs_y)
                
        xlib_display.sync()
          
    def paintEvent(self, event):
        painter = QPainter(self)
        painter.fillRect(event.rect(), QColor(255, 0, 0, 128))

if __name__ == "__main__":
    import sys
    import signal
    
    DBusGMainLoop(set_as_default=True) # WARING: only use once in one process
    
    bus = dbus.SessionBus()
    if bus.request_name(EAF_DBUS_NAME) != dbus.bus.REQUEST_NAME_REPLY_PRIMARY_OWNER:
        print("EAF tray process has startup.")
    else:
        app = QApplication(sys.argv)
        
        eaf = EAF(sys.argv[1:])
        
        print("EAF tray process start.")
        
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        sys.exit(app.exec_())
