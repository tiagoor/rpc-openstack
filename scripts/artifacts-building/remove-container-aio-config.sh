#!/usr/bin/env bash
# Copyright 2017, Rackspace US, Inc.
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

## Main ----------------------------------------------------------------------

# Remove the env.d configurations that set the build to use
# container artifacts. We don't want this because container
# artifacts do not currently exist when this script is used.
sed -i.bak '/lxc_container_variant: /d' /etc/openstack_deploy/env.d/*.yml

# Remove the RPC-O default configurations that are necessary
# for deployment, but cause the build to break due to the fact
# that they require the container artifacts to be available,
# but those are not yet built.
sed -i.bak '/lxc_image_cache_server: /d' /etc/openstack_deploy/user_osa_variables_defaults.yml
sed -i.bak '/lxc_cache_default_variant: /d' /etc/openstack_deploy/user_osa_variables_defaults.yml
sed -i.bak '/lxc_cache_download_template_extra_options: /d' /etc/openstack_deploy/user_osa_variables_defaults.yml
sed -i.bak '/lxc_container_variant: /d' /etc/openstack_deploy/user_osa_variables_defaults.yml
sed -i.bak '/lxc_container_download_template_extra_options: /d' /etc/openstack_deploy/user_osa_variables_defaults.yml
