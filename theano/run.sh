#!/bin/bash


# FOR MAGGIE I INSTALLED MKL SO DO LIKE THIS:
# LD_LIBRARY_PATH to include     /u/bergstrj/pub/intel/mkl/10.2.4.032/lib/em64t 
# LIBRARY_PATH to include        /u/bergstrj/pub/intel/mkl/10.2.4.032/lib/em64t
# THEANO_FLAGS="device=cpu,floatX=float64,blas.ldflags=-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_def -lpthread" python mlp.py

mkdir -p outs
MKL32='linker=c|py_nogc,device=cpu,floatX=float32,blas.ldflags=-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_def'
MKL64='linker=c|py_nogc,device=cpu,floatX=float64,blas.ldflags=-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_def'
GPU32='linker=c|py_nogc,device=gpu0,floatX=float32'

#MLP tests need the cvm linker.
MKL32_MLP='linker=cvm,device=cpu,floatX=float32,blas.ldflags=-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_def'
MKL64_MLP='linker=cvm,device=cpu,floatX=float64,blas.ldflags=-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_def'
GPU32_MLP='linker=cvm,device=gpu0,floatX=float32'

(THEANO_FLAGS="$MKL32_MLP" python mlp.py 2>>./outs/errors.log >> outs/${HOSTNAME}_mlp_cpu32.bmark) &&
(THEANO_FLAGS="$MKL64_MLP" python mlp.py 2>>./outs/errors.log >> outs/${HOSTNAME}_mlp_cpu64.bmark) &&
(THEANO_FLAGS="$GPU32_MLP" python mlp.py 2>>./outs/errors.log >> outs/${HOSTNAME}_mlp_gpu32.bmark) ;

(THEANO_FLAGS="$MKL32" python convnet.py 2>>./outs/errors.log >> outs/${HOSTNAME}_convnet_cpu32.bmark) &&
(THEANO_FLAGS="$MKL64" python convnet.py 2>>./outs/errors.log >> outs/${HOSTNAME}_convnet_cpu64.bmark) &&
(THEANO_FLAGS="$GPU32" python convnet.py 2>>./outs/errors.log >> outs/${HOSTNAME}_convnet_gpu32.bmark) ;


cat /proc/cpuinfo |grep "model name"|uniq > ${HOSTNAME}_config.conf
free >> ${HOSTNAME}_config.conf
uname -a >>  ${HOSTNAME}_config.conf
w >> ${HOSTNAME}_config.conf}

(THEANO_FLAGS="$MKL32" python rbm.py 1024 1024 1 100 2>>./outs/errors.log >> outs/${HOSTNAME}_rbm_cpu32_b1.bmark) &&
(THEANO_FLAGS="$MKL32" python rbm.py 1024 1024 60 20 2>>./outs/errors.log >> outs/${HOSTNAME}_rbm_cpu32_b60.bmark) ;

(THEANO_FLAGS="$MKL64" python rbm.py 1024 1024 1 100 2>>./outs/errors.log >> outs/${HOSTNAME}_rbm_cpu64_b1.bmark) &&
(THEANO_FLAGS="$MKL64" python rbm.py 1024 1024 60 20 2>>./outs/errors.log >> outs/${HOSTNAME}_rbm_cpu64_b60.bmark) ;

(THEANO_FLAGS="$GPU32" python rbm.py 1024 1024 1 100 2>>./outs/errors.log >> outs/${HOSTNAME}_rbm_gpu32_b1.bmark) &&
(THEANO_FLAGS="$GPU32" python rbm.py 1024 1024 60 20 2>>./outs/errors.log >> outs/${HOSTNAME}_rbm_gpu32_b60.bmark) ;
