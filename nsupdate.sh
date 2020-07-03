#!/usr/bin/env bash

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

# check required tools
command -v curl &> /dev/null || { echo >&2 "I require curl but it's not installed. Note: all needed items are listed in the README.md file."; exit 1; }
command -v awk &> /dev/null || { echo >&2 "I require awk but it's not installed. Note: all needed items are listed in the README.md file."; exit 1; }
command -v drill &> /dev/null || command -v nslookup &> /dev/null || { echo >&2 "I need drill or nslookup installed. Note: all needed items are listed in the README.md file."; exit 1; }
command -v xmllint &> /dev/null || { echo >&2 "I recommend xmllint but it's not installed. Note: all needed items are listed in the README.md file."; NO_XMLLINT="true";}

LOG=$0.log
SILENT=NO

# Check if there are any usable config files
if ls $(dirname $0)/nsupdate.d/*.config &> /dev/null; then
   # Loop through configs
   for f in $(dirname $0)/nsupdate.d/*.config
   do
      # Config files could be much cleaner by containing only relevant settings.
      # If your User and Password is always the same just set it here once and delete it in the config files.
      #INWX_USER="Username"
      #INWX_PASS="Password"
      # Resets previous set variables to catch wrong or not configured settings and set defaults.
      MAIN_DOMAIN=
      DOMAIN=
      INWX_DOMAIN_ID="unset"
      TTL=300
      TYPE=A
      CONNECTION_TYPE=4
      # For backward compatability the following options remain in this script
      IPV6="NO"
      MX="NO"

      source $f

      if [[ "$SILENT" == "NO" ]]; then
         echo "Starting nameserver update with config file $f ($LOG)"
      fi

      if [[ "$TYPE" == "A" ]]; then
          CONNECTION_TYPE=4
      fi

      ## Set record type to MX
      if [[ "$MX" == "YES" ]]; then
         TYPE=MX
      fi

      ## Set record type to IPv6
      if [[ "$IPV6" == "YES" ]]; then
         TYPE=AAAA
      fi

      if [[ "$TYPE" == "AAAA" ]]; then
         CONNECTION_TYPE=6
      fi

      if [[ "$USE_DRILL" == "YES" ]]; then
         if [[ "$TYPE" == "MX" ]]; then
            echo looking up MX records with drill currently not supported!
            exit 1
         else
            NSLOOKUP=$(drill $DOMAIN @ns.inwx.de $TYPE | head -7 | tail -1 | awk '{print $5}')
         fi
      else
         if [[ "$TYPE" == "MX" ]]; then
            PART_NSLOOKUP=$(nslookup -sil -type=$TYPE $DOMAIN - ns.inwx.de | tail -2 | head -1 | cut -d' ' -f5)
            NSLOOKUP=${PART_NSLOOKUP%"."}
         else
            NSLOOKUP=$(nslookup -sil -type=$TYPE $DOMAIN - ns.inwx.de | tail -2 | head -1 | cut -d' ' -f2)
         fi
      fi

      # WAN_IP=`curl -s -$CONNECTION_TYPE ${IP_CHECK_SITE}| grep -Eo '\<[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3}\>'`
      WAN_IP=$(curl -s -$CONNECTION_TYPE ${IP_CHECK_SITE})

      # This is relevant for getting the specific domain record id.
      API_XML_INFO="<?xml version=\"1.0\"?>
      <methodCall>
      <methodName>nameserver.info</methodName>
      <params>
         <param>
            <value>
               <struct>
                  <member>
                     <name>user</name>
                     <value>
                        <string>$INWX_USER</string>
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
                        <string>$INWX_PASS</string>
                     </value>
                  </member>
                  <member>
                     <name>domain</name>
                     <value>
                        <string>$MAIN_DOMAIN</string>
                     </value>
                  </member>
                  <member>
                     <name>name</name>
                     <value>
                        <string>$DOMAIN</string>
                     </value>
                  </member>
                  <member>
                     <name>type</name>
                     <value>
                        <string>$TYPE</string>
                     </value>
                  </member>
               </struct>
            </value>
         </param>
      </params>
      </methodCall>"

      # The full xpath is
      # XPATH='string(/methodResponse/params/param/value/struct/member[name="resData"]/value/struct/member[name="record"]/value/array/data/value/struct/member[name="id"]/value/int)'
      # A short version of the xpath
      XPATH='string(//member[name="id"]/value/int/text())'
      if [[ "$NO_XMLLINT" != "true" ]]; then
         if [[ "$NSLOOKUP" != "$WAN_IP" ]]; then
            if [[ "$INWX_DOMAIN_ID" == "unset" ]]; then
               INWX_DOMAIN_ID=$(curl -s   -X POST https://api.domrobot.com/xmlrpc/ \
               -H "Content-Type: application/xml" \
               -d "$API_XML_INFO" \
               | xmllint --xpath $XPATH -)
               if [[ "$SILENT" == "NO" ]]; then
                  echo $(printf "%s - The %s-Type Record-ID of %s is: %s" "$(date)" "$TYPE" "$DOMAIN" "$INWX_DOMAIN_ID")>>$LOG
               fi
            fi
         fi
      fi

      API_XML_UPDATE_RECORD="<?xml version=\"1.0\"?>
      <methodCall>
         <methodName>nameserver.updateRecord</methodName>
         <params>
            <param>
               <value>
                  <struct>
                     <member>
                        <name>user</name>
                        <value>
                           <string>$INWX_USER</string>
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
                           <string>$INWX_PASS</string>
                        </value>
                     </member>
                     <member>
                        <name>id</name>
                        <value>
                           <int>$INWX_DOMAIN_ID</int>
                        </value>
                     </member>
                     <member>
                        <name>content</name>
                        <value>
                           <string>$WAN_IP</string>
                        </value>
                     </member>
                     <member>
                        <name>ttl</name>
                        <value>
                           <int>$TTL</int>
                           </value>
                     </member>
                  </struct>
               </value>
            </param>
         </params>
      </methodCall>"

      if [[ "$NSLOOKUP" != "$WAN_IP" ]]; then
         curl -s -X POST https://api.domrobot.com/xmlrpc/ \
         -H "Content-Type: application/xml" \
         -d "$API_XML_UPDATE_RECORD"

         if [[ "$SILENT" == "NO" ]]; then
            echo "$(date) - $DOMAIN updated. Old IP: "$NSLOOKUP "New IP: "$WAN_IP >> $LOG
         fi
      else
         if [[ "$SILENT" == "NO" ]]; then
            echo "$(date) - No update needed for $DOMAIN. Current IP: "$NSLOOKUP >> $LOG
         fi
      fi

      unset TYPE
      unset MAIN_DOMAIN
      unset DOMAIN
      unset IPV6
      unset MX
      unset WAN_IP
      unset TTL
      unset NSLOOKUP
      unset INWX_PASS
      unset INWX_USER
      unset INWX_DOMAIN_ID
      unset API_XML_UPDATE_RECORD
      unset API_XML_INFO
   done
else
   echo "There does not seem to be any config file available in $(dirname $0)/nsupdate.d/."
   exit 1
fi
