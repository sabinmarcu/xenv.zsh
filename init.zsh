if ! command -v _xenv_remove_variable &> /dev/null; then 
  function _xenv_remove_variable() {
    local removeVar=$1
    local -a vars=(${@:2})

    local -a newVars=()
    for key value in ${vars[@]}; do
      if [ $key != $removeVar ]; then
        newVars+=(
          $key $value
        )
      fi
    done

    echo ${newVars[@]}
  }
fi

if ! command -v xenv &> /dev/null; then
  function xenv() {
    if ! [ -f .env ]; then 
      echo "No .env file found!" 1>&2
    fi

    local -a vars=()
    for line in $(cat .env); do
      local key=$(echo $line | cut -d'=' -f1)
      local value=$(echo $line | cut -d'=' -f2)
      vars+=(
        $key $value
      )
    done

    # Print all variables
    if [ -z $1 ]; then
      echo "Environment variables:" 1>&2
      for key value in ${vars[@]}; do
        echo "$key=$value"
      done
      return 0
    fi

    local var=$1
    local removeVar=$(echo $1 | grep -E '^-' | sed 's/^-//g')

    # If there's no removing
    if [ -z $removeVar ]; then
      # Print the value of the variable
      if [ -z $2 ]; then
        for key value in ${vars[@]}; do
          if [ $key == $var ]; then
            echo "$value"
            return 0
          fi
        done
        return 0
      fi

      # Update the value of the variable
      local newValue=$2
      local -a newVars=($(_xenv_remove_variable $var ${vars[@]}))
      newVars+=($var $newValue)
      vars=(${newVars[@]})
    else
      # If a variable has to be removed
      vars=($(_xenv_remove_variable $removeVar ${vars[@]}))
    fi


    # Finally, write to file
    echo "" > .env
    for key value in ${vars[@]}; do
      echo "$key=$value" >> .env
    done
  }
fi
