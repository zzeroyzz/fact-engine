<div align="center">
  <h1>Fact Engine</h1>
  <p>A simple fact storage and querying system for storing and matching facts.</p>
</div>


## Table of Contents
- [Introduction](#introduction)
- [Getting Started](#getting-started)
  - [Using IEx Session](#using-iex-session)
  - [Initialization](#initialization)
  - [Inputting Facts](#inputting-facts)
- [Querying Facts](#querying-facts)
- [Processing a .txt File](#processing-a-txt-file)
- [Processing a .txt FileOutput](#processing-a-txt-file-output)

## Introduction

FactEngine is a straightforward fact storage and querying system that enables users to store facts and then query or match against them. This guide will walk you through the basic usage of the FactEngine.

## Getting Started

### Using IEx Session

1. Navigate to your project directory in your terminal.
2. Start an IEx session with your project using:
   ```shell
   iex -S mix

### Initialization
To start the FactEngine, execute:

```shell
FactEngine.start()
```
### Inputting Facts

To input facts into the engine, use:

```shell
FactEngine.input("fact_name(value1, value2)")
```

For example:
```shell
FactEngine.input("likes(alex, sam)")
FactEngine.input("likes(sam, sam)")
FactEngine.input("dislikes(sam, alex)")
FactEngine.input("is_a_cat(biscuit)")
FactEngine.input("is_a_cat(beetlejuice)")
```

## Querying Facts
You can query facts using variables (X, Y). For example, if you have inputted the fact likes(alex, sam), you can query:

```shell
FactEngine.query_facts("likes(X, sam)")

Expected output:
[["alex"], ["sam"]]
```

if you have inputted the fact likes(sam, sam), you can query:

```shell
FactEngine.query_facts("likes(Y, Y)")

Expected output:
[["sam"]]
```
you can also query the like facts likes(X, Y)
Expected output:

```shell
FactEngine.query_facts("likes(X, Y)")

[[%{"X" => "alex", "Y" => "sam"}], [%{"X" => "sam", "Y" => "sam"}]]
```
if you have inputted the fact is_a_cat(x), you can query:

```shell
FactEngine.query_facts("is_a_cat(x)")

[["biscuit"], ["beetlejuice"]]
```

## Processing a .txt File
You can also process a .txt file that contains a list of inputs and queries. The format of the file should be:

```shell
INPUT fact_name1(value1, value2)
INPUT fact_name2(value1, value2)
...
QUERY your_query
...
```

For example, fact_file.txt might contain:

```shell
INPUT likes(alex, sam)
INPUT likes (sam, sam)
QUERY likes(X, sam)
```
To process the file, use an IEx session with your project using:

```shell
iex -S mix
```

```shell
FactEngine.process_file("path_to_your_file.txt")
```

The results of the queries will be printed to the console.

## Processing a .txt File Output
When you process a file or make a query in an IEx session, the results will be printed to the console. For file processing, the output for each query in the file will be displayed sequentially.

The expected output for fact_file.txt with data:

```shell
INPUT likes(alex, sam)
INPUT likes (sam, sam)
QUERY likes(X, sam)

Expected output:
Result of query likes (X, sam): [["alex"], ["sam"]]
```
