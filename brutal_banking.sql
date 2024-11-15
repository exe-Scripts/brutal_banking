CREATE TABLE IF NOT EXISTS `brutal_banking_accounts` (
  `account_id` text DEFAULT NULL,
  `identifier` text DEFAULT NULL,
  `pincode` text DEFAULT NULL,
  `accounts` text DEFAULT NULL,
  `partners` text DEFAULT NULL,
  `account_name` text DEFAULT NULL,
  `iban` text DEFAULT NULL,
  `created` text DEFAULT NULL,
  `transactions` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `brutal_banking_sub_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` text DEFAULT NULL,
  `account_name` text DEFAULT NULL,
  `owner` text DEFAULT NULL,
  `owner_name` text DEFAULT NULL,
  `balance` int(50) DEFAULT NULL,
  `created` text DEFAULT NULL,
  `iban` text DEFAULT NULL,
  `permissions` text DEFAULT NULL,
  `transactions` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;