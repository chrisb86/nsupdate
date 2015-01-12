# Nameserver update for inwx (nsupdate)

Update nameserver entrys at inwx with the current WAN IP (DynDNS)

nsbackup is a bash script that uses curl and the inwx API to update nameserver entrys at inwx with the current WAN IP. It supports IPv4 and IPv6.

Place your config files in the _nsupdate.d_ folder.

## Requirements

In order to run you need to have _curl_ and _awk_ installed, as well as _drill_ or _nslookup_.

At least one config file needs to exist ending with _.config_. A "sample.config.dist" is provided.

## Changelog

**2015-01-12**

- Added checking for needed commands
- Added checking for existing config file
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
