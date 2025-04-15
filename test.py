import requests
import json

# trackConfig = "Default"
# result = requests.post("http://localhost:8080/addRow", 
#     data=json.dumps({
#         "SessionID" : "currentSession",
#         "LapID" : "currentLap",
#         "LapTime" : 0,
#         "DriverName" : "ac.getDriverName(carID)", 
#         "TrackName" : "ac.getTrackName(carID)", 
#         "TrackConfiguration" : trackConfig, 
#         "CarName" : "ac.getCarName(carID)"
#     }), 
#     headers={"Content-Type": "application/json"}
# )
# print(str(result.content))

# highestSessionID = 0
# result = requests.get("http://localhost:8080/sessions")
# results = str(result.content)[3:-5].replace("\\", "").split('},')
# decoder = json.JSONDecoder()
# for x in results:
#     content = decoder.decode(str(x) + "}")
#     highestSessionID = max(content["SessionID"], highestSessionID)

# print(highestSessionID)