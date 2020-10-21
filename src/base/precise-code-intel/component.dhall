let Kubernetes/Deployment =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/Service = ../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let component =
      { Deployment :
          { precise-code-intel-bundle-manager : Kubernetes/Deployment.Type
          , precise-code-intel-worker : Kubernetes/Deployment.Type
          }
      , Service :
          { precise-code-intel-bundle-manager : Kubernetes/Service.Type
          , precise-code-intel-worker : Kubernetes/Service.Type
          }
      , PersistentVolumeClaim :
          { bundle-manager : Kubernetes/PersistentVolumeClaim.Type }
      }

in  component
