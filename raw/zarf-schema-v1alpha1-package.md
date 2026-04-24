# Zarf v1alpha1 Package Schema Documentation

## Overview

The Zarf v1alpha1 schema defines the structure for Zarf package configuration files. The top-level `ZarfPackage` element requires a list of components and specifies the package kind as either "ZarfInitConfig" or "ZarfPackageConfig".

## Core Package Structure

**ZarfPackage** serves as the root configuration element and includes:

- **components** (required, minimum 1): Collection of deployable functional units
- **kind**: Package classification; defaults to "ZarfPackageConfig"
- **apiVersion**: Specification version ("zarf.dev/v1alpha1")
- **metadata**: Package identification and descriptive information
- **build**: Zarf-generated creation metadata
- **variables**: Interactive prompts for deployment customization
- **constants**: Static template values for Kubernetes resources
- **values**: Configuration file imports for templating
- **documentation**: Bundled reference materials

## Package Metadata

**ZarfMetadata** encompasses:

- **name** (required): Package identifier following lowercase alphanumeric pattern
- **version**: Author-defined version tracking
- **architecture**: Target platform (arm64, amd64)
- **description**: Usage summary
- **annotations**: OCI image-spec compliant custom metadata
- **yolo**: Deployment without prior cluster initialization in connected environments
- **allowNamespaceOverride**: Namespace customization permission
- **uncompressed**: Compression toggle

## Component Definition

**ZarfComponent** represents the primary deployment grouping and supports:

- **name** (required): Component identifier
- **description**: Purpose explanation during deployment
- **required**: Mandatory installation indicator
- **default**: Pre-selected installation state
- **charts**: Helm chart deployments
- **manifests**: Kubernetes YAML deployments via Helm
- **files**: Filesystem artifacts
- **images**: Container image references
- **repos**: Git repository sources
- **only**: Deployment filtering conditions
- **actions**: Lifecycle command automation
- **healthChecks**: Post-deployment resource validation

## Variables and Constants

**InteractiveVariable** enables runtime user input:

- **name** (required): Variable identifier (uppercase alphanumeric)
- **prompt**: User input request toggle
- **description**: Input guidance text
- **default**: Fallback value
- **pattern**: Regex validation
- **sensitive**: Log redaction flag
- **type**: "raw" or "file" handling modes

**Constant** provides static values:

- **name** (required): Template placeholder
- **value** (required): Static assignment
- **description**: Usage context
- **pattern**: Validation regex
- **autoIndent**: Multiline formatting option

## Chart and Manifest Deployment

**ZarfChart** defines Helm installations:

- **name** (required): Zarf chart identifier
- **url**: OCI registry, repository, or Git source
- **version**: Chart specification
- **releaseName**: Helm release designation
- **namespace**: Target deployment namespace
- **valuesFiles**: Local or remote override configurations
- **variables**: Chart-specific parameter definitions
- **serverSideApply**: Apply strategy ("true", "false", "auto")

**ZarfManifest** handles Kubernetes manifests:

- **name** (required): Collection identifier
- **namespace**: Deployment namespace
- **files**: YAML file references
- **kustomizations**: Kustomize configuration sources
- **template**: Go-template processing enablement

## Image and Repository Handling

**Images** appear as a string array for OCI image inclusion. **Repos** similarly use string arrays for Git repository sources. **ImageArchive** structures reference archived OCI layouts with specified image selections.

## File Deployment

**ZarfFile** manages artifact distribution:

- **source** (required): Local path or remote URL
- **target** (required): Destination path
- **executable**: File permission flag
- **extractPath**: Archive extraction specification
- **shasum**: Integrity verification
- **template**: Go-template processing option

## Actions and Lifecycle Management

**ZarfComponentActions** groups operation-specific action sets:

- **onCreate**: Package creation phase
- **onDeploy**: Installation phase
- **onRemove**: Removal phase

**ZarfComponentAction** executes commands:

- **cmd**: Command execution string
- **wait**: Condition-based continuation
- **maxRetries**: Failure recovery attempts
- **maxTotalSeconds**: Operation timeout
- **shell**: Shell preference by OS
- **setValues**: Output variable capture
- **description**: Human-readable operation summary

## Build and Version Tracking

**ZarfBuildData** records package creation details:

- **version**: Zarf CLI version used
- **timestamp**: Creation datetime
- **architecture**: Build platform
- **user**: Package creator identifier
- **terminal**: Machine hostname
- **differential**: Incremental packaging indicator
- **signed**: Signature presence flag
- **versionRequirements**: Minimum version constraints

This schema enables comprehensive package definition from simple deployments to complex multi-component systems with dynamic configuration and lifecycle automation.
