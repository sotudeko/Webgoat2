#!/bin/bash

echo Hello World
echo running Nexus IQ scan

nexus-iq-cli -s http://localhost:8070 -a zwwu7vYv:zwwu7vYv -i webgoat2 target/WebGoat-*.war
