using Mandelbrot, Test

# ## Kneading Sequences
#
# ``3/5`` and ``2/5`` are conjugate angles:

@test Mandelbrot.Sequence{Mandelbrot.KneadingSymbol{3}}(KneadingSequence(3//5)) == Mandelbrot.Sequence{Mandelbrot.KneadingSymbol{3}}(KneadingSequence(2//5))
