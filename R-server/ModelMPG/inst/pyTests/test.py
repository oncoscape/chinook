import sys
from websocket import create_connection
from json import *
ws = create_connection("ws://localhost:11002")
#------------------------------------------------------------------------------------------------------------------------
def runTests():

  testServerStatus()
  testGetTable()

    # testCalculate will mature into a linear model with user-selectable independent 
    # variables, but just returns x & y vectors now, with mins, maxes, x & y labels, rownames

  testCalculate()  
                   

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
def testGetTable():

   print "--- testGetTable"

   msg = dumps({     "cmd": "getTable",
                  "status": "request",
                "callback": "displayTable",
                 "payload":  ""});
   
   ws.send(msg)
   result = loads(ws.recv())
   assert(result["status"] == ["success"])
   assert(result["cmd"]    == ["displayTable"])
   assert("callback" in result.keys())
   assert("payload" in result.keys())
   mtx = result["payload"]["mtx"]
     # a 32 row, 12 column matrix
   assert(len(mtx) == 32)
   assert(len(mtx[0]) == 12)
   assert(mtx[0][0] == "Mazda RX4")
   
   colTitles = result["payload"]["cols"]
   assert(len(colTitles) == 12)
   assert(colTitles[0] == " ")
   assert(colTitles[1] == "mpg")
   
#------------------------------------------------------------------------------------------------------------------------
def testCalculate():

   print "--- testCalculate"

   msg = dumps({     "cmd": "calculate",
                  "status": "request",
                "callback": "displayPlot",
                 "payload":  {"x": "disp", "y": "mpg"}});
   
   ws.send(msg)
   result = loads(ws.recv())
   assert(result["status"] == ["success"])
   assert(result["cmd"]    == ["displayPlot"])
   assert("callback" in result.keys())
   assert("payload" in result.keys())
   payload = result["payload"]
   assert(payload.keys() == ['xAxisLabel', 'yMax', 'yAxisLabel', 'xMin', 'rownames', 'xMax', 'y', 'x', 'yMin'])
   assert(payload["xAxisLabel"] == ["disp"])
   assert(payload["yAxisLabel"] == ["mpg"])
   assert(len(payload["x"]) == 32)
   assert(len(payload["y"]) == 32)
   assert(payload["xMax"] == [512.09])
   assert(payload["yMin"] == [10.111])
   assert(len(payload["rownames"]) == 32)
   assert(payload["rownames"][1:3] == ['Mazda RX4 Wag', 'Datsun 710'])
   
#------------------------------------------------------------------------------------------------------------------------
interactive = (sys.argv[0] != "test.py")

if(not(interactive)):
  runTests()

