#!/bin/bash

# List all users in the organization
gam print users

gam print users primaryemail name.givenName name.familyName organizations > users_list.csv
