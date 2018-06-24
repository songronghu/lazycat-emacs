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
from PyQt5.QtGui import QImage
import functools
import abc

class postGui(QtCore.QObject):
    
    through_thread = QtCore.pyqtSignal(object, object)    
    
    def __init__(self, inclass=True):
        super(postGui, self).__init__()
        self.through_thread.connect(self.on_signal_received)
        self.inclass = inclass
        
    def __call__(self, func):
        self._func = func
        
        @functools.wraps(func)
        def obj_call(*args, **kwargs):
            self.emit_signal(args, kwargs)
        return obj_call
        
    def emit_signal(self, args, kwargs):
        self.through_thread.emit(args, kwargs)
                
    def on_signal_received(self, args, kwargs):
        if self.inclass:
            obj, args = args[0], args[1:]
            self._func(obj, *args, **kwargs)
        else:    
            self._func(*args, **kwargs)

class Buffer(object):
    __metaclass__ = abc.ABCMeta
    
    def __init__(self, buffer_id, url, width, height, background_color):
        self.width = width
        self.height = height
        
        self.buffer_id = buffer_id
        self.url = url
                
        self.qimage = None
        self.buffer_widget = None
        self.background_color = background_color
        
    def resize_buffer(self, width, height):
        pass
            
    def handle_destroy(self):
        if self.buffer_widget != None:
            self.buffer_widget.destroy()
            
        if self.qimage != None:
            del self.qimage
            
        print("Destroy buffer: %s" % self.buffer_id)
        
    @postGui()    
    def update_content(self):
        if self.buffer_widget != None:
            qimage = QImage(self.width, self.height, QImage.Format_ARGB32)
            self.buffer_widget.render(qimage)
            self.qimage = qimage
