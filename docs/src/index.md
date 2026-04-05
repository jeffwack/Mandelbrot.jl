# Mandelbrot.jl

## Package Features
- Calculate things about the Mandelbrot set

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

## Function Documentation

```@docs
KneadingSequence
```
```@docs
BinaryExpansion
```
```@docs
OrientedHubbardTree
```
```@docs
InternalAddress
```
```@docs
HubbardTree
```
```@docs
AngledInternalAddress
```