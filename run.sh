#!/bin/bash

FCREPO=http://localhost:8080/fcrepo/rest

# Create objects for a book and three pages
curl -i -X PUT -H "Content-Type: text/turtle"                                $FCREPO/objects/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl $FCREPO/objects/raven/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl $FCREPO/objects/cover/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl $FCREPO/objects/page0/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl $FCREPO/objects/page1/

# Make the pages members of the book object with membership proxies
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-membership.ttl  $FCREPO/objects/raven/members/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-cover-proxy.ttl $FCREPO/objects/raven/members/coverProxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page0-proxy.ttl $FCREPO/objects/raven/members/page0Proxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page1-proxy.ttl $FCREPO/objects/raven/members/page1Proxy

# Cover container and files
curl -i -X PUT   -H "Content-Type: text/turtle"               --data-binary @ldp-cover-direct.ttl $FCREPO/objects/cover/files/
curl -i -X PUT   -H "Content-Type: image/jpeg"                --data-binary @cover.jpg            $FCREPO/objects/cover/files/cover.jpg
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         $FCREPO/objects/cover/files/cover.jpg/fcr:metadata
curl -i -X PUT   -H "Content-Type: image/tiff"                --data-binary @cover.tif            $FCREPO/objects/cover/files/cover.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         $FCREPO/objects/cover/files/cover.tif/fcr:metadata

# Page0 container and files
curl -i -X PUT -H   "Content-Type: text/turtle"               --data-binary @ldp-page0-direct.ttl $FCREPO/objects/page0/files/
curl -i -X PUT -H   "Content-Type: image/jpeg"                --data-binary @page0.jpg            $FCREPO/objects/page0/files/page0.jpg
curl -i -X PUT -H   "Content-Type: image/tiff"                --data-binary @page0.tif            $FCREPO/objects/page0/files/page0.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         $FCREPO/objects/page0/files/page0.jpg/fcr:metadata
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         $FCREPO/objects/page0/files/page0.tif/fcr:metadata

# Page1 container and files
curl -i -X PUT -H   "Content-Type: text/turtle"               --data-binary @ldp-page1-direct.ttl $FCREPO/objects/page1/files/
curl -i -X PUT -H   "Content-Type: image/jpeg"                --data-binary @page1.jpg            $FCREPO/objects/page1/files/page1.jpg
curl -i -X PUT -H   "Content-Type: image/tiff"                --data-binary @page1.tif            $FCREPO/objects/page1/files/page1.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         $FCREPO/objects/page1/files/page1.jpg/fcr:metadata
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru         $FCREPO/objects/page1/files/page1.tif/fcr:metadata

# Add a collection and add the book as a member
curl -i -X PUT -H "Content-Type: text/turtle"                                     $FCREPO/collections/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-collection.ttl  $FCREPO/collections/poe/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-indirect.ttl     $FCREPO/collections/poe/members/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-raven-proxy.ttl $FCREPO/collections/poe/members/ravenProxy

# Order the pages within the book
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-cover-proxy.ru $FCREPO/objects/raven/members/coverProxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page0-proxy.ru $FCREPO/objects/raven/members/page0Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page1-proxy.ru $FCREPO/objects/raven/members/page1Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-raven.ru       $FCREPO/objects/raven/

# alternate order (without cover)
curl -i -X PUT   -H "Content-Type: text/turtle"               --data-binary @pcdm-object.ttl            $FCREPO/objects/alternateOrder/
curl -i -X PUT   -H "Content-Type: text/turtle"               --data-binary @ldp-ordering-alternate.ttl $FCREPO/objects/alternateOrder/members/
curl -i -X PUT   -H "Content-Type: text/turtle"               --data-binary @ldp-page0-alternate.ttl    $FCREPO/objects/alternateOrder/members/page0Proxy
curl -i -X PUT   -H "Content-Type: text/turtle"               --data-binary @ldp-page1-alternate.ttl    $FCREPO/objects/alternateOrder/members/page1Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page0-alternate.ru    $FCREPO/objects/alternateOrder/members/page0Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page1-alternate.ru    $FCREPO/objects/alternateOrder/members/page1Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-alternateOrder.ru     $FCREPO/objects/alternateOrder/
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-hasRelatedObject.ru   $FCREPO/objects/raven/
