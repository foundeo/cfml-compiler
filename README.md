# cfml-compiler

CommandBox command to compile CFML 

## Example Usage

To compile a folder `src` and write the compiled files into a `compiled` folder using lucee 5.3.5:

    box compile source=./src dest=./compiled cfengine=lucee@5.3.5

Suppose now that you are building a docker container, or a [CFML Lambda Function](https://fuseless.org/) you don't need the source files, and you will eliminate the time it takes Lucee to compile your CFML on the first request:

    box compile source=./src --overwrite cfengine=lucee@5.3.5
    
### CFEngine

Currently only Lucee is supported. You should always specify a CFML engine that exactally matches the version that your code will run on. This way if there are any changes to the lucee compiler in a future version you won't run into incompatibale compiled classes.

## Command Arguments

| Argument  | Required | Description                                                                                  |
|-----------|----------|----------------------------------------------------------------------------------------------|
| source    | Y        | Folder containing CFML code.                                                                 |
| dest      | N        | The folder where compiled cfm/cfcs will be written. Defaults to source if not specified.     |
| cfengine  | N        | The version of lucee you are using, specified in commandbox cfengine format, eg: lucee@5.3.2 |
| overwrite | N        | Prevent prompting if source == dest                                                          |
