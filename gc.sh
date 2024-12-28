#/bin/sh
NS=${NAMESPACE}

if [ -z "${NS}" ]
then
 NS="default"
fi

HR=${AGE}

case $string in
    ''|*[!0-9]*) HR="" ;;
    *)  ;;
esac

# 24hrs = day, 168 = week
if [ -z "${HR}" ]
then
  HR=168
fi

kubectl -n "${NS}" get pods -o custom-columns="NAME:.metadata.name,CREATED:.metadata.creationTimestamp" --field-selector=status.phase=Succeeded | while read name created
do
  if [ "$name" = "NAME" ]; then
    continue
  fi

  created_sec=$(date -u -d "$created" "+%s" 2>/dev/null || date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$created" "+%s" 2>/dev/null || date -u -f "%Y-%m-%dT%H:%M:%SZ" "$created" "+%s")
  now_sec=$(date -u "+%s")

  diff=$(( (now_sec - created_sec) / 3600 ))
  if [ ${diff} -gt ${HR} ]
  then
    echo "DELETE POD ${NS}/$name because age=${diff} > ${HR}"
    kubectl -n "${NS}" delete pod "${name}"
  fi
done
