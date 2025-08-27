# About

This image contains a python runtime along with python-requests, and a
synchronization script.  It is meant to be used along with the
[geoserver-lb](https://github.com/camptocamp/charts-gs/tree/main/geoserver-lb)
helm chart.

The script runs as a sidecar and tracks changes in the geoserver configuration
(the "Geoserver datadir"), and triggers a HTTP request to the GeoServer so that
the configuration is reloaded. If geofence needs a cache invalidation, - when
geofence is activated - the script can detect it as well and proceed.

