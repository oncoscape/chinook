import sys
from websocket import create_connection
from json import *
ws = create_connection("ws://localhost:5127")


#------------------------------------------------------------------------------------------------------------------------
def runTests():

  testServerStatus()

#------------------------------------------------------------------------------------------------------------------------
def testServerStatus():

   print "--- testServerStatus"
   msg = dumps({"cmd": "getServerStatus",
                "status": "request",
                "callback": "displayServerStatus",
                "payload":  ""});

   ws.send(msg)
   result = loads(ws.recv())
   assert(result["status"] == "success")
   assert(result["cmd"]    == "displayServerStatus")
   assert("callback" in result.keys())
   assert("payload" in result.keys())
   assert(result["payload"].keys() == ['serverVersion', 'registeredHandlers', 'currentTime'])
   assert(result["payload"]["registeredHandlers"] >= 1)

#------------------------------------------------------------------------------------------------------------------------
interactive = (sys.argv[0] != "test.py")

if(not(interactive)):
  runTests()

