-- Author: Ross Boxall --

/**
 * Table structure for table `sample`
 */
CREATE TABLE `sample` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(60) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

/**
 * Seeds for `sample` table
 */
INSERT INTO `sample` (`id`, `name`, `email`, `password`)
VALUES
	(1, 'Local Development Test', 'test@email.com', 'testPassword1');
