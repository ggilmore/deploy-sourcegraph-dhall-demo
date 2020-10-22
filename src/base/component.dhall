let Frontend/Component = ./frontend/component.dhall

let Cadvisor/Component = ./cadvisor/component.dhall

let GithubProxy/Component = ./github-proxy/component.dhall

let Gitserver/Component = ./gitserver/component.dhall

let Grafana/Component = ./grafana/component.dhall

let IndexedSearch/Component = ./indexed-search/component.dhall

let Jaeger/Component = ./jaeger/component.dhall

let Postgres/Component = ./postgres/component.dhall

let PreciseCodeIntel/Component = ./precise-code-intel/component.dhall

let Prometheus/Component = ./prometheus/component.dhall

let QueryRunner/Component = ./query-runner/component.dhall

let Redis/Component = ./redis/component.dhall

let RepoUpdater/Component = ./repo-updater/component.dhall

let Searcher/Component = ./searcher/component.dhall

let Symbols/Component = ./symbols/component.dhall

let SyntaxHighlighter/Component = ./syntax-highlighter/component.dhall

let Codeintel-db/Component = ./code-intel-db/component.dhall

let Kubernetes/Service = ../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/StorageClass =
      ../deps/k8s/schemas/io.k8s.api.storage.v1.StorageClass.dhall

let component =
      { Base :
          { Service : { backend : Kubernetes/Service.Type }
          , StorageClass : { sourcegraph : Kubernetes/StorageClass.Type }
          }
      , Frontend : Frontend/Component
      , Cadvisor : Cadvisor/Component
      , Github-Proxy : GithubProxy/Component
      , Gitserver : Gitserver/Component
      , Grafana : Grafana/Component
      , Indexed-Search : IndexedSearch/Component
      , Jaeger : Jaeger/Component
      , Pgsql : Postgres/Component
      , Precise-Code-Intel : PreciseCodeIntel/Component
      , Prometheus : Prometheus/Component
      , Query-Runner : QueryRunner/Component
      , Redis : Redis/Component
      , Repo-Updater : RepoUpdater/Component
      , Searcher : Searcher/Component
      , Symbols : Symbols/Component
      , Syntect-Server : SyntaxHighlighter/Component
      , Codeintel-Db : Codeintel-db/Component
      }

in  component
