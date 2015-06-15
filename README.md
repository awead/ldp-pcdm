# LDP-PCDM

This is a walkthrough of [LDP-PCDM-F4 In Action](https://wiki.duraspace.org/display/FEDORA4x/LDP-PCDM-F4+In+Action).  It uses the [Fedora 4 Vagrant VM](https://github.com/fcrepo4-labs/fcrepo4-vagrant).


# Book

### Book - Create DirectContainer
 
First, create the top-level "objects/" ldp:BasicContainer.

```sh
curl -i -X PUT -H "Content-Type: text/turtle" localhost:8080/fcrepo/rest/objects/
```

Second, create the nested "raven/" pcdm:Object, which is also another ldp:BasicContainer.

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/fcrepo/rest/objects/raven/
```

Then create pcdm:Objects for each of three pages (the cover, page0 and page1):

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/fcrepo/rest/objects/cover/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/fcrepo/rest/objects/page0/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/fcrepo/rest/objects/page1/
```

To make the pages members of the book, create an ldp:IndirectContainer, "members/" that will facilitate the establishment of relationships between "raven/" and its constituent pages.

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-membership.ttl localhost:8080/fcrepo/rest/objects/raven/members/
```

An ldp:IndirectContaner is an LDP construct that activates the creation of certain RDF triples when a new resource is added as a child of this container.  Specifically, when a new resource is added inside of the "pages/" IndirectContainer, a new triple on the ldp:membershipResource ("raven/") will be created with the predicate defined by the ldp:hasMemberRelation property ("pcdm:hasMember") and an object that is a reference to the new resource.  The auto-created triple resulting from the addition of a new child resource within "pages/" will take the form:

```
<http://localhost:8080/fcrepo/rest/objects/raven/> <pcdm:hasMember> <new-resource>
```

We use the IndirectContainer "raven/members/" to link the pages to the book:

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-cover-proxy.ttl localhost:8080/fcrepo/rest/objects/raven/members/coverProxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page0-proxy.ttl localhost:8080/fcrepo/rest/objects/raven/members/page0Proxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page1-proxy.ttl localhost:8080/fcrepo/rest/objects/raven/members/page1Proxy
```

### Cover - Create DirectContainer
In the same way that we used an ldp:DirectContainer to facilitate the auto-generation of triples linking "raven/" to each of the pages, now use the same pattern to auto-generate the creation of triples that link each page pcdm:Object to their various file representations.
 
To begin with, create an ldp:DirectContainer, "files/", which is also a pcdm:Object, as a child of "cover/" as follows:

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-cover-direct.ttl localhost:8080/fcrepo/rest/objects/cover/files/
```

Now, any new resource that is added as a child of the DirectContainer "files/" will cause the auto-generation of a new triple on "cover/" that has a predicate of pcdm:hasFile and an object of the new resource.

### Cover - Create Files
Once again, we demonstrate the use of LDP in creating PCDM relationships simply as a result of repository interactions.
 
Add two pcdm:File resources to the DirectContainer, "files/" as follows:

```sh
curl -i -X PUT -H "Content-Type: image/jpeg" --data-binary @cover.jpg localhost:8080/fcrepo/rest/objects/cover/files/cover.jpg
```

If you perform a subsequent HTTP HEAD on this new resource, you will see there is a "Link" header of rel="describedby". Update the RDF metadata of the ldp:NonRdfSource to specify that the resource is a pcdm:File, as follows:

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru localhost:8080/fcrepo/rest/objects/cover/files/cover.jpg/fcr:metadata
```

Repeat for the attached TIFF, cover.tif

```sh
curl -i -X PUT -H "Content-Type: image/tiff" --data-binary @cover.tif localhost:8080/fcrepo/rest/objects/cover/files/cover.tif
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru localhost:8080/fcrepo/rest/objects/cover/files/cover.tif/fcr:metadata
```

After creating the two "cover" resources, an HTTP GET on "cover/" will include the two new triples:
```
<http://localhost:8080/fcrepo/rest/objects/cover/> pcdm:hasFile <http://localhost:8080/fcrepo/rest/objects/cover/files/cover.jpg> 
<http://localhost:8080/fcrepo/rest/objects/cover/> pcdm:hasFile <http://localhost:8080/fcrepo/rest/objects/cover/files/cover.tif>
```
Once again,
* the subject of the triple comes from the "ldp:membershipResource" defined on "files/"
* the predicate of the triple comes from the "ldp:hasMemberRelation" defined on "files/", and
* the object of the triple is the new resource ("cover.jpg" or "cover.tif") that was added to the ldp:DirectContainer ("files/")

### Page0 - Create DirectContainer
Here we repeat the exact steps as for the "cover/" above, but for "page0/".

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page0-direct.ttl localhost:8080/fcrepo/rest/objects/page0/files/
```

### Page0 - Create Files
Here we add the attached page0 files (page0.jpg and page0.tif) to the newly created DirectContainer. 

```sh
curl -i -X PUT -H "Content-Type: image/jpeg" --data-binary @page0.jpg localhost:8080/fcrepo/rest/objects/page0/files/page0.jpg
curl -i -X PUT -H "Content-Type: image/tiff" --data-binary @page0.tif localhost:8080/fcrepo/rest/objects/page0/files/page0.tif
```

Followed by assigning the type of pcdm:File to the respective RDF Sources found in the "Link; rel=describedby" header of each of the ldp:NonRdfSources.

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru localhost:8080/fcrepo/rest/objects/page0/files/page0.jpg/fcr:metadata
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru localhost:8080/fcrepo/rest/objects/page0/files/page0.tif/fcr:metadata
```

### Page1 - Create DirectContainer
Here we repeat the exact steps as for the "page0/" above, but for "page1/".

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page1-direct.ttl localhost:8080/fcrepo/rest/objects/page1/files/
```

### Page1 - Create Files
Finally, we add the attached page1 files (page1.jpg and page1.tif) to the newly created DirectContainer. 

```sh
curl -i -X PUT -H "Content-Type: image/jpeg" --data-binary @page1.jpg localhost:8080/fcrepo/rest/objects/page1/files/page1.jpg
curl -i -X PUT -H "Content-Type: image/tiff" --data-binary @page1.tif localhost:8080/fcrepo/rest/objects/page1/files/page1.tif
```

Followed by assigning the type of pcdm:File to the respective RDF Sources found in the "Link; rel=describedby" header of each of the ldp:NonRdfSources.

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru localhost:8080/fcrepo/rest/objects/page1/files/page1.jpg/fcr:metadata
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-file.ru localhost:8080/fcrepo/rest/objects/page1/files/page1.tif/fcr:metadata
```

### Book - Conclusion
Using LDP in conjunction with PCDM terms, we have created a book, "raven/", with its constituent pages and their file representations.

# Collection

Continuing with the previous example of modeling and creating a book with LDP, PCDM and F4, here we will detail an approach for adding that book, "raven/" to a new collection, "poe/".

The objective in this section is to leverage LDP interaction models to not only create the appropriate pcdm:hasMember relationship between the collection "poe/" and the book "raven/", but to put the LDP structure in place for a simplified addition of new items to the "poe/" collection.

### Collection - Create IndirectContainer
Here we will begin to walk through the mechanics of creating the structures that will facilitate creation of the collection and its single member, in this case.

First, create the top-level "collections/" pcdm:Object, which is also an ldp:BasicContainer.

```sh
curl -i -X PUT -H "Content-Type: text/turtle" localhost:8080/fcrepo/rest/collections/
```

Second, create the nested "poe/" pcdm:Object, which is also another ldp:BasicContainer.

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-collection.ttl localhost:8080/fcrepo/rest/collections/poe/
```

Lastly, create an ldp:IndirectContainer, "members/" that will facilitate the establishment of relationships between "poe/" and the collection members.

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-indirect.ttl localhost:8080/fcrepo/rest/collections/poe/members/
```

Similar to the previously described ldp:DirectContainer, an ldp:IndirectContainer is an LDP construct that also activates the creation of certain RDF triples when a new resource is added as a child of this container.  Just like with a DirectContainer, when a new resource is added inside of the "members/" IndirectContainer, a new triple on the ldp:membershipResource ("poe/") will be created with the predicate defined by the ldp:hasMemberRelation property ("pcdm:hasMember").  However, the difference from a DirectContainer is that the object of the created triple is not the newly added child, but instead the resource defined by the ldp:insertedContentRelation property (ore:proxyFor, in this case) found on the newly added child of this container.

### Collection - Create Raven Proxy
Create a new pcdm:Object, "ravenProxy/", that is an ldp:RdfSource within the "members/" IndirectContainer.
 
```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-raven-proxy.ttl localhost:8080/fcrepo/rest/collections/poe/members/ravenProxy
```

As mentioned in the previous step, the addition of "ravenProxy/" automatically creates the following new triple on "poe/".
```
<http://localhost:8080/fcrepo/rest/collections/poe/> pcdm:hasMember <http://localhost:8080/fcrepo/rest/objects/raven/>
```

The ldp:IndirectContainer defines the creation of this triple as follows:
* the subject of the triple comes from the "ldp:membershipResource" defined on "members/"
* the predicate of the triple comes from the "ldp:hasMemberRelation" defined on "members/", and
* the object of the triple is the resource defined by the ldp:insertedContentRelation property (ore:proxyFor) found on the newly added child resource, "ravenProxy".

### Collection - Conclusion
Using LDP in conjunction with PCDM terms, we have created a collection, "poe/", with its single member, "raven/".
Ordering In Action

# Ordering
This final example will both illustrate a second use of ldp:DirectContainers as well as detail the PCDM recommendation for how to handle ordering of resources.  The addtional predicates/relationships that will be used in this example are:
* ore:proxyIn
* ore:proxyFor
* iana:first
* iana:next
* iana:prev
* iana:last

...all of which are further described in the Portland Common Data Model.

### Ordering - Create Next and Prev
To order the member pages within the book object, we can add triples to the membership proxies, per the PCDM recommendations.  First, establish the order among the proxies with iana:next and iana:prev.

1) Establish "coverProxy" has iana:next of "page0Proxy":

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-cover-proxy.ru localhost:8080/fcrepo/rest/objects/raven/members/coverProxy
```

2) Establish both:
* "page0Proxy" has iana:prev of "coverProxy", and
* "page0Proxy" has iana:next of "page1Proxy":

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page0-proxy.ru localhost:8080/fcrepo/rest/objects/raven/members/page0Proxy
```

