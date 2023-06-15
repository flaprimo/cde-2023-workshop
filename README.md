### Useful commands
* `terraform fmt -recursive`: recursively format.tf files before commit/push
* `terraform -chdir=foundation init -upgrade`: initialize new modules in a layer/env
* `terraform -chdir=foundation apply`: apply changes to layer/env
* Example datasets: https://github.com/erkansirin78/datasets/

Login with gcloud for applications:
gcloud auth application-default login --no-launch-browser