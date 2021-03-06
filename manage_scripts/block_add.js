"use strict";

const argv = require('minimist')(process.argv.slice(2));

if (!argv.height) {
	console.error("Please specify block height");
	process.exit(1);
}
const height = argv.height;

if (!argv.body) {
	console.error("Please specify block body");
	process.exit(1);
}
const body = argv.body;
let body2;

try { body2 = JSON.parse(body); } catch(e) {
	console.error("Can't parse block body: " + body);
	process.exit(1);
}

require("../init_mini.js").init(function() {
	const body3 = {
		"hash":       body2.hash,
		"difficulty": body2.difficulty,
		"shares":     body2.shares,
		"timestamp":  body2.timestamp,
		"poolType":   body2.poolType,
		"unlocked":   body2.unlocked,
		"valid":      body2.valid,
		"value":      body2.value
	};
	if (typeof (body3.hash) === 'undefined' ||
	    typeof (body3.difficulty) === 'undefined' ||
	    typeof (body3.shares) === 'undefined' ||
	    typeof (body3.timestamp) === 'undefined' ||
	    typeof (body3.poolType) === 'undefined' ||
	    typeof (body3.unlocked) === 'undefined' ||
	    typeof (body3.valid) === 'undefined' ||
	    typeof (body3.value) === 'undefined') {
		console.error("Block body is invalid: " + JSON.stringify(body3));
		process.exit(1);
        }
	const body4 = global.protos.Block.encode(body3);
        let txn = global.database.env.beginTxn();
	txn.putBinary(global.database.blockDB, height, body4);
        txn.commit();
	console.log("Block on " + height + " height added! Exiting!");
	process.exit(0);
});
