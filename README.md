Bash Release Utility
====================

A small bash utility to enable parallel release to many applications on Heroku.

Installation
------------

Clone this repo

Usage
-----

### Configuration

Edit `dorelease.sh` to set:
 
* `release_script` to the script that you would like to be run for each app your app list file. This defaults to
  `release_app.sh` which is included in this repo. `release_app.sh` has lots of examples of things you might want
  to do like setting environment variables and running migrations. So if you want to do more that just push new code
  then you'll need to either modify `release_app.sh` or write your own script.

Create a text file somewhere with all of the apps that you want to be released to, with one per line like
  ```
  heroku-app-1
  heroku-app-2
  ```
If you want to keep an app in the list but skip over it just comment it out with a `#`
  
### Run it

`cd` into the git repo you want to be released and run your release with

```bash
  <PATH_TO_REPO>/dorelease.sh <APP_LIST_FILE> <LOG_DIR> <VERSION>
```
* `APP_LIST_FILE` the path to the file that lists all of your applications
* `VERSION` to the git tag that you would like to be released
* `LOG_DIR` to the directory where you would like logs to be written.


Running Tests
-------------

Tests! We don't need no stinking tests!
