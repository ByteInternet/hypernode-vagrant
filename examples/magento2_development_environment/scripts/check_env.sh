#!/bin/sh

[ ! -z $MAGENTO_MARKETPLACE_PUBLIC_KEY ] || \
    (echo "please set MAGENTO_MARKETPLACE_PUBLIC_KEY in your environment" && /bin/false)
[ ! -z $MAGENTO_MARKETPLACE_PRIVATE_KEY ] || \
    (echo "please set MAGENTO_MARKETPLACE_PRIVATE_KEY in your environment" && /bin/false)
[ ! -z $MAGENTO_ADMIN_PASSWORD ] || \
    (echo "please set MAGENTO_ADMIN_PASSWORD in your environment.\n\
For example: export MAGENTO_ADMIN_PASSWORD=admin1234" && /bin/false)
