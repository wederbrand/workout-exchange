#!/usr/bin/ruby

require 'pstore'

# open pstore

# if new pstore add current time (utc) to all sites as last exported
# exit with "sync database initialized, future workouts will be synced"

# if old pstore

# for each site (endomondo, strava, garmin)
# check last export, if within CHECK_LIMIT skip it with "check too soon"
# if more than CHECK_LIMIT ago check the site
# throw everything already synced
# bump the pstore value to current time
# those not synced should be stored locally aswell as being remembered in the pstore

# for all workouts found import to each site, update pstore and possibly delete local file