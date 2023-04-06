#!/bin/bash

echo Hello World
echo running Nexus IQ scan

$(NEXUS_IQ_CLI) -s $(NEXUS_IQ_URL) -a $(NEXUS_IQ_USER):$(NEXUS_IQ_PWD) -i $(APPLICATION_NAME) $(SCAN_TARGET)