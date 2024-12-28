# Kubernetes Garbage Collection

GC stray pods that have completed successfully

# Reasoning 

Teamcity's agentless kubernetes integration does not appear to tidy up after itself.
Which makes sense, as you may want to examine the pods, or logs if something has gone wrong.
However, automating deletion makes sense.

Longhorn.io's backup cronjobs don't appear to have a TTL set, possibly for similar reasons.
Again, automating deletion makes sense here also.

At least until both systems decide to implement their own deletion policies

# Usage

Here I'm going to be using a Job that will GC my teamcity setup (see files for an example teamcity cronjob)
I run all my jobs in the namespace `work-teamcity` setting the following environment variables:

* NAMESPACE = default
* AGE = 168 hours (one week)

If not set, the defaults are `default` and `168` (one week in hours).

The `command:` stanza is there for debugging, as the containers' entrypoint runs `bash gc.sh` without the `-ex` options. You can safely remove it.

The service account `teamcity` is set as per the jetbrains instructions, but the minimum permissions needed would possibly be:

* namespaces (list,get)
* pods (get/list/delete)

Finally the `ttlSecondsAfterFinished` can be set to zero, to immediately tidy up after itself, but if you're debugging you can remove it

## Example
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: gc
  namespace: work-teamcity
spec:
  template:
    spec:
      restartPolicy: Never
      serviceAccountName: teamcity
      containers:
      - env:
          - name: NAMESPACE
            value: "work-teamcity"
          - name: AGE
            value: "168"
        name: gc
        image: opless/kube-gc:latest
        command: ["/bin/bash","-ex","gc.sh"]
  backoffLimit: 4
  ttlSecondsAfterFinished: 10
```
