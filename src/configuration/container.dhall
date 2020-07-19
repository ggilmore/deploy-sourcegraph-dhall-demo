let Kubernetes/EnvVar = ../deps/k8s/schemas/io.k8s.api.core.v1.EnvVar.dhall

let Resources = ./container-resources.dhall

let configuration =
      { Type =
          { image : Optional Text
          , resources : Resources.Type
          , additionalEnvironmentVariables :
              Optional (List Kubernetes/EnvVar.Type)
          }
      , default =
        { image = None Text
        , resources = Resources.default
        , additionalEnvironmentVariables = None (List Kubernetes/EnvVar.Type)
        }
      }

in  configuration
