# README

This is the README for the AWS Perl Lambda Serverless
Framework...aka..._plambda_?

__This is a POC and WIP! Documentation and implementation will likely
change in the near future.__

# Table of Contents

* [Background](#background)
* [Project Details](#project-details)
  * [Perl Lambda Architecture](#perl-lambda-architecture)
* [What's Included in this Project?](#whats-included-in-this-project?)
  * [What's Not Included?](#whats-not-included?)
  * [Project Dependencies](#project-dependencies)
    * [Perl Modules](#perl-modules)
    * [GNU Utilities](#gnu-utilities)
    * [AWS CLI Environment](#aws-cli-environment)
    * [Other Dependencies](#other-dependencies)
    * [Instaling Dependencies on an Amazon Linux AMI](#instaling-dependencies-on-an-amazon-linux-ami)
* [Installation](#installation)
* [Configuring, Building and Invoking Your Lambda](#configuring-building-and-invoking-your-lambda)
  * [Summary](#summary)
  * [Create a `buildspec.yml` file](#create-a-buildspec.yml-file)
  * [Create a Lambda handler](#create-a-lambda-handler)
  * [Configure the project](#configure-the-project)
  * [Build your Lambda package](#build-your-lambda-package)
  * [Install your Lambda](#install-your-lambda)
  * [Invoke you Lambda handler](#invoke-you-lambda-handler)
  * [Development Cycle](#development-cycle)
* [Perl and Custom Perl Runtime Layers](#perl-and-custom-perl-runtime-layers)
  * [Creating A Perl Layer (optional)](#creating-a-perl-layer-optional)
    * [Detailed Instructions](#detailed-instructions)
    * [`make-a-perl`](#make-a-perl)
    * [Hints and Tips](#hints-and-tips)
  * [Custom Perl Runtime Layer (CPRL)](#custom-perl-runtime-layer-cprl)
* [Technical Notes & Troubleshooting](#technical-notes-&-troubleshooting)
  * [More About Perl Versions](#more-about-perl-versions)
  * [`cpanm` failures](#cpanm-failures)
  * [Custom Perl Runtime Layer (CPRL)](#custom-perl-runtime-layer-cprl)
  * [More on Module Dependencies](#more-on-module-dependencies)
    * [Mirrors](#mirrors)
    * [Creating a DarkPAN](#creating-a-darkpan)
  * [Packaging Libraries](#packaging-libraries)
  * [Packaging Additional Perl Modules](#packaging-additional-perl-modules)
  * [Downloading Custom Runtimes for Use in Multiple Projects](#downloading-custom-runtimes-for-use-in-multiple-projects)
  * [FAQs](#faqs)
  * [Accessing VPC Resources](#accessing-vpc-resources)
  * [Passing Environment Variables](#passing-environment-variables)
  * [Logging](#logging)
* [TODO/Roadmap](#todo/roadmap)
* [Copyright](#copyright)

# Background

**TL;DR**

At re:Invent 2018 Amazon announced support for the [_Lambda Runtime
API_ and _Lambda
Layers_](https://aws.amazon.com/about-aws/whats-new/2018/11/aws-lambda-now-supports-custom-runtimes-and-layers/).

The statement below from the [press
release](https://aws.amazon.com/about-aws/whats-new/2018/11/aws-lambda-now-supports-custom-runtimes-and-layers/)
confirms that for the first time it is technically feasible and more
importantly, supported, to create Lambdas in languages others than
those supported directly by their standard Lambda runtime environments.

>_We are announcing Lambda Runtime API and Lambda Layers, two new AWS
Lambda features that enable developers to build custom runtimes, and
share and manage common code between functions._

While it always been possible to invoke a shell and perform certain
operations within the Lambda runtime environment (like run a Perl
script using the system perl), you were forced to do that from a supported
runtime language (like Node or Python) which was responsible for
unloading the event and context and presenting it to your Lambda
function in a language specific manner.  The new Lambda API makes it
possible to do the unloading and presentation piece of this in any
language directly...including Perl.  Hence this project.

[Back to Table of Contents](#table-of-contents)

# Project Details

In order to create a Perl Lambda you need:

1. An AWS _custom runtime_

   A custom runtime is a environment that implements the Lambda
   protocol using the [Lambda Runtime
   API](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html).
   The runtime passes control to your Lambda function with the context
   of the current event. You can see a reference implementation in
   `bash` that the folks at AWS provide as a guide
   [here](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html). This
   project will implement something I'll call the _Custom Perl
   Runtime Layer_ or *CPRL*.
1. A handler, written in Perl that acts as your Lambda function

   This project provides a framework that will allow you to write Perl
   based Lambda functions without worrying about the handshaking
   required by a custom runtime. For example a "Hello World!" Lambda:

   ```perl
   package MyLambda;

   use strict;
   use warnings;
   
   use parent qw/Amazon::Lambda::Runtime/;

   sub handler {
     my $self = shift;
     my ($event, $context) = @_;
 
     return "Hello World!";
   }
 
   1;
   ```
1. A Perl _layer_

   A Perl layer is a Lamba Layer that will contain a full installation
   of a specific version of `perl`.  You can use a Perl layer when
   developing Lambdas or alternately accept the limitations associated
   with the version of `perl` that is part of the Lambda runtime
   environment (currently 5.16.3).  You should know that if you decide
   to use the system Perl, it may not include modules you need in your
   application.  My deep dive into that environment reveals that
   important modules are missing, modules that you might expect from a
   full Perl installation (for example `Data::Dumper`).  You can
   backfill those modules by creating additional layers that have just
   the Perl dependencies you need and continue to use the system
   `perl`...or you could create a layer containing a newer, complete
   version of `perl`. The latter mechanism being a more desirable
   method.
 1. An IAM role for your Lambda

   >_"A Lambda function requires an execution role created in IAM that
   provides the function with the necessary permissions to run."_

   In other words, if you want your Lambda to interact with AWS
   resources, it should be granted permissions to access those
   resources. At a minimum you'll need a role that has at least has
   permissions to produce CloudWatch logs.

## Perl Lambda Architecture

```
  ...............................................................................
 /                                                                               \
.                        L A M B D A   S E R V I C E                             .
.     +-------------------------------------------------------------------+      .
.     |                         H a n d l e r                             |      .
.     |...................................................................|      .
.     |                                                                   |      .
.     |                  package MyLambda.pm;                             |      .
.     |                                                                   |      .
.     |                  use strict;                                      |      .
.     |                  use warnings                                     |      .
.     |                                                                   |      .
.     |                  use parent qw/Amazon::Lambda::Runtime/;          |      .
.     |                                                                   |      .
.     |                  sub handler {                                    |      .
.     |                    my $self = shift;                              |      .
.     |                    my ($event, $context) = @_;                    |      .
.     |                                                                   |      .
.     |                    return "Hello World!";                         |      .
.     |                  }                                                |      .
.     |                                                                   |      .
.     |                  1;                                               |      .
.     +-----------+-------------------------------------------------------+      .
.     |           |         Custom Perl Runtime Layer (CPRL)              |      .
.     |           |                                                       |      .
.     | bootstrap |              plambda.pl                               |      .
.     |           |          Amazon::Lambda::Runtime                      |      .
.     +-----------+-------------------------------------------------------+      .
.     |                    optional Perl Layer  (e.g. perl-5_28_1)        |      .
.     +-----------+-------------------------------------------------------+      .
.     |                  Lambda Execution Environment                     |      .
.     |                                                                   |      .
.     |         - Operating system – Amazon Linux                         |      .           
.     |         - AMI – amzn-ami-hvm-2017.03.1.20170812-x86_64-gp2        |      .
.     |         - Linux kernel – 4.14.77-70.59.amzn1.x86_64               |      .
.     |         - AWS SDK for JavaScript – 2.290.0                        |      .
.     |         - SDK for Python (Boto 3) – 3-1.7.74 botocore-1.10.74     |      .
.     +-------------------------------------------------------------------+      .
.                                Firecracker                                     .
 \............................................................................../

```

# What's Included in this Project?

This project provides the tooling necessary to create item #1 - a
custom runtime layer.

## What's Not Included?

* Item #2 (handler) - you create your own handler by implementing a
  class and method written in Perl.

* Item #3 (a Perl layer) above is either unnecessary if you use the
  system version of `perl` found in the Lambda environment or is
  [somewhat trivial to concoct](#creating-a-perl-layer).

* Item #4 (IAM role) is something your cloud SysOps team will create
  for you or you'll create on your own if your user or role
  permissions allow you to create IAM roles and policies.  Here's an
  example of creating a basic IAM role with an appropriate attached
  policy for your Lambda to access resources in your VPC.

  ```
  cat >assume-role-policy-document.json <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "sts:AssumeRole",
              "Effect": "Allow",
              "Principal": {
                  "Service": "lambda.amazonaws.com"
              }
          }
      ]
  }
  EOF
  
  aws iam create-role --role-name my-lambda-role --assume-role-policy-document file://assume-role-policy-document.json
  aws iam attach-role-policy --role-name my-lambda-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole 
  ```

The _tooling_ provided in this project is in the form of several
scripts and at its core (and mostly opaque to you) an
[autoconfiscated](http://foldoc.org/autoconfiscate) project. Once
installed and configured, you can create and install your Lambdas by
executing the `plambda` script with the appropriate commands.

```
plambda config
plambda install lambda
```

##  Project Dependencies

Dependencies for the project are described below.  It is recommended
that you develp your Lambdas on a system that is compatible with the
target Lambda enviroment.  It's also assumed you have knowledge and
experience with:

* Perl
  * developing classes
  * installing modules
* Amazon Web Services
  * command line interface
  * EC2s
  * Lambdas

### Perl Modules

* `App::cpanminus`
* ...and many others

I think it can be assumed that the consumers of this project will be Perl
programmers who wish to interact with AWS cloud resources.  Therefore,
it will also be assumed that you are familiar with installing Perl
modules.  The project provides a _cpanfile_ named `plambda-cpanfile`
you can use to install the necessary Perl modules that support the
_plambda_ framework.

### GNU Utilities

* `autoconf`, `automake`, `libtools` suite from the GNU project

You will also need to have handy the GNU `automake` tools which should
be available on all *nix distros.  Depending on _how you roll_ you may
have success with simply using the system package manager (`yum`,
`apt`, `pkg`, etc) to install many of the dependencies listed below.

### AWS CLI Environment

* `aws` - CLI utility

  You should also have the latest AWS CLI installed that has support
  for Lambda Layers and have the necessary IAM permissions to issue
  Lambda API calls (you probably want to at least have
  [PowerUserAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_job-functions.html#jf_developer-power-user))
  and possible need to be able to create IAM roles and
  policies. Specifically, you'll need to be able to issue the Lambda
  operations:

  * `create-function`
  * `delete-function`
  * `delete-layer-version`
  * `get-function`
  * `get-layer-version`
  * `invoke`
  * `list-functions`
  * `list-layer-versions`
  * `list-layers-by-version`
  * `list-layers`
  * `publish-layer-version`
  * `publish-version`
  * `update-function-configuration`

  Additionally, you should be able to issue the Security Token Service
  operation `get-caller-identity` and the IAM `list-roles` API.

### Other Dependencies

* The standard set of utilities found on all *nix based systems
  * `perl`, `sed`, `awk`, `cp`, `mv`, `rm`, `mkdir`, `mktemp`, `zip`, `unzip`, `comm`, and possibly others
* `jq` - a JSON parsing utility - used to parse JSON output from AWS CLI output

### Instaling Dependencies on an Amazon Linux AMI

The instructions below assume you have provisioned an EC2 or are
running in a container or system that looks like one. If you are
attempting to develop on a Debian based distro (Ubuntu, e.g.) you
might have some success as long as you can install the dependencies
*and* your Lambdas are not too complex (meaning you are not packaging
up dependencies that might be binary incompatible with the Lambda
environment).

You will, however, more than likely, run into problems if you don't
develop in the target environment...so...[I can't emphasize enough the
fact that you should be building and packaging your assets on a system
that mimics the Lamdbda runtime environment.](#hints-and-tips)

* Install dependencies:
  * upgrade your AWS CLI to make sure it support Lambda Layers.
  * install `git`, `gcc`, `jq`, `automake`, `openssl` and `cpanm`
  * install `scandeps.pl`
  
  ```
  sudo pip install awscli --upgrade
  sudo yum install -y git gcc jq automake openssl-devel 'perl(App::cpanminus)'
  cpanm -S --install Module::ScanDeps
  ```

  **After installing the above dependencies, make sure you run `aws
  configure` to create your AWS credentials file.**

* Bootstrap the latest version of `cpanm`:
  * get rid of the packaged version of `cpanm` on RHEL/CentOS as it's
    an older version with no `cpanfile` support

  ```
  sudo cpanm --install App::cpanminus
  sudo yum remove -y 'perl(App::cpanminus)'
  ```

# Installation

After you've installed all of the project dependencies, install the
project by first cloning the project and creating a distribution
tarball. Install the Perl module dependencies listed in _plambda-cpanfile_.

```
git clone https://github.com/rlauer6/perl-Amazon-Lambda-Runtime.git
cd perl-Amazon-Lambda-Runtime
sudo /usr/local/bin/cpanm --cpanfile plambda-cpanfile --installdeps .
autoreconf -i --force
./configure
make dist
```

If you see errors similar to this during the configure phase:

`configure: error: cpanm  not found?`

...it may indicate that you do not have one of the dependencies
required.

Unpack the tarball created in the step above and run the
`install-framework` script. This will install the `plambda`
scripts.

```
mkdir ~/my-project
cd ~/my-project
export PLAMBDA_HOME=$(pwd)
tar --strip-components=1 -xvzf perl-Amazon-Lambda-Runtime-0.0.1.tar.gz
sudo ./install-framework
```

You can install the framework locally as long as you create and add the
location to your `PATH`.

```
PATH=$PATH:~/plambda/bin
./install-framework ~/plambda
```

You should now have installed the necessary plumbing to create a
custom runtime and Perl Lambdas.  The framework includes a script
named _plambda_ that will assist in this process.

You can get help with any `plambda` command by providing the command name
followed by `help`.

```
plambda init help
```

# Configuring, Building and Invoking Your Lambda

## Summary

1. Create a `buildspec.yml` file
1. Create a Lambda handler
1. Configure the project
1. Build your Lambda package
1. Install your Lambda package
1. Invoke your Lambda handler

## Create a `buildspec.yml` file

Before you can build and install your Lambda you'll need to create a
`buildspec.yml` file that describes your Lambda. You can create a
template for your `buildspec.yml` by invoking the `init` command of
the `plambda` utility.

```
plambda init > buildspec.yml
```

Inspect and edit your `buildspec.yml` and customize as per your
requirements.  See `plambda init help` for more details on the
format and options you can set in the `buildspec.yml` file.

Here's an example buildspec.

```
aws:
  profile: sandbox
  account: 111111111111
  role: perl-lambda-vpc-role
  region: us-east-1
handler: Lambda.handler
layers:
  perl-runtime:
    version: 128
  perl-5_28_1:
    version: 1
vpc-config:
  subnet-ids:
    - subnet-08b5e355
  securitygroup-ids:
    - sg-55888722
environment:
  DBI_DBNAME: mydb
  DBI_USER: user
  DBI_PASS: password
  DBI_HOST: somerds.cbjxu8mkvkk3.us-east-1.rds.amazonaws.com
timeout: 3
memory-size: 128
extra-libs:
  - /usr/lib64/mysql/libmysqlclient.so.18
```

The sections of the YAML file are described below.

* `aws`

  Provides basic information about the AWS account and Lambda environment.
* `handler`

  The name of the Lambda handler.
* `layers` (optional)

  Specifies the layers that your Lambda will use.  Each section within
  the `layer` section should specify the name of the layer and the
  version.
* `vpc-config` (optional)

  If you need to access resources in your VPC, configure the subnets
  and security groups here.
* `environment` (optional)

  Add custom environment variables in this section.
* `timeout` (optional)

  The default time out for Lambda functions is 3s. The limit for a
  Lambda function is 15m (900s).
  value by setting this value.
* `memory-size` (optional)

  The default memory size is 128MB. The value should be a multiple of 64.
* `extra-libs` (optional)

  If you would like to include shared library files, specify the fully
  qualified path names of those files here.


## Create a Lambda handler

Create your Lambda in the project root directory. If you ran the
`plambda init` command above, you'll have a stub of a Lambda written
as `Lambda.pm`.

```perl
package Lambda;

use strict;
use warnings;

use parent qw/Amazon::Lambda::Runtime/;

sub handler {
  my $self = shift;
  my ($event, $context) = @_;
  
  return "Hello World!";
}

1;

```

## Configure the project

Once you have created a `buildspec.yml` file and implemented your
handler, configure the framework.

```
plambda config
```

## Build your Lambda package

After configuring the project, you build a zip-file that contains your
Lambda handler and any additional dependencies.  The framework
tries to determine dependencies and creates a cpanfile you can later
edit.  You can maintain this file or you can continue to allow the
framework to automatically attempt to keep it up to date when changes are
made to your handler.

```
plambda build lambda
```

## Install your Lambda

You can now build and install the Lambda and runtime packages. These
two steps can be done at the same time by just running `install`
command.  If changes were made that require the Lambda package to be
rebuilt, the framework will detect them and initiate a build prior to
installing the package. If this is the first time you have run the
install, both the custom Perl runtime layer (CPRL) and the Lambda
package will be built and installed.

```
plambda install lambda
```

Alternately, you can build the packages separately and inspect the output prior
to installation to the AWS environment.

```
plambda build runtime
unzip -l ~/.plambda/perl-runtime.zip | less
```

```
plambda build lambda
unzip -l ~/.plambda/Lambda.zip | less
```

Execute the `state` command to report the current state of your Lambda
and runtime.

```
plambda state
```

## Invoke you Lambda handler

After installing your runtime and Lambda packages, you can invoke your
Lambda by using _plambda_ or the AWS CLI. The _plambda_ `invoke`
command has some nice features that make it somewhat more convenient
than using the AWS CLI. Try `plambda invoke help` for more details.

Typically, Lambdas are not invoked by the CLI but rather as a result
of an AWS event.  For example, you can map an S3 event
like `PutObject` to a Lambda to execute some operation on an object
that has landed in S3. See [AWS Lambda Event Source
Mapping](https://docs.aws.amazon.com/lambda/latest/dg/intro-invocation-modes.html).

For testing your Lambdas, you can simulate an event by
supplying an event object as the payload and using the `invoke`
command.  The Lambda console can also be used to test your Lambda and
configure test events that mimick actual AWS events.

```
plambda invoke payload '{"text":"Hello"}' outfile lambda.out
```

...or using the AWS CLI:

```
aws lambda invoke --payload '{"text":"Hello"}' --function-name Lambda lambda.out
```

The return value of your Lambda is written to the file `lambda.out` in
the exmple above. You'll see the return code from the invoke method on STDOUT.

You can view the Lambda logs by visiting the AWS console, accessing
the CloudWatch service page, and clicking on the _Logs_ link.  This
will allow you to inspect the log stream created by the invocation of
your Lambda.  You might want to [check out this
project](https://github.com/jorgebastida/awslogs) for a CLI method of
watching your Lambda logs.

```
awslogs get /aws/lambda/Lambda -s 1m --no-color -G -w | perl -npe 's/\r/\n/g;' | less
```

## Development Cycle

Any time you edit your *handler*, the *buildspec*, or your *cpanfile*
a new Lambda package will need to be built and deployed.  Editing your
buildspec file requires that you re-configure the framework using the
`plambda config` command. Execute the `plambda install lambda` command
and the framework will recognize that a change has been made and
update your Lambda package.

The `build`and `install` commands will create a new cpanfile whenever your
*Lambda* changes (just in case you've added new dependencies).  If
you've been manually maintaining your cpanfile, you may want to
prevent the framework from overwriting it. Use the `--no-scandeps`
option when you build or install the Lambda package. You can set an
environment variable (`NO_SCANDEPS`) which will also prevent
overwriting your cpanfile.

You can report whether or not your Lambda needs to be rebuilt by
executing the `install` command with the `--dryrun` option.

```
touch Lambda.pm
plambda --dryrun install plambda
```

You can force a build and install of your Lambda, using the `--force` option.

The `state` command will also tell you the current state of the Lambda
development environment.

```
.----------------------------------------------------------------.
|                          Lambda State                          |
+--------+-----------+-----------+------------+------------------+
| Name   | Module    | Installed | Function   | CPRL             |
+--------+-----------+-----------+------------+------------------+
| Lambda | Lambda.pm | yes       | re-install | perl-runtime:193 |
'--------+-----------+-----------+------------+------------------'
```

Columns in the output of the `state` commnand are color coded to
suggest the current state and potential actions you might want to
take.

* Module
  * green => current
  * yellow => has changed, re-build
* Function
  * green => installed and current
  * red => needs to be re-built & re-installed
  * yellow => needs to be installed
  * --- => not installed
* CPRL
  * green => current
  * red => re-build/re-install
  * yellow => CPRL/Lambda configuration in sync, but no runtime in your working tree
  * --- => not installed

A typical development cycle looks like this:

1. Start a new project as previously described
1. Create a `buildspec.yml` file (manually or using `plambda init`)
1. Create a Perl class and method that implements your handler.
1. Configure the framework by executing `plambda config`
1. Build and install your Lambda using `plambda install`
1. Invoke and test your Lambda
1. Modify the Lambda as necessary
1. Iterate on steps #5, #6, #7

The project includes a `gitignore` file you can rename to `.gitignore`
to have git ignore many of the files that make up the framework itself.

# Perl and Custom Perl Runtime Layers

Along with publishing the Lambda runtime protocol, AWS announced a new
feature called Lambda Layers. These two things can, but don't have to,
work together when you create custom runtimes.  Most Perl developers
will probably want to use a customized version of Perl (not the system
`perl` in the default Lambda runtime environment) and an
implementation of the Lambda protocol (custom runtime) that makes it
easy to write and invoke Perl Lambdas.  This can be done by creating two
new Lambda Layers; a customized version of Perl (e.g. 5.28.1) and a
custom runtime layer that calls our Perl Lambdas, i.e. the layer produced by this project (Custom Perl
Runtime Layer - CPRL).

## Creating A Perl Layer (optional)

If you'd like to use a version of `perl` other than the version found on
the Lambda runtime (5.16.3), then you'll need to create a Perl layer
**and** rebuild your CPRL to match that version. __Your development
environment version of `perl` should also match the version of `perl` you
are going to use in the Lambda environment.__

You specify the version of `perl` to use for your Lambdas in the
`runtime-buildspec.yml` file.  If the value is not set, then the
default version of `perl` in Lambda runtime is used.  Again, if you opt to use
the default value, you should be building your Lambda packages in an
environment that matches that version.

__Only set the version of `perl` if you do not want to use the default
version of `perl`!  If you set the value to 5.16.3, the `bootstrap`
script will look for `perl` in `/opt/perl-5.16.3` and you will be sad.__

---

A Lambda Layer is just a collection of files that you assemble that
will be overlayed on the Lambda runtime environment in the `/opt`
directory.  Therefore, to create a Perl version that can be used as a layer
you'll need to bundle up a suitable version of `perl` from the
`/opt` directory.  Follow this recipe:

* Download and compile a version of Perl you'd like to install as a
  layer
   * build the source so that it will reside under `/opt`. The
     framework uses the convention `/opt/perl-{version}`, so for 5.28.1, build
     the Perl environment to be installed to `/opt/perl-5.28.1`.
* Create a zip-file that contails the Perl layer
* Publish the layer using the AWS CLI

   ```
   aws publish-layer-version --layer-name perl-5_28_1 --zip-file fileb://perl-5.28.1.zip | jq -r .LayerArn > perl-layer-arn
   ```

  For layer names, use the convention `perl-{version}` with
  periods ('.') are replaced with underscore ('_').

If you follow these conventions you'll be able to configure this
framework to use any version of Perl you happen to upload as a layer.

### Detailed Instructions

As previously discussed you should create your Lambda Layers on a
compatible Linux environment. Make sure you have `gcc` installed.

* Download and unpack a stable version of Perl

  ```
  wget http://www.cpan.org/src/5.0/perl-5.28.1.tar.gz
  tar xfvz perl-5.28.1.tar.gz
  cd perl-5.28.1
  ```
* Configure as per your needs.  You probably want to avoid adding the man pages since they just take up space.

  ```
  ./Configure -des -Dprefix=/opt/perl-5.28.1 -Dman1dir=none -Dman3dir=none
* Build and install the binaries

  ```
  sudo make install
  ```
* zip up the binary and publish the layer as described above

  ```
  cd /opt
  zip -9 -r /tmp/perl-5.28.1.zip perl-5.28.1/*
  ```

After uploading a new version of `perl` as a layer, you should make
sure the `perl` in your working environment points to this same
version.  You will also need to build a CPRL specifically for this
version of `perl`.

Edit the `runtime-buildspec.yml` file, update the version of `perl`,
rebuild and install a new CPRL.

```
perl:
  version: 5.28.1
```

### `make-a-perl`

See the `make-a-perl` script in the project root.  This script will
spark up an EC2, compile a version of `perl`, create a zip-file,
write it to an S3 bucket and optionally terminate itself.  Depending
on your region, you select an appropriate AMI that supports one
of the Lambda runtime enviroments.  The script starts an EC2 with that
AMI and runs a user-data script that will download the Perl source
code from CPAN and compile it for you.


### Hints and Tips

* __Take note of the version that is returned from the `publish-layer-version` CLI call as this will be used when you
configure your Lambda environment.__
* You should install your new version of `perl` to a path named using the convention `perl-{version}`. (ex: `perl-5.28.1`)
* You should also name your Perl layer based on the version of `perl`, replacing '.' with '_'. (ex: `perl-5_28_1`)
* The size of all of your _Lambda Layers_ must be <250MB in total (including your function).
* Use high compression (`zip -9 `) when zipping your Perl layer since the total size of zip file to upload must be <50MB
* Compile your `perl` on a compatible Amazon Linux AMI to insure
compatibility with the Lambda runtime environment. [See this page for
more details.](https://github.com/awslabs/aws-support-tools/tree/master/Lambda/DeploymentPackages)
* Build your custom Perl runtime layer on the same compatible Amazon
Linux AMI (e.g. in us-east-1 use ami-4fffc834)

## Custom Perl Runtime Layer (CPRL)

As noted developers can write Lambdas in any language by implementing
the documented protocol for custom runtimes.  This project provides
just such a custom runtime that allows developers to invoke Lambdas
written in Perl. Feel free to modify the custom runtime provided by this
project if necessary (need I say it? Pull requests welcomed!).

This project includes a `bootstrap` script that invokes the Perl
custom runtime which eventually invokes your Perl Lambda. Take a look
at the `bootstrap` script and the Perl class `Amazon::Lambda::Runtime`
found in this project if you'd like to learn more.

If you do decide to modify the runtime you can re-build and install
the custom runtime layer by following these instructions.

1. Clone the project as previously described.
2. Make modifications as necessary to `src/main/perl/lambda/bootstrap.in` and/or `src/main/perl/lambda/lib/Amazon/Lambda/Runtime.pm.in`
2. Clear out any previously built runtime artifacts

   ```
   plambda clean
   ```
3. Build and install the runtime.

   ```
   plambda install runtime
   ```

*Important*

Rebuilding the runtime will require that you rebuild your Lambda
package for use with that version of the runtime. The rebuild process
will automatically trigger _plambda_
to rebuild your Lambda package the next time you try the `install`
command.  This is necessary due to the fact that your Lambda function is
configured to use a specific version of the runtime layer and that
will change each time your build a runtime. Read on...

Perl Lambda packages are __supplementary__ to the CPRL.  To avoid
installing conflicting libraries when a Lambda function is packaged,
only the Perl modules that are unique to the Lambda are included in
the package. If modules have already been packaged in the runtime,
they are **not** added to the Lambda deployment package.  Therefore any
time you build a new runtime, the framework will need to re-compute
the non-overlapping modules of your Lambda and create a new Lambda
package.

Again, as noted above, Lambda layers are versioned __and__ a Lambda is
configured to use a specific version of a layer.

__If you start creating your own CPRLs, you may want to remove old layers that are not in use.__

To remove all but the latest version of the CPRL:

```
plambda --old delete runtime
```

To see what what CPRLs you have use the `--dryrun` option.

```
plambda --dryrun delete runtime
```

# Technical Notes & Troubleshooting

## More About Perl Versions

The `plambda` framework uses the Perl in your path (`/bin/env perl`) when running
scripts and more importantly when using `cpanm` to package
dependencies for your custom Perl runtime layer (CPRL) and your Lambda
package.  If there is a misalignment between the `perl` version in
your development environment and the `perl` you will be using in your
Lambda environment, then the dependency resolution phase may not
detect the correct dependencies for the environment in which you will
be running your Lambda.

_It is highly recommended that you use the same version of `perl` in
both environments._

Moreover, if you choose to use the system `perl` for developing and
the system `perl` in your Lambda runtime environment, make sure they
are the same version (currently 5.16.3).  You should also be aware
that certain modules (like `Data::Dumper`, `Digest::SHA` and many
others) are missing from the standard Lambda runtime.

The framework relies on `cpanm` for installing non-core packages, so
it needs to know what is core and what is not core. Note this from the
`cpanm` documentation with regard to the `-L` option:

>_Note that this option does NOT reliably work with perl installations
supplied by operating system vendors that strips standard modules from
perl, such as RHEL, Fedora and CentOS, UNLESS you also install
packages supplying all the modules that have been stripped. For these
systems you will probably want to install the perl-core meta-package
which does just that._

Empirically, I have found that some modules in the
`perl-core` meta-package are in fact included in the Lambda
environment's Perl installation. If you want to know if a Perl module
is part of the standard Lambda environment, launch an EC2 with one of
the compatible AWS Linux AMIs or install the
[`lambci/lambda`](https://hub.docker.com/r/lambci/lambda/) Docker
container and poke around.  They both contain the same system `perl`
environment (5.16.3).

If you have Docker installed...

```
cat >Dockerfile <<eot
FROM lambci/lambda
ENTRYPOINT []
CMD bash
eot
```

...and after building the local container...have a look around

```
docker build . -t lambci/lambda
docker run -it --entrypoint /bin/bash lambci/lambda:latest
```

Attempts to package missing modules to supplement the 5.16.3
environment by simply adding them to your `cpanfile` may result in
some degree of futility since `cpanm` may consider a module part of
core __if you have already installed the `perl-core` meta-package__ on
your RHEL or Amazon Linux development system (as you almost certainly
would have done in order to get anything useful accomplished) and
therefore fail to install that module in your Lambda package.

You may be able to __force an installation of a module__ that is
considered core by specifying a version of the module greater than the
version already installed or _possibly uninstalling_ the specific
module (either via `cpanm` or your package manager) and re-install
each module you need as you encounter a dependency that is missing
from the Lambda environment.  In this manner you may cajole `cpanm`
into packaging your module.

In the end however, your best approach is probably to abandon the use
of the system `perl` and develop your Perl application using a specific
version that you've installed with all of the bells, whistles and modules
you'd like to see in your Perl environment (keeping it all under
250MB of course!).

## `cpanm` failures

Occasionally `cpanm` will fail while trying to install a module to be
packaged.  Here are some tips.

* Check the `cpan` build log (`~/.cpanm/build.log`)
* Try adding additional modules manually to your `cpanfile`
* Dependencies are sometimes reported by `scandeps.pl` that are not actually
  dependencies (at least for your use case).  In those situations,
  remove the module from the `cpanfile`.  Don't forget to use the `--no-scandeps`
  option after modifying the `cpanfile` when re-building your Lambda
* Specify a version of the module
* You may need to install a shared library or
  development package that contains necessary header files, etc to
  build a module.  You may also need to package the
  library.  See [Packaging Libraries](#packaging-libraries)

## Custom Perl Runtime Layer (CPRL)

The custom runtime layer created by this project essentially consists of:

* `bootstrap`
* `plambda.pl`
* `Amazon::Lambda::Runtime` ... and its Perl dependencies

In practice, this should be built and installed to your AWS
environment just *once* either when you build your Lambda function for
the first time or prior to building and installing your Lambda
function.  You can do this immediately *after* you have
configured the framework and *before* starting work on your Lambda as
shown below:

```
plambda install runtime
```

Now list the layers available:

```
plambda -t -a list layers
.----------------------------------------------------------------------------------------------------------------------.
|                                                     Lambda Layers                                                    |
+--------------+---------+------------------------------+--------------------------------------------------------------+
| Name         | Version | Created                      | ARN                                                          |
+--------------+---------+------------------------------+--------------------------------------------------------------+
| perl-runtime |     129 | 2019-01-14T02:22:26.588+0000 | arn:aws:lambda:us-east-1:111111111111:layer:perl-runtime:129 |
'--------------+---------+------------------------------+--------------------------------------------------------------'
```

Once you have a stable CPRL you may use that same layer for multiple
projects. See [Downloading Custom Runtimes for Use in Multiple Projects](#downloading-custom-runtimes-for-use-in-multiple-projects)

## More on Module Dependencies

The most challenging part of creating Lambdas in Perl is satisfying
the module dependencies. The framework uses `cpanm` to install
dependencies in a build directory that is then packaged in a
zip-file. The zip-file is uploaded to the AWS environment.

In order for `cpanm` to know what to install, the framework will run a
dependency checker against your Lambda module to produce a cpanfile.
By default, dependency checking is done essentially using `scandeps.pl`.

```
scandeps.pl -Rc Lambda.pm > cpanfile
```

If you choose to create your own cpanfile or opt to later maintain
that manually, disable the scandeps option in one of the following
manners:

1. disable it globally in your `plambda.yml` file found in the
   installation `share/plambda` directory.

   ```
   scandeps:
      enabled: no
   ```
1. use the `--no-scandeps` option when building or installing your
   Lambda or runtime

   ```
   plambda --no-scandeps install lambda
   ```
1. set the environment variable `NO_SCANDEPS`

You can provide your own dependency resolution program.  The
program should produce (on STDOUT) a cpanfile. Set the path to your
program in the `plambda.yml` file:

```
scandeps:
   path: /path/to/program
   enabled: true
   args:
     - some-arg
```

### Mirrors

As noted previously, the framework uses `cpanm` which allows you to
set various options that direct it to find modules in different
locations. By default the framework will look for CPAN modules at
http://www.cpan.org. If you want to specify a local repository (a
so-called _DarkPAN_ repo) then set the path to your DarkPAN repo using
the `mirror-only` option in the `cpan` section of your `plambda.yml`
file.

```
cpan:
  mirror-only: /tmp/DarkPAN
  mirror: http://www.cpan.org
```

This will cause the framework to essentially execute a statement
similar to the one shown below to install dependencies in a local
directory to be packaged.

```
cpanm --mirror-only --mirror file:///tmp/DarkPAN --mirror http://www.cpan.org ...
```

### Creating a DarkPAN

Use the [`orepan.pl`](https://metacpan.org/release/OrePAN) script to
create a DarkPAN if you need a version of a module not available on
CPAN or have your own mirrored repository.


```
mkdir -p /path/to/DarkPAN
orepan.pl --destination /path/to/DarkPAN --pause BIGFOOT Amazon-S3-0.47.tar.gz
```

## Packaging Libraries

Some Perl modules require shared libraries. For example `DBD::mysql`
requires `libmysqlclient.so`. In the Lambda environment shared
libraries should be installed in the `/opt/lib` directory if they are
not already provided in the default runtime environment. Accordingly,
the _plambda_ framework allows you to specify shared libraries to be
installed in that directory by adding a list of libraries in your
`buildspec.yml` file in the `exra-libs` section.

```
extra-libs:
  - /usr/lib64/mysql/libmysqlclient.so.18
```

You should specify the paths in your development environment where
_plambda_ can find the shared libraries.

Libraries can be added to your Lambda package or the runtime itself. Add the
same section (`extra-libs`) to the `runtime-buildspec.yml` file with a
list of libraries you'd like to add to your CPRL.

If you are building modules that require shared libraries that are not
already installed in the default Lambda environment, make sure you are
building your runtime on one of the AMIs that represent a currently
supported Lambda runtime environment. From this page
https://github.com/awslabs/aws-support-tools/tree/master/Lambda/DeploymentPackages:

>_When creating deployment packages for AWS Lambda, any native
binaries must be compiled to match the underlying AWS Lambda execution
environment. Please see the AWS Lambda Developer Guide section
[Execution Environment and Available
Libraries](http://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html)
for additional details._

## Packaging Additional Perl Modules

In order to add packages that are not identified by the `scandeps.pl`,
modify `cpanfile` or `runtime-cpanfile` by adding the necessary Perl
modules. If you add files to either file you should use the
`--no-scandeps` option to prevent _plambda_ from re-computing
dependencies when you modify your Lambda or the runtime.

```
plambda --no-scandeps install lambda
```

## Downloading Custom Runtimes for Use in Multiple Projects

You only need to build and install the CPRL in your AWS environment
once. Subsequently for other Lambdas you will be developing you can
download the runtime into your current project's build tree so that
you can develop and package Lambdas for that runtime.

* Why is this necessary?

  The working model for developing Lambdas with this framework is to
  use a _standardized CPRL_, _a Perl layer with a specific version of
  `perl` if desired_, and _your Lambda package_ together as the Lambda
  environment.  Since each Lambda only packages the modules necessary
  to *supplement* the CPRL, the framework must be able to determine
  the additional modules needed to address your dependencies.  By
  downloading the CPRL you wish to use, _plambda_ can then compare
  the modules already packaged in the CPRL against the modules
  required by your Lambda to create the minimal package necessary to
  create a working Lambda environment.

* Can I have multiple CPRLs?

  Sure. Since each CPRL is versioned and your Lambda is configured to
  use versioned layers, you can have multiple CPRLs for various
  projects or to address the need to package projects with different
  versions of `perl`.  In practice, it may be best for the Perl
  community to use standardized CPRLs (one for each version of `perl` ?)
  and use your own custom runtime layers to supplement your needs.
  The hope is that this project is a catalyst for creating standard
  CPRLs and who knows...encourage AWS to add Perl to their supported
  runtime list.

* Why not make the Custom Perl Runtime Layer public?

  Although layers can be published for cross (AWS) account access, and
  the roadmap is in fact to perhaps publish a CPRL as a public layer,
  this project is highly experimental and it is almost certainly
  premature to publish a layer at this time.  Before a CPRL is
  published as a public layer, more thought and consideration should
  be given to various aspects of this implementation as it represents
  only a _reference implementation_.  Security, ubiquity of the
  toolchain, design of the interface, etc are all topics that should
  be vetted prior to publishing version 1.0 of the CPRL.

* How do I use an existing CPRL in a new project?
  
  Start a new project by unpacking the distribution tarball into your
  project directory.  If you have previously run the
  `install-framework` script you do not need to run that again, the
  _plambda_ utilities should already have been installed.

  ```
  mkdir ~/my-project
  cd ~/my-project
  tar --strip-components=1 xfvz perl-Amazon-Lambda-Runtime-1.0.0.tar.gz
  ```

  Now download the latest CPRL runtime you've previously installed in
  your AWS environment using the `download` command with the
  `--runtime` option.

  ```
  plambda --runtime download
  ```

  This will download the most recent (highest versioned) layer named
  `perl-runtime`.  If you want to download a specific version, use the
  `--version` option when using the `download` command.
  
  Create your buildspec file, run the `config` command and then build
  and install your Lambda.  Your Lambda will be built against the
  runtime you downloaded and only the Lambda package will be
  installed.

## FAQs

* Can I bundle my custom `perl` version and the CPRL into one layer?

  Sure. You can even bundle your customized `perl` version, the
  runtime and your Lambda into the deployment package and avoid using
  layers. That's probably impractical, but you could bundle `perl` and
  the CPRL into one layer since they do have a relationship with one
  another.  Assuming some degree of stability in the CPRL, this may in
  fact be the way to encourage a community based CPRL based on `perl`
  versions. There may be other reasons for bundling as well - you may
  not like this OO implementation of the Lambda protocol, object to
  the logging mechanism, or have some other reason to roll your own or
  modify the CPRL in this project (TIMTOWTDI).

  OTOH, after noodling this a long time, my guts says it is probably
  best to decouple the `perl` version layer and the CPRL. If you want
  to bundle the smallest Lambda functions possible and continue to use
  this framework for developing your Lambdas, the three package (Perl,
  CPRL, Lambda) approach seems to makes sense to me. If you disagree,
  or want to experiment see below.

  __If you plan on using the Lambda console to develop Perl Lambdas
  (and you can!), you'll want to try hard to keep your deployment
  package under 3MB in size.  That's another good reason to split up
  the layers.__
  

* If I want to bundle the CPRL with my version of `perl` how do I do
  that?

  After you create a zip file containing your version of `perl`,
  simply add the runtime to the zip file and create a new layer.

  * Clear out any existing runtime
  
     ```
     plambda clean
     plambda config
     ```
  * Make sure your `runtime-buildspec.yml` file specifies your version of `perl`.
  
     ```
     cat runtime-buildspec.yml
     ---
     extra-libs: ~
     perl:
       version: 5.28.1
     ```
  * Build a new version of the CPRL.
  
     ```
     plambda build runtime
     ```
  * Merge the CPRL files just built into your zipped Perl package.
  
     ```
     cd src/main/perl/lambda/cache/runtime
     zip -r /tmp/perl5.28.1.zip local/*
     ```
  * Create a new Lambda layer that represents the bundled package
  
     ```
     aws lambda publish-layer-version --layer-name perl5_28_1 --compatible-runtimes provided \
       --description 'perl5.28.1/CPRL' --zip-file fileb:///tmp/perl5.28.1.zip > layer_arn
     ```

  Currently, if you choose to use a __bundled layer__, you will no
  longer be able to use this framework to package your Lambda
  functions. That may change in the future, however in order to build
  and install your Lambdas now, you will need to manually track your
  dependencies and create the Lambda zip file in a fashion similar to
  that shown below.

  ```
  mkdir -p local/lib/perl5
  cp Lambda.pm local/lib/perl5
  zip -r Lambda.zip local/*
  aws lambda create-function --function-name Lambda --runtime provide --handler Lambda.handler \
                             --role arn:aws:iam::111111111111:role/perl-lambda-vpc-role \
                             --zip-file fileb://Lambda.zip
  aws lambda update-function-configuration --function-name Lambda --layers $(cat layer_arn)
  ```

  _HINT: After building your runtime for your version of `perl`,
  create a Lambda package for a Lambda that does nothing but provide a
  stub handler.  This process will create a cpanfile that lists the
  dependencies for the Lambda. Save that cpanfile since it represents
  the additional modules that have already been packaged with your
  layer. You can safely omit those from any future package you build
  and install._

* I think I know what I'm doing with this Lambda stuff.  Can't I just
  create the CPRL without using the included `plambda` script?

  Yes, this project is actually just an autoconfiscated project that
  is designed to build a CPRL and your Lambda package using a
  Makefile.  The `plambda` script is a POC project that might grow up
  someday to represent a smoother pathway for developing serverless
  Perl applications, OTOH, you may just want to use the included Perl
  modules that represent the core of the runtime and deal with
  dependencies, building and packaging using your own toolchain.

  If all you want to do is create the runtime layer package *and* you
  are familiar with configuring and installing GNU projects in the
  Linux environment *and* know enough about the AWS Lambda environment
  to install layers and functions, then follow the basic recipe below.

  * Provision an EC2 using the latest Linux AMI that is compatible with the Lambda runtime environment
  * Install dependencies (_note you'll need the latest AWS CLI with Lambda layer support_)
  * Clone the project
  * Configure the project
  * In the `src/main/perl/lambda` directory run `make runtime-pkg`
  * Publish the layer

    After you've completed these steps you will have a file named
    `perl-runtime.zip` which represents the CPRL __built for use with
    the system `perl` found on the default Lambda runtime
    environment__.

    Install the zip file as a new layer, create a Lambda handler,
    package and install it manually as previously described and have
    some fun.

  * A more detailed recipe is shown below. These instructions are only
    for building a CPRL that you might use with the system version of
    `perl` and assumes you don't want to use the framework itself.

    * Install dependencies to your EC2 - See [Installing Dependencies on an Amazon Linux AMI](#installing-dependencies-on-an-amazon-linux-ami)
     
    * Clone the project:
    
      ```
      git clone https://github.com/rlauer6/perl-Amazon-Lambda-Runtime.git
      cd perl-Amazon-Lambda-Runtime/
      export PLAMBDA_HOME=$(pwd)
      ```
    
    * Install some additional Perl dependencies:
    
      ```
      cp runtime-cpanfile-default  runtime-cpanfile
      sudo /usr/local/bin/cpanm --cpanfile runtime-cpanfile --installdeps .
      ```
    
    * Configure and build the runtime:
    
      ```
      touch runtime-buildspec.yml
      autoreconf -i --force
      ./configure
      cd src/main/perl/lambda/
      touch runtime-libs
      NO_SCANDEPS=1 make runtime-pkg
      ```
      
   *  Publish the layer:

      _Note: Make sure you run `aws configure` first and/or your EC2 has a role
      that enables you to make Lambda API calls._
      
      ```
      aws lambda publish-layer-version --layer-name perl-runtime-test --zip-file fileb://perl-runtime.zip | jq -r .LayerVersionArn > layer_arn
      ```
    
   *  Write a Lambda function:
   
      ```
      cd $PLAMBDA_HOME
      mkdir -p local/lib/perl5
      cat >local/lib/perl5/MyLambda.pm <<eof
      package MyLambda;
    
      use parent qw/Amazon::Lambda::Runtime/;
    
      sub handler {
        return "Hello World!";
      }
      1;
      eof
      ```
    
   *  Package it up:
   
      ```
      zip -r MyLambda.zip local/*
      ```
    
   * Create the Lambda:
   
      ```
      aws lambda create-function --function-name MyLambda --handler MyLambda.handler --role some-role --zip-file fileb://MyLambda.zip --runtime provided
      aws lambda update-function-configuration --layers $(cat layer_arn) --function-name MyLambda
      ```
    
   *  Invoke the Lambda:
   
      ```
      aws lambda invoke --function-name MyLambda --invocation-type RequestResponse   --payload '{"text":"Hello"}' lambda.out
      ```

* Cool, but I'd really rather just install a CPAN module and be done
  with it.  Any chance I can do that?

  Ok. The core of the CPRL just is just three Perl artifacts
  and one bash script as noted previously.  This only represents
  however, the necessary but insufficient components that make up the
  CPRL. You still need to package these artifacts up with the other
  dependent Perl modules into a zip file to create a Lambda layer. The
  instructions above that you have hopefully read are to make sure
  the correct dependencies are packaged in the right places to make
  the whole kit & kaboodle work.  In other words, you need the kit and
  the kaboodle! Knowing that people like have options and enjoy
  gnashing their teeth installing dependencies, there may be a CPAN
  distribution available soo that just bundles the core components.

  * `bootplambda.pl`
  * `plambda.pl`
  * `Amazon::Lambda::Runtime`
  * `Amazon::Lambda::Context`

  It's left as an exercise to the reader to go from there, but there
  are plenty of clues sprinkled throughout this tome so that those
  with the inclination can tinker.

## Accessing VPC Resources

In order for your Lambda to access resources in your VPC (like RDS
instances), you'll need to provide the subnet ids and security group
ids necessary for your Lambda to communicate with these resources.
You can provide these in your buildspec file.

```
vpc-config:
   subnet-ids:
     - string
     - string
   securitygroup-ids:
     - string
     - string
```

## Passing Environment Variables

You can configure your Lambda environment with environment variables
by specifying them in an `environment` section of your buildspec.
Specify a environment variables as key value pairs as shown below:

```
environment:
   LOG_LEVEL: debug
   BUCKET_NAME: my_bucket
```

__IMPORTANT: Whenever the `buildspec.yml` file is updated, you will
need to re-configure and build your Lambda.__

## Logging

Your Lambda can simply write to STDERR in order to log messages to
CloudWatch log streams.  You may find this adequate, but you can also
use the logger from the parent class of your Lambda to log messages at
various log levels that are more consumable (and understandable in the
console) by CloudWatch.

```perl
sub handler {
  my $self = shift;

  my ($event, $context) = @_;

  my $logger = $self->get_logger;
  $logger->set_log_level('debug');
  $logger->log_debug("some message");
  ...
}
```

By default, logging is done at the `info` level. You can also set the
log level using an environment variable (LOG_LEVEL) configured in your
Lambda environment. See [Passing Environment
Variables](#passing_environment_variables) for information
regarding environment variables in your Lambda environment.

See `perldoc AWS::Lambda::Runtime` for more details about logging.

Be aware that logs messages may not immediately be available in
CloudWatch.  If you are familiar with Lambda debugging you know that it
may take several seconds for log messages to appear in CloudWatch.

# TODO/Roadmap

- [ ] automatically create a role and policies for the Lambda
- [ ] autocleanup old layers
- [ ] create a CPAN distribution of core files
- [ ] allow events to be bound to Lambda
- [ ] create a CI/CD pipeline for creating the CRPL using Docker or `packer`
- [ ] eliminate use of `make` and `autoconf`

# Copyright

(c) Copyright 2019 Robert C. Lauer. All rights reserved. This is free
software. It may be used, redistributed and/or modified under the same
terms as Perl itself.
