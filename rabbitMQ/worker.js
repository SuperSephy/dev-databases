var rabbit 	= require('./rabbitmq'),
    q 		= 'sample_q';

(function check_for_conn() {
	if (!process.rabbitMQ) {
		console.log('No process.rabbitMQ');
		setTimeout(check_for_conn, 1000);
	} else {
		console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q);	
		var r_ch = process.rabbitMQ.ch;

		r_ch.assertQueue(q, {durable: true});	// Ensure Queue exists, set to durable so it will persist through crash
		r_ch.prefetch(1);						// Check not already working on something before sending

		// Watch the queue
		r_ch.consume(q, function(msg) {
			console.log(" [x] Received %s", msg.content.toString());

			// Acknowledge message: can also use ch.consumer(q, function, {noAck: true})
			r_ch.ack(msg);
		});
	}
})();
