#!/usr/bin/env sh

# Update a nameserver entry at inwx with the current WAN IP (DynDNS)

# Copyright 2013 Christian Busch
# http://github.com/chrisb86/

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Print and log messages when verbose mode is on
# Usage: chat [0|1|2|3] MESSAGE
## 0 = regular output
## 1 = error messages
## 2 = verbose messages
## 3 = debug messages

chat () {
  messagetype=$1
  message=$2
  log=$nsupdate_log_dir/$nsupdate_log_file
  log_date=$(date "+$log_date_format")

  if [ $messagetype = 0 ]; then
    echo "[$log_date] [INFO] $message" | tee -a $log ;
  fi
  #
  if [ $messagetype = 1 ]; then
    echo "[$log_date] [ERROR] $message" | tee -a $log ; exit 1;
  fi

  if [ $messagetype = 2 ] && [ "$VERBOSE" = true ]; then
    echo "[$log_date] [INFO] $message" | tee -a $log
  fi

  if [ $messagetype = 3 ] && [ "$DEBUG" = true ]; then
    echo "[$log_date] [DEBUG] $message" | tee -a $log
  fi
}

# Load config file, set default variables and get wan IP
# Usage: init
init () {

  nsupdate_conf_file="nsupdate.conf"
  basedir="${BASEDIR:-/usr/local/etc}"
  nsupdate_conf_dir="${NSUPDATE_CONF_DIR:-$basedir/nsupdate}"

  ## Try to load nsupdate.conf
  [ -f "./$nsupdate_conf_file" ] && . ./$nsupdate_conf_file
  [ -f "$nsupdate_conf_dir/$nsupdate_conf_file" ] && . $nsupdate_conf_dir/$nsupdate_conf_file

  VERBOSE="${VERBOSE:-false}"
  DEBUG="${DEBUG:-false}"

  if [ "$DEBUG" = true ]; then
    set -x
  fi

  nsupdate_confd_dir="${NSUPDATE_CONFD_DIR:-$nsupdate_conf_dir/conf.d}"
  log_date_format="${LOG_DATE_FORMAT:-%Y-%m-%d %H:%M:%S}"
  nsupdate_log_dir="${NSUPDATE_LOG_DIR:-/var/log/nsupdate}"
  nsupdate_log_file="${NSUPDATE_LOG_FILE:-nsupdate.log}"
  tmp_dir="${NSUPDATE_TMP_DIR:-/tmp}"
  nsupdate_conf_extension="${NSUPDATE_CONF_EXTENSION:-.conf}"

  nsupdate_record_type="${NSUPDATE_RECORD_TYPE:-A}"
  nsupdate_record_ttl="${NSUPDATE_RECORD_TTL:-300}"

  inwx_api="https://api.domrobot.com/xmlrpc/"
  inwx_api_xpath_ip='string(/methodResponse/params/param/value/struct/member[name="resData"]/value/struct/member[name="record"]/value/array/data/value/struct/member[name="content"]/value/string)'
  inwx_api_xpath_id='string(/methodResponse/params/param/value/struct/member[name="resData"]/value/struct/member[name="record"]/value/array/data/value/struct/member[name="id"]/value/string)'
  inwx_nameserver="ns.inwx.de"
  ip_check_site="${NSUPDATE_IP_CHECK_SITE:-https://api64.ipify.org}"

  ## Get WAN IP 4
  wan_ip4="$(curl -s -4 ${ip_check_site})"
  chat 2 "WAN IP 4: ${wan_ip4}"

  ## Get WAN IP 6
  wan_ip6="$(curl -s -6 ${ip_check_site})"
  chat 2 "WAN IP 6: ${wan_ip6}"
}

# Get the data for a given domain
# Usage: get_inwx_domain_id
get_domain_info () {

  ## Check if xmllint is installed and use it.
  if command -v xmllint > /dev/null 2>&1; then

    ## File name for temporary file to store the XML from API
    tmp_file="${main_domain}_${record_type}_$(date +%s).xml" # ${main_domain} in case of wildcards in ${domain}

    chat 3 "Found xmllint. Using curl for retrieving data from INWX API."

    inwx_api_xml_info="<?xml version=\"1.0\"?>
    <methodCall>
    <methodName>nameserver.info</methodName>
    <params>
        <param>
          <value>
              <struct>
                <member>
                    <name>user</name>
                    <value>
                      <string>${inwx_user}</string>
                    </value>
                </member>
                <member>
                    <name>lang</name>
                    <value>
                      <string>en</string>
                    </value>
                </member>
                <member>
                    <name>pass</name>
                    <value>
                      <string>${inwx_password}</string>
                    </value>
                </member>
                <member>
                    <name>domain</name>
                    <value>
                      <string>${main_domain}</string>
                    </value>
                </member>
                <member>
                    <name>name</name>
                    <value>
                      <string>${domain}</string>
                    </value>
                </member>
                <member>
                    <name>type</name>
                    <value>
                      <string>${record_type}</string>
                    </value>
                </member>
              </struct>
          </value>
        </param>
    </params>
    </methodCall>"

    ## Get domain info from INWX API and save it to a temporary file
    curl --silent --show-error --fail --output ${tmp_dir}/${tmp_file} -X POST ${inwx_api} -H "Content-Type: application/xml" -d "${inwx_api_xml_info}"

    ## Extract ID and IP from INWX data
    inwx_domain_ip="$(xmllint --xpath ${inwx_api_xpath_ip} ${tmp_dir}/${tmp_file})"
    inwx_domain_id="$(xmllint --xpath ${inwx_api_xpath_id} ${tmp_dir}/${tmp_file})"

    ## Remove domain info tmp file
    rm ${tmp_dir}/${tmp_file}
  else  
    ## Check if nslookup is installed and use it to get the IP
    if command -v nslookup > /dev/null 2>&1; then
      chat 3 "Found nslookup. Using it for IP from INWX nameserver."
      inwx_domain_ip=$(nslookup -sil -type=${record_type} ${domain} - ${inwx_nameserver} | tail -2 | head -1 | cut -d' ' -f2)
    ## Check if drill is installed and use it to get the IP
    else command -v drill > /dev/null 2>&1;
      chat 3 "Found drill. Using it for IP from INWX nameserver."
      inwx_domain_ip=$(drill ${domain} @${inwx_nameserver} ${record_type} | head -7 | tail -1 | cut -f2 -d$'\t' -f5)
    fi

    ## Set domain ID from config file
    chat 3 "Trying to get domain ID from config file."
    inwx_domain_id="${INWX_DOMAIN_ID}"
  fi

  if [ -z "$inwx_domain_ip" ]; then
    chat 1 "Couldn't get current IP address for ${domain} [${record_type}]. please check the installation instructions."
  fi

  if [ -z "$inwx_domain_id" ]; then
    chat 1 "Couldn't find domain ID for ${domain} [${record_type}]. please check the installation instructions."
  fi
}

