let Kubernetes = ../../deps/k8s/schemas.dhall

let Configuration/global = ../../configuration/global.dhall

let component = ./component.dhall

let Service/generate =
      λ(c : Configuration/global.Type) →
        let service =
              Kubernetes.Service::{
              , metadata = Kubernetes.ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "prometheus.io/port", mapValue = "6060" }
                  , { mapKey = "sourcegraph.prometheus/scrape"
                    , mapValue = "true"
                    }
                  ]
                , labels = Some
                  [ { mapKey = "app", mapValue = "searcher" }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "searcher"
                }
              , spec = Some Kubernetes.ServiceSpec::{
                , ports = Some
                  [ Kubernetes.ServicePort::{
                    , name = Some "http"
                    , port = 3181
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  , Kubernetes.ServicePort::{
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
        let deployment =
              Kubernetes.Deployment::{
              , metadata = Kubernetes.ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "description"
                    , mapValue = "Backend for text search operations."
                    }
                  ]
                , labels = Some
                  [ { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "searcher"
                }
              , spec = Some Kubernetes.DeploymentSpec::{
                , minReadySeconds = Some 10
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes.LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = "searcher" } ]
                  }
                , strategy = Some Kubernetes.DeploymentStrategy::{
                  , rollingUpdate = Some Kubernetes.RollingUpdateDeployment::{
                    , maxSurge = Some (< Int : Natural | String : Text >.Int 1)
                    , maxUnavailable = Some
                        (< Int : Natural | String : Text >.Int 1)
                    }
                  , type = Some "RollingUpdate"
                  }
                , template = Kubernetes.PodTemplateSpec::{
                  , metadata = Kubernetes.ObjectMeta::{
                    , labels = Some
                      [ { mapKey = "app", mapValue = "searcher" }
                      , { mapKey = "deploy", mapValue = "sourcegraph" }
                      ]
                    }
                  , spec = Some Kubernetes.PodSpec::{
                    , containers =
                      [ Kubernetes.Container::{
                        , env = Some
                          [ Kubernetes.EnvVar::{
                            , name = "SEARCHER_CACHE_SIZE_MB"
                            , value = Some "100000"
                            }
                          , Kubernetes.EnvVar::{
                            , name = "POD_NAME"
                            , valueFrom = Some Kubernetes.EnvVarSource::{
                              , fieldRef = Some Kubernetes.ObjectFieldSelector::{
                                , fieldPath = "metadata.name"
                                }
                              }
                            }
                          , Kubernetes.EnvVar::{
                            , name = "CACHE_DIR"
                            , value = Some "/mnt/cache/\$(POD_NAME)"
                            }
                          ]
                        , image = Some
                            "index.docker.io/sourcegraph/searcher:3.17.2@sha256:7813d44b378e6ce9f85bbe8a378a6b671f525545369fc4d8b22984cd9bffe4b1"
                        , name = "searcher"
                        , ports = Some
                          [ Kubernetes.ContainerPort::{
                            , containerPort = 3181
                            , name = Some "http"
                            }
                          , Kubernetes.ContainerPort::{
                            , containerPort = 6060
                            , name = Some "debug"
                            }
                          ]
                        , readinessProbe = Some Kubernetes.Probe::{
                          , failureThreshold = Some 1
                          , httpGet = Some Kubernetes.HTTPGetAction::{
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , periodSeconds = Some 1
                          }
                        , resources = Some Kubernetes.ResourceRequirements::{
                          , limits = Some
                            [ { mapKey = "cpu", mapValue = "2" }
                            , { mapKey = "memory", mapValue = "2G" }
                            ]
                          , requests = Some
                            [ { mapKey = "cpu", mapValue = "500m" }
                            , { mapKey = "memory", mapValue = "500M" }
                            ]
                          }
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , volumeMounts = Some
                          [ Kubernetes.VolumeMount::{
                            , mountPath = "/mnt/cache"
                            , name = "cache-ssd"
                            }
                          ]
                        }
                      , Kubernetes.Container::{
                        , args = Some
                          [ "--reporter.grpc.host-port=jaeger-collector:14250"
                          , "--reporter.type=grpc"
                          ]
                        , env = Some
                          [ Kubernetes.EnvVar::{
                            , name = "POD_NAME"
                            , valueFrom = Some Kubernetes.EnvVarSource::{
                              , fieldRef = Some Kubernetes.ObjectFieldSelector::{
                                , apiVersion = Some "v1"
                                , fieldPath = "metadata.name"
                                }
                              }
                            }
                          ]
                        , image = Some
                            "index.docker.io/sourcegraph/jaeger-agent:3.17.2@sha256:a29258e098c7d23392411abd359563afdd89529e9852ce1ba73f80188a72fd5c"
                        , name = "jaeger-agent"
                        , ports = Some
                          [ Kubernetes.ContainerPort::{
                            , containerPort = 5775
                            , protocol = Some "UDP"
                            }
                          , Kubernetes.ContainerPort::{
                            , containerPort = 5778
                            , protocol = Some "TCP"
                            }
                          , Kubernetes.ContainerPort::{
                            , containerPort = 6831
                            , protocol = Some "UDP"
                            }
                          , Kubernetes.ContainerPort::{
                            , containerPort = 6832
                            , protocol = Some "UDP"
                            }
                          ]
                        , resources = Some Kubernetes.ResourceRequirements::{
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
                    , securityContext = Some Kubernetes.PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    , volumes = Some
                      [ Kubernetes.Volume::{
                        , emptyDir = Some Kubernetes.EmptyDirVolumeSource::{=}
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
            { Deployment = Deployment/generate c, Service = Service/generate c }
        )
      : ∀(c : Configuration/global.Type) → component

in  Generate
