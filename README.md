Database
--------



BlueprintManager
----------------

constructor (@db) ->

get (extension, name) ->


Blueprint
---------

constructor (@manager)

find (options, callback)

create (data)

save (item)

destroy (item)

db ->
  @bluprints.db


BlueprintItem
-------------

The data container will get the dynamic get/set based on the properties of the
blueprint.

The item will also get functions for lazy loading relationships, and will get a
dynamic method for each relationship that will return an item or collection
based on the relationship type.

constructor (@blueprint) ->

Save will be a proxy to `@blueprint.save @`.

save ->

Destroy will be a proxy to `@blueprint.destroy @`

destroy ->

get (key) ->

set (key, value) ->

Returns the data that defines this item.

data ->

json ->

BlueprintCollection
-------------------
