#!/bin/bash

set -x

#CMDB_ENDPOINT_READ=https://cloud-90-147-75-64.cloud.ba.infn.it/cmdb/
#CMDB_ENDPOINT_WRITE=https://cloud-90-147-75-64.cloud.ba.infn.it/couch/indigo-cmdb-v2
IAM_ACCESS_TOKEN=`oidc-token deep-cip`

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 4 ] || die "CMDB user and password are required"

CMDB_USER=$1
CMDB_PASS=$2
CMDB_ENDPOINT_READ=$3
CMDB_ENDPOINT_WRITE=$4


################
## RECAS-BARI ##
################

echo "***** RECAS-BARI *****"
echo "Getting OpenStack data from https://cloud.recas.ba.infn.it:5000/v3.."

## [RECAS-BARI] CIP:Openstack with OIDC token
cloud-info-provider-service \
    --insecure \
    --all-images \
    --os-auth-type v3oidcaccesstoken \
    --os-protocol oidc \
    --os-identity-provider deep-hdc \
    --os-access-token $IAM_ACCESS_TOKEN \
    --os-auth-url https://cloud.recas.ba.infn.it:5000/v3 \
    --os-tenant-name DEEP_DEMO \
    --os-project-domain-name default \
    --middleware openstack \
    --format cmdb \
    --yaml-file /cip/sites/os.RECAS-BARI.yaml \
    --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                 --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                 --cmdb-db-user $CMDB_USER \
                                                                                 --cmdb-db-pass $CMDB_PASS

echo ""

## [RECAS-BARI] CIP:Mesos with OIDC token
for endpoint in mesos marathon chronos; do
    echo "Getting Mesos data from https://mesos.recas.ba.infn.it/${endpoint}.."
    cloud-info-provider-service \
        --middleware mesos \
        --format cmdb \
        --mesos-cacert /etc/ssl/certs \
        --mesos-framework $endpoint \
        --mesos-endpoint https://mesos.recas.ba.infn.it/${endpoint} \
        --oidc-auth-bearer-token $IAM_ACCESS_TOKEN \
        --yaml-file /cip/sites/mesos.RECAS-BARI.yaml \
        --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                     --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                     --cmdb-db-user $CMDB_USER \
                                                                                     --cmdb-db-pass $CMDB_PASS
    echo ""
done


###############
## IFCA-LCG2 ##
###############

echo "***** IFCA-LCG2 *****"
echo "Getting OpenStack data from https://api.cloud.ifca.es:5000/v3.."

## [IFCA-LCG2] CIP:Openstack with OIDC token
cloud-info-provider-service \
    --insecure \
    --os-auth-type v3oidcaccesstoken \
    --os-protocol openid \
    --os-identity-provider deep-hdc \
    --os-access-token $IAM_ACCESS_TOKEN \
    --os-auth-url https://api.cloud.ifca.es:5000/v3 \
    --os-project-domain-name default \
    --os-tenant-name deep-hybrid-datacloud.eu \
    --middleware openstack \
    --format cmdb \
    --all-images \
    --property-flavor-gpu-number gpu:number  \
    --property-flavor-gpu-vendor gpu:vendor \
    --property-flavor-gpu-model gpu:model \
    --property-image-gpu-driver gpu:driver:version \
    --property-image-gpu-cuda gpu:cuda:version \
    --property-image-gpu-cudnn gpu:cudnn:version \
    --yaml-file /cip/sites/os.IFCA-LCG2.yaml \
    --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                 --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                 --cmdb-db-user $CMDB_USER \
                                                                                 --cmdb-db-pass $CMDB_PASS

## [IFCA-LCG2] CIP:Mesos with OIDC token
for endpoint in mesos marathon; do
    echo "Getting Mesos data from https://mesos.cloud.ifca.es/${endpoint}.."
    cloud-info-provider-service \
        --middleware mesos \
        --format cmdb \
        --mesos-cacert /etc/ssl/certs \
        --mesos-framework $endpoint \
        --mesos-endpoint https://mesos.cloud.ifca.es/${endpoint} \
        --oidc-auth-bearer-token $IAM_ACCESS_TOKEN \
        --yaml-file /cip/sites/mesos.IFCA-LCG2.yaml \
        --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                     --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                     --cmdb-db-user $CMDB_USER \
                                                                                     --cmdb-db-pass $CMDB_PASS
    echo ""
done

