#!/bin/bash

/opt/dependency-check/bin/dependency-check.sh \
  --project "poc-1" \
  --scan app \
  --format HTML \
  --out dependency-check-report
``