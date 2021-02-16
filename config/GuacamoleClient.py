import string
import json
import requests


class GuacamoleException(Exception):
    pass


# Guacamole API reference: https://github.com/ridvanaltun/guacamole-rest-api-documentation/tree/master/docs
class GuacamoleClient:
    base_url: string
    token: string
    datasource: string
    connections: json
    user_groups: json
    verify_certificate: bool = True

    def __init__(self, base_url):
        self.base_url = base_url

    def retrieve_auth_token(self, username, password):
        payload = {"username": username, "password": password}
        response = requests.post(self.base_url + "/api/tokens", data=payload, verify=self.verify_certificate)
        if not response.ok:
            raise GuacamoleException("Could not authenticate: " + response.text)
        body = response.json()
        self.token = body["authToken"]
        self.datasource = body["dataSource"]

    def request(self, method, path, body=None):
        if body is None:
            data = None
        else:
            data = json.dumps(body)
        params = {"token": self.token}
        headers = {'content-type': 'application/json'}
        return requests.request(method, self.base_url + path,
                                params=params,
                                headers=headers,
                                data=data,
                                verify=self.verify_certificate)

    def retrieve_connections(self):
        self.connections = self.list_connections()

    def retrieve_connection_groups(self):
        self.user_groups = self.list_user_groups()

    def update_user_password(self, username, old_password, new_password):
        path = f"/api/session/data/{self.datasource}/users/{username}/password"
        body = {"oldPassword": old_password, "newPassword": new_password}
        response = self.request("PUT", path, body)
        if not response.ok:
            raise GuacamoleException("Could not update user password: " + response.text)

    def create_user(self, username, password):
        with open("user.json", "r") as file:
            body = json.load(file)
            body["username"] = username
            body["password"] = password
            path = f"/api/session/data/{self.datasource}/users"
            response = self.request("POST", path, body)
            if not response.ok:
                raise GuacamoleException("Could not create user: " + response.text)

    def get_user(self, username):
        path = f"/api/session/data/{self.datasource}/users/{username}"
        response = self.request("GET", path)
        if response.status_code == 404:
            return None
        if not response.ok:
            raise GuacamoleException("Could not get user: " + response.text)
        return response.json()

    def patch_user_permissions(self, username, write_connection_id):
        body = [{"op": "add",
                 "path": f"/connectionPermissions/{write_connection_id}",
                 "value": "READ"}]
        path = f"/api/session/data/{self.datasource}/users/{username}/permissions"
        response = self.request("PATCH", path, body)
        if not response.ok:
            raise GuacamoleException("Could not patch permissions: " + response.text)

    def assign_member_to_user_group(self, username, group):
        body = [{"op": "add",
                 "path": "/",
                 "value": username}]
        path = f"/api/session/data/{self.datasource}/userGroups/{group}/memberUsers"
        response = self.request("PATCH", path, body)
        if not response.ok:
            raise GuacamoleException("Could not assign member to user group: " + response.text)

    def assign_connection_to_user_group(self, connection_id, group):
        body = [{"op": "add",
                 "path": f"/connectionPermissions/{connection_id}",
                 "value": "READ"}]
        path = f"/api/session/data/{self.datasource}/userGroups/{group}/permissions"
        response = self.request("PATCH", path, body)
        if not response.ok:
            raise GuacamoleException("Could not assign connection to user group: " + response.text)

    def create_user_group(self, body):
        path = f"/api/session/data/{self.datasource}/userGroups"
        response = self.request("POST", path, body)
        if not response.ok:
            raise GuacamoleException("Could not create user group: " + response.text)
        return response.json()["identifier"]

    def list_user_groups(self):
        path = f"/api/session/data/{self.datasource}/userGroups"
        response = self.request("GET", path)
        if not response.ok:
            raise GuacamoleException("Could not list user groups: " + response.text)
        return response.json()

    def upsert_user_group(self, name):
        conn_group_id = self.user_group_id(name)
        if conn_group_id is None:
            body = {"identifier": name, "attributes": {"disabled": ""}}
            self.create_user_group(body)

    def user_group_id(self, name):
        for key, value in self.user_groups.items():
            if value["identifier"] == name:
                return value["identifier"]
        return None

    def create_connection(self, body):
        path = f"/api/session/data/{self.datasource}/connections"
        response = self.request("POST", path, body)
        if not response.ok:
            raise GuacamoleException("Could not create connection: " + response.text)
        return response.json()["identifier"]

    def update_connection(self, body):
        identifier = body["identifier"]
        path = f"/api/session/data/{self.datasource}/connections/{identifier}"
        response = self.request("PUT", path, body)
        if not response.ok:
            raise GuacamoleException("Could not update connection: " + response.text)

    def upsert_connection(self, body):
        conn_id = self.connection_id(body["name"])
        if conn_id is None:
            return self.create_connection(body)
        else:
            body["identifier"] = conn_id
            self.update_connection(body)
            return conn_id

    def list_connections(self):
        path = f"/api/session/data/{self.datasource}/connections"
        response = self.request("GET", path)
        if not response.ok:
            raise GuacamoleException("Could not create connection: " + response.text)
        return response.json()

    def connection_id(self, name):
        for key, value in self.connections.items():
            if value["name"] == name:
                return value["identifier"]
        return None
