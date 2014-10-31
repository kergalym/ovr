#!/usr/bin/python

# drvctrl.py

import sys
import os
from PyQt4 import QtGui
from PyQt4 import QtCore


class ToggleButton(QtGui.QWidget):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)

        self.color = QtGui.QColor(0, 0, 0)

        self.setGeometry(300, 300, 280, 170)
        self.setWindowTitle('Configure Driver')

        self.red = QtGui.QPushButton('ATI', self)
        self.red.setCheckable(True)
        self.red.move(10, 10)

        self.connect(self.red, QtCore.SIGNAL('clicked()'), self.setATI)

        self.green = QtGui.QPushButton('nVidia', self)
        self.green.setCheckable(True)
        self.green.move(10, 60)

        self.connect(self.green, QtCore.SIGNAL('clicked()'), self.setnVidia)

        self.blue = QtGui.QPushButton('FOSS', self)
        self.blue.setCheckable(True)
        self.blue.move(10, 110)

        self.connect(self.blue, QtCore.SIGNAL('clicked()'), self.setFOSS)

        self.label = QtGui.QLabel(self)
        self.label.setPixmap(QtGui.QPixmap('/usr/share/drvconf/images/graphic_card_logo.png'))
        self.label.setGeometry(150, 20, 100, 100)

        QtGui.QApplication.setStyle(QtGui.QStyleFactory.create('cleanlooks'))

    def setATI(self):
	os.system('eselect opengl set fglrx && echo "blacklist radeon" > /etc/modprobe.d/gfx-blacklist.conf && amdconfig --initial -f')

    def setnVidia(self):
	os.system('eselect opengl set nvidia && echo "blacklist nouveau" > /etc/modprobe.d/gfx-blacklist.conf && nvidia-xconfig')

    def setFOSS(self):
	os.system('eselect opengl set xorg-x11 && rm /etc/X11/xorg.conf')


app = QtGui.QApplication(sys.argv)
tb = ToggleButton()
tb.show()
app.exec_()
