# dsc-smooth-gaussian

This is a Dynamic Statistical Comparisons (DSC) designed for comparing nonparametric regression methods. This repo contains two DSC scripts `susie-np.dsc` and `susie-tf.dsc` that are two benchmarks for wavelet-based SuSiE and trend filtering-based SuSiE respectively. It also contains corresponding R code for running DSC srcipts as well as a yml file for submitting jobs over clusters. Finally, the analysis folder includes a rmarkdown file `query_data.Rmd` to illustrate how to extract these DSC results for further analysis. 

## Setup

First, to install and use DSC, please follow the [DSC tutorial](https://stephenslab.github.io/dsc-wiki/overview). 

## Benchmarks

### Wavelet-based SuSiE benchmark

This benchmark compares [`smashr`](https://github.com/stephenslab/smashr/tree/master/R) with wavelet-based [`SuSiE`](https://github.com/stephenslab/susieR/tree/master/R), as well as using different families of wavelets.

Please use the command 

```
dsc susie-np.dsc -h
```
to view available runs, and

```
dsc susie-np.dsc --host kaiqian_midway.yml --replicate 50 -c 4
```
to run the benchmark.


### Trend filtering-based SuSiE benchmark

This benchmark compares trend filtering-based `SuSiE` with MAD initializations or not for change points problem.

Please use the command 

```
dsc susie-tf.dsc -h
```
to view available runs, and

```
dsc susie-tf.dsc --host kaiqian_midway.yml --replicate 50 -c 4
```
to run the benchmark.

## Query data

Please follow the instructions in the `query_data.Rmd` under the `analysis` folder. Thus, you are able to perform analysis for benchmark results by using RDS files obtained. 





