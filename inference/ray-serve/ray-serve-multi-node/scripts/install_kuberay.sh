#!/bin/bash
# install_kuberay.sh - Install the KubeRay operator via Helm.
#
# Usage:
#   bash install_kuberay.sh            # Install operator
#   bash install_kuberay.sh cleanup    # Uninstall operator
#
# Prerequisites: EKS cluster running (deploy_cluster.sh), helm installed.

set -eo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }
print_success() { echo -e "${GREEN}\xe2\x9c\x93 $1${NC}"; }
print_warning() { echo -e "${YELLOW}! $1${NC}"; }
print_error()   { echo -e "${RED}x $1${NC}"; }

SECONDS=0
KUBERAY_NAMESPACE="kuberay-operator"

check_prerequisites() {
    local missing=()
    command -v kubectl &>/dev/null || missing+=("kubectl")
    command -v helm &>/dev/null || missing+=("helm")

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing[*]}"
        echo "Install helm: https://helm.sh/docs/intro/install/"
        exit 1
    fi

    if ! kubectl cluster-info &>/dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Check kubeconfig."
        exit 1
    fi
    print_success "Prerequisites satisfied (kubectl, helm)"
}

cleanup() {
    print_section "Uninstalling KubeRay Operator"
    helm uninstall kuberay-operator -n "$KUBERAY_NAMESPACE" 2>/dev/null || true
    kubectl delete namespace "$KUBERAY_NAMESPACE" --ignore-not-found 2>/dev/null || true
    print_success "KubeRay operator uninstalled"
}

COMMAND=${1:-"install"}
if [ "$COMMAND" = "cleanup" ]; then
    check_prerequisites
    cleanup
    exit 0
fi

echo -e "${BLUE}"
echo "=================================================="
echo "  Install KubeRay Operator"
echo "=================================================="
echo -e "${NC}"
echo "  KubeRay version: $KUBERAY_VERSION"
echo "  Namespace:       $KUBERAY_NAMESPACE"
echo

check_prerequisites

if helm status kuberay-operator -n "$KUBERAY_NAMESPACE" &>/dev/null; then
    print_success "KubeRay operator already installed"
    kubectl get pods -n "$KUBERAY_NAMESPACE"
    exit 0
fi

print_section "Adding KubeRay Helm repo"
helm repo add kuberay https://ray-project.github.io/kuberay-helm/
helm repo update

print_section "Installing KubeRay operator (v${KUBERAY_VERSION})"
helm install kuberay-operator kuberay/kuberay-operator \
    --version "$KUBERAY_VERSION" \
    --namespace "$KUBERAY_NAMESPACE" \
    --create-namespace

print_section "Waiting for operator to be Ready"
kubectl wait --for=condition=Available deployment/kuberay-operator \
    -n "$KUBERAY_NAMESPACE" --timeout=180s

print_success "KubeRay operator installed and ready"
kubectl get pods -n "$KUBERAY_NAMESPACE"

ELAPSED_MIN=$((SECONDS / 60))
ELAPSED_SEC=$((SECONDS % 60))
echo -e "\n${BLUE}Elapsed: ${ELAPSED_MIN}m ${ELAPSED_SEC}s${NC}"
