let Optional/default =
      https://prelude.dhall-lang.org/v17.0.0/Optional/default sha256:5bd665b0d6605c374b3c4a7e2e2bd3b9c1e39323d41441149ed5e30d86e889ad

let Kubernetes/ConfigMap =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMap.dhall

let Kubernetes/ServiceAccount =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ServiceAccount.dhall

let Kubernetes/LocalObjectReference =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.LocalObjectReference.dhall

let Kubernetes/Container =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.Container.dhall

let Kubernetes/ContainerPort =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ContainerPort.dhall

let Kubernetes/LabelSelector =
      ../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let Kubernetes/ObjectMeta =
      ../../deps/k8s/schemas/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/PersistentVolumeClaimSpec =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall

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

let Kubernetes/StatefulSet =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSet.dhall

let Kubernetes/StatefulSetSpec =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetSpec.dhall

let Kubernetes/Volume = ../../deps/k8s/schemas/io.k8s.api.core.v1.Volume.dhall

let Kubernetes/VolumeMount =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.VolumeMount.dhall

let Kubernetes/ConfigMapVolumeSource =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.ConfigMapVolumeSource.dhall

let Kubernetes/StatefulSetUpdateStrategy =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.StatefulSetUpdateStrategy.dhall

let Configuration/global = ../../configuration/global.dhall

let component = ./component.dhall

let containerResources = ../../configuration/container-resources.dhall

let containerResources/tok8s = ../../util/container-resources-to-k8s.dhall

let Octal = ../../util/octal.dhall

let Util/component-label = ../../util/component-label.dhall

let componentLabel = Util/component-label "grafana"

let ServiceAccount/generate =
      λ(c : Configuration/global.Type) →
        let serviceAccount =
              Kubernetes/ServiceAccount::{
              , imagePullSecrets = Some
                [ Kubernetes/LocalObjectReference::{
                  , name = Some "docker-registry"
                  }
                ]
              , metadata = Kubernetes/ObjectMeta::{
                , labels = Some
                  [ componentLabel
                  , { mapKey = "category", mapValue = "rbac" }
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "grafana"
                }
              }

        in  serviceAccount

let ConfigMap/generate =
      λ(c : Configuration/global.Type) →
        let configMap =
              Kubernetes/ConfigMap::{
              , data = Some
                  (toMap { `datasources.yml` = ./datasources.yaml as Text })
              , metadata = Kubernetes/ObjectMeta::{
                , labels = Some
                  [ componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "grafana"
                }
              }

        in  configMap

let Service/generate =
      λ(c : Configuration/global.Type) →
        let service =
              Kubernetes/Service::{
              , metadata = Kubernetes/ObjectMeta::{
                , labels = Some
                  [ { mapKey = "app", mapValue = "grafana" }
                  , componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "grafana"
                }
              , spec = Some Kubernetes/ServiceSpec::{
                , ports = Some
                  [ Kubernetes/ServicePort::{
                    , name = Some "http"
                    , port = 30070
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  ]
                , selector = Some [ { mapKey = "app", mapValue = "grafana" } ]
                , type = Some "ClusterIP"
                }
              }

        in  service

let StatefulSet/generate =
      λ(c : Configuration/global.Type) →
        let overrides = c.Grafana.StatefulSet.Containers.Grafana

        let image =
              Optional/default
                Text
                "index.docker.io/sourcegraph/grafana:10.0.13@sha256:2d7fbbda9ae9797145a4769a1503dfbe3b78f6591afceedd6af351c95636029e"
                overrides.image

        let resources =
              containerResources/tok8s
                { limits =
                    containerResources.overlay
                      containerResources.Configuration::{
                      , cpu = Some "1"
                      , memory = Some "512Mi"
                      }
                      overrides.resources.limits
                , requests =
                    containerResources.overlay
                      containerResources.Configuration::{
                      , cpu = Some "100m"
                      , memory = Some "512Mi"
                      }
                      overrides.resources.requests
                }

        let additionalEnvironmentVariables =
              overrides.additionalEnvironmentVariables

        let statefulSet =
              Kubernetes/StatefulSet::{
              , metadata = Kubernetes/ObjectMeta::{
                , annotations = Some
                  [ { mapKey = "description"
                    , mapValue = "Metrics/monitoring dashboards and alerts."
                    }
                  ]
                , labels = Some
                  [ componentLabel
                  , { mapKey = "deploy", mapValue = "sourcegraph" }
                  , { mapKey = "sourcegraph-resource-requires"
                    , mapValue = "no-cluster-admin"
                    }
                  ]
                , name = Some "grafana"
                }
              , spec = Some Kubernetes/StatefulSetSpec::{
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector = Kubernetes/LabelSelector::{
                  , matchLabels = Some
                    [ { mapKey = "app", mapValue = "grafana" } ]
                  }
                , serviceName = "grafana"
                , template = Kubernetes/PodTemplateSpec::{
                  , metadata = Kubernetes/ObjectMeta::{
                    , labels = Some
                      [ { mapKey = "app", mapValue = "grafana" }
                      , { mapKey = "deploy", mapValue = "sourcegraph" }
                      ]
                    }
                  , spec = Some Kubernetes/PodSpec::{
                    , containers =
                      [ Kubernetes/Container::{
                        , env = additionalEnvironmentVariables
                        , image = Some image
                        , name = "grafana"
                        , ports = Some
                          [ Kubernetes/ContainerPort::{
                            , containerPort = 3370
                            , name = Some "http"
                            }
                          ]
                        , resources = Some resources
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , volumeMounts = Some
                          [ Kubernetes/VolumeMount::{
                            , mountPath = "/var/lib/grafana"
                            , name = "grafana-data"
                            }
                          , Kubernetes/VolumeMount::{
                            , mountPath =
                                "/sg_config_grafana/provisioning/datasources"
                            , name = "config"
                            }
                          ]
                        }
                      ]
                    , securityContext = Some Kubernetes/PodSecurityContext::{
                      , runAsUser = Some 0
                      }
                    , serviceAccountName = Some "grafana"
                    , volumes = Some
                      [ Kubernetes/Volume::{
                        , configMap = Some Kubernetes/ConfigMapVolumeSource::{
                          , defaultMode = Some
                              (Octal.toNatural Octal.Enum.Oo777)
                          , name = Some "grafana"
                          }
                        , name = "config"
                        }
                      ]
                    }
                  }
                , updateStrategy = Some Kubernetes/StatefulSetUpdateStrategy::{
                  , type = Some "RollingUpdate"
                  }
                , volumeClaimTemplates = Some
                  [ Kubernetes/PersistentVolumeClaim::{
                    , apiVersion = "apps/v1"
                    , metadata = Kubernetes/ObjectMeta::{
                      , name = Some "grafana-data"
                      }
                    , spec = Some Kubernetes/PersistentVolumeClaimSpec::{
                      , accessModes = Some [ "ReadWriteOnce" ]
                      , resources = Some Kubernetes/ResourceRequirements::{
                        , requests = Some
                          [ { mapKey = "storage", mapValue = "2Gi" } ]
                        }
                      , storageClassName = Some "sourcegraph"
                      }
                    }
                  ]
                }
              }

        in  statefulSet

let Generate =
        ( λ(c : Configuration/global.Type) →
            { StatefulSet.grafana = StatefulSet/generate c
            , Service.grafana = Service/generate c
            , ServiceAccount.grafana = ServiceAccount/generate c
            , ConfigMap.grafana = ConfigMap/generate c
            }
        )
      : ∀(c : Configuration/global.Type) → component

in  Generate
