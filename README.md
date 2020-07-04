# Nameserver update for INWX (nsupdate)

This shell script implements [dynamic DNS](https://en.wikipedia.org/wiki/Dynamic_DNS) using the [DomRobot XML-RPC API](https://www.inwx.de/de/help/apidoc/f/ch02s13.html#nameserver.updateRecord) by [INWX](https://www.inwx.de/).  
This script can update nameserver entries with your current WAN IPv4 and IPv6 addresses.  
It uses the `nameserver.updateRecord` method of the API.  

advantage: You don't need payed dynDNS-accounts for multiple domains.  
disadvantage: The minimum TTL is 300 (5 minutes). The dynDNS-Service allowes 60 (1 minute).

There exists the `dyndns.updateRecord` method in the DomRobot API. Therefore you need a DynDNS-account by INWX. If you need this option, feel free to change the script to your needs.  

## Requirements

In order to run the script you need to have installed the following command line tools:

- _curl_
- _awk_
- _nslookup_ or _drill_

recommendation

- _xmllint_  
Look for _libxml2-utils_ (Debian, Ubuntu) or  
_libxml2_ (FreeBSD, CentOS),  
_xmlstarlet_ is also available on many systems and it gets _xmllint_.  
If _xmllint_ is not on your system you have to set the domain record id in your config files.

Note: 2-Factor-Authentification method (2FA) is not implemented.

## Installation

Simply clone this project or download the `master.zip` and extract it, e.g., using `wget` and `7z x master.zip`.

Place your config files in the `nsupdate.d` folder. A `dist.config.sample` file with all possible options is provided. At least one config file needs to exist, ending with `.config`.  
All .config files (one for each dns-record) will be processed by looping them.  

For home.example.com you may create:  
A-Record Update configuration e.g.  
`myV4.config`  
```
INWX_USER="USERNAME"
INWX_PASS="PASSWORD"
MAIN_DOMAIN="example.de"
DOMAIN="home.example.de"
TYPE="A"
IP_CHECK_SITE="https://api.ipify.org"
```
AAAA-Record Update configuration e.g.  
`myV6.config`  
```
INWX_USER="USERNAME"
INWX_PASS="PASSWORD"
MAIN_DOMAIN="example.de"
DOMAIN="home.example.de"
TYPE="AAAA"
IP_CHECK_SITE="https://api6.ipify.org"
```

## Run nsupdate by cron
With `crontab -e` you can add the following line for running the script every 5 minutes:  
`*/5 * * * * bash /home/$USER/nsupdate/nsupdate.sh`  

## Changelog

**2020-07-03**

 - Rearranged config.sample
 - Updated Readme
 - Getting the Domain-Record-ID via XML-RPC API

**2020-05-11**

- Updated Readme with some hints
- Updated config.sample with a hint for TTL

**2020-03-31**

- Made time to live configurable

**2019-12-20**

- Fixed DomRobot XML-RPC API syntax
- Added some more documentation

**2015-07-22**

- Changed the way how the existence of config files is checked
- Updated the sample config file to reflect new options from the last updates
- The script is reported to work in csh and sh too

**2015-06-30**

- Fixed the check for config files. Can now handle more than one file
- Changed warning for missing config files

**2015-01-12**

- Added checks for needed commands
- Added checks for existing config file
- Added requirements to README.md

**2014-02-21**

- Added support for IPv6
- Added support for config files

**2014-01-02**

- Changed default IP check site to ip.dblx.io
- Added a switch to use _drill_ instead of _nslookup_ because FreeBSD 10 switched from _bind_ to _unbound_ 
- Renamed _$HOSTNAME_ to _$DOMAIN_ to work around potential conflicts with _$HOSTNAME_ that's set by the host itself

**2014-01-06**

- Config files are sourced relative to the script folder now

**2013-07-12**

- First commit

## License

nsupdate is distributed under the MIT license, which is similar in effect to the BSD license.

> Copyright 2013 Christian Busch (http://github.com/chrisb86)
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
