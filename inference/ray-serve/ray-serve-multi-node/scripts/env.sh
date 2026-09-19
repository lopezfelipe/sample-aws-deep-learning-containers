#!/bin/bash
# env.sh - Single source of truth for all shared variables. No side effects.
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/env.sh"

export CLUSTER_NAME=${CLUSTER_NAME:-"eks-cluster"}
export REGION=${REGION:-"us-east-2"}
export K8S_VERSION=${K8S_VERSION:-"1.35"}
export AWS_REGION="$REGION"
export AWS_DEFAULT_REGION="$REGION"
export NAMESPACE=${NAMESPACE:-"inference"}

export SYSTEM_NODE_TYPE=${SYSTEM_NODE_TYPE:-"m7i.xlarge"}
export SYSTEM_NODE_COUNT=${SYSTEM_NODE_COUNT:-1}

# g5 has no EFA; NIXL KV-cache transfer runs over TCP on ENA.
export GPU_NODE_TYPE=${GPU_NODE_TYPE:-"g5.xlarge"}
export GPU_NODE_COUNT=${GPU_NODE_COUNT:-2}
export GPU_NODEGROUP_NAME=${GPU_NODEGROUP_NAME:-"gpu-workers"}

export DLC_IMAGE=${DLC_IMAGE:-"763104351884.dkr.ecr.${REGION}.amazonaws.com/ray:serve-llm-cuda-v1.0"}

export KUBERAY_VERSION=${KUBERAY_VERSION:-"1.4.0"}
export RAY_VERSION=${RAY_VERSION:-"2.58.0"}
export RAY_SERVICE_NAME=${RAY_SERVICE_NAME:-"ray-llm"}

export MODEL_ID=${MODEL_ID:-"qwen3.5-9b"}
export MODEL_SOURCE=${MODEL_SOURCE:-"Qwen/Qwen3.5-9B"}