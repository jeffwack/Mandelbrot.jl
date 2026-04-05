# Mandelbrot

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeffwack.github.io/Mandelbrot.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeffwack.github.io/Mandelbrot.jl/dev/)
[![Build Status](https://github.com/jeffwack/Mandelbrot.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeffwack/Mandelbrot.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Summary

This package implements several algorithms related to complex quadratic dynamics. 
- The spider algorithm calculates the center of a hyperbolic component of the Mandelbrot set from one of its external angles. [Read about the spider algorithm.](https://pi.math.cornell.edu/~hubbard/SpidersFinal.pdf)
- The external angles of a hyperbolic component can be calculated from an angled internal address, describing the path to this component from zero. [Read about internal addresses.](https://arxiv.org/abs/math/9411238)
- A combinatorial description of a Hubbard trees can be generated from a kneading sequence, and when oriented in the plane can produce external angles. [Read about Hubbard trees.](https://www.mat.univie.ac.at/~bruin/papers/bkafsch.pdf)

## Algorithm Flow

```mermaid
flowchart TD
    AIA["Angled internal address"]
    IA["Internal address"]
    KS["Kneading sequence"]
    CHT["Combinatorial Hubbard tree"]
    OHT["Oriented Hubbard tree"]
    OP["Orbit portrait"]
    CA["Companion angles\n(minor leaf)"]
    RA["Rational angle"]
    CO["Critical orbit"]
    CP["Center parameter"]
    ER["External rays"]
    BP["Branch parameters"]
    EVHT["Embedded vertex Hubbard tree"]
    EHT["Embedded Hubbard tree"]

    AIA --> KS
    AIA --> OHT
    IA --> KS
    KS --> CHT
    CHT --> OHT
    OHT --> OP
    OHT --> CA
    OHT --> EVHT
    CA --> RA
    CA -.-> AIA
    RA --> CO
    CO --> CP
    OP --> ER
    CP --> ER
    ER --> BP
    BP --> EVHT
    EVHT --> EHT

    CP ==> JS(["Julia set"])
    ER ==> ERout(["External rays"])
    EHT ==> HTout(["Hubbard tree"])
```

## Source File Dependencies

```mermaid
flowchart TD
    Seq["Sequences.jl"]
    AD["angledoubling.jl"]
    G["Graphs.jl"]
    HT["HubbardTrees.jl"]
    OT["orienttrees.jl"]
    SM["spidermap.jl"]
    DR["dynamicrays.jl"]
    ET["embedtrees.jl"]

    Seq --> AD
    AD --> HT
    AD --> SM
    AD --> DR
    G --> HT
    HT --> OT
    OT --> ET
    SM --> ET
    DR --> ET
```
