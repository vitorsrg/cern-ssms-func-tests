#!/usr/bin/env bash


set -e

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"


manage::main () {
	case $1 in
	"setup_ssh" )
		manage::setup_ssh
	;;
	"sync_down" )
		rsync \
			-aczP --delete --force --chmod=777 \
			"vsantaro@$(cat lxplus8_host.txt):~/" \
			"./lxplus8_home/"
	;;
	"remount" )
		manage::remount
	;;
	"build_docker" )
		manage::build_docker
	;;
	"dispatch_argo" )
		manage::dispatch_argo
	;;
	"serve_argo" )
		manage::serve_argo
	;;
	esac
}

manage::setup_ssh () {
	set -x
	printf "lxplus8s16.cern.ch" > lxplus8_host.txt

	kdestroy -A
	rm -rf ./keytab.krb
	set +x
	read -s -p "Password: " cern_password
	printf "\n"
	ktutil \
		-k ./keytab.krb \
		add \
			-p "vsantaro@CERN.CH" \
			-e arcfour-hmac-md5 \
			--password=$cern_password \
			-V 3 \
			--no-salt
	set -x
	kinit --afslog -f -kt ./keytab.krb "vsantaro@CERN.CH"
	klist -Af
}

manage::remount () {
	set -x
	umount -f "./lxplus8_home/" || true
	mkdir -p "./lxplus8_home/"
	sshfs "vsantaro@$(cat lxplus8_host.txt):./" "./lxplus8_home/"
}

manage::build_docker () {
	set -x

	cp -rf ./keytab.krb ./lxplus8-ssh-image/keytab.krb

	ssh \
		"vsantaro@$(cat lxplus8_host.txt)" \
		'export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"; openstack token issue -f json' \
		| jq -r '.id' \
		> ./lxplus8-ssh-image/os_token.txt

	
	docker build \
		-t registry.cern.ch/vsantaro/lxplus8-ssh-image \
		--build-arg lxplus8_host="$(cat lxplus8_host.txt)" \
		--squash \
		./lxplus8-ssh-image
	# Login to < https://registry.cern.ch/ > with SSO in the browser
	cat ./harbor_secret.txt \
		| docker login \
			registry.cern.ch \
			--username vsantaro \
			--password-stdin
	docker push registry.cern.ch/vsantaro/lxplus8-ssh-image
}

manage::dispatch_argo () {
	set -x

	source_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	export KUBECONFIG="$source_dir/kubeconfig.yml"

	kubectl get namespace
	./argo-darwin-amd64 \
		submit -n argo ./sample.yml # --watch
}

manage::serve_argo () {
	source_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	export KUBECONFIG="$source_dir/kubeconfig.yml"

	kubectl -n argo port-forward deployment/argo-server 2746:2746

	# ssh \
	# 	"vsantaro@$(cat lxplus8_host.txt)" \
	# 	<<-'EOS' &
	# 	set -e
	# 	export KUBECONFIG=/afs/cern.ch/user/v/vsantaro/config
	# 	export OS_PROJECT_NAME="IT Cloud Infrastructure Developers"
	# 	set -v
	# 	kubectl -n argo port-forward deployment/argo-server 2746:2746
	# EOS
	# argo_server_pid=$!

	# ssh \
	# 	-NT \
	# 	-L '2746:[::1]:2746' \
	# 	"vsantaro@$(cat lxplus8_host.txt)" \
	# 	&
	# ssh_port_forward_pid=$!

	# set -x

	# trap \
	# 	"kill $argo_server_pid || kill $ssh_port_forward_pid || true; wait" \
	# 	SIGINT SIGTERM

	# sleep inf || true
	# jobs -p
	# wait

}

manage::dispatch_job () {
	set -x

	source_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	export KUBECONFIG="$source_dir/kubeconfig.yml"

	kubectl delete job check-eos || true
	kubectl apply -f ./lxplus8-ssh-image/src/k8s-eos/job.yml
	# kubectl wait --for=condition=complete job/check-eos --timeout=-1s
	# sleep 30
	# kubectl get job check-eos -o json | jq '.status'

	while true; do
		sleep 10
		active=$(kubectl get job check-eos -o json | jq -r '.status | has("active")')
		succeeded=$(kubectl get job check-eos -o json | jq -r '.status | has("succeeded")')

		if [ "$active" = "true" ]; then
			printf "Waiting job to finish.\n"
			continue
		elif [ "$succeeded" = "true" ]; then
			printf "Job succeeded.\n"
			break
		else
			printf "Job failed.\n"
			exit -1
		fi
	done
	sleep 30
	# kubectl logs job/check-eos
	kubectl describe job/check-eos
	# kubectl explain jobs.status
	kubectl get job check-eos -o json | jq '.status'
	kubectl get job check-eos -o json | jq -r '.status.succeeded'

}

manage::main $1
