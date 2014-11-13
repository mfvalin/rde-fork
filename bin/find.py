#!/usr/bin/env python
import os,optparse

def listfiles(folder,ftype,lfollow,maxdepth=-1):
    for root, folders, files in os.walk(folder,followlinks=lfollow):
        nottoodeep=True
        if maxdepth > 0:
             nottoodeep = (len(root.split('/'))<=maxdepth)
        if nottoodeep:
            if ftype == 'f':
                for filename in files:
                    yield os.path.join(root, filename)
            elif ftype == 'd':
                for filename in folders:
                    yield os.path.join(root, filename)
            elif ftype == 'l':
                for filename in folders + files:
                    mypath = os.path.join(root, filename)
                    if os.path.islink(mypath):
                        yield mypath
            else:
                for filename in folders + files:
                    yield os.path.join(root, filename)

if __name__ == "__main__":
    usage = "usage: \n\t%prog PATH [-type l/d/f] "
    parser = optparse.OptionParser(usage=usage)
    parser.add_option("-t","--type",
                      dest="ftype",default="",
                      help="Filter by type [fdl]")
    parser.add_option("-L","--follow-links",
                      action="store_true",dest="lfollow",default=False,
                      help="Follow links")
    parser.add_option("","--maxdepth",
                      dest="maxdepth",default="-1",
                      help="Descend at most levels of directories below the command line arguments")
    (options,args) = parser.parse_args()
    for mydir in args:
        for myfile in listfiles(mydir,options.ftype,options.lfollow==1,int(options.maxdepth)+1):
            print(myfile)
    ## print("p=%s, l=%s, t=%s, o=%s, a=%s" % (args[0], options.lfollow, options.ftype, repr(options),repr(args)))
