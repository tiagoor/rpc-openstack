#!/usr/bin/env bash
#
# Copyright 2014-2017, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Shell Opts ----------------------------------------------------------------
set -e -u -x

## Functions -----------------------------------------------------------------

export BASE_DIR=${BASE_DIR:-"/opt/rpc-openstack"}
source ${BASE_DIR}/scripts/functions.sh

## Main ----------------------------------------------------------------------

# Check the openstack-ansible submodule status
check_submodule_status

# Get minimum disk size
DATA_DISK_MIN_SIZE="$((1024**3 * $(awk '/bootstrap_host_data_disk_min_size/{print $2}' ${OA_DIR}/tests/roles/bootstrap-host/defaults/main.yml) ))"
# Determine the largest secondary disk device available for repartitioning which meets the minimum size requirements
DATA_DISK_DEVICE=$(lsblk -brndo NAME,TYPE,RO,SIZE | \
                   awk '/d[b-z]+ disk 0/{ if ($4>m && $4>='$DATA_DISK_MIN_SIZE'){m=$4; d=$1}}; END{print d}')
# Only set the secondary disk device option if there is one
if [ -n "${DATA_DISK_DEVICE}" ]; then
  export BOOTSTRAP_OPTS="${BOOTSTRAP_OPTS} bootstrap_host_data_disk_device=${DATA_DISK_DEVICE}"
fi

# Run AIO bootstrap playbook
openstack-ansible -vvv ${BASE_DIR}/scripts/bootstrap-aio.yml \
                  -i "localhost," -c local \
                  -e "${BOOTSTRAP_OPTS}"

# Bootstrap ironic as well
openstack-ansible -vvv ${BASE_DIR}/scripts/bootstrap-ironic.yml -i "localhost," -c local

if ! apt_artifacts_available; then
  # Remove the AIO configuration relating to the use
  # of apt artifacts. This needs to be done because
  # the apt artifacts do not exist yet.
  sed -i '/^rpco_mirror_base_url/,$d' /etc/openstack_deploy/user_osa_variables_defaults.yml
fi

# If there are no container artifacts for this release, then remove the container artifact configuration
if ! container_artifacts_available; then
  # Remove the AIO configuration relating to the use
  # of container artifacts. This needs to be done
  # because the container artifacts do not exist yet.
  ./scripts/artifacts-building/remove-container-aio-config.sh
fi
