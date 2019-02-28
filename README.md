# bash-params
Simple parameter parsing and help message generation for bash scripts.

Note: a `--help` parameter is created by the script.

#### Usage
The most basic use case is to create a parameter to parse. A variable with the parameter name is created. Kepping only the uppercased latin letters.
````bash
source bash-params.sh

param-def param-name

param-parse "$@"

echo ${PARAMNAME}
````
Call the script:
````bash
$ bash script.sh --param-name value
value
````

You can also specify short one-dash options. If you specify several names, the corresponding variable is generated from the **first** one (it is therefore not recommended to place the one-letter flags first).
````bash
param-def param-name p # the variable will be *PARAMNAME*
param-def b baram-name # the variable will be *B*
````
Finally you can add a default value and an argument description after the flags.
````bash
param-def param-name :! "Parameter description" :- "default value"
````


####Customizing the parse
You can customize how a parameter is treated during the parse. In order to do so, before calling `param-parse "$@"` you must redefine the corresponding parse function `parameters-param-name` where `param-name` is the name of your parameter. This function is given all the arguments following its own one and must return the number of arguments that it consumes.
````bash
source bash-param.sh

param-def single-flag f :! "This parameter is a toggle flag, it does not consume arguments"
param-def eat-two :! "This parameter eats two arguments"

parameters-single-flag () {
  SINGLEFLAG=1;
  return 0;
}

parameters-eat-two () {
  ONE=$1;
  TWO=$2;
  return 2;
}

param-parse "$@"

echo ${SINGLEFLAG}
echo ${ONE}
echo ${TWO}
````
This will give :
````bash
$ bash script.sh -f --eat-two 42 56
1
42
56
````
