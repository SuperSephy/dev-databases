'use strict';

let dbm;
let type;
let seed;
let Promise;
const fs = require('fs');
const path = require('path');
const fileName = path.parse(__filename).name;

/**
 * We receive the db-migrate dependency from db-migrate initially.
 * This enables us to not have to rely on NODE_PATH.
 */
exports.setup = (options, seedLink) => {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
  Promise = options.Promise;
};

exports.up = (db) => runQuery(db, 'up');
exports.down = (db) => runQuery(db, 'down');

function runQuery(db, type) {
  const filePath = path.join(__dirname, 'sqls', `${ fileName }-${ type }.sql`);
  return new Promise(( resolve, reject ) => {
    fs.readFile(filePath, {encoding: 'utf-8'}, (err,data) => {
      if (err) return reject(err);
      console.log('received data: ' + data);

      resolve(data);
    });
  }).then(data => db.runSql(data));
}

exports._meta = { version: 1 };
