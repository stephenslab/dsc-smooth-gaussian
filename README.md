# dsc-smooth-gaussian

DSC for comparing nonparametric regression methods.

## Benchmarks

### Wavelet-based SuSiE benchmark

This benchmark compares `smashr` with wavelet-based `SuSiE`, as well as using different families of wavelets.

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

This benchmark compares trend filtering-based `SuSiE` using MAD initializations or not for change points problem.

Please use the command 

```
dsc susie-tf.dsc -h
```
to view available runs, and

```
dsc susie-tf.dsc --host kaiqian_midway.yml --replicate 50 -c 4
```
to run the benchmark.





