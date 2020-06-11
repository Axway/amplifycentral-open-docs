/**
 * Docs page collections require the following minimal dataset:
 *   name: [string] used in routes, ie.: /admin/collections/:slug/edit
 *   label: [string] used in CMS UI left nav
 *   label_singular: [string] used in CMS UI, ie.: 'New Post'
 *   description: [string] used in CMS UI
 */
const docsDefaults = (contentDirectory, imageDirectory) => ({
  folder: `content/en/docs/${contentDirectory}`,
  media_folder: `{{media_folder}}/${imageDirectory}`,
  public_folder: `{{public_folder}}/${imageDirectory}`,
  preview_path: `docs/${contentDirectory}/{{filename}}/`,
  create: true, // Allow users to create new documents in this collection
  delete: false, // Allow users to delete documents in this collection
  format: 'json-frontmatter', // Specify frontmatter for YAML or json-frontmatter for JSON
  fields: [
    { name: 'title', label: 'Title', widget: 'string' },
    { name: 'linkTitle', widget: 'hidden', required: false },
    { name: 'no_list', widget: 'hidden', required: false },
    { name: 'simple_list', widget: 'hidden', required: false },
    { name: 'draft', widget: 'hidden', required: false },
    { name: 'weight', widget: 'hidden', required: false },
    { name: 'date', widget: 'hidden', required: false },
    { name: 'description', label: 'Summary', widget: 'text', required: false },
    { name: 'body', label: 'Body', widget: 'markdown' },
  ],
})

/**
 * Post collections require the same minimal dataset as docs pages.
 */
const postDefaults = {
  create: true,
  delete: false,
  fields: [
    { label: 'Title', name: 'title', widget: 'string' },
    { label: 'Author', name: 'author', widget: 'string' },
    { label: 'Publish Date', name: 'date', widget: 'datetime' },
    { label: 'Summary', name: 'description', widget: 'text' },
    { label: 'Image', name: 'image', widget: 'image', required: false },
    { label: 'Body', name: 'body', widget: 'markdown' },
  ],
}

/**
 * Add new collections here.
 */
const collections = [{
  ...docsDefaults('', 'docbook/images/general'), // content directory, image directory
  name: 'docs',
  label: 'Documentation',
  description: 'Top level pages in documentation.',
  format: 'frontmatter',
  create: false,
}, {
  ...docsDefaults('central', 'central'),
  name: 'central',
  label: 'AMPLIFY Central documentation',
  label_singular: 'page in AMPLIFY Central section',
  description: 'All pages relating to AMPLIFY Central.',
  format: 'frontmatter',
}, {
  ...docsDefaults('central/mesh_management', 'central/mesh_management'),
  name: 'mesh_management',
  label: 'Mesh management documentation',
  label_singular: 'page in Mesh management',
  description: 'All pages relating to Mesh management.',
  format: 'frontmatter',
}, {
  ...docsDefaults('central/connect-api-manager', 'central/connect-api-manager'),
  name: 'connect-api-manager',
  label: 'Connect API Manager documentation',
  label_singular: 'page in Connect API Manager',
  description: 'All pages relating to Connect API Manager.',
  format: 'frontmatter',
}, {
  ...docsDefaults('central/connect-aws-gateway', 'central/connect-aws-gateway'),
  name: 'connect-aws-gateway',
  label: 'Connect AWS Gateway documentation',
  label_singular: 'page in Connect AWS Gateway',
  description: 'All pages relating to Connect AWS Gateway.',
  format: 'frontmatter',
}, {
  ...docsDefaults('catalog', 'catalog'),
  name: 'catalog',
  label: 'AMPLIFY Unified Catalog documentation',
  label_singular: 'page in AMPLIFY Unified Catalog',
  description: 'All pages relating to AMPLIFY Unified Catalog.',
  format: 'frontmatter',
}, {
  ...postDefaults,
  name: 'news',
  label: 'News posts',
  label_singular: 'News post',
  description: 'All news posts.',
  folder: 'content/en/blog/news',
}, {
  ...postDefaults,
  name: 'releases',
  label: 'Release posts',
  label_singular: 'Release post',
  description: 'All product release posts.',
  folder: 'content/en/blog/releases',
}, {
  ...postDefaults,
  name: 'friends',
  label: 'Friends posts',
  label_singular: 'Friends post',
  description: 'All friends of the doc posts.',
  folder: 'content/en/blog/friends',
}];

const config = {
  backend: {
    name: 'github',
    repo: 'Axway/amplifycentral-open-docs', //Path to your GitHub repository. For fork testing use alexearnshaw/axway-open-docs.
    open_authoring: true,
  },
  publish_mode: 'editorial_workflow',
  media_folder: '/static/Images', // Media files will be stored in the repo under static/Images
  public_folder: '/Images', // The src attribute for uploaded media will begin with /Images
  site_url: 'https://amplifycentral-open-docs.netlify.app/', // for fork testing use https://fork-axway-open-docs.netlify.com/
  collections,
};

// Make the config object available on the global scope for processing by
// subsequent scripts.Don't rename this to `CMS_CONFIG` - it will cause the
// config to be loaded without proper processing.
window.CMS_CONFIGURATION = config;

CMS.init({ config })
