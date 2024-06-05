# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## 2024-06-05

### Added
- Added Gitea workflow for building docker images

### Changed

- Moved changelog to CHANGELOG.md

## 2023-11-06

### Added
- Added jq to Docker image (for processing json)

## 2022-12-14

### Added
- Added Dockerfile
- Added docker-compose.yml

## 2022-10-18

### Changed
- Completly rewritten. nsupdate is now a POSIX compliant /bin/sh script 👍🏻
- Backwards compatibility should be given (please test and report bugs!).
- If using the xmmlint method, now also the IP for a record is retrieved this way
- WAN IP now is only checked once per session instead of every time a new config is processed.
- The script now automagically determines the best way to get the needed data (xmllint, nslookup, drill) and has some nice output options.
- The code is now structured in functions which makes it more maintainable and modular.

### Removed
- Avoid using awk and get rid of dependency

## 2021-12-11

### Added
- Added the possibility to retrieve the WAN IP by a shell command (e.g. SSHing into your router and get the IP of the WAN interface)

## 2020-07-03

### Changed
- Rearranged config.sample
- Updated Readme

### Added
- Getting the Domain-Record-ID via XML-RPC API

## 2020-05-11

### Changed
- Updated Readme with some hints
- Updated config.sample with a hint for TTL

## 2020-03-31

### Changed

- Made time to live configurable

## 2019-12-20

### Fixed
- Fixed DomRobot XML-RPC API syntax

### Added
- Added some more documentation

## 2015-07-22

### Changed
- Changed the way how the existence of config files is checked
- Updated the sample config file to reflect new options from the last updates

### Added
- The script is reported to work in csh and sh too

## 2015-06-30

### Fixed
- Fixed the check for config files. Can now handle more than one file

### Changed
- Changed warning for missing config files

## 2015-01-12

### Added
- Added checks for needed commands
- Added checks for existing config file
- Added requirements to README.md

## 2014-02-21

### Added
- Added support for IPv6
- Added support for config files

## 2014-01-02

### Changed
- Changed default IP check site to ip.dblx.io
- Renamed _$HOSTNAME_ to _$DOMAIN_ to work around potential conflicts with _$HOSTNAME_ that's set by the host itself

### Added
- Added a switch to use _drill_ instead of _nslookup_ because FreeBSD 10 switched from _bind_ to _unbound_ 

## 2014-01-06

### Changed

- Config files are sourced relative to the script folder now

## 2013-07-12

- First commit