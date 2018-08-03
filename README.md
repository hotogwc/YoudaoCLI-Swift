# YoudaoCLI-Swift

A command line tool for You Dao dictionary written in Swift

## Installation

#### Homebrew

```bash
brew tap hotogwc/tap
brew install hotogwc/tap/Youdaoswift
```

## Speech

Starting from V0.9, speech feature is available. You need to install mpg123 to enable this feature.

___NOTICE:___ Currently, speech feature is only available for MacOS/Linux.

#### Mac OS

```bash
brew install mpg123
```

#### Ubuntu

```bash
sudo apt-get install mpg123
```

#### CentOS

```bash
yum install -y mpg123
```

## Usage

1. Query

```text
YoudaoCLI-Swift <word(s) to query>
```

1. Query with speetch (__Available for MacOS & Linux__)

```text
YoudaoCLI-Swift <word(s) to query> -v
```

1. Query and show more example sentences

```text
YoudaoCLI-Swift <word(s) to query> -m
```

## 