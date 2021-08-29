#!/bin/bash
DIRNAME=`dirname $0`

usage(){
  cat 1>&2 << EOF
Usage: $0 [-h] [-n ARGOCD_NS] [-f VALUES_FILE] 

Upgrade or installs the chart in ${DIRNAME}/argocd in a specific namespace and with a specific values file if options are provided.

  -f        Values file to use. Default: ${DIRNAME}/argocd/values.yaml

  -n        Namespace to install argocd. Default: argocd

  -y        Don't ask for confirmation

  -h        Display help

EOF
}

OPTSPEC=":f:n:y"

while getopts "$OPTSPEC" OPT; do
  case $OPT in
    f)
      if [ -z ${VALUES_FILE+x} ];then
        VALUES_FILE=$OPTARG
      fi
      ;;
    n)
      if [ -z ${ARGOCD_NS+x} ];then
        ARGOCD_NS=$OPTARG
      fi
      ;;
    y)
      CONFIRM=y
      ;;
    \?)
      usage
      exit 1
      ;;
    :)
      echo "ERROR: Option -$OPTARG requires a value.\n" >&2
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z ${VALUES_FILE+x} ]; then
  VALUES_FILE="${DIRNAME}/argo-cd/values.yaml"
fi

if [ -f $VALUES_FILE ]; then
  echo "INFO: Using values file $VALUES_FILE"
else
  echo "ERROR: No file exist $VALUES_FILE"
  exit 1
fi

if [ -z ${ARGOCD_NS+x} ];then
  ARGOCD_NS='argocd'
fi

echo "INFO: Argocd will be installed on '$ARGOCD_NS' namespace with values file '$VALUES_FILE'"
if [ -z ${CONFIRM+x} ]; then
  echo -n "Do you want to proceed? [y/n]: "
  read CONFIRM
fi
if [ "$CONFIRM" == "y" ]; then
  helm upgrade --install argocd ${DIRNAME}/argo-cd \
    --namespace=$ARGOCD_NS \
    --create-namespace \
    -f $VALUES_FILE
else
  echo "INFO: Exit without any action"
  exit 0
fi

