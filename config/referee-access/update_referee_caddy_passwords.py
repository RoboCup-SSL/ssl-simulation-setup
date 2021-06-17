#!/usr/bin/env python3

import json
import os
from datetime import datetime
from urllib import request

script_dir = os.path.dirname(__file__)
config_dir = script_dir + "/.."
offset_before_seconds = 15 * 60
duration_seconds = 60 * 60
admin_users = {"guacadmin"}
root_domain_file = config_dir + "/root_domain"
tournament_path = "/tournament_json"


def load_root_domain():
    with open(root_domain_file) as file:
        return file.read().strip()


def scheduler_url():
    return "https://scheduling." + load_root_domain() + tournament_path


def fetch_tournament():
    return request.urlopen(scheduler_url()).read()


def load_tournament(file_location):
    with open(file_location) as file:
        return file.read().strip()


def team_name_map():
    result = {}
    with open(config_dir + "/team_name_map") as file:
        rows = file.readlines()
        for row in rows:
            values = row.split(",")
            result[values[0]] = values[1].strip()
    return result


def caddy_passwords():
    passwords = {}
    with open(config_dir + "/caddy_passwords") as file:
        rows = file.readlines()
        for row in rows:
            values = row.split(":")
            passwords[values[0]] = values[1].strip()
    return passwords


def current_field():
    with open(config_dir + "/field_name") as file:
        return file.read().strip().replace("field-", "").upper()


def find_referees():
    schedule = json.loads(fetch_tournament())
    field = current_field()
    now = datetime.utcnow().timestamp()
    referees = []
    for row in schedule:
        if row["field"] == field:
            start_timestamp = datetime.strptime(row["day"] + "_" + row["starttime"], '%Y-%m-%d_%H:%M').timestamp()
            timestamp_diff = now - start_timestamp
            if -offset_before_seconds < timestamp_diff < duration_seconds:
                referees += row["referee"].split(",")
    return referees


def write_caddy_passwords(teams):
    passwords = caddy_passwords()
    with open(config_dir + "/caddy_passwords_active", "w") as file:
        for team in teams:
            if team in passwords:
                password = passwords[team]
                file.write(team + ":" + password + "\n")
            else:
                print("No password known for team " + team)


if __name__ == '__main__':
    refs = find_referees()
    team_map = team_name_map()
    users = set()
    for ref in refs:
        users.add(team_map[ref.strip()])

    if len(users) == 0:
        print("No referees assigned")
        users = set(team_map.values())

    # Always give admin users access
    users |= admin_users

    print("Giving referee access to the following users: " + str(users))
    write_caddy_passwords(users)
