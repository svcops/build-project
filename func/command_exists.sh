#!/bin/bash

function command_exists() {
  type "$1" &>/dev/null
}
