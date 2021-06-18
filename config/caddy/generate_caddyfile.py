#!/usr/bin/env python3

import os
from jinja2 import Template

script_dir = os.path.dirname(__file__)
config_dir = script_dir + "/.."
passwords_file = config_dir + "/caddy_passwords_active"
caddy_template_file = script_dir + "/Caddyfile.template"
caddy_file = config_dir + "/../caddy/init/Caddyfile"


def load_caddyfile_template():
    with open(caddy_template_file, "r") as file:
        return file.read()


def load_field_name():
    with open(config_dir + "/field_name", "r") as file:
        return file.read().strip()


def load_root_domain():
    with open(config_dir + "/root_domain", "r") as file:
        return file.read().strip()


def load_password_hashes():
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


field_name = load_field_name()
root_domain = load_root_domain()
password_hashes = load_password_hashes()

gc_users = []
gc_admin_users = []
for username, password_hash in password_hashes.items():
    gc_users.append({"name": username, "hash": password_hash})
    if username == "guacadmin":
        gc_admin_users.append({"name": username, "hash": password_hash})

template = Template(load_caddyfile_template())
caddyfile = template.render({
    "root_domain": root_domain,
    "field_name": field_name,
    "gc_users": gc_users,
    "gc_admin_users": gc_admin_users
})
with open(caddy_file, "w") as file:
    file.write(caddyfile)
