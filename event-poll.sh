#!/bin/bash

# Copyright (C) 2024  Aki Niemi <aki@viito.io>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


url="https://anc.ca.apm.activecommunities.com/vancouver/rest/activity/detail"
poll_every=30
json_path='.body.detail.space_type'
expected_value=2

echo -e "\a"
printf "\nEnter event ID to poll: "
read id

printf "\nPolling '$url/$id' every $poll_every seconds, until space_type turns to '$expected_value'\n"

while true; do
  x=$(curl -s "$url/$id" | jq "$json_path")
  printf "\r$(date +%H:%M:%S): status: $x (expecting: $expected_value)"

  if [[ "$x" == "$expected_value" ]]; then
    print "Found an empty slot. Hurry up and enroll!"
    echo -e "\a"
    break
  fi

  sleep $poll_every
done
