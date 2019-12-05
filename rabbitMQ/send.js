var rabbit 	= require('./rabbitmq'),
    q 		= 'sample_q';

var msg = process.argv.slice(2).join(' ') || "Hello World!";

(function check_for_conn() {
	if (!process.rabbitMQ) {
		console.log('No process.rabbitMQ');
		setTimeout(check_for_conn, 1000);
	} else {
	var r_ch = process.rabbitMQ.ch;	
		r_ch.assertQueue(q, {durable: true});
		r_ch.sendToQueue(q, new Buffer(msg), {persistent: true});
		return console.log(" [x] Sent 'Hello World!'");
	}
})();
