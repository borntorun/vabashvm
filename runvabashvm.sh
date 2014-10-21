sh -n vabashvm.sh
[[ ! $? -eq 0 ]] && exit 1
#printf "%s\n" $*
vabashvm.sh $*