echo "Getting Oneprovider data from https://onezone.cloud.cnaf.infn.it/api/v3.."
cloud-info-provider-service \
    --middleware onedata \
    --format cmdb \
    --onezone-api-url https://onezone.cloud.cnaf.infn.it/api/v3 \
    --oidc-x-auth-token $IAM_ACCESS_TOKEN \
    --oidc-idp-prefix deep-hdc \
    --yaml-file /cip/sites/oneprovider.IFCA-LCG2.yaml \
    --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                 --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                 --cmdb-db-user $CMDB_USER \
                                                                                 --cmdb-db-pass $CMDB_PASS

###########
### PSNC ##
###########
#
#echo "***** PSNC *****"
#
### [PSNC] CIP:Mesos with OIDC token
#for endpoint in marathon chronos; do
#    echo "Getting Mesos data from https://cereus.man.poznan.pl/api-${endpoint}.."
#    cloud-info-provider-service \
#        --middleware mesos \
#        --format cmdb \
#        --mesos-cacert /etc/ssl/certs \
#        --mesos-framework $endpoint \
#        --mesos-endpoint https://cereus.man.poznan.pl/api-${endpoint} \
#        --oidc-auth-bearer-token $IAM_ACCESS_TOKEN \
#        --yaml-file /cip/sites/mesos.PSNC.yaml \
#        --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
#                                                                                     --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
#                                                                                     --cmdb-db-user $CMDB_USER \
#                                                                                     --cmdb-db-pass $CMDB_PASS
#    echo ""
#done


######################
## IISAS-Bratislava ##
######################

echo "***** IISAS-Bratislava *****"

## [IISAS-Bratislava] CIP:Mesos with OIDC token
for endpoint in marathon chronos; do
    echo "Getting Mesos data from https://mesos.ui.sav.sk/${endpoint}.."
    cloud-info-provider-service \
        --middleware mesos \
        --format cmdb \
        --mesos-cacert /etc/ssl/certs \
        --mesos-framework $endpoint \
        --mesos-endpoint https://mesos.ui.sav.sk/${endpoint} \
        --oidc-auth-bearer-token $IAM_ACCESS_TOKEN \
        --yaml-file /cip/sites/mesos.IISAS-Bratislava.yaml \
        --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                     --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                     --cmdb-db-user $CMDB_USER \
                                                                                     --cmdb-db-pass $CMDB_PASS
    echo ""
done

echo "Getting Oneprovider data from https://onezone.cloud.cnaf.infn.it/api/v3.."
cloud-info-provider-service \
    --middleware onedata \
    --format cmdb \
    --onezone-api-url https://onezone.cloud.cnaf.infn.it/api/v3 \
    --oidc-x-auth-token $IAM_ACCESS_TOKEN \
    --oidc-idp-prefix deep-hdc \
    --yaml-file /cip/sites/oneprovider.IISAS-Bratislava.yaml \
    --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                 --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                 --cmdb-db-user $CMDB_USER \
                                                                                 --cmdb-db-pass $CMDB_PASS


###############
## INFN-CNAF ##
###############

echo "***** INFN-CNAF *****"
echo "Getting OpenStack data from https://horizon.cloud.cnaf.infn.it:5000/v3.."

## [RECAS-BARI] CIP:Openstack with OIDC token
cloud-info-provider-service \
    --insecure \
    --all-images \
    --os-auth-type v3oidcaccesstoken \
    --os-protocol oidc \
    --os-identity-provider deep-hdc \
    --os-access-token $IAM_ACCESS_TOKEN \
    --os-auth-url https://horizon.cloud.cnaf.infn.it:5000/v3 \
    --os-tenant-name DEEP \
    --os-project-domain-name default \
    --middleware openstack \
    --format cmdb \
    --yaml-file /cip/sites/os.INFN-CNAF.yaml \
    --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                 --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                 --cmdb-db-user $CMDB_USER \
                                                                                 --cmdb-db-pass $CMDB_PASS

###################
## AWS US-east-1 ##
###################

echo "***** AWS US-east-1 *****"

## [RECAS-BARI] CIP:Openstack with OIDC token
cloud-info-provider-service \
    --aws-region us-east-1 \
    --middleware aws \
    --format cmdb \
    --yaml-file /cip/sites/aws.US-east-1.yaml \
    --template-dir /root/cloud-info-provider-deep/etc/templates/ | bulksend2cmdb --cmdb-read-endpoint $CMDB_ENDPOINT_READ \
                                                                                 --cmdb-write-endpoint $CMDB_ENDPOINT_WRITE \
                                                                                 --cmdb-db-user $CMDB_USER \
                                                                                 --cmdb-db-pass $CMDB_PASS
