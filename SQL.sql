CREATE TABLE `consignment` (
    `citizenid` text  NULL,
  `item` text  NOT NULL,
  `shop` text  NOT NULL,
  `price` text  NOT NULL,
  `amount` text NOT NULL,
  `timer` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

ALTER TABLE `players` ADD COLUMN `consignment` VARCHAR(255) NULL DEFAULT '0';