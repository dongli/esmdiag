# Introduction

Earth system modeling is a systematic and complex scientific and engineering task for researching the climate of our Earth, which involves many people working together. Because the models are becoming more and more complex, we need a standard and automatic tool to diagnose the performance of models.

# Usage

## Step 1
Get the codes in whatever way you like, the recommendated way is:
```
$ git clone https://github.com/dongli/esmdiag
```
Assume the directory of `esmdiag` is `<ESMDIAG>`.

## Step 2
```
$ source <ESMDIAG>/bashrc
```
This will add `<ESMDIAG>` into your `PATH` environment variable.

## Step 3
Prepare the configuration file that is in JSON format, you can refer to `<ESMDIAG>/run/sample_config.json`.

## Step 4
Invoke the real command to run diagnostics.
```
esmdiag <CONFIG_FILE>
```

# Contributors

- Li Dong <dongli@lasg.iap.ac.cn>
