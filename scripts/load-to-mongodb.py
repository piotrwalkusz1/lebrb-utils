#!/bin/python3

from pymongo import MongoClient
from gridfs import GridFS
import sys

client = MongoClient(sys.argv[1])
fs = GridFS(client[sys.argv[2]])
with open(sys.argv[3]) as f:
    for i in fs.find({"filename": sys.argv[4]}):
        fs.delete(i._id)
    fs.put(f.read(), encoding="UTF-8", filename=sys.argv[4])
