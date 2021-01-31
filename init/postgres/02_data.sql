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
       (1101, 'read-only', 'true');

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



