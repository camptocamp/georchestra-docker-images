import xml.etree.ElementTree as ET
import requests
import time
import socket
import os
import stat
import sys

last_mtime = None
file = "/mnt/geoserver_datadir/global.xml"
HTTP_HEADERS={ 'sec-username': 'superadmin', 'sec-roles': 'ROLE_ADMINISTRATOR', 'Accept': 'application/xml' }

def port_opened(ip,port):
   s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   try:
      s.connect((ip, int(port)))
      s.shutdown(2)
      return True
   except:
      return False

def get_update_sequence_from_datadir():
   try:
     tree = ET.parse(file)
     root = tree.getroot()
     return int(root.findall('updateSequence')[0].text)
   except FileNotFoundError as not_found:
     print("File", not_found.filename, "not found")
     return 0

def get_current_update_sequence():
  try:
    ct = requests.get('http://localhost:8080/geoserver/rest/settings',
          headers=HTTP_HEADERS)
    tree = ET.fromstring(ct.content)
    return int(tree.findall('updateSequence')[0].text)
  except Exception as e:
    print("Unable to parse GS REST XML response: {}".format(e))
    return -1

def reload_gs():
  requests.post('http://localhost:8080/geoserver/rest/reload',
        headers=HTTP_HEADERS)

def geofence_needs_cache_invalidation():
    global last_mtime
    current_mtime = None
    try:
        current_mtime = os.stat("/mnt/geoserver_datadir/GEOFENCE_INVALIDATED.lock").st_mtime
    except OSError:
        # File does not exist (yet ?)
        return False
    if (last_mtime is None) or (current_mtime > last_mtime):
        last_mtime = current_mtime
        print("GeoFence cache invalidation detected")
        return True
    return False

def reload_geofence_cache():
      requests.put('http://localhost:8080/geoserver/rest/geofence/ruleCache/invalidate',
            headers=HTTP_HEADERS)

if __name__ == "__main__":
    if not os.path.exists(file):
      print("File", os.path.basename(file), "not found")
      sys.exit(1)
    while True:
      time.sleep(1)
      if not port_opened("127.0.0.1", "8080"):
        time.sleep(30)
        continue
      #if geofence_needs_cache_invalidation():
      #      reload_geofence_cache()
      new_us = get_update_sequence_from_datadir()
      current_us = get_current_update_sequence()
      if current_us == -1:
        continue
      if (new_us > current_us):
          print("GS configuration change detected ({} -> {}), reloading ..."
           .format(current_us, new_us))
          try:
              reload_gs()
              print("GeoServer reloaded (updateSequence {}).".format(new_us))
              current_us = new_us
          except:
              print("Error when reloading GS, updateSequence %d" %  (new_us))