3) Establish "page1Proxy" has iana:prev of "page0Proxy":

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page1-proxy.ru localhost:8080/fcrepo/rest/objects/raven/members/page1Proxy
```

### Ordering - Create First and Last
Finally, the very last step is to define from the book's perspective, the iana:first and iana:last pages of "raven/".

Establish both:
* "raven/" has iana:first of "coverProxy", and
* "raven/" has iana:last of "page1Proxy":

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-raven.ru localhost:8080/fcrepo/rest/objects/raven/
```

## Alternate Orders

To create an alternate order of the same objects, we can create a separate pcdm:Object called "objects/alternateOrder" to express the different order.  In this case,
we'll create an alternate order that omits the cover.

### Alternate Ordering - Create alternateOrder object

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @pcdm-object.ttl localhost:8080/fcrepo/rest/objects/alternateOrder/
```

### Alternate Ordering - Create membership container and proxies

```sh
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-ordering-alternate.ttl localhost:8080/fcrepo/rest/objects/alternateOrder/members/
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page0-alternate.ttl localhost:8080/fcrepo/rest/objects/alternateOrder/members/page0Proxy
curl -i -X PUT -H "Content-Type: text/turtle" --data-binary @ldp-page1-alternate.ttl localhost:8080/fcrepo/rest/objects/alternateOrder/members/page1Proxy
```

### Alternate Ordering - Create iana:next and iana:prev relationships

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page0-alternate.ru localhost:8080/fcrepo/rest/objects/alternateOrder/members/page0Proxy
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-page1-alternate.ru localhost:8080/fcrepo/rest/objects/alternateOrder/members/page1Proxy
```

### Alternate Ordering - Establish first and last members

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @iana-alternateOrder.ru localhost:8080/fcrepo/rest/objects/alternateOrder/
```

### Alternate Ordering - Relate the alternate order to the original pcdm:Object

```sh
curl -i -X PATCH -H "Content-Type: application/sparql-update" --data-binary @pcdm-hasRelatedObject.ru localhost:8080/fcrepo/rest/objects/raven/
```

### Ordering - Conclusion
Using LDP in conjunction with PCDM terms, we have established the ordering of pages within the book, "raven/", and also created an alternate order that omits the cover.
