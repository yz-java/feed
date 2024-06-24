#!/bin/sh

fwupdtool --version 2>&1 | grep "runtime\s*org.freedesktop.fwupd\s*$2"
