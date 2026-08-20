FROM public.ecr.aws/deep-learning-containers/ray:serve-ml-cuda-v1.0.0

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY qwen_serve.py .

EXPOSE 8000

CMD ["serve", "run", "--host", "0.0.0.0", "qwen_serve:app", "--app-dir", "/app"]

# ---------------------------------------------------------------
# Build and push to Amazon ECR:
#
#   export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
#   export AWS_REGION=$(aws configure get region)
#
#   aws ecr create-repository --repository-name ray-serve-qwen --region $AWS_REGION || true
#   aws ecr get-login-password --region $AWS_REGION | \
#     docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
#
#   IMG=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ray-serve-qwen
#   docker build --push -t $IMG .
# ---------------------------------------------------------------
