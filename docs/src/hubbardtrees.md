The Hubbard tree is a description of the dynamics of a quadratic polynomial

Topological, embedded perspective: Take a Julia set with finite critical orbit. The Hubbard tree is the minimal tree containing all the critical points, and the dynamics of the tree are given by restricting the function on the plane to the tree.

Combinatorial perspective: Given a kneading sequence, the Hubbard tree can be defined using the triod map

Implementation: The tree is stored as an adjacency matrix, with the first n entries holding the critical point and its forward images. The remaining entries refer to the branch points. 

Question: can there be disjoint cycles of branch points?
Answer: Yes. This happens when the denominator sequence has multiple entries greater than 2