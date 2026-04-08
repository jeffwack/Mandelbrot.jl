using Mandelbrot, Test

# ## Kneading Sequences
#
# ``3/5`` and ``2/5`` are conjugate angles:

@test KneadingSequence(3//5) == KneadingSequence(2//5)
