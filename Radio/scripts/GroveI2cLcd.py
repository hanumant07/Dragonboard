#!/usr/bin/env python

import getopt
import Pyro4
import smbus
import sys
import time

Pyro4.config.SERVERTYPE = "multiplex"


class GroveI2cLcd(object):

    __text_addr = 0x3e
    #   Text subcommands
    __clear_screen = 0x01
    # line length
    __linelength = 16

    def _text_command(self, cmd):
        bus = self._bus
        try:
            bus.write_byte_data(self.__text_addr, 0x80, cmd)
        except IOError as e:
            print "I/OError in text cmd %x" % cmd
            print "I/OError ({0}): {1}".format(e.errno, e.strerror)
            raise Exception('I2cError')
        except:
            print "Unexpected error in text cmd %x" % cmd
            print "Unexpected error:", sys.exc_info()[0]
            raise Exception('I2cError')

    def set_text(self, text):
        bus = self._bus
        length = self.__linelength
        self._text_command(self.__clear_screen)
        time.sleep(.05)
        #   display on/off bit[2] cursor on/off bit[1]
        self._text_command(0x8 | 0x4)
        #   2 line
        self._text_command(0x28)
        time.sleep(.05)
        count = 0
        row = 0
        for c in text:
            if c == '\n' or count == length:
                count = 0
                row += 1
                if row == 2:
                    break
                self._text_command(0xc0)
                if c == '\n':
                    continue
            count += 1
            try:
                bus.write_byte_data(self.__text_addr, 0x40, ord(c))
            except IOError as e:
                print "I/OError in setting text %s" % text
                print "I/OError ({0}): {1}".format(e.errno, e.strerror)
                raise IOError('I2cError')
            except:
                print "Unexpected error in setting text %s" % text
                print "Unexpected error:", sys.exc_info()[0]
                raise IOError('I2cError')

    def __init__(self, bus_id):
        try:
            self._bus = smbus.SMBus(bus_id)
        except IOError as e:
            print "I/O error({0}): {1}".format(e.errno, e.strerror)
            raise IOError('I2CError')
        except:
            raise IOError('I2CError')


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "hn:", ["num="])
    except getopt.GetoptError:
        print './GroveI2cLcd.py -n [0..n]'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'GroveI2cLcd.py -n [0..n]'
            sys.exit()
        if opt == '-D':
            global _debug
            _debug = 1
        elif opt in ("-n", "--num"):
            bus_id = arg
    try:
        bus_id = int(bus_id)
        lcd = GroveI2cLcd(bus_id)
    except IOError as e:
        print "I/O Error{0}".format(e.strerror)
    else:
        name = "Grovelcd-" + repr(bus_id)
        daemon = Pyro4.Daemon()
        uri = daemon.register(lcd)
        ns = Pyro4.locateNS()
        ns.register(name, uri)
        print "Starting daemon " + name
        daemon.requestLoop()


if __name__ == "__main__":
    main(sys.argv[1:])
