#!/bin/bash

# Clear out existing resources
curl -X DELETE localhost:8080/rest/objects/
curl -X DELETE localhost:8080/rest/objects/fcr:tombstone
curl -X DELETE localhost:8080/rest/collections/
curl -X DELETE localhost:8080/rest/collections/fcr:tombstone

# The Book

# Create DirectContainer
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/rest/objects/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/rest/objects/raven
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-direct.ttl  localhost:8080/rest/objects/raven/pages/

# Create cover, page0 and page1
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/rest/objects/raven/pages/cover/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/rest/objects/raven/pages/page0/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/rest/objects/raven/pages/page1/

# Cover container and files
curl -i -X PUT   -H "Content-Type: text/turtle"               --data-binary @ldp-cover-direct.ttl localhost:8080/rest/objects/raven/pages/cover/files/
curl -i -X PUT   -H "Content-Type: image/jpeg"                --data-binary @cover.jpg            localhost:8080/rest/objects/raven/pages/cover/files/cover.jpg
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         localhost:8080/rest/objects/raven/pages/cover/files/cover.jpg/fcr:metadata
curl -i -X PUT   -H "Content-Type: image/tiff"                --data-binary @cover.tif            localhost:8080/rest/objects/raven/pages/cover/files/cover.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         localhost:8080/rest/objects/raven/pages/cover/files/cover.tif/fcr:metadata

# Page0 container and files
curl -i -X PUT -H   "Content-Type: text/turtle"               --data-binary @ldp-page0-direct.ttl localhost:8080/rest/objects/raven/pages/page0/files/
curl -i -X PUT -H   "Content-Type: image/jpeg"                --data-binary @page0.jpg            localhost:8080/rest/objects/raven/pages/page0/files/page0.jpg
curl -i -X PUT -H   "Content-Type: image/tiff"                --data-binary @page0.tif            localhost:8080/rest/objects/raven/pages/page0/files/page0.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         localhost:8080/rest/objects/raven/pages/page0/files/page0.jpg/fcr:metadata
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         localhost:8080/rest/objects/raven/pages/page0/files/page0.tif/fcr:metadata

# Page1 container and files
curl -i -X PUT -H   "Content-Type: text/turtle"               --data-binary @ldp-page1-direct.ttl localhost:8080/rest/objects/raven/pages/page1/files/
curl -i -X PUT -H   "Content-Type: image/jpeg"                --data-binary @page0.jpg            localhost:8080/rest/objects/raven/pages/page1/files/page1.jpg
curl -i -X PUT -H   "Content-Type: image/tiff"                --data-binary @page0.tif            localhost:8080/rest/objects/raven/pages/page1/files/page1.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         localhost:8080/rest/objects/raven/pages/page1/files/page1.jpg/fcr:metadata
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         localhost:8080/rest/objects/raven/pages/page1/files/page1.tif/fcr:metadata

# The collection

curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl      localhost:8080/rest/collections/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl      localhost:8080/rest/collections/poe/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-indirect.ttl     localhost:8080/rest/collections/poe/members/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-raven-proxy.ttl localhost:8080/rest/collections/poe/members/ravenProxy

# Proxies for ordering

curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-ordering-direct.ttl localhost:8080/rest/objects/raven/orderProxies/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-cover-proxy.ttl     localhost:8080/rest/objects/raven/orderProxies/coverProxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page0-proxy.ttl     localhost:8080/rest/objects/raven/orderProxies/page0Proxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page1-proxy.ttl     localhost:8080/rest/objects/raven/orderProxies/page1Proxy

# And the actual order
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-cover-proxy.ru localhost:8080/rest/objects/raven/orderProxies/coverProxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page0-proxy.ru localhost:8080/rest/objects/raven/orderProxies/page0Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page1-proxy.ru localhost:8080/rest/objects/raven/orderProxies/page1Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-raven.ru       localhost:8080/rest/objects/raven/


