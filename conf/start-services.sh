#!/bin/sh

echo 'starting services ...'

/etc/init.d/postgresql start
/etc/init.d/oml2-server start
