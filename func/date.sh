#!/bin/bash

date_general=$(date '+%Y-%m-%d %H:%M:%S')
datetime_version=$(date '+%Y-%m-%d_%H-%M-%S')
datetime_tight_version=$(date '+%Y%m%d%H%M%S')
date_version=$(date '+%Y-%m-%d')
date_tight_version=$(date '+%Y%m%d')

echo "data_general $date_general"
echo "datetime_version $datetime_version"
echo "datetime_tight_version $datetime_tight_version"
echo "date_version $date_version"
echo "date_tight_version $date_tight_version"
