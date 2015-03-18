# Copyright 2005-2015 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
#
# In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
# virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.

#
# Python implementation: bufr_get_keys
#
# Description: how to read values of different type of keys from BUFR messages.
#
#

import traceback
import sys

from eccodes import *

INPUT='../../data/bufr/syno_1.bufr'
VERBOSE=1 # verbose error reporting

def example():

    # open bufr file
    f = open(INPUT)

    cnt=0

    # loop for the messages in the file
    while 1:
        # get handle for message
        gid = codes_bufr_new_from_file(f)
        if gid is None: break

        print "message: %s" % cnt

        # we need to instruct ecCodes to expand all the descriptors
        # i.e. unpack the data values
        codes_set(gid,'unpack',1)

        #-----------------------------------
        # get all the expanded data values
        #-----------------------------------
        key='numericValues'

        # get size
        num=codes_get_size(gid,key)
        print  '  size of %s is: %s' % (key,num)

        # get values
        values=codes_get_array(gid,key)
        for i in xrange(len(values)):
            print "   %d %.10e" % (i+1,values[i])

        cnt+=1

        # delete handle
        codes_release(gid)

    # close the file
    f.close()

def main():
    try:
        example()
    except CodesInternalError,err:
        if VERBOSE:
            traceback.print_exc(file=sys.stderr)
        else:
            print >>sys.stderr,err.msg

        return 1

if __name__ == "__main__":
    sys.exit(main())
