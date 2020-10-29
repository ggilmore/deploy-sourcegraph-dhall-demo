let Generate = https://raw.githubusercontent.com/ggilmore/deploy-sourcegraph-dhall-demo/3.21/src/base/generate.dhall

let customizations = ./customizations.dhall

in  Generate customizations
