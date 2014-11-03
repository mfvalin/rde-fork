#!/usr/bin/env python
import os,string,optparse,difflib

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
                if myname0 == os.path.basename(myname):
                    a.append(mybasename)
                else:
                    if mybasename not in filelist:
                        filelist.append(mybasename)
        b = difflib.get_close_matches(myname,filelist,n=5)#,n=9,cutoff=0.5
        a += b
        #print mydir,myname,b,"\n"
        #print filelist
    c = set(a) #sorted(set(a))
    d = [os.path.basename(item) for item in c]
    print(string.join(d,' '))
