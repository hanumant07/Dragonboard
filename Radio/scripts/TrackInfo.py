#!/usr/bin/env python

import getopt
import Pyro4
import Pyro4.util
import sys
import time


sys.excepthook = Pyro4.util.excepthook


class TrackInfo:

    def display(self):
        fname = self._fname
        lcd = self._lcd
        while 1:
            try:
                fd = open(fname, 'r')
            except:
                raise IOError('Unable to open file ' + fname)
            for line in fd:
                try:
                    lcd.set_text(line)
                except:
                    print "Display daemon failed to set text"
                    raise
                else:
                    time.sleep(4)
            fd.close()

    def __init__(self, fname, lcdDaemon):
        self._fname = fname
        uri = "PYRONAME:"+lcdDaemon
        try:
            lcd = Pyro4.Proxy(uri)
        except:
            raise IOError('Unable to find Display Daemon handle')
        else:
            self._lcd = lcd


def main(argv):
    dname = ''
    file_name = ''
    try:
        opts, args = getopt.getopt(argv, "hi:d:", ["ifile=", "dname="])
    except getopt.GetoptError:
        print 'Trackinfo.py -i <inputfile> -d <daemonName>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'test.py -i <inputfile> -o <daemonName>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            file_name = arg
            print "File name is " + file_name + "\n"
        elif opt in ("-d", "--dname"):
            dname = arg
            print "Daemon is " + dname + "\n"
    try:
        print "Obtaining LCD handle from " + dname + "\n"
        info = TrackInfo(file_name, dname)
    except IOError as e:
        print "Error: {0}\n".format(e.strerror)
        sys.exit(2)
    else:
        info.display()

if __name__ == "__main__":
    main(sys.argv[1:])
