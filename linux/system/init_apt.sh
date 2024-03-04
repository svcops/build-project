#!/bin/bash
# debian 系列系统初始化

apt update -y
apt upgrade -y

apt install -y sudo vim git curl wget net-tools
