#!/usr/bin/env python3

import json
import os
import secrets
import string

from GuacamoleClient import GuacamoleClient

guacamoleAdminUser = "guacadmin"
guacamoleAdminStandardPassword = "guacadmin"
script_dir = os.path.dirname(__file__)
config_dir = script_dir + "/.."
env_file = config_dir + "/../.env"
ssh_key_location = config_dir + "/vnc_rsa"
teams_file = config_dir + "/teams"
passwords_file = config_dir + "/passwords"
root_domain_file = config_dir + "/root_domain"
fields_file = config_dir + "/fields"
verify_certificate = True


def load_root_domain():
    with open(root_domain_file) as file:
        return file.read().strip()


def load_fields():
    with open(fields_file) as file:
        return [line.replace("\n", "") for line in file.readlines()]


def load_guacamole_private_ssh_key():
    with open(ssh_key_location, 'r') as file:
        return file.read()


def load_teams():
    with open(teams_file) as file:
        return [line.replace("\n", "") for line in file.readlines()]


def load_env():
    with open(env_file, "r") as file:
        lines = file.readlines()
        env_map = {}
        for line in lines:
            parts = line.replace("\n", "").split("=", 1)
            if len(parts) == 2:
                env_map[parts[0]] = parts[1]
        return env_map


def generate_password():
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(32))


def load_passwords():
    if not os.path.isfile(passwords_file):
        return {}
    with open(passwords_file) as file:
        lines = file.readlines()
        password_map = {}
        for line in lines:
            parts = line.replace("\n", "").split(":")
            if len(parts) == 2:
                password_map[parts[0]] = parts[1]
        return password_map


def save_passwords(passwords):
    with open(passwords_file, "w") as file:
        for user, password in passwords.items():
            file.write(f"{user}:{password}\n")


def default_connection():
    with open(script_dir + "/vnc-connection.json", "r") as file:
        return json.load(file)


def init_field(field_id):
    root_domain = load_root_domain()

    client = GuacamoleClient(f'https://vnc.{field_id}.{root_domain}/guacamole')
    client.verify_certificate = verify_certificate
    if root_domain == "localhost":
        client.verify_certificate = False
    teams = load_teams()
    ssh_private_key = load_guacamole_private_ssh_key()
    passwords = load_passwords()
    if guacamoleAdminUser not in passwords:
        client.retrieve_auth_token(guacamoleAdminUser, guacamoleAdminStandardPassword)
        new_password = generate_password()
        print("New admin password: " + new_password)
        client.update_user_password(guacamoleAdminUser, guacamoleAdminStandardPassword, new_password)
        passwords[guacamoleAdminUser] = new_password

    save_passwords(passwords)
    client.retrieve_auth_token(guacamoleAdminUser, passwords[guacamoleAdminUser])
    client.retrieve_connections()
    client.retrieve_connection_groups()

    viewer_group = "viewers"
    client.upsert_user_group(viewer_group)

    env_map = load_env()
    vnc_password = env_map["VNC_PW"]

    auto_ref_conn_tigers = default_connection()
    auto_ref_conn_tigers["name"] = "autoref-tigers"
    auto_ref_conn_tigers["parameters"]["port"] = "5900"
    auto_ref_conn_tigers["parameters"]["password"] = vnc_password
    auto_ref_conn_tigers["parameters"]["hostname"] = "autoref-tigers"
    client.upsert_connection(auto_ref_conn_tigers)
    auto_ref_conn_tigers["name"] = "autoref-tigers-view"
    auto_ref_conn_tigers["parameters"]["read-only"] = "true"
    client.upsert_connection(auto_ref_conn_tigers)

    auto_ref_conn_erforce = default_connection()
    auto_ref_conn_erforce["name"] = "autoref-erforce"
    auto_ref_conn_erforce["parameters"]["port"] = "5900"
    auto_ref_conn_erforce["parameters"]["password"] = vnc_password
    auto_ref_conn_erforce["parameters"]["hostname"] = "autoref-erforce"
    client.upsert_connection(auto_ref_conn_erforce)
    auto_ref_conn_erforce["name"] = "autoref-erforce-view"
    auto_ref_conn_erforce["parameters"]["read-only"] = "true"
    client.upsert_connection(auto_ref_conn_erforce)

    maintainer_conn = default_connection()
    maintainer_conn["name"] = "maintainer"
    maintainer_conn["parameters"]["port"] = "5901"
    maintainer_conn["parameters"]["password"] = vnc_password
    maintainer_conn["parameters"]["hostname"] = "maintainer"
    maintainer_conn["parameters"]["enable-sftp"] = "true"
    maintainer_conn["parameters"]["sftp-private-key"] = ssh_private_key
    client.upsert_connection(maintainer_conn)

    for team in teams:
        if client.get_user(team) is None:
            password = generate_password()
            client.create_user(team, password)
            passwords[team] = password
            save_passwords(passwords)
        write_conn = default_connection()
        write_conn["name"] = f"team-{team}"
        write_conn["parameters"]["port"] = "5901"
        write_conn["parameters"]["password"] = vnc_password
        write_conn["parameters"]["hostname"] = f"team-{team}"
        write_conn["parameters"]["enable-sftp"] = "true"
        write_conn["parameters"]["sftp-private-key"] = ssh_private_key
        write_connection_id = client.upsert_connection(write_conn)
        view_conn = default_connection()
        view_conn["name"] = f"team-{team}-view"
        view_conn["parameters"]["port"] = "5901"
        view_conn["parameters"]["password"] = vnc_password
        view_conn["parameters"]["hostname"] = f"team-{team}"
        view_conn["parameters"]["read-only"] = "true"
        view_connection_id = client.upsert_connection(view_conn)

        client.patch_user_permissions(team, write_connection_id)
        client.assign_member_to_user_group(team, viewer_group)
        client.assign_connection_to_user_group(view_connection_id, viewer_group)


fields = load_fields()
for field in fields:
    init_field(field)
