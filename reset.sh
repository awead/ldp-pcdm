#!/bin/bash

FCREPO=http://localhost:8080/fcrepo/rest

# Clear out existing resources
curl -X DELETE $FCREPO/objects/
curl -X DELETE $FCREPO/objects/fcr:tombstone
curl -X DELETE $FCREPO/collections/
curl -X DELETE $FCREPO/collections/fcr:tombstone
curl -X DELETE $FCREPO/audit/
curl -X DELETE $FCREPO/audit/fcr:tombstone

# Re-create audit container
curl -X PUT $FCREPO/audit/
