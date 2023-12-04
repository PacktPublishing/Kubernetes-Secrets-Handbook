#!/bin/sh

cat haproxy.cfg | sed "s/port/$port/" > haproxy.cfg.tmp

apk add haproxy

haproxy -f ./haproxy.cfg.tmp