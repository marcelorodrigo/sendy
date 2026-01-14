<?php 
	//----------------------------------------------------------------------------------//	
	//                               COMPULSORY SETTINGS
	//----------------------------------------------------------------------------------//
	
	/*  Set the URL to your Sendy installation (without the trailing slash) */
	define('APP_PATH', getenv('SENDY_URL') ?: 'http://localhost');
	
	/*  MySQL database connection credentials (please place values between the apostrophes) */
	$dbHost = getenv('MYSQL_HOST') ?: 'mysql'; //MySQL Hostname
	$dbUser = getenv('MYSQL_USER') ?: ''; //MySQL Username
	$dbPass = getenv('MYSQL_PASSWORD') ?: ''; //MySQL Password
	$dbName = getenv('MYSQL_DATABASE') ?: 'sendy'; //MySQL Database Name
	
	
	//----------------------------------------------------------------------------------//	
	//								  OPTIONAL SETTINGS
	//----------------------------------------------------------------------------------//	
	
	/* 
		Change the database character set to something that supports the language you'll
		be using. Example, set this to utf16 if you use Chinese or Vietnamese characters
	*/
	$charset = getenv('MYSQL_CHARSET') ?: 'utf8mb4';
	
	/*  Set this if you use a non standard MySQL port.  */
	$dbPort = (int)(getenv('MYSQL_PORT') ?: 3306);	
	
	/*  Domain of cookie (99.99% chance you don't need to edit this at all)  */
	define('COOKIE_DOMAIN', getenv('SENDY_COOKIE_DOMAIN') ?: '');
	
	//----------------------------------------------------------------------------------//
?> 
