## 3.2.0 2024-12-19 <dave at tiredofit dot ca>

   ### Added
      - Discourse 3.3.3
      - Debian Bookworm
      - Ruby 3.3.6
      - Ability to create admin user and admin pass on first install
      - Switch to Unicorn from Puma
      - Added more plugin support


## 3.1.4 2023-03-17 <dave at tiredofit dot ca>

   ### Added
      - Discourse 3.0.2


## 3.1.3 2023-02-26 <dave at tiredofit dot ca>

   ### Changed
      - Fix for building chat plugin


## 3.1.2 2023-02-26 <dave at tiredofit dot ca>

   ### Added
      - Discourse 3.0.1


## 3.1.1 2023-02-26 <dave at tiredofit dot ca>

   ### Added
      - Discourse 2.8.14


## 3.1.0 2022-12-19 <dave at tiredofit dot ca>

   ### Added
      - Change base image to use `tiredofit/nginx`
      - Set Nginx to be disabled
      - Set Nginx to automatically proxy all requests in to 127.0.0.1:3000


## 3.0.1 2022-12-16 <dave at tiredofit dot ca>

   ### Changed
      - Remove directories that are not necessary to reduce image size


## 3.0.0 2022-12-15 <dave at tiredofit dot ca>

This has breaking changes all over the image, specifically related to paths and environment variables. Please read the README.md carefully and view examples and port over accordingly.

   ### Added
      - Discourse 2.8.13
      - Debian Bullseye
      - Ruby 3.0.5 compiled w/ JemAlloc
      - Node 16
      - Added new image optimization packages
      - Postgresql 15 Support
      - Rewrote initialization routines and configured configurable paths for uploads, backups, plugins, logs
      - Logrotate routines for all logs
      - Switchable environment variables for plugins
      - New plugins added: Footnote, Formatting Toolbar, Mermaid, Post Voting, Spoiler Alert

   ### Changed
      - Reworked all environment variables, now use standard variables for those used to other tiredofit images


## 2.5.1 2021-12-15 <dave at tiredofit dot ca>

   ### Added
      - Discourse 2.7.9


## 2.5.0 2020-07-17 <dave at tiredofit dot ca>

   ### Added
      - Update to Discourse 2.6.0-beta1
      - Remove some plugins


## 2.4.1 2019-11-29 <dave at tiredofit dot ca>

   ### Added
      - Discourse 2.3.6

   ### Changed
      - Ruby 2.6

## 2.4 2019-09-01 <edisonlee at selfdesign dot org>

* Update Discourse version to 2.3.2

## 2.3 2019-07-02 <dave at tiredofit dot ca>

* Discourse 2.3.1

## 2.2.1 2019-03-26 <dave at tiredofit dot ca>

* Discourse 2.2.3

## 2.2 2019-02-28 <dave at tiredofit dot ca>

* Discourse 2.2.0
* Ruby 2.5
* NodeJS 11

## 2.1-dev 2018-08-26 <dave at tiredofit dot ca>

* Putting Nginx in front of 3000 for CORS

## 2.0.2 2018-08-26 <dave at tiredofit dot ca>

* Bump to 2.0.4 

## 2.01 2018-07-10 <dave at tiredofit dot ca>

* Bump to 2.02

## 2.0 2018-06-04 <dave at tiredofit dot ca>

* Migrate to Debian Stretch
* Ruby 2.4
* Discourse 2.0

## 1.4 2018-02-01 <dave at tiredofit dot ca>

* Rebase

## 1.3 2017-10-19 <dave at tiredofit dot ca>

* Version Bump and Cleanup


## 1.2 2017-08-25 <dave at tiredofit dot ca>

* A few more plugins added

## 1.1 2017-08-25 <dave at tiredofit dot ca>

* Major Cleanup
* Added a few plugins specific to SelfDesign and BB-Code Colour

## 1.0 2017-08-06 <dave at tiredofit dot ca>

* Initial Release
* Debian Base
