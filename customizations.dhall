let Sourcegraph/Configuration =
      https://raw.githubusercontent.com/ggilmore/deploy-sourcegraph-dhall-demo/original/src/configuration/global.dhall

let c
    : Sourcegraph/Configuration.Type
    = Sourcegraph/Configuration::{=}
    --   with Frontend.Deployment.replicas = Some 2
    --   with Gitserver.StatefulSet.Containers.Gitserver.resources.limits.cpu = Some "8"
    --   with Gitserver.StatefulSet.persistentVolumeSize = Some "400Gi"

in  c
