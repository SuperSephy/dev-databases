#!/bin/bash

vagrant up
node node_modules/db-migrate/bin/db-migrate reset 	--config "./migrations/database.json"
node node_modules/db-migrate/bin/db-migrate up 		  --config "./migrations/database.json"
npm run mongoSeeds
