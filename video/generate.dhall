let Generate = https://raw.githubusercontent.com/ggilmore/deploy-sourcegraph-dhall-demo/original/src/base/generate.dhall

let customizations = ./customizations.dhall

in  Generate customizations
