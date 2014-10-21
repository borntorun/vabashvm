#!/bin/bash

printf "\nRunning [%s]...\n" "$0"

yum -y update

[[ ! $? -eq 0 ]] && printf "\nError: System Update Failed\n" && exit 1

printf "\nSystem Update.\n"

exit 0