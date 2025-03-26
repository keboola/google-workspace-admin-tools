#!/bin/bash

# GAM Configuration
# This file contains common GAM settings used across scripts

# GAM executable path
GAM="/Users/maziak/bin/gam7/gam"

# Default organization unit paths
ORG_UNIT_EXTERNALS="/-externals-non-keboola-employee-accounts"
ORG_UNIT_GENEEA="/-externals-non-keboola-employee-accounts/Geneea"
ORG_UNIT_NETHOST="/-externals-non-keboola-employee-accounts/NetHost"
ORG_UNIT_REVOLGY="/-externals-non-keboola-employee-accounts/Revolgy"

# Export variables for use in other scripts
export GAM
export ORG_UNIT_EXTERNALS
export ORG_UNIT_GENEEA
export ORG_UNIT_NETHOST
export ORG_UNIT_REVOLGY 