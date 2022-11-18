#!/bin/bash
logFunction(){
   timeNow=`date +%H:%M:%S`
   date=`date +%m-%d-%Y`
   message="$timeNow $1"
   echo "${message}"
}

setupDirectory(){
  logFunction "********** ${FUNCNAME[0]}: STARTED **********"
  logFunction "Setting up temp directory"
  mkdir -p support_bundle/
  logFunction "********** ${FUNCNAME[0]}: COMPLETED **********"
}

compressBundle(){
  logFunction "********** ${FUNCNAME[0]}: STARTED **********"
  logFunction "Compressing log files and removing temp directory"
  tar -czvf support_bundle.tar.gz support_bundle
  rm -rf support_bundle/
  logFunction "********** ${FUNCNAME[0]}: COMPLETED **********"
}

retrieveSupportBundle(){
  logFunction "********** ${FUNCNAME[0]}: STARTED **********"
  NS_LIST=( kore application-system flux cert-manager-http01 external-dns ingress-external )
  for NS in "${NS_LIST[@]}";
  do 
    case $NS in
      application-system) 
        logFunction "Extracting logs for pods in namespace: $NS"
        POD=`kubectl get pods -n ${NS} --no-headers | awk '{print $1}'`
        kubectl logs ${POD} -n ${NS} -c kube-app-manager > support_bundle/${POD}_kube-app-manager.log
        kubectl logs ${POD} -n ${NS} -c kube-rbac-proxy > support_bundle/${POD}_kube-rbac-proxy.log
      ;;
      *) 
        logFunction "Extracting logs for pods in namespace: $NS"
        kubectl get pods -n ${NS} --no-headers | awk '{print $1}' > pod_file
        for POD in $(cat pod_file); 
          do
              kubectl logs ${POD} -n ${NS} > support_bundle/${POD}.log
        done
      ;;
    esac
  done
  logFunction "********** ${FUNCNAME[0]}: COMPLETED **********"
}

setContext(){
  logFunction "********** ${FUNCNAME[0]}: STARTED **********"
  echo "Would you like to check more than one cluster? (Y/N)"
  read CLUSTER_RESPONSE
  case $CLUSTER_RESPONSE in 
    Y)
      kubectl config get-contexts
      echo "Please enter the clusters you wish to check using the contexts, enter all separated with spaces e.g context1 context2"
      read CONTEXTS
      for CONTEXT in $CONTEXTS 
      do 
        kubectl config use-context ${CONTEXT}
        setupDirectory
        retrieveSupportBundle
      done
    ;;
    N)
      kubectl config get-contexts
      echo "Which context would you like to use? (please use the context name you wish to use)"
      read CONTEXT
      kubectl config use-context ${CONTEXT}
      setupDirectory
      retrieveSupportBundle
    ;;
  esac
  logFunction "********** ${FUNCNAME[0]}: COMPLETED **********"
}

uploadFile() {
  logFunction "********** ${FUNCNAME[0]}: STARTED **********"
  logFunction "Uploading compressed file to Appvia support"
  curl -X PUT -T support_bundle.tar.gz "S3_PUT_URL"
  rm -rf pod_file support_bundle.tar.gz
  logFunction "********** ${FUNCNAME[0]}: COMPLETED **********"
}
  
setContext
compressBundle
uploadFile
