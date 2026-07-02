#!/bin/bash

DATE=$(date +%F)

tar -czf backup-$DATE.tar.gz app config

aws s3 cp backup-$DATE.tar.gz \
s3://surya-backup-demo-2026-12345/