MongoDB has an operator helm chart that can be used in K8s. And it's quite easy
to define a `MongoDBCommunity` object.

# CLI
```sh
# Authenticate into the engine
mongosh --authenticationDatabase admin --username user --password paSSw0rd  --eval "show dbs"
mongosh "mongodb://user:password@127.0.0.1:7429/?authSource=admin" --eval "show dbs"

# Basic queries
show dbs;
use MyDatabase;
show collections;

# Show number of objects(rows) in a collection(table)
db = db.getSiblingDB('MyDatabase'); db.getCollection('myCollection').find().count();

# Count objects created after a given date
db.getCollection('myCollection').find({"create_time": { $gt: ISODate("2025-07-14 00:00:00.000Z") }}).count();

# First and last object in a collection
db.getCollection("myCollection").find().sort({ _id: 1 }).limit(1)
db.getCollection("myCollection").find().sort({ _id: -1 }).limit(1)
```
