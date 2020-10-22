let Frontend/Generate = ./frontend/generate.dhall

let Cadvisor/Generate = ./cadvisor/generate.dhall

let GithubProxy/Generate = ./github-proxy/generate.dhall

let Gitserver/Generate = ./gitserver/generate.dhall

let Grafana/Generate = ./grafana/generate.dhall

let IndexedSearch/Generate = ./indexed-search/generate.dhall

let Jaeger/Generate = ./jaeger/generate.dhall

let Postgres/Generate = ./postgres/generate.dhall

let PreciseCodeIntel/Generate = ./precise-code-intel/generate.dhall

let Prometheus/Generate = ./prometheus/generate.dhall

let QueryRunner/Generate = ./query-runner/generate.dhall

let Redis/Generate = ./redis/generate.dhall

let RepoUpdater/Generate = ./repo-updater/generate.dhall

let Searcher/Generate = ./searcher/generate.dhall

let Symbols/Generate = ./symbols/generate.dhall

let SyntaxHighlighter/Generate = ./syntax-highlighter/generate.dhall

let Code-intel-db/Generate = ./code-intel-db/generate.dhall

let component = ./component.dhall

let Configuration/global = ../configuration/global.dhall

let Kubernetes/Service = ../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServiceSpec =
      ../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Kubernetes/ServicePort =
      ../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/StorageClass =
      ../deps/k8s/schemas/io.k8s.api.storage.v1.StorageClass.dhall

let Kubernetes/ObjectMeta =
      ../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Generate =
        ( λ(c : Configuration/global.Type) →
            { Base =
              { StorageClass.sourcegraph = Kubernetes/StorageClass::{
                , metadata = Kubernetes/ObjectMeta::{
                  , labels = Some
                    [ { mapKey = "deploy", mapValue = "sourcegraph" } ]
                  , name = Some "sourcegraph"
                  }
                , parameters = Some [ { mapKey = "type", mapValue = "pd-ssd" } ]
                , provisioner = "kubernetes.io/gce-pd"
                , reclaimPolicy = Some "Retain"
                }
              , Service.backend = Kubernetes/Service::{
                , metadata = Kubernetes/ObjectMeta::{
                  , annotations = Some
                    [ { mapKey = "description"
                      , mapValue =
                          "Dummy service that prevents backend pods from being scheduled on the same node if possible."
                      }
                    ]
                  , labels = Some
                    [ { mapKey = "deploy", mapValue = "sourcegraph" }
                    , { mapKey = "group", mapValue = "backend" }
                    , { mapKey = "sourcegraph-resource-requires"
                      , mapValue = "no-cluster-admin"
                      }
                    ]
                  , name = Some "backend"
                  }
                , spec = Some Kubernetes/ServiceSpec::{
                  , clusterIP = Some "None"
                  , ports = Some
                    [ Kubernetes/ServicePort::{
                      , name = Some "unused"
                      , port = 10811
                      , targetPort = Some
                          (< Int : Natural | String : Text >.Int 10811)
                      }
                    ]
                  , selector = Some
                    [ { mapKey = "group", mapValue = "backend" } ]
                  , type = Some "ClusterIP"
                  }
                }
              }
            , Frontend = Frontend/Generate c
            , Cadvisor = Cadvisor/Generate c
            , Github-Proxy = GithubProxy/Generate c
            , Gitserver = Gitserver/Generate c
            , Grafana = Grafana/Generate c
            , Indexed-Search = IndexedSearch/Generate c
            , Jaeger = Jaeger/Generate c
            , Pgsql = Postgres/Generate c
            , Precise-Code-Intel = PreciseCodeIntel/Generate c
            , Prometheus = Prometheus/Generate c
            , Query-Runner = QueryRunner/Generate c
            , Redis = Redis/Generate c
            , Repo-Updater = RepoUpdater/Generate c
            , Searcher = Searcher/Generate c
            , Symbols = Symbols/Generate c
            , Syntect-Server = SyntaxHighlighter/Generate c
            , Codeintel-Db = Code-intel-db/Generate c
            }
        )
      : ∀(c : Configuration/global.Type) → component

in  Generate
