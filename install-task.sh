#!/bin/bash
sh -c "$(curl -ssL https://taskfile.dev/install.sh)" -- -d -b /tmp && sudo mv /tmp/task /usr/local/bin/task && task --version