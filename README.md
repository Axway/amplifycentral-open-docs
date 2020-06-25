# Axway-Open-Docs

Axway-Open-Docs is a docs-as-code implementation for Axway documentation. It is built using [Hugo](https://gohugo.io/) static site generator with the [Google Docsy](https://github.com/google/docsy) theme. The site is deployed on Netlify at <https://axway-open-docs.netlify.com/>

# Amplifycentral-Open-Docs

The **axway-open-docs** project in its original form contains the documentation mark ups for many Axway projects. Instead of maintaining a monolith project for all products, the documentation site is going to be broken up into many micro sites for specific products. The **amplifycentral-open-docs** repo is going to be used for the documentation of Amplify Central and Catalog. The micro site built using this repo is deployed on Netlify at <https://amplifycentral-open-docs.netlify.app/>

# Axway-Open-Docs-Common

The **amplifycnetral-open-docs** repo is missing key hugo directory structure such as **archetypes/**, **assets/**, **i18n/**, **layouts/** and **scripts/** and sub folders of **content/en/** and **static/Images/**. The contents of these folders are used to create the look and feel of the documentation site and so are common across all micro sites. They are now in a repo called **axway-open-docs-common** and this is now a git submodule.

Note that the repo **axway-open-docs-common** is not a micro site. It's the common content used by all micro sites to have a consistent look and feel.

# Local Builds

Pre-requisites:
1. hugo extended v0.66.0
1. npm

Run the provided shell script **build.sh** and it should build the site locally you can access using http://localhost:1313/.


# Netlify Configurations

After creating the micro site project on Netlify you need to configure Netlify to access **axway-open-docs-common/** since it's a private repo. To do this one will need to:
1. go to site settings -> build and deploy -> continuous deployment
1. click on the "generate public deploy key" button
1. go to https://github.com/Axway/axway-open-docs-common/settings/keys and add in the generate key

Note: the repo **axway-open-docs-common/** might not stay private .... if so then this is not needed

# Contribute

We welcome your contributions! To get started, go to <https://axway-open-docs.netlify.com/> and click **Documentation** in the top menu. Browse the documentation and use the options in the right navigation to edit any page using GitHub or Netlify CMS.

Before you start contributing, please read the [contribution guidelines](https://axway-open-docs.netlify.com/docs/contribution_guidelines/).
