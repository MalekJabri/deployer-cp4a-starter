
namespace=cp4ba-starter2
case=5.1.6
version=23.0.2
oc project $namespace
echo "CP4BA failed to install in the correct amount of time... Cleaning up"

echo "Deleting ICP4ACluster/icp4adeploy"
oc delete ICP4ACluster/icp4adeploy --ignore-not-found


curl -s https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-cp-automation/index.yaml > cp-index.yaml
version=$(yq e ".versions.\"$case\".appVersion" cp-index.yaml)
echo "Using case $case with appVersion $version"
curl -L -O "https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-cp-automation/$case/ibm-cp-automation-$case.tgz"
tar -xvzf "ibm-cp-automation-$case.tgz"

currentDir=$(pwd)
fileName=$(ls -p $currentDir/ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs | grep -v /)
tar -xvf $currentDir/ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/$fileName

bash $currentDir/cert-kubernetes/scripts/deleteOperator.sh -n  $namespace
printf 'y' | bash $currentDir/cert-kubernetes/scripts/cp4a-uninstall-clean-up.sh

echo "Deleting namespace"
oc delete project $namespace
echo "Waiting for project to fully delete..."
sleep 180
echo "CP4BA uninstall successfully. Please rerun this pipeline to reinstall."