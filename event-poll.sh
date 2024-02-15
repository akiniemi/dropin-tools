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


rest="https://anc.ca.apm.activecommunities.com/vancouver/rest/activity/detail"
enroll="https://anc.ca.apm.activecommunities.com/vancouver/activity/search/detail"

poll_every=30
max_poll=$((8*60*2))
available=2
count=0

title="Hockey Notification"

finish() {
    echo -e "\a"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript \
            -e "display dialog \"$1\" with title \"$title\" \
                buttons {\"Enroll Now\", \"Cancel\"} default button \"Enroll Now\" cancel button \"Cancel\"" \
            -e "if button returned of result is \"Enroll Now\" then open location \"$2\""
    else
        printf $1 $2
    fi
}

echo -e "\a"
printf "Enter event ID to poll: "
read id

printf "Polling event '$id' every $poll_every seconds, until space is '$available'\n"

while true; do
    space_type=$(curl -s "$rest/$id" | jq '.body.detail.space_type')

    printf "\r$(date +%H:%M:%S): space_type=$space_type (expecting=$available) count=$count (max=$max_poll)"

    if [[ "$space_type" == "$available" ]]; then
        finish "Open spot detected, hurry up and enroll!" "$enroll/$id"
        break
    fi

    if [[ "$max_poll" > 0 && "$count" == "$max_poll" ]]; then
        finish "Max poll count reached. Tough luck!" "$enroll/$id"
        break;
    fi

    sleep $poll_every

    ((count++))
done
