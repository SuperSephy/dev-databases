'use strict';

let dbm;
let type;
let seed;
const path = require('path');
const fileName = path.parse(__filename).name;

// Data
const collectionName = 'sample';

/**
 * We receive the db-migrate dependency from db-migrate initially.
 * This enables us to not have to rely on NODE_PATH.
 */
exports.setup = (options, seedLink) => {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
};

exports.up = function (db, callback) {
  db.createCollection(collectionName, (err) => {
    if (err) return callback(err);

    console.log('[+] Created Collection: ' + collectionName);
    const records = require(`./queries/${ fileName}-up.js`);

    console.log(`  [i] Inserting [${ records.length ? records.length : 1 }]`);
    db.insert(collectionName, records, callback);
  });
};

exports.down = (db, callback) => {
  console.log(`[-] Dropping collection: [${ collectionName }]`);

  db.dropCollection(collectionName, callback)
};

exports._meta = { version: 1 };
