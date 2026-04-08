# # Golden Tests for Mandelbrot
#
# These tests verify core calculations against hand-computed values.

using Mandelbrot, Test

# ## Kneading Sequences
#
# Two angles land on the same parameter ray if and only if they share a kneading sequence.
# For example, ``3/5`` and ``2/5`` are conjugate angles:

@test KneadingSequence(3//5) == KneadingSequence(2//5)
