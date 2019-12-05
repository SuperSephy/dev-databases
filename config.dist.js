module.exports = {
    dev: {
        mongo: {
            host	 : 	'33.33.33.10',
            port	 : 	27017,
            user	 : 	'root',
            password : 	'root',
            database : 	'admin',
            schemas	 : []
        },
        mysql: {
            host     : '33.33.33.10',
            user     : 'root',
            password : 'root',
            database : 'LocalData'
        },
    },
    prod: {
        mongo: {
            host	 : 	'',
            port	 : 	27017,
            user	 : 	'',
            password : 	'',
            database : 	'',
            schemas	 : []
        },
        mysql: {
            host     : '',
            user     : '',
            password : '',
            database : ''
        },
    },
};