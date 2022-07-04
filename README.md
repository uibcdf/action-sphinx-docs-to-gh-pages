# action-sphinx-docs-to-gh-pages
[![Open Source Love](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


The [Sphinx](https://www.sphinx-doc.org/en/master/) documentation in a repository is automatically compiled as 'html'
and deployed, by means of the `gh-pages` branch, with this GitHub Action. The user has only to be sure that the
repository accomplishes [a couple of requirements](#Requirements).

In summary, this GitHub action does the following:

- Takes the author and SHA id of the trigger action (`push` or `pull request`) to be consistent along the action.
- Creates a new `gh-pages` branch if this is not already in the repository.
- Compiles the sphinx documentation in the directory and branch specified by the user.
- Pushes the output html documentation to the `gh-pages` branch.

This GitHub Action was developed by [the Computational Biology and Drug Design Research Unit -UIBCDF- at the
Mexico City Children's Hospital Federico Gómez](https://www.uibcdf.org/) (see also
[Contributers](https://github.com/uibcdf/action-sphinx-docs-to-gh-pages/graphs/contributors)). Other GitHub Actions can
be found at [the UIBCDF GitHub site](https://github.com/search?q=topic%3Agithub-actions+org%3Auibcdf&type=Repositories).

## Requirements

### GitHub Pages taking the source from the branch gh-pages

There is no need to have a `gh-pages` branch already in the repository. This action will create it for you. But once
this GitHub action runned for first time, make sure that GitHub Pages is taking the web source code from the branch
`gh-pages`. In the github repository go to 'Settings -> Pages -> Source' and check that no other branch is selected as
source.

### A YAML file to create a conda environment with docs compilation dependencies

The compilation of your sphinx documentation requires dependencies that can be solved with a
temporary conda environment. Make sure that the repository has a Yaml file with the details to make
this environment (see the section ["Documentation conda environment"](#Documentation-conda-environment)).

## How to use it

To include this GitHub Action, put a [YAML](https://yaml.org/) file (named `sphinx_docs_to_gh_pages.yaml`, for instance)
with the following content in the directory `.github/workflows` of your repository:

```yaml
name: Sphinx docs to gh-pages

on:
  push:
    branches:
      - main

# workflow_dispatch:        # Un comment line if you also want to trigger action manually

jobs:
  sphinx_docs_to_gh-pages:
    runs-on: ubuntu-latest
    name: Sphinx docs to gh-pages
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Make conda environment
        uses: conda-incubator/setup-miniconda@v2
        with:
          python-version: 3.7    # Python version to build the html sphinx documentation
          environment-file: devtools/conda-envs/docs_env.yaml    # Path to the documentation conda environment
          auto-update-conda: false
          auto-activate-base: false
          show-channel-urls: true
      - name: Installing the library
        shell: bash -l {0}
        run: |
          python setup.py install
      - name: Running the Sphinx to gh-pages Action
        uses: uibcdf/action-sphinx-docs-to-gh-pages@v1.0.0
        with:
          branch: main
          dir_docs: docs
          sphinxapiopts: '--separate -o . ../'
          sphinxapiexclude: '../*setup* ../*.ipynb'
          sphinxopts: ''
```

Two things need to be known to run the GitHub Actions without further work: the meaning of the input parameters and the
YAML file to make a temporary Conda environment where the sphinx documentation can be compiled.

### Input parameters

These are the input parameters of the action:

| Input parameters   | Description                                                                                         | Default value    |
|--------------------|-----------------------------------------------------------------------------------------------------|------------------|
| `branch`           | Name of the branch where the sphinx documentation is located                                        | `main`           |
| `dir\_docs`        | Path where the sphinx documentation is located                                                      | `docs`           |
| `sphinxopts`       | Compilation options for sphinx-build                                                                | '-o . ../'       |
| `spinxapiopts`     | Options passed to `sphinx-apidoc`, typically the output directory and location to look for modules. | ''               |
| `sphinxapiexclude` | Files to be excluded from API documentation generation, by default `tests/` are excluded.           | `*setup* tests*` |

They are placed in the last lines of the above workflow example file:

```yaml
      - name: Running the Sphinx to gh-pages Action
        uses: uibcdf/action-sphinx-docs-to-gh-pages@v1.0.0
          with:
            branch: main
            dir_docs: docs
            sphinxopts: ''
            sphinxapiopts: '--separate -o . ../'
            sphinxapiexclude: '../*.ipynb'
```

In case your sphinx documentation is placed in a directory named 'docs' in the 'main' branch to be
compiled with no further options, you can do without the section `with:`.

### Documentation Requirements

The Sphinx documentation will need specific libraries and packages to be compiled. There are a few options to achieving
this, one is to create a [Conda](https://docs.conda.io/en/latest/) environment in which to build the
documentation. Alternatively if your package includes the `[options.extras_require] docs` section you can install these.

#### Conda environment

They can be specified in a Conda environment file. This way, a temporary enviroment can be made and activated
to compile the documentation with all dependencies satisfied. Write a file in the repository with
the following content:

```yaml
name: docs

channels:

  - conda-forge
  - defaults

dependencies:

  # Write here all dependencies to compile the sphinx documentation.
  # This list is just an example
  - python=3.7
  - sphinx
  - sphinx_rtd_theme
  - sphinxcontrib-bibtex
  - nbsphinx
  - recommonmark
  - sphinx-markdown-tables
```

And replace the value of the workflow input parameter `environment-file:` with the right path to your documentation conda enviroment file. In
the case of [the above example](#How-to-use-it) ('devtools/conda-envs/docs\_env.yaml'):

```yaml
jobs:
  sphinx_docs_to_gh-pages:
    steps:
      - name: Make conda environment
        uses: conda-incubator/setup-miniconda@v2
        with:
          # Replace with the path to your documentation conda enviroment file
          environment-file: devtools/conda-envs/docs_env.yaml
```

#### `setup.cfg`

Many Python packages use [setuptools]() for configuring installation via the `setup.cfg` file. One section of this is
the `[options.extras_require]` where packages not required for running the package but used in testing or building
documentation can be listed. To list your documentation build requirements add the following to your `setup.cfg`

``` cfg
[options.extras_require]

docs =
  sphinx<5.0
  myst_parser
  pydata_sphinx_theme
  sphinx_markdown_tables
  sphinx_rtd_theme
  sphinxcontrib-mermaid
```

Then in your `sphinx_docx_to_gh_pages.yaml` that you have created under the `.github/workflows/` directory replace the
step with `-name Make conda environment` (see above example) with the following steps which will setup the specified
Python version and then install the docs requirements listed in your `setup.cfg`.

``` yaml
jobs:
  sphinx_docs_to_gh-pages:
    steps:
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.9
      - name: Installing the Documentation requirements
        run: |
          pip3 install .[docs]
```

## Other tools like this one

This GitHub Action was developed to solve a need of the [UIBCDF]((https://www.uibcdf.org/)). And to be used,
additionally, as an example of house-made GitHub Action for researchers and students in this lab.

Other tools you can find in the market doing these same tasks are mentioned below. We recognize and
thank the work of their developers. Many of those GitHub Actions were used by us to learn how to set up our own one.

If you think that your GitHub Action should be mentioned here, fell free to PR with a new line.

### Sphinx

* [sphinx-pages](https://github.com/seanzhengw/sphinx-pages)
* [spinx-action](https://github.com/ammaraskar/sphinx-action)
* [action-sphinx-composite](https://github.com/rickstaa/action-sphinx-composite)

### GitHub Pages

* [gh-pages-action](https://github.com/axetroy/gh-pages-action)
* [github-pages-deploy-action](https://github.com/JamesIves/github-pages-deploy-action)
* [GitHub-Pages-deploy](https://github.com/Cecilapp/GitHub-Pages-deploy)
* [create-ghpages-ifnotexists](https://github.com/ChristopherDavenport/create-ghpages-ifnotexists)
* [simple-github-pages-deploy-action](https://github.com/rdarida/simple-github-pages-deploy-action)
* [gh-pages-action](https://github.com/axetroy/gh-pages-action)
* [ghaction-github-pages](https://github.com/crazy-max/ghaction-github-pages)
* [actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)

### Shinx + GitHub Pages

* [pages](https://github.com/sphinx-notes/pages)
* [spinx-pages](https://github.com/seanzhengw/sphinx-pages)

## Links

* [GitHub Pages](https://pages.github.com/)
* [GitHub Actions](https://github.com/features/actions)
