-- entities
INSERT INTO public.guacamole_entity (entity_id, name, type)
VALUES (1000, 'tigers', 'USER'),
       (1001, 'erforce', 'USER');

-- connection groups
INSERT INTO public.guacamole_connection_group (connection_group_id, parent_id, connection_group_name, type,
                                               max_connections, max_connections_per_user, enable_session_affinity)
VALUES (1000, null, 'viewers', 'ORGANIZATIONAL', null, null, false);


-- permissions
INSERT INTO public.guacamole_connection_group_permission (entity_id, connection_group_id, permission)
VALUES (1, 1000, 'READ'),
       (1000, 1000, 'READ'),
       (1001, 1000, 'READ');

INSERT INTO public.guacamole_user (user_id, entity_id, password_hash, password_salt, password_date, disabled, expired,
                                   access_window_start, access_window_end, valid_from, valid_until, timezone, full_name,
                                   email_address, organization, organizational_role)
VALUES (1000, 1000, E'\\xA7250C0F947D7A7CFC7D9E625EF953124E2E910D9130D5FE63D9D3902330334C',
        E'\\xD98335FDB1AD9B496B162030A387A6691508381C23201C26ED454846C7EC54A3', '2021-01-31 09:57:28.627000', false,
        false, null, null, null, null, null, 'TIGERs Mannheim', null, null, null),
       (1001, 1001, E'\\x648A9339C5D5D663D82CAA9233D8ECEAE870C3945ABAE8AED094A9D62BC877A0',
        E'\\x4058FD9AE01E9D1AD49DF2AF294B214EC6DDF79F295685F5A70537E3CB63BF9E', '2021-01-31 09:57:28.627000', false,
        false, null, null, null, null, null, 'ER-Force', null, null, null);

INSERT INTO public.guacamole_user_permission (entity_id, affected_user_id, permission)
VALUES (1000, 1000, 'READ'),
       (1000, 1000, 'UPDATE'),
       (1001, 1001, 'READ'),
       (1001, 1001, 'UPDATE');


-- connections
INSERT INTO guacamole_connection (connection_id, connection_name, parent_id, protocol, max_connections,
                                  max_connections_per_user, connection_weight, failover_only, proxy_port,
                                  proxy_hostname, proxy_encryption_method)
VALUES (1000, 'tigers', null, 'vnc', 10, null, null, false, null, null, null),
       (1100, 'tigers-read-only', 1000, 'vnc', 100, null, null, false, null, null, null),
       (1001, 'erforce', null, 'vnc', 10, null, null, false, null, null, null),
       (1101, 'erforce-read-only', 1000, 'vnc', 100, null, null, false, null, null, null);


INSERT INTO public.guacamole_connection_parameter (connection_id, parameter_name, parameter_value)
VALUES (1000, 'hostname', 'tigers'),
       (1000, 'password', 'vncpassword'),
       (1000, 'port', '5901'),
       (1100, 'hostname', 'tigers'),
       (1100, 'password', 'vncpassword'),
       (1100, 'port', '5901'),
       (1100, 'read-only', 'true'),
       (1001, 'hostname', 'erforce'),
       (1001, 'password', 'vncpassword'),
       (1001, 'port', '5901'),
       (1101, 'hostname', 'erforce'),
       (1101, 'password', 'vncpassword'),
       (1101, 'port', '5901'),
       (1101, 'read-only', 'true'),
       (1000, 'sftp-username', 'default'),
       (1000, 'enable-sftp', 'true'),
       (1001, 'sftp-username', 'default'),
       (1001, 'enable-sftp', 'true'),
       (1000, 'sftp-root-directory', '/home/default'),
       (1001, 'sftp-root-directory', '/home/default'),
       (1000, 'sftp-private-key', '-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----'),
       (1001, 'sftp-private-key', '-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----');

INSERT INTO public.guacamole_connection_permission (entity_id, connection_id, permission)
VALUES (1, 1000, 'READ'),
       (1, 1000, 'UPDATE'),
       (1, 1000, 'DELETE'),
       (1, 1000, 'ADMINISTER'),
       (1, 1100, 'READ'),
       (1, 1100, 'UPDATE'),
       (1, 1100, 'DELETE'),
       (1, 1100, 'ADMINISTER'),
       (1, 1001, 'READ'),
       (1, 1001, 'UPDATE'),
       (1, 1001, 'DELETE'),
       (1, 1001, 'ADMINISTER'),
       (1, 1101, 'READ'),
       (1, 1101, 'UPDATE'),
       (1, 1101, 'DELETE'),
       (1, 1101, 'ADMINISTER'),
       (1000, 1000, 'READ'), -- tigers
       (1000, 1100, 'READ'), -- tigers read only tigers
       (1000, 1101, 'READ'), -- tigers read only erforce
       (1001, 1001, 'READ'), -- erforce
       (1001, 1100, 'READ'), -- erforce read only tigers
       (1001, 1101, 'READ'); -- erforce read only erforce



