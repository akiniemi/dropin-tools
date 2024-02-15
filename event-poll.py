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


import sys
import time
import requests
import subprocess
import platform
import argparse


rest = "https://anc.ca.apm.activecommunities.com/vancouver/rest/activity/detail"
enroll = "https://anc.ca.apm.activecommunities.com/vancouver/activity/search/detail"

parser = argparse.ArgumentParser(
    description='Hockey event polling script with interval and max poll params'
)

parser.add_argument('-i', '--interval',
                    type=int,
                    help='The poll interval in seconds',
                    default=30)
parser.add_argument('-m', '--max-poll',
                    type=int,
                    help='The maximum number of polls',
                    default=480)

# Parse the command-line arguments
args = parser.parse_args()
available = 2
count = 0

title = "Hockey Notification"


def finish(msg: str, url: str):
    sys.stdout.write('\a')
    sys.stdout.flush()

    if platform.system() == "Darwin":
        subprocess.run([
            'osascript',
            '-e',
            f'display dialog "{msg}" with title "{title}" '
            'buttons {"Enroll Now", "Cancel"} default button "Enroll Now" '
            'cancel button "Cancel"',
            '-e',
            f'if button returned of result is "Enroll Now" then '
            f'open location "{url}"'
        ])


event = input("Enter the ID to poll: ")

print(f'Polling event {event} every {args.interval} seconds until space shows '
      f'as available ({available}) or poll count reaches {args.max_poll}')

poll = f'{rest}/{event}'
url = f'{enroll}/{event}'

while True:
    response = requests.get(poll)
    data = response.json()

    space_type = data['body']['detail']['space_type']
    print(f'{time.strftime("%H:%M:%S")}: event is showing '
          f'{"❌" if available != space_type else "🟢"}',
          end='\r')

    if space_type == available:
        finish('Open spot detected, hurry up and enroll!', url)
        break

    if args.max_poll > 0 and count >= args.max_poll:
        finish('Max poll count reached. Tough luck!', url)
        break

    count += 1

    time.sleep(args.interval)
