let Optional/default =
      https://prelude.dhall-lang.org/v17.0.0/Optional/default sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Kubernetes/HTTPGetAction =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.HTTPGetAction.dhall

let Kubernetes/EmptyDirVolumeSource =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.EmptyDirVolumeSource.dhall

let Kubernetes/Volume = ../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/Probe = ../../deps/k8s/schemas/io.k8s.api.core.v1.Probe.dhall

let Kubernetes/VolumeMount =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

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

let componentLabel = Util/component-label "searcher"

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
                  [ { mapKey = "app", mapValue = "searcher" }
                  , componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "searcher"
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "http"
                    , port = 3181
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  , Kubernetes/ServicePort::{
                    , name = Some "debug"
                    , port = 6060
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "debug")
                    }
                  ]
                , selector = Some [ { mapKey = "app", mapValue = "searcher" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let Deployment/generate =
      λ(c : Configuration/global.Type) →
        let overrides = c.Searcher.Deployment.Containers.Searcher

        let image =
              Optional/default
                Text
                "index.docker.io/sourcegraph/searcher:3.21.2@sha256:2b48885aabb714cea6c1b516ba5d27aca78d992b5965253f50322a8dc2b325df"
                overrides.image

        let resources =
              containerResources/tok8s
                { limits =
                    containerResources.overlay
                      containerResources.Configuration::{
                      , cpu = Some "2"
                      , memory = Some "2G"
                      }
                      overrides.resources.limits
                , requests =
                    containerResources.overlay
                      containerResources.Configuration::{
                      , cpu = Some "500m"
                      , memory = Some "500M"
                      }
                      overrides.resources.requests
                }

        let deployment =
              Kubernetes/Deployment::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "description"
                    , mapValue = "Backend for text search operations."
                    }
                  ]
                , labels = Some
                  [ componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "searcher"
                }
              , spec = Some Kubernetes/DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = "searcher" } ]
                  }
                , strategy = Some Kubernetes/DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes/RollingUpdateDeployment::{
                    , maxSurge = Some (< Int : Natural | String : Text >.Int 1)
                    , maxUnavailable = Some
                        (< Int : Natural | String : Text >.Int 1)
                    }
                  , type = Some "RollingUpdate"
                  }
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some
                      [ { mapKey = "app", mapValue = "searcher" }
                      , { mapKey = "deploy", mapValue = "sourcegraph" }
                      ]
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers =
                      [ Kubernetes/Container::{
                        , env = Some
                          [ Kubernetes/EnvVar::{
                            , name = "SEARCHER_CACHE_SIZE_MB"
                            , value = Some "100000"
                            }
                          , Kubernetes/EnvVar::{
                            , name = "POD_NAME"
                            , valueFrom = Some Kubernetes/EnvVarSource::{
                              , fieldRef = Some Kubernetes/ObjectFieldSelector::{
                                , fieldPath = "metadata.name"
                                }
                              }
                            }
                          , Kubernetes/EnvVar::{
                            , name = "CACHE_DIR"
                            , value = Some "/mnt/cache/\$(POD_NAME)"
                            }
                          ]
                        , image = Some image
                        , name = "searcher"
                        , ports = Some
                          [ Kubernetes/ContainerPort::{
                            , containerPort = 3181
                            , name = Some "http"
                            }
                          , Kubernetes/ContainerPort::{
                            , containerPort = 6060
                            , name = Some "debug"
                            }
                          ]
                        , readinessProbe = Some Kubernetes/Probe::{
                          , failureThreshold = Some 3
                          , httpGet = Some Kubernetes/HTTPGetAction::{
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , periodSeconds = Some 5
                          , timeoutSeconds = Some 5
                          }
                        , resources = Some resources
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , volumeMounts = Some
                          [ Kubernetes/VolumeMount::{
                            , mountPath = "/mnt/cache"
                            , name = "cache-ssd"
                            }
                          ]
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
                    , volumes = Some
                      [ Kubernetes/Volume::{
                        , emptyDir = Some Kubernetes/EmptyDirVolumeSource::{=}
                        , name = "cache-ssd"
                        }
                      ]
                    }
                  }
                }
              }

        in  deployment

let Generate =
        ( λ(c : Configuration/global.Type) →
            { Deployment.searcher = Deployment/generate c
            , Service.searcher = Service/generate c
            }
        )
      : ∀(c : Configuration/global.Type) → component

in  Generate
