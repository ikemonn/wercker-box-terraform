#!/bin/bash
# これを参考にスクリプトを書いた →http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming

# 引数で渡されたディレクトリのファイルが変更されたか？
is_file_changed() {
  local environment=$1
  # 実行ステータスだけ取得したいので、grepの結果は出力しない
  git diff --name-only HEAD HEAD^ \
    | grep $environment/ >> /dev/null
  echo $?
}

# ファイルが変更されたディレクトリの配列を取得
get_file_change_environment_list() {
  local environment
  for environment in ${ALL_ENVIRONMENT[@]}
  do
    if [ `is_file_changed $environment` == "0" ]; then
      echo $environment
      FILE_CHANGE_ENVIRONMENT+=($environment)
    fi
  done
  echo ${FILE_CHANGE_ENVIRONMENT[@]}
}

# terraform planを与えられた環境で行う
exec_terraform_plan_per_environment() {
  local environment_list=$@
  for environment in ${environment_list[@]}
  do
    cd $TERRAFORM_DIR/$environment
    echo `pwd`
    cd -
  done
}

main() {
  readonly ALL_ENVIRONMENT=("evaluation" "staging" "production")
  readonly EVALUATION="evaluation"
  readonly STAGING="staging"
  readonly PRODUCTION="production"
  readonly TERRAFORM_DIR="terraform/aws/"

  FILE_CHANGE_ENVIRONMENT=()

  # ファイルが変更された環境を取得
  file_change_environment=`get_file_change_environment_list`
  echo ${file_change_environment[@]}

  # ファイルが変更された環境でterraform planを実行
  exec_terraform_plan_per_environment ${file_change_environment[@]}


}

main
