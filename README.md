# Nameserver update for INWX (nsupdate)

This shell script implements [dynamic DNS](https://en.wikipedia.org/wiki/Dynamic_DNS) using the [DomRobot XML-RPC API](https://www.inwx.de/de/help/apidoc/f/ch02s13.html#nameserver.updateRecord) by [INWX](https://www.inwx.de/).  
This script can update nameserver entries with your current WAN IPv4 and IPv6 addresses.

This way you can update your DNS records directly utilizing the INWX API and don't need the payed DynDNS option from INWX which uses DDNS over HTTP/S.

The minimum TTL when using the API is 300 seconds. The paid DynDNS option can go as low as 60 seconds.

## Requirements

_nsupdate_ is fully POSIX compliant and should work in every shell.

Nevertheless it has some dependencies to use it:
- _xmllint_ (Look for _libxml2-utils_ (Debian, Ubuntu) or _libxml2_ (FreeBSD, CentOS)). It's used for Getting the ID and the current IP from the INWX API. This is the recommended way.

- If you don't have installed _xmllint_, you need either _nslookup_ or _drill_ to query the nameserver for the current IP. In this case you must define the specific INWX IDs in the config files for your INWX records.

- A hard requirement is _curl_ as it's used to make the API calls.

Note: 2-Factor-Authentification method (2FA) is not supported when using the INWX API.

## Installation

Simply clone this project or download the `master.zip` and extract it, e.g., using `wget` and `7z x master.zip`.

Move the included _nsupdate directory_, which holds the configuration files, to _/usr/local/etc/_ (see the config section if you want to use another path) and nsupdate.sh anywhere in your $PATH (e.g. /_usr/local/bin/_ or _~/bin/_).

### Log directory
The default log directory is _/var/log/nsupdate_. You have to create this directory and ensure write access for the user that runs _nsupdate_ (e.g. `sudo mkdir -p /var/log/nsupdate && sudo chown $USER /var/log/nsupdate`). When you want to use another path, see the config section.

## Configuration

### nsupdate.conf

_nsupdate.conf_ is the main configuration file for _nsupdate_. Here you can set global defaults which can be used for all DNS records (e.g. INWX credentials, TTL, record type). These can be overwritten in the configuration files for your DNS records. There are also options to set the paths that are used by _nsupdate_.

See _/usr/local/etc/nsupdate/nsupdate.conf.dist_ for all available options and their defaults.

All options except the INWX credentials have sensible defaults and can be left untouched if they suit your needs.

### Configuring DNS records

The configuration files for your DNS belong to _/usr/local/etc/nsupdate/conf.d/_.

If you configured your INWX credentials in _nsupdate.conf_ and the other defaults are fine for your use case, all you have to do is to set **$MAIN_DOMAIN** and **$DOMAIN**.

See _/usr/local/etc/nsupdate/conf.d/sub.example.com_AAAA.conf.dist_ for an example with all available options.

### Backwards compatibility
If you used _nsupdate_ before, you should be able to use your existing configs. Some options have changed names but are recognized when processing the configuration files. This may change in the future.

## Run nsupdate by cron

The best way to use _nsupdate_ is by setting up a cron job (e.g. by running `crontab -e`).

To run the script every 5 minutes and suppress the output you can write something like `*/5 * * * * /usr/local/bin/nsupdate.sh > /dev/null 2>&1`.

## License

nsupdate is distributed under the MIT license, which is similar in effect to the BSD license.

> Copyright 2013 Christian Busch (http://github.com/chrisb86)
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