# Get specific WAN IP for a domain
# Usage: get_domain_wan_ip
get_domain_wan_ip () {

  ## Check if WAN_IP_COMMAND is set and use it for retrieving the IP
  if [ "$WAN_IP_COMMAND" != "" ]; then
    #WAN_IP_COMMAND="${IPCOMMAND:-$WAN_IP_COMMAND}" ## for backwards compatibility
    wan_ip="${WAN_IP_COMMAND}"
    chat 2 "Using WAN_IP_COMMAND for retrieving WAN IP."
  else
    ## Otherwise use IP retrieved from web site
    ## Get connection type by record type
    if [ "${record_type}" = "AAAA" ]; then
      wan_ip="${wan_ip6}"
    else
      wan_ip="${wan_ip4}"
    fi
  fi
}

# Update a dns record
# Usage: update_record
update_record () {
  chat 3 "Using curl to update the DNS record with INWX API."
  inwx_api_xml_update_record="<?xml version=\"1.0\"?>
        <methodCall>
          <methodName>nameserver.updateRecord</methodName>
          <params>
              <param>
                <value>
                    <struct>
                      <member>
                          <name>user</name>
                          <value>
                            <string>${inwx_user}</string>
                          </value>
                      </member>
                      <member>
                          <name>lang</name>
                          <value>
                            <string>en</string>
                          </value>
                      </member>
                      <member>
                          <name>pass</name>
                          <value>
                            <string>${inwx_password}</string>
                          </value>
                      </member>
                      <member>
                          <name>id</name>
                          <value>
                            <int>${inwx_domain_id}</int>
                          </value>
                      </member>
                      <member>
                          <name>content</name>
                          <value>
                            <string>${wan_ip}</string>
                          </value>
                      </member>
                      <member>
                          <name>ttl</name>
                          <value>
                            <int>${record_ttl}</int>
                            </value>
                      </member>
                    </struct>
                </value>
              </param>
          </params>
        </methodCall>"
  
  curl --silent --output /dev/null --show-error --fail -X POST "${inwx_api}" -H "Content-Type: application/xml" -d "${inwx_api_xml_update_record}"
}

## Initalize nsupdate
init

# Check if there are any usable config files
if ls ${nsupdate_confd_dir}/*${nsupdate_conf_extension} > /dev/null 2>&1; then
  # Loop through config files
  for f in ${nsupdate_confd_dir}/*${nsupdate_conf_extension}
  do
    . ${f}
    chat 2 "Loading config file ${f}"

    ## Get variables from config file
    inwx_user="${INWX_USER:-$NSUPDATE_INWX_USER}"
    inwx_password="${INWX_PASSWORD:-$NSUPDATE_INWX_PASSWORD}"
    main_domain="${MAIN_DOMAIN}"
    domain="${DOMAIN}"



    RECORD_TYPE="${TYPE:-$RECORD_TYPE}" ## For backwards compatibility in config files
    RECORD_TTL="${TTL:-$RECORD_TTL}" ## For backwards compatibility in config files
    record_type="${RECORD_TYPE:-$nsupdate_record_type}"
    record_ttl="${RECORD_TTL:-$nsupdate_record_ttl}"

    ## Get domain info
    get_domain_info

    ## Get WAN IP
    get_domain_wan_ip

    ## Verbose output
    chat 2 "DOMAIN: ${domain}"
    chat 2 "RECORD TYPE: ${record_type}"
    chat 2 "RECORD TTL: ${record_ttl}"
    chat 2 "INWX DOMAIN ID: ${inwx_domain_id}"
    chat 2 "INWX IP: ${inwx_domain_ip}"

    ## Check if record needs an update and do it
    if [ "${inwx_domain_ip}" != "${wan_ip}" ]; then
      chat 0 "Updating DNS record for ${domain} [${record_type}]. Old IP: ${inwx_domain_ip}. New IP: ${wan_ip}."
      update_record ${inwx_user} ${inwx_password} ${inwx_domain_id} ${wan_ip} ${record_ttl}
    else
      chat 0 "No update required for ${domain} [${record_type}]."
    fi

    ## Clean up variables for a fresh start
    unset INWX_USER
    unset INWX_PASSWORD
    unset MAIN_DOMAIN
    unset DOMAIN
    unset RECORD_TYPE
    unset RECORD_TTL
    unset WAN_IP_COMMAND
    unset tmp_file
    unset inwx_domain_id
    unset inwx_domain_ip
    unset wan_ip
  done
else
  chat 1 "Couldn't find any usable config files. Check installation instructions."
fi