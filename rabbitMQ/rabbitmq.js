
// Bring env variable and amqplib into the app 
var env			= process.env.NODE_ENV || 'local',
	log 		= require('debug')('rabbitMQ');

var rabbit_url = 'amqp://root:root@33.33.33.10/';

// =========================
// RabbitMQ Connection =====
// =========================

// If new connection
if (!process.RabbitMQ) {
	require('amqplib/callback_api')
		.connect(rabbit_url, function(err, conn) {
			if (err) return log('AMQP Error: '+ err);
			log('AMQP connected!');

			// On App Close
			process.once('SIGINT', function() { conn.close(); });

			conn.createChannel(function(err, ch) {
				if (err) return log('AMQP Channel Error: '+ err);
				log('AMQP channel connected!');

				// Add to process
				process.rabbitMQ = { conn, ch };
				
				// Return to caller
				module.exports = { conn, ch };
			});

		});

// Return connection details
} else {
	return process.rabbitMQ
}