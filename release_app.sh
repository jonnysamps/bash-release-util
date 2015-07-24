#!/usr/bin/env bash

# Arguments #################
APPNAME=$1
VERSION=$2
#############################

echo "Releasing to $APPNAME with version: $VERSION"

## Grant access to a user
#heroku sharing:add johnsmith@bmail.com -a "$APPNAME"

## I fyou want to stop the application before release
#echo "Stopping app..."
#heroku ps:stop web --app "$APPNAME"

## If you want to change the way the dynos are scaled
#echo "Removing worker and scheduler dynos"
#heroku ps:scale worker=0 --app "$APPNAME"
#heroku ps:scale scheduler=0 --app "$APPNAME"

## If you want to setup any environment variables
#echo "Setting config"
#heroku config:set SOMECONFIG=TRUE -a "$APPNAME"

## Push out the release
#echo "Pushing release"
git push -f git@heroku.com:$APPNAME.git $VERSION^{}:master

## Run rails migrations
#echo "Running migration..."
#(heroku run rake db:migrate --app "$APPNAME")

## If you had stopped the app above then you'll need to restart it here
#echo "Starting app..."
#heroku ps:restart --app "$APPNAME"
