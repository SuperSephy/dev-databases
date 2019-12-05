"use strict";

// Support Libraries
const
	config 	= require('../migrations/database'),
	moment 	= require('moment'),
	mysql 	= require('mysql'),
	stream 	= require('stream');

// Set Up Variables
const
	tableToMigrate 	= process.env.TABLE,
	limit 			= process.env.LIMIT;

// Sanity Checks
if (!tableToMigrate) {
	console.error(`\n[x] Missing TABLE input: please run using command like "TABLE=table_name node lib/seedLocalWithProdTableMySQL.js"\n`);
	return process.exit(1);
}
if (!limit) {
	console.info(`[i] No limit detected, will copy the whole table`);
}

let started = moment();
console.log(`[i] Started application at ${started.format("M/D/YYYY, h:mm:ss a")}`);

// Open connections
console.log(`\n [i] Connecting to DBs`);
let localMySQL = mysql.createConnection(config.dev.mysql);
let prodMySQL = mysql.createConnection(config.prod.mysql);
localMySQL.connect();
prodMySQL.connect();

// error handling
localMySQL.on('error', errHandler);
prodMySQL.on('error', errHandler);

function errHandler(err) {
	localMySQL.end();
	prodMySQL.end();

	console.log('err', err);
	process.exit(1);
}

/**
 * 1. TRUNCATE current local table
 * 2. GET data from prod table
 * 3. Stream to local table (speed seems to be about 1k/s, be aware how this may affect production)
 */

// 1
localMySQL.query(`TRUNCATE ${tableToMigrate}`, err => {
	if (err)
		return errHandler(`Unable to truncate ${tableToMigrate}`);

	console.log(`\nEmptied ${tableToMigrate} - beginning copy ${limit ? `of ${limit} records` : ''} \n`);

	let insertStream = new stream.Writable({highWaterMark: 100, objectMode: true});

	// 2
	prodMySQL
		.query(`SELECT * FROM ${tableToMigrate}`)
		.on('error', errHandler)
		.stream({highWaterMark: 100})
		.pipe(insertStream)
		.on('error', errHandler)
		.on('finish', completedTask);

	// 3
	insertStream._write = (row, encoding, cb) => {
		console.log(`Reading id: ${row.id} `);

		localMySQL.query(`INSERT INTO ${tableToMigrate} SET ? ${limit ? `LIMIT ${limit}` : ''}`, row, err => {
			if (err) return cb(err);

			console.log(`  [i] Inserted ${row.id}`);
			cb();
		});
	};
});

function completedTask() {
	localMySQL.end();
	prodMySQL.end();

	let finished = moment();
	console.log(`Finished at ${finished.format("M/D/YYYY, h:mm:ss a")} after ${finished.diff(started, 's', true)}s`);
}


