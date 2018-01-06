import numpy
cimport numpy
import cython
from libc.string cimport memcpy
from ... data_structures cimport DoubleList, Vector3DList, Vector2DList

def arrayToFloatList(numpy.ndarray[double, ndim=1, mode="c"] input):
    cdef double* inputPointer = &input[0]
    cdef int l = input.shape[0]
    cdef Py_ssize_t nbytes = input.nbytes
    cdef DoubleList values = DoubleList(length = l, capacity = l)
    memcpy(values.data, inputPointer, nbytes)
    return values

def arrayTo3DList(numpy.ndarray[float, ndim=2, mode="c"] input):
    cdef float* inputPointer = &input[0, 0]
    cdef int l = input.shape[0]
    cdef Py_ssize_t nbytes = input.nbytes
    cdef Vector3DList vectors = Vector3DList(length = l, capacity = l)
    memcpy(vectors.data, inputPointer, nbytes)
    return vectors

def arrayTo2DList(numpy.ndarray[float, ndim=2, mode="c"] input):
    cdef float* inputPointer = &input[0, 0]
    cdef int l = input.shape[0]
    cdef Py_ssize_t nbytes = input.nbytes
    cdef Vector2DList vectors = Vector2DList(length = l, capacity = l)
    memcpy(vectors.data, inputPointer, nbytes)
    return vectors
