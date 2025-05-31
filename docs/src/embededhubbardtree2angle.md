Source: TreesBook page 175
The schematic diagram of algorithms (figure 1.2) suggests that this should be achieved by first embedding the Hubbard tree corresponding to this internal address using corollary 4.11, then calculating the external angle from this embedded Hubbard tree using algorithm 13.6

The implementation of algorithm 13.6 requires that the Hubbard tree's endpoints have a cyclic order. How can we obtain a cyclic order on the endpoints from an angled internal address? If we can put a cyclic order on all the branch points this will impose a cyclic order on the endpoints.

Corollary 4.11 (page 40) counts the number of ways to assign cyclic order to the branch points.

Lemmma 11.14 (page 146) tells us how to find the numerators of the angled internal address of an an external angle.

We want to describe the bijection between choices of numerator and choices of cyclic order. Here's a guess: A denominator of q corresponds to a characteristic branch point (equivalently a periodic branch orbit) with q arms. When the Hubbard tree is admissible the first return map of the characteristic point permutes the local arms transitively (page 37). The numerator p tells us how many arms the local arm towards 0 moves to be mapped to the local arm to c. Equivalently, it tells us how many arms apart the local arms to 0 and c are. 

The definition of characteristic point (page 34) tells us that characteristic points separate $0$ from $c_1$. In light of this we consider the arc $(0,c_1)$ and all the branch points on this arc. 

Calculating the external angles of the points of a Hubbard Tree should look like the process of orienting them. Namely, we should do it using preimages, and we can calculate all the angles one orbit at a time using the critical orbit and the branch orbits. Use the characteristic sets.

$7/19$ shows us an example where there is only a single characteristic point but many branch points, including on the path between zero and one.

How do we append the fixed point $\beta$ and its preimage $-\beta$ to a Hubbard tree? This process is described in algorithm 13.6 (page 175)