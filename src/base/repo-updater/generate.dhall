let Optional/default =
      https://prelude.dhall-lang.org/v17.0.0/Optional/default sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Kubernetes/RollingUpdateDeployment =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.RollingUpdateDeployment.dhall

let Kubernetes/ObjectFieldSelector =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let Kubernetes/Container =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/Deployment =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/DeploymentSpec =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentSpec.dhall

let Kubernetes/DeploymentStrategy =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.DeploymentStrategy.dhall

let Kubernetes/EnvVar = ../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Kubernetes/EnvVarSource =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.EnvVarSource.dhall

let Kubernetes/LabelSelector =
      ../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/ObjectMeta =
      ../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/PodSecurityContext =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PodSecurityContext.dhall

let Kubernetes/PodSpec = ../../deps/k8s/schemas/io.k8s.api.core.v1.PodSpec.dhall

let Kubernetes/Probe = ../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/HTTPGetAction =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall

let Kubernetes/PodTemplateSpec =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PodTemplateSpec.dhall

let Kubernetes/ResourceRequirements =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ResourceRequirements.dhall

let Kubernetes/Service = ../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/ServicePort =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ServicePort.dhall

let Kubernetes/ServiceSpec =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceSpec.dhall

let Configuration/global = ../../configuration/global.dhall

let component = ./component.dhall

let containerResources = ../../configuration/container-resources.dhall

let containerResources/tok8s = ../../util/container-resources-to-k8s.dhall

let Util/component-label = ../../util/component-label.dhall

let componentLabel = Util/component-label "repo-updater"

let Service/generate =
      λ(c : Configuration/global.Type) →
        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "prometheus.io/port", mapValue = "6060" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                  [ { mapKey = "app", mapValue = "repo-updater" }
                  , componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "repo-updater"
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "http"
                    , port = 3182
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  ]
                , selector = Some
                  [ { mapKey = "app", mapValue = "repo-updater" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let Deployment/generate =
      λ(c : Configuration/global.Type) →
        let overrides = c.RepoUpdater.Deployment.Containers.RepoUpdater

        let image =
              Optional/default
                Text
                "index.docker.io/sourcegraph/repo-updater:3.21.2@sha256:adf59a4369871412639a8cfb265ba914b006507f0a987c3de2eb6fd8ab1655e6"
                overrides.image

        let resources =
              containerResources/tok8s
                { limits =
                    containerResources.overlay
                      containerResources.Configuration::{
                      , cpu = Some "1"
                      , memory = Some "2Gi"
                      }
                      overrides.resources.limits
                , requests =
                    containerResources.overlay
                      containerResources.Configuration::{
                      , cpu = Some "1"
                      , memory = Some "500Mi"
                      }
                      overrides.resources.requests
                }

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "description"
                    , mapValue =
                        "Handles repository metadata (not Git data) lookups and updates from external code hosts and other similar services."
                    }
                  ]
                , labels = Some
                  [ componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "repo-updater"
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = "repo-updater" } ]
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes/RollingUpdateDeployment::{
                    , maxSurge = Some (< Int : Natural | String : Text >.Int 1)
                    , maxUnavailable = Some
                        (< Int : Natural | String : Text >.Int 0)
                    }
                  , type = Some "RollingUpdate"
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some
                      [ { mapKey = "app", mapValue = "repo-updater" }
                      , { mapKey = "deploy", mapValue = "sourcegraph" }
                      ]
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers =
                      [ Kubernetes/Container::{
                        , image = Some image
                        , name = "repo-updater"
                        , ports = Some
                          [ Kubernetes/ContainerPort::{
                            , containerPort = 3182
                            , name = Some "http"
                            }
                          , Kubernetes/ContainerPort::{
                            , containerPort = 6060
                            , name = Some "debug"
                            }
                          ]
                        , resources = Some resources
                        , readinessProbe = Some Kubernetes/Probe::{
                          , failureThreshold = Some 3
                          , httpGet = Some Kubernetes/HTTPGetAction::{
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , periodSeconds = Some 1
                          , timeoutSeconds = Some 5
                          }
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        }
                      , Kubernetes/Container::{
                        , args = Some
                          [ "--reporter.grpc.host-port=jaeger-collector:14250"
                          , "--reporter.type=grpc"
                          ]
                        , env = Some
                          [ Kubernetes/EnvVar::{
                            , name = "POD_NAME"
                            , valueFrom = Some Kubernetes/EnvVarSource::{
                              , fieldRef = Some Kubernetes/ObjectFieldSelector::{
                                , apiVersion = Some "v1"
                                , fieldPath = "metadata.name"
                                }
                              }
                            }
                          ]
                        , image = Some
                            "index.docker.io/sourcegraph/jaeger-agent:3.21.2@sha256:9141a2f8e46ae38193820c612df30e0911ee614a9c4f0c647b363f6ae1a1cdc2"
                        , name = "jaeger-agent"
                        , ports = Some
                          [ Kubernetes/ContainerPort::{
                            , containerPort = 5775
                            , protocol = Some "UDP"
                            }
                          , Kubernetes/ContainerPort::{
                            , containerPort = 5778
                            , protocol = Some "TCP"
                            }
                          , Kubernetes/ContainerPort::{
                            , containerPort = 6831
                            , protocol = Some "UDP"
                            }
                          , Kubernetes/ContainerPort::{
                            , containerPort = 6832
                            , protocol = Some "UDP"
                            }
                          ]
                        , resources = Some Kubernetes/ResourceRequirements::{
                          , limits = Some
                            [ { mapKey = "cpu", mapValue = "1" }
                            , { mapKey = "memory", mapValue = "500M" }
                            ]
                          , requests = Some
                            [ { mapKey = "cpu", mapValue = "100m" }
                            , { mapKey = "memory", mapValue = "100M" }
                            ]
                          }
                        }
                      ]
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    }
                  }
                }
              }

        in  deployment

let Generate =
        ( λ(c : Configuration/global.Type) →
            { Deployment.repo-updater = Deployment/generate c
            , Service.repo-updater = Service/generate c
            }
        )
      : ∀(c : Configuration/global.Type) → component

in  Generate
