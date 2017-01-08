# xml-converter

A collection of small ruby scripts to convert [version 0.8](http://cricsheet.org/format/) [Cricsheet YAML data files](http://cricsheet.org/downloads/) into XML, and to allow validation of the XML against [the schema file (schema.xsd)](schema.xsd).

These scripts are used to generate the XML data available in the [Cricsheet XML project](https://github.com/cricsheet/cricsheet-xml).

## Installation

You can manage the dependencies using [Bundler](http://bundler.io/). Once you have it installed you can install the dependencies using:

```bash
$ bundle install
```

## Usage

`convert.rb` is a ruby script, which can be configured using command-line arguments. See `./convert.rb --help` for all available options.

`validate.rb` is also a ruby script, which cannot be configured. It simply takes a list of XML files to be validated against the schema, and outputs any errors it finds for each file.

## Examples

### Converting YAML to XML

In all of the examples that follow the resulting XML will be saved with with a `.xml` extension. For example, `foobar.yaml` will be converted to `foobar.xml`.

Convert a single YAML file, and save the resulting XML into the default output folder (`./tmp`).

```bash
$ ./convert.rb data.yaml
```

Convert the provided YAML files, and save the resulting XML into the default output folder (`./tmp`).

```bash
$ ./convert.rb *yaml
```

Convert the provided YAML files, and save the resulting XML into a specified folder.

```bash
$ ./convert.rb -f some/other/folder 1.yaml 2.yaml
```

### Validating XML

Validate a single XML file against the schema.

```bash
$ ./validate.rb data.xml
```

Validate multiple XML files against the schema.

```bash
$ ./validate.rb data.xml other_data.xml
```

## Credits

Thanks to Rob Mohseni for the initial version of the schema file, which I then extended. Without his efforts the XML version would never have happened.
