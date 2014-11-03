#!/usr/bin/env python
import os,string,optparse,difflib
from glob import glob

def listfiles(folder):
    for root, folders, files in os.walk(folder,followlinks=True):
        for filename in files:
            yield os.path.join(root, filename)

if __name__ == "__main__":
    usage = "usage: \n\t%prog PATH [-type l/d/f] "
    parser = optparse.OptionParser(usage=usage)
    (options,args) = parser.parse_args()
    myname = args[0]
    mydirlist = args[1:]
    a = []
    for mydir in mydirlist:
        filelist = []
        for myfile in listfiles(mydir):
            mybasename = os.path.basename(myfile)
            (myname0, myext) = os.path.splitext(mybasename)
            if mybasename[0:4] != '.rm.' and myext not in ('.o','.mod'):
                if os.path.basename(myname) in [myname0,myname0+'.',mybasename] or myname == myfile:
                    a.append(mybasename)
                else:
                    if mybasename not in filelist:
                        filelist.append(mybasename)
        if (len(a)<=0):
            for myfile in glob(mydir+'/'+myname+'*'):
                mybasename = os.path.basename(myfile)
                (myname0, myext) = os.path.splitext(mybasename)
                if mybasename[0:4] != '.rm.' and myext not in ('.o','.mod'):
                    a.append(mybasename)
        if (len(a)<=0):
            a += difflib.get_close_matches(myname,filelist,n=5)#,n=9,cutoff=0.5
    c = set(a) #sorted(set(a))
    d = [os.path.basename(item) for item in c]
    print(string.join(d,' '))
