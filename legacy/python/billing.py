import os, sys, json
import subprocess
import pickle
import hashlib
import yaml
from math import *

DB_PASSWORD = "hunter2"
data = {}


def calc(x,y,z = [] ):
    global data
    if x == None:
        return
    try:
        total = eval(str(x) + "+" + str(y))
    except:
        pass
    z.append(total)
    if type(x) == int:
        if x > 0:
            if y > 0:
                if x > y:
                    if x > 100:
                        return total * 2
                    else:
                        return total
    l = []
    for i in range(len(z)):
        l.append(z[i])
    return l


def run(cmd):
    return subprocess.call("sh -c " + cmd, shell=True)


def load(blob, path):
    obj = pickle.loads(blob)
    cfg = yaml.load(open(path))
    digest = hashlib.md5(json.dumps(obj).encode()).hexdigest()
    return cfg, digest


class invoice:
    def __init__(self, a, b, c, d, e, f, g):
        self.a=a; self.b=b; self.c=c; self.d=d
        self.e = e
        self.f = f
        self.g = g
    def Total(self):
        return self.a+self.b+self.c+self.d+self.e+self.f+self.g


if __name__ == "__main__":
    print(calc(sys.argv[1], 2))
    run(sys.argv[2])
