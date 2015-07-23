-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.

--;
-- Schema upgrade from 4.9.2.0 to 4.10.0.0;
--;

ALTER TABLE `cloud`.`domain_router` ADD COLUMN  update_state varchar(64) DEFAULT NULL;

INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (257, UUID(), 6, 'Windows 10 (32-bit)', now());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (258, UUID(), 6, 'Windows 10 (64-bit)', now());
INSERT IGNORE INTO `cloud`.`guest_os` (id, uuid, category_id, display_name, created) VALUES (259, UUID(), 6, 'Windows Server 2012 (64-bit)', now());

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, uuid, created) VALUES ('Xenserver', '6.5.0', 'Windows 10 (32-bit)', 257, UUID(), now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, uuid, created) VALUES ('Xenserver', '6.5.0', 'Windows 10 (64-bit)', 258, UUID(), now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, uuid, created) VALUES ('Xenserver', '6.5.0', 'Windows Server 2012 (64-bit)', 259, UUID(), now());

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'windows9Guest', 257, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'windows9_64Guest', 258, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'VMware', '6.0', 'windows9Server64Guest', 259, now());

INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Windows 10', 257, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Windows 10', 258, now());
INSERT IGNORE INTO `cloud`.`guest_os_hypervisor` (uuid, hypervisor_type, hypervisor_version, guest_os_name, guest_os_id, created) VALUES (UUID(), 'KVM', 'default', 'Windows Server 2012', 259, now());

CREATE TABLE `cloud`.`vlan_details` (
  `id` bigint unsigned NOT NULL auto_increment,
  `vlan_id` bigint unsigned NOT NULL COMMENT 'vlan id',
  `name` varchar(255) NOT NULL,
  `value` varchar(1024) NOT NULL,
  `display` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Should detail be displayed to the end user',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_vlan_details__vlan_id` FOREIGN KEY `fk_vlan_details__vlan_id`(`vlan_id`) REFERENCES `vlan`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`network_offerings` ADD COLUMN supports_public_access boolean default false;

ALTER TABLE `cloud`.`image_store_details` CHANGE COLUMN `value` `value` VARCHAR(255) NULL DEFAULT NULL COMMENT 'value of the detail', ADD COLUMN `display` tinyint(1) NOT
NULL DEFAULT '1' COMMENT 'True if the detail can be displayed to the end user' AFTER `value`;

ALTER TABLE `snapshots` ADD COLUMN `location_type` VARCHAR(32) COMMENT 'Location of snapshot (ex. Primary)';

DROP TABLE IF EXISTS `cloud`.`netscaler_servicepackages`;
CREATE TABLE `cloud`.`netscaler_servicepackages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uuid` varchar(255) UNIQUE,
  `name` varchar(255) UNIQUE COMMENT 'name of the service package',
  `description` varchar(255) COMMENT 'description of the service package',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `cloud`.`external_netscaler_controlcenter`;
CREATE TABLE `cloud`.`external_netscaler_controlcenter` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `uuid` varchar(255) UNIQUE,
  `username` varchar(255) COMMENT 'username of the NCC',
  `password` varchar(255) COMMENT 'password of NCC',
  `host_id` bigint unsigned NOT NULL COMMENT 'host id coresponding to the external load balancer device',
  `ncc_ip` varchar(255) COMMENT 'IP of NCC Manager',
  `num_retries` bigint unsigned NOT NULL default 2 COMMENT 'Number of retries in ncc for command failure',
  PRIMARY KEY  (`id`),
  CONSTRAINT `fk_external_ncc_devices_host_id` FOREIGN KEY (`host_id`) REFERENCES `host`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`network_offerings` ADD COLUMN `service_package_id` varchar(255) NULL default NULL COMMENT 'Netscaler ControlCenter Service Package';
ALTER TABLE `network_offerings` ADD CONSTRAINT `fk_netscaler_service_package_id` FOREIGN KEY (`service_package_id`) REFERENCES `netscaler_servicepackages` (`uuid`);