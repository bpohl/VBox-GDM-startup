#!/bin/bash -e
# Simple install script for starting VM from GDM
#
# $Id$
# $Revision$
# $Tags$
#

# Set some defaults
: ${XSESSIONS_DIR:="/usr/share/xsessions"}
: ${SECURITY_DIR:="/etc/security/limits.d"}
: ${GDM3_CONFIG_FILE:="/etc/gdm3/custom.conf"}

# Have a nice way out
function egress () {
  [ $1 -gt 0 ] && exec >&2
  [ -n "$2" ] && echo "$2"
  cat <<EOS
Usage: $0 <vm-user> [auto]
EOS
  exit $1
}

# Make sure we have a valid user and home
[ -z "${VM_USER:="$1"}" ] && egress 1 "Error: Must specify the user to set."
: ${USER_HOME:="$(eval "cd ~$VM_USER" && pwd)"}
[ -d "$USER_HOME" ] || egress 2 \
                    "Error: Could not find home directory for user '$VM_USER'."

# Check for the config file to be sure GDM3 is available 
[ -f "$GDM3_CONFIG_FILE" ] || egress 3 \
                      "Error: Can't find GDM3 config file '$GDM3_CONFIG_FILE'."


# Prime sudo
sudo -v || exit 2

# Work from the install dir
cd "$(dirname "$0")"

# Copy files into place
  sudo -u "$VM_USER" cp -v *.Exec "${USER_HOME}/"
  sudo cp -v *.desktop "${XSESSIONS_DIR}/"

# Bail here if not setting auto login
[ "$2" != 'auto' ] && exit 0

# Short for space and tab
SP=" "$'\x09'

# See if AutomaticLogin is already enabled and if so recommend changing
#   the GDM3 configuration by hand
if egrep -q "^[^#$SP]*[$SP]*AutomaticLogin(Enable)?[$SP]*=" \
                                             "$GDM3_CONFIG_FILE"; then
  cat <<EOS
Auto Login already specifically enabled or disabled.  Edit the
file '$GDM3_CONFIG_FILE' by hand to add the appropriate settings.

    # Enabling automatic login
    AutomaticLoginEnable = True
    AutomaticLogin = $VM_USER

EOS
else
  # If AutomaticLogin is not enabled, see if it is just commented out...
  if egrep -q "^[#$SP]*AutomaticLogin[$SP]*=" "$GDM3_CONFIG_FILE" && \
      egrep -q "^[#$SP]*AutomaticLoginEnable[$SP]*=" "$GDM3_CONFIG_FILE"; then
    # ... and if so write the new setting lines below the commented ones...
    exec 9< <(cat <<EOS
s/^\([#$SP]*AutomaticLoginEnable[$SP]*=.*\)$/\1\n   AutomaticLoginEnable = True/; 
s/^\([#$SP]*AutomaticLogin[$SP]*=.*\)$/\1\n   AutomaticLogin = $VM_USER/;
EOS
             )
  else
    # ... Otherwise slip them in under the [daemon] label
    exec 9< <(cat <<EOS
s/^\(\[daemon\]\)[$SP]*$/\1\n# Enabling automatic login\n\
   AutomaticLoginEnable = True\n   AutomaticLogin = $VM_USER\n/;
EOS
             )
  fi

  # Put the original somewhere safe 
  sudo mv "$GDM3_CONFIG_FILE" "${GDM3_CONFIG_FILE}.bak"

  # Edit the config file in place but keep a backup
  sed -f <( cat <&9 ) "${GDM3_CONFIG_FILE}.bak" | \
    sudo tee "$GDM3_CONFIG_FILE" > /dev/null
fi

exit 0
