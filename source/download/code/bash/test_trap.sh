#!/bin/bash
trap 'echo TRAP CAPTURED' INT TERM EXIT
sleep 3