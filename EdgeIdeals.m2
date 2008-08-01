needsPackage "SimplicialComplexes"

newPackage("EdgeIdeals", 
           Version => "0.1",
           Date => "July 1, 2008",
           Authors => {
		       {Name => "Chris Francisco", 
                        Email => "chris@math.okstate.edu",
                        HomePage => "http://www.math.okstate.edu/~chris/"
                       },
		       {Name => "Andrew Hoefel", 
                        Email => "handrew@mathstat.dal.ca",
                        HomePage => "http://andrew.infinitepigeons.org/"
                       },
		       {Name => "Adam Van Tuyl", 
                        Email => "avantuyl@sleet.lakeheadu.ca",
                        HomePage => "http://flash.lakeheadu.ca/~avantuyl/"
                       }
                      },
           Headline => "a package for edge ideals.",
           DebuggingMode => true
          )

needsPackage "SimplicialComplexes"
needsPackage "SimpleDoc"

export {HyperGraph, 
        hyperGraph, 
	Graph,
	graph,
	adjacencyMatrix,
	allOddHoles,
	allEvenHoles,
	antiCycle,
	chromaticNumber,
	cliqueComplex,
	cliqueNumber,
	coverIdeal,
	complementGraph,
	completeGraph,
	completeMultiPartite,
	connectedComponents,
	cycle,
	degreeVertex,
	deleteEdges,
	edgeIdeal,
	edges, 
	getCliques,
	getEdge,
	getEdgeIndex,
	getGoodLeaf,
	getGoodLeafIndex,
	getMaxCliques,
	hasGoodLeaf,
	hasOddHole,
	hyperGraphToSimplicialComplex,
	incidenceMatrix,
	independenceComplex,
	independenceNumber,
	inducedGraph,
      	isBipartite,
	isChordal,
	isCM,
	isConnected,
	isEdge,
	isForest,
	isGoodLeaf,
	isGraph,
	isLeaf,
	isPerfect,
	isSCM,
	lineGraph,
	neighbors,
	numConnectedComponents,
	numTriangles,
     	randomGraph,
	randomHyperGraph,
	randomUniformHyperGraph,
	simplicialComplexToHyperGraph,
	smallestCycleSize,
	spanningTree,
	vertexCoverNumber,
	vertexCovers,
	vertices,
	Gins
        };

----------------------------------------------------------------------------------------
--
-- TYPES
--
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- HyperGraph
----------------------------------------------------------------------------------------

HyperGraph = new Type of HashTable;
hyperGraph = method(TypicalValue => HyperGraph);

hyperGraph (PolynomialRing, List) := HyperGraph => (R, E) -> ( 
     -- Output: HyperGraph over R with edges E
     -- Assert: R is a polynomial ring
     -- Assert: E is a List of Lists of variables of R or
     --         E is a List of square-free monomials in R 
     if any(E, e -> class e =!= List) and any(E, e -> class class e =!= PolynomialRing)
     then ( print apply(E, e -> class e) ;error "Edges must be lists of varibles or monomials.");

     V := gens R;
     --- check needed for square free 
     if any(E, e-> class class e === PolynomialRing) then E = apply(E, support);
     E = apply(E, unique); --- Enforces square-free if edges are given as lists
     H := new HyperGraph from hashTable({"ring" => R, "vertices" => V, "edges" => E});
     if any(H#"edges", e -> not instance(e, List)) then error "Edges must be lists.";
     if any(H#"edges", e -> not isSubset(e,H#"vertices")) then error "Edges must be subsets of the vertices.";
     if any(0..#(H#"edges") -1, I -> 
	  any(0..I-1, J-> isSubset(H#"edges"#I, H#"edges"#J) or isSubset(H#"edges"#J, H#"edges"#I))
     	  )
     then error "Edges satisfy a inclusion relation";
     return H;
)

hyperGraph (MonomialIdeal) := HyperGraph => (I) -> 
( 
     if not isSquareFree I then error "Ideals must be square-free.";
     hyperGraph(ring I, apply(flatten entries gens I, support))
)

hyperGraph (Ideal) := HyperGraph => (I) -> 
( 
     hyperGraph monomialIdeal I
)

hyperGraph (List) := HyperGraph => (E) -> 
( 
     M := null; 
     if all(E, e-> class e === List) then (
	  if E == {} or E == {{}} then error "Use alternate construction with PolynomialRing to input empty hyperGraph" else
     	  M = monomialIdeal apply(E, product);
	  );
     if all(E, e-> class class e === PolynomialRing) then M = monomialIdeal E;
     if M === null then error "Edge must be represented by a list or a monomial.";
     if #E =!= numgens M then error "Edges satisfy an inclusion relation."; 
     hyperGraph M
)


----------------------------------------------------------------------------
-- Graph
----------------------------------------------------------------------------

Graph = new Type of HyperGraph;

graph = method(TypicalValue => Graph);

graph (PolynomialRing, List) := Graph => (R, E) ->
(
     H := hyperGraph(R, E);
     if not isGraph(H) then error "Edges must be of size two.";
     new Graph from H
)	

graph (MonomialIdeal) := Graph => (I) -> 
(
     H := hyperGraph(I);
     if not isGraph(H) then error "Ideal must have quadratic generators.";
     new Graph from H
)	

graph (Ideal) := Graph => (I) -> 
(
     H := hyperGraph(I);
     if not isGraph(H) then error "Ideal must have quadratic generators.";
     new Graph from H
)	

graph List := Graph => E -> 
(
     if E == {} or E == {{}} then error "Use alternate construction with PolynomialRing to input empty graph";
     H := hyperGraph(E);
     if not isGraph(H) then error "Edges must be of size two.";
     new Graph from H
)	

graph (HyperGraph) := Graph => (H) -> 
(
     if not isGraph(H) then error "Edges must be of size two.";
     new Graph from H
)	

hyperGraph (Graph) := HyperGraph => (G) -> 
(
     new HyperGraph from G
)	


-------------------------------------------------------------------
--
-- FUNCTIONS
--
------------------------------------------------------------------




--------------------------------------------------------------
-- Mathematical equality 
-- return true if two graphs are equal (defined over same ring,
-- have same edge sets in some order).
--------------------------------------------------------------

HyperGraph == HyperGraph := (G,H) -> (
     G#"ring" == H#"ring" and
     set(G#"vertices") === set(H#"vertices") and
     set(apply(G#"edges", set)) === set(apply(H#"edges",set))
     ) 

--------------------------------------------------------------
-- adjacencyMatrix
-- return the adjacency matrix of a graph
--------------------------------------------------------------

adjacencyMatrix = method();

adjacencyMatrix Graph := G -> (
     vert:= G#"vertices";
     n := #vert;
     m := toList apply(0..n-1,i-> toList apply(0..n-1,j-> if isEdge(G,{vert_i,vert_j}) then 1 else 0));  
     return (matrix m)
     )


------------------------------------------------------------
-- allEvenHoles
-- returns a list of even induced cycles
-- NOTE:  this function will be SLOWWW!
-----------------------------------------------------------

allEvenHoles = method();
allEvenHoles Graph := G -> (
     R:=G#"ring";
     S:=(coefficientRing R)[append(flatten entries vars R,newVar)];
     edges:=G#"edges";
     numEdges:=#edges;
     count:=0;
     evenCycles:={};
     while count < numEdges do (
	  newEdges:={{first(edges#count),newVar},{newVar,(edges#count)#1}};
     	  tempEdges:=apply(join(drop(edges,{count,count}),newEdges),i->apply(i,j->substitute(j,S)));
	  tempGraph:=graph(S,tempEdges);
	  evenCycles=append(evenCycles,select(allOddHoles tempGraph,i->member(newVar,i)));
	  count=count+1;
	  );
     use R;
     apply(unique apply(flatten evenCycles,i->select(i,j->(j != newVar))),k->apply(k,l->substitute(l,R)))
     )

--------------------------------------------------------------
-- allOddHoles
-- returns a list of all the odd holes in a graph
--------------------------------------------------------------

allOddHoles = method();
allOddHoles Graph := G -> (
     coverI:=coverIdeal G;
     apply(select(ass coverI^2,i->codim i > 3),j->flatten entries gens j)
     )


-------------------------------------------------------------------
-- antiCycle
-- return the complement of a cycle.
------------------------------------------------------------------

antiCycle = method(TypicalValue=>Graph);
antiCycle (Ring) := Graph =>(R) -> antiCycle(generators R)

antiCycle (Ring, ZZ) := Graph =>(R, N) -> antiCycle(apply(N, i->R_i))

antiCycle (List) := Graph =>(L)-> (
     if #L < 3 then error "Cannot construct anticycles of length less than three";
     antiCycleEdgeSet := subsets(L,2) - set append(apply(#L-1, i-> {L#i,L#(i+1)}), {(first L),(last L)});
     graph(ring L#0,toList antiCycleEdgeSet)
     )     	   



    



---------------------------------------------------------------
-- chromaticNumber
-- returns the chromatic number of a (hyper)graph
-- NOTE: based upon work in progress by Francisco-Ha-Van Tuyl
---------------------------------------------------------------

chromaticNumber = method();
chromaticNumber HyperGraph := H -> (
     Chi := 2; -- assumes graph has at least one edge
     m := product H#"vertices";
     j := coverIdeal H;
     while ((m^(Chi-1) % j^Chi) != 0) do (
	  Chi = Chi + 1;
	  );
     return (Chi); 
     )


---------------------------------------------------------------
-- cliqueComplex
-- return the simplicial complex whose faces are the cliques of a graph
---------------------------------------------------------------
cliqueComplex =method();
cliqueComplex Graph := G -> independenceComplex complementGraph G;


-------------------------------------------------
-- cliqueNumber
-- return the clique number of a graph
------------------------------------------------

cliqueNumber = method();
cliqueNumber Graph := G -> (
     #(last getCliques G)
     )


---------------------------------------------------------------
-- complementGraph
-- returns the complement of a graph or hypergraph
-- NOTE:  does something different for graphs vs hyerpergraphs
--------------------------------------------------------------

complementGraph = method();
complementGraph Graph := G -> (
     v := G#"vertices";
     alledges := set(subsets(v,2));
     gedges := set G#"edges";
     gcedges := alledges - gedges;  -- edges of the complement
     return(graph(G#"ring",toList gcedges));
     )

complementGraph HyperGraph := H -> (
     hcedge := apply(H#"edges",e-> toList (set(H#"vertices") - set e));  -- create edge set of hypergraph
     return (hyperGraph(H#"ring",toList hcedge));
     )




----------------------------------------------------------------------
-- completeGraph
-- return graph of complete n-graph
----------------------------------------------------------------------

completeGraph = method();
completeGraph (Ring) := Graph =>(R) -> completeGraph(generators R)

completeGraph (Ring, ZZ) := Graph =>(R, N) -> completeGraph(apply(N, i->R_i))

completeGraph (List) := Graph =>(L)-> (
     if #L === 0 then error "Cannot construct complete graph on no vertices";
     E := for i from 0 to #L -2 list
     for j from i+1 to #L-1 list
     L#i * L# j;
     graph(ring first L, flatten E)  
     )     


--------------------------------------------------------------------------
-- completeMultiPartite
-- return the complete multi-partite graph
--------------------------------------------------------------------------

completeMultiPartite = method();

completeMultiPartite (Ring, ZZ, ZZ) := Graph =>(R,N,M) -> 
     completeMultiPartite(R, toList apply(N, i->M))

completeMultiPartite (Ring, List) := Graph =>(R, L) -> (
     if all(L, l -> class l === ZZ) then (
	if sum L > #gens(R) then 
	    error "Too few variables in ring to make complete multipartite graph";	
	N := 0;
	L = for i from 0 to #L-1 list (
	    E := toList apply(L#i, j -> R_(j+N));
	    N = N+L#i;
	    E
	    );
     );
     if all(L, l -> class l === List) then (
	K := flatten for i from 0 to #L-2 list
	    flatten for j from i+1 to #L-1 list
		flatten for x in L#i list
		    for y in L#j list {x,y};
	return graph(R, K);
     ) else error "completeMultipartite must be passed a list of partition sizes or a list of partitions.";
     )


-----------------------------------------------------------------------
-- connectedComponents
-- returns all the connected components of a graph
----------------------------------------------------------------------

connectedComponents = method();
connectedComponents HyperGraph := H -> (
     V := select(H#"vertices", v-> any(H#"edges", e -> member(v,e)));
     while #V > 0 list (
	C := {V#0};
	i := 0;
	while i < #C do (
	    N := select(neighbors(H, C#i), v-> not member(v,C));
	    C = join(C,N);
	    i = i+1;
        );
	V = select(V, v -> not member(v,C));
	C
     )
     )



----------------------------------------------------------------------
-- coverIdeal
-- return the Alexander dual of edge ideal, otherwise known as the cover ideal
------------------------------------------------------------------------
coverIdeal = method();
coverIdeal HyperGraph := H -> dual edgeIdeal H




----------------------------------------------------------------------------
-- cycle
-- return graph of the cycle on n vertices
---------------------------------------------------------------------------

cycle = method(TypicalValue=>Graph);
cycle (Ring) := Graph =>(R) -> cycle(generators R)

cycle (Ring, ZZ) := Graph =>(R, N) -> cycle(apply(N, i->R_i))

cycle (List) := Graph =>(L)-> (
     if #L < 3 then error "Cannot construct cycles of length less than three";
     graph(ring L#0,append(apply(#L-1, i-> L#i*L#(i+1)), (last L)*(first L)))
     )     	   


----------------------------------------------------------------------
-- degreeVertex
-- returns the degree of a vertex
----------------------------------------------------------------------

degreeVertex = method();
degreeVertex (HyperGraph, ZZ) := (H,N) ->	(
		degreeVertex(H, (H#"ring")_N)
	)
degreeVertex (HyperGraph, RingElement) := (H,V) ->	(
		use H#"ring";
		N := index V;
		if N === null then error "Variable is not a vertex of the given HyperGraph";
		number(H#"edges", E-> member(V,E))
	)

----------------------------------------------------------------------------------
-- deleteEdges
-- remove edges from a (hyper)graph
----------------------------------------------------------------------------------
deleteEdges = method();

deleteEdges (HyperGraph,List) := (H,E) -> (
     if (isSubset(set E,set H#"edges") =!= true) then error "Second argument must be a subset of the edges, entered as a list";
     newedges:=set(H#"edges")-set(E);
     if toList newedges == {} then return (hyperGraph monomialIdeal(0_(H#"ring")));
     return (hyperGraph toList newedges);
     )

--deleteEdges (Graph,List) := (H,E) -> (graph deleteEdges (hyperGraph(H),E))


----------------------------------------------------------------------
-- edgeIdeal
-- return the edge ideal of a graph or hypergraph
----------------------------------------------------------------------

edgeIdeal = method();
edgeIdeal HyperGraph := H -> (
     if H#"edges" == {} or H#"edges" == {{}} then return monomialIdeal(0_(H#"ring"));
     monomialIdeal apply(H#"edges",product)) 


------------------------------------------------------------
-- edges
-- returns edges of a (hyper)graph
------------------------------------------------------------

edges = method();
edges HyperGraph := H -> H#"edges";


----------------------------------------------------------------
-- getCliques
-- return all cliques of the graph
----------------------------------------------------------------

getCliques = method();
getCliques (Graph,ZZ) := (G,d) -> (
     subs:=apply(subsets(G#"vertices",d),i->subsets(i,2));
     cliqueIdeals:=apply(subs,i->ideal apply(i,j->product j));
     edgeId:=edgeIdeal G;
     apply(select(cliqueIdeals,i->isSubset(i,edgeId)),j->support j)
       )

getCliques Graph := G -> (
     numVerts:=#(G#"vertices");
     cliques:={};
     count:=2;
     while count <= numVerts do (
	  newCliques:=getCliques(G,count);
	  if newCliques == {} then return flatten cliques;
	  cliques=append(cliques,newCliques);
	  count=count+1;
	  );
     flatten cliques
     )


------------------------------------------------------------
-- getEdge
-- return a specific edge
------------------------------------------------------------

getEdge = method();
getEdge (HyperGraph, ZZ) := (H,N) -> H#"edges"#N;

------------------------------------------------------------
-- getEdgeIndex
-- returns position of a given edge in a list of edges
------------------------------------------------------------

getEdgeIndex = method();
getEdgeIndex (HyperGraph, List) := (H,E) -> ( 
     if class class E === PolynomialRing then E = support E;
     N :=  select(0..#(H#"edges")-1, N -> set H#"edges"#N === set E);
     if #N === 0 then return -1; 
     return first N;
)

getEdgeIndex (HyperGraph, RingElement) := (H,E) -> ( 
     getEdgeIndex(H, support E)
)

-----------------------------------------------------------
-- getGoodLeaf
-- return a "Good Leaf" of a hypergraph
----------------------------------------------------------

getGoodLeaf = method();
getGoodLeaf HyperGraph := H -> ( 
     return H#"edges"#(getGoodLeafIndex H);
)


------------------------------------------------------------
-- getGoodLeafIndex
-- return the index of a "Good Leaf" in a hypergraph
------------------------------------------------------------

getGoodLeafIndex = method();
getGoodLeafIndex HyperGraph := H ->
(  GL := select(0..#(H#"edges")-1, N -> isGoodLeaf(H,N));
   if #GL == 0 then return -1;
   return first GL;
);

--------------------------------------------------------------------------
-- getMaxCliques
-- return all cliques of maximal size
--------------------------------------------------------------------------

 -- return all cliques of maximal size
getMaxCliques = method();
getMaxCliques Graph := G -> (
     cliqueList:=getCliques G;
     clNum:=#(last cliqueList);
     select(cliqueList,i->#i == clNum)
     )


-----------------------------------------------------------------------------
-- hasGoodLeaf
-- checks if a hypergraph has any "Good Leaves"
----------------------------------------------------------------------------

hasGoodLeaf = method();
hasGoodLeaf HyperGraph := H -> any(0..#(H#"edges")-1, N -> isGoodLeaf(H,N))


------------------------------------------------------------------------------
-- hasOddHole
-- checks if a graph has an odd hole (not triangle)
-----------------------------------------------------------------------------

hasOddHole = method();
hasOddHole Graph := G -> (
     coverI:=coverIdeal G;
     any(ass coverI^2,i->codim i > 3)
     )     

--------------------------------------------------
-- hyperGraphToSimplicialComplex
-- change the type of a (hyper)graph to a simplicial complex
---------------------------------------------------
hyperGraphToSimplicialComplex = method()
hyperGraphToSimplicialComplex HyperGraph := H -> (
     simplicialComplex flatten entries gens edgeIdeal H
     )




-----------------------------------------------------------------------------
-- incidenceMatrix
-- return the incidence matrix of a graph
-----------------------------------------------------------------------------

incidenceMatrix = method();

incidenceMatrix HyperGraph := H -> (
     v:= H#"vertices";
     e := H#"edges";
     m := toList apply(0..#v-1,i-> toList apply(0..#e-1,j-> if member(v_i,e_j) then 1 else 0));  
     return (matrix m)
     )


-------------------------------------------------------------------------------
-- independenceComplex
-- returns the simplicial complex whose faces are the independent sets of a (hyper)graph
--------------------------------------------------------------------------------
independenceComplex =method();

independenceComplex HyperGraph := H -> (simplicialComplex edgeIdeal H)


------------------------------------------------------------------
-- independenceNumber
-- return the independence number, the size of the largest independent set of a vertices
------------------------------------------------------------------

independenceNumber = method();
independenceNumber Graph:= G -> (
     return (dim edgeIdeal G);
     )


--------------------------------------------------------------------------------
-- inducedGraph
-- given a set of vertices, return induced graph on those vertices
--------------------------------------------------------------------------------

inducedGraph = method();
inducedGraph (HyperGraph,List) := (H,S) -> (
     if (isSubset(set S, set H#"vertices") =!= true) then error "Second argument must be a subset of the vertices";
     ie := select(H#"edges",e -> isSubset(set e,set S));
     R := (coefficientRing H#"ring")[S];
     F := map(R,H#"ring");
     ienew := apply(ie,e -> apply(e,v->F(v)));
		 use H#"ring";
     return(hyperGraph(R,ienew));
     )


-----------------------------------------------------------
-- isBipartite
-- checks if a graph is bipartite
-----------------------------------------------------------

isBipartite = method();
isBipartite Graph := G -> (chromaticNumber G == 2); -- checks if chromatic number is 2


-------------------------------------------------------------
-- isChordal
-- check if a graph is a chordal graph
-------------------------------------------------------------

isChordal = method(); -- based upon Froberg's characterization of chordal graphs
isChordal Graph := G -> (
     I := edgeIdeal complementGraph G;
     graphR := G#"ring";
     if I == ideal(0_graphR) then return (true);
     D := min flatten degrees I;
     B := coker gens I;
     R = regularity(B);
     if D-1 =!= R then return (false);
     return(true);
     )
----------  this function will break! if G is a complete graph.  We need to fix it!

-------------------------------------------------------------
-- isCM
-- checks if a (hyper)graph is Cohen-Macaulay
------------------------------------------------------------

isCM = method();

isCM HyperGraph := H -> (
     I:=edgeIdeal H;
     codim I == pdim coker gens I
     )

--    R := H#"ring";
--    M := R^1 / edgeIdeal H;
--    Q := R^1 / ideal gens R;
--    D := dim M;
--    Ext^D(Q,M) !=0 and Ext^(D-1)(Q,M) == 0
--    )

------------------------------------------------------------
-- isConnected
-- checks if a graph is connected
-- (the graph is connected <=> A, the adjacency the matrix,
-- and I, the identity matrix of size n, has the 
-- property that (A+I)^{n-1} has no zero entries)
------------------------------------------------------------

isConnected = method();
isConnected HyperGraph := H -> numConnectedComponents H == 1


------------------------------------------------------------
-- isEdge
-- checks if a set is an edge of a (hyper)graph
------------------------------------------------------------

isEdge = method();
isEdge (HyperGraph, List) := (H,E) -> (
		if class class E === PolynomialRing then E = support E;
		any(H#"edges", G->set G === set E)
	)
isEdge (HyperGraph, RingElement) := (H,E) -> (
		isEdge(H, support E)
	)

-------------------------------------------------------------
-- isForest
-- checks if a (hyper)graph is a tree
------------------------------------------------------------

isForest = method();
isForest Graph := G -> (smallestCycleSize G == 0);

isForest HyperGraph := H -> (
    E := toList(0..#(H#"edges") -1);
    while #E =!= 0 do (
	L := select(E, i-> isGoodLeaf(H,i));
	if #L === 0 then return false;
        H = hyperGraph(H#"ring", drop(H#"edges", {first L, first L}));
	E = toList(0..#(H#"edges") -1);
    );
    true
    )

-------------------------------------------------------------
-- isGoodLeaf
-- checks if the n-th edge of a hypergraph is a "Good Leaf"
----------------------------------------------------------

isGoodLeaf = method();
isGoodLeaf (HyperGraph, ZZ) := (H,N) -> ( 
     intersectEdges := (A,B) -> set H#"edges"#A * set H#"edges"#B;
     overlaps := apply(select(0..#(H#"edges")-1, M -> M =!= N), M -> intersectEdges(M,N));
     overlaps = sort toList overlaps;
     --Check if the overlaps are totally ordered
     all(1..(#overlaps -1), I -> overlaps#(I-1) <= overlaps#I)
     );

------------------------------------------------------------
-- isGraph
-- checks if a hypergraph is a graph
------------------------------------------------------------

isGraph = method();
isGraph HyperGraph := Boolean => (H) -> (
		H#"edges" == {{}} or H#"edges" == {} or all(H#"edges", e-> #e === 2 )
	)


--------------------------------------------------------------
-- isLeaf
-- checks if the n-th edge of the (hyper)graph is a leaf
--------------------------------------------------------------

isLeaf = method();
isLeaf (HyperGraph, ZZ) := (H,N) -> ( 
     intersectEdges := (A,B) -> set H#"edges"#A * set H#"edges"#B;
     overlaps := apply(select(0..(#(H#"edges")-1), M -> M =!= N), M -> intersectEdges(M,N));
     overlapUnion := sum toList overlaps;
     any(overlaps, branch -> isSubset(overlapUnion,branch))
     )

isLeaf (Graph, ZZ) := (G,N) -> ( 
     any(G#"edges"#N, V -> degreeVertex(G,V) === 1)
     ---Note N refers to an edge index
     )

isLeaf (HyperGraph, RingElement) := (H,V) -> ( 
     E := select(0..#(H#"edges")-1, I -> member(V, H#"edges"#I));
     #E == 1 and isLeaf(H, E#0)
     )


------------------------------------------------------------
-- isPerfect
-- checks if a graph is a perfect graph
------------------------------------------------------------

isPerfect = method();
isPerfect Graph := G -> (
     if hasOddHole G then return false;
     if hasOddHole complementGraph G then return false;
     return true;
     )

------------------------------------------------------------
-- isSCM
-- checks if (hyper)graph is Sequentially Cohen-Macaulay
-------------------------------------------------------------

needsPackage "GenericInitialIdeal"

isSCM= method(Options=>{Gins=>false});
isSCM HyperGraph := opts -> H -> (
     J:=dual edgeIdeal H;
     if opts#Gins then (
	  g:=gin J;
	  return (#(flatten entries mingens g) == #(flatten entries mingens J));
	  );
     degs:=sort unique apply(flatten entries gens J,i->first degree i);
     numDegs:=#degs;
     count:=0;
     while count < numDegs do (
	  Jdeg:=monomialIdeal super basis(degs#count,J);
	  if regularity Jdeg != degs#count then return false;
	  count=count+1;
	  );
     return true;
     )
     

------------------------------------------------------------------
-- lineGraph
-- return the graph with E(G) as its vertices where two
--  vertices are adjacent when their associated edges are adjacent in G.
------------------------------------------------------------------

lineGraph = method();

lineGraph HyperGraph := H -> (
    R := QQ[x_0..x_(#edges(H)-1)];
    E := apply(H#"edges", set);
    L := select(subsets(numgens R, 2), e -> #(E#(e#0) * E#(e#1)) > 0);
    graph(R, apply(L,e->apply(e, i-> x_i)))
    )


-----------------------------------------------------------
-- neighbors
-- returns all the neighbors of a vertex or a set
-----------------------------------------------------------

neighbors = method();

neighbors (HyperGraph, ZZ) :=  (H, N) -> neighbors(H, H#"ring"_N)

neighbors (HyperGraph, RingElement) := (H,V) -> (
     unique select(flatten select(H#"edges", E-> member(V,E)), U-> U =!= V)
     )

neighbors (HyperGraph, List) := (H,L) -> (
     if any(L, N-> class N === ZZ) then L = apply(L, N-> H#"ring"_N);
     unique select(flatten apply(L, V-> neighbors(H,V)), U -> not member(U, L))
     )

------------------------------------------------------------
-- numConnectedComponents
-- the number of connected components of a (hyper)Graph
------------------------------------------------------------

numConnectedComponents = method();
numConnectedComponents HyperGraph:= H -> (rank HH_0 hyperGraphToSimplicialComplex H)+1

-----------------------------------------------------------
-- numTrianges
-- returns the number of triangles in a graph
-----------------------------------------------------------

numTriangles = method();
numTriangles Graph := G -> (
     number(ass (coverIdeal G)^2,i->codim i==3)
     )

-----------------------------------------------------------
-- randomGraph
-- returns a graph with a given vertex set and randomly chosen
-- edges with the user determining the number of edges
-----------------------------------------------------------
randomGraph = method();
randomGraph (PolynomialRing,ZZ) := (R,num) -> (
     graph randomUniformHyperGraph(R,2,num)
     )

-----------------------------------------------------------
-- randomHyperGraph
-- returns a hypergraph on a given vertex set and randomly
-- chosen edges of given cardinality
-- NOTE: currently conflicts with inclusion error 
-----------------------------------------------------------

randomHyperGraph = method();
randomHyperGraph (PolynomialRing,List) := (R,li) -> (
     if not all(li,i->instance(i,ZZ) and i > 0) then error "cardinalities of hyperedges must be positive integers";
     verts:=flatten entries vars R;
     if any(li,i->i>#verts) then error "cardinality of at least one hyperedge is too large";
     cards:=sort li;
     uniques:=unique cards;
     numCards:=#uniques;
     edgeList:={};
     count:=0;
     while count < numCards do (
	  subs:=subsets(verts,uniques#count);
	  edgeList=append(edgeList,take(random subs,number(cards,i->i==uniques#count)));
     	  count=count+1;
	  );
     hyperGraph(R,flatten edgeList)
     )	  

-----------------------------------------------------------
-- randomUniformHyperGraph
-- returns a random hypergraph on a given vertex set
-- user chooses cardinality of edges and the number of edges
-----------------------------------------------------------

randomUniformHyperGraph = method();
randomUniformHyperGraph (PolynomialRing,ZZ,ZZ) := (R,card,num) -> (
     randomHyperGraph(R,toList(num:card))
     )



--------------------------------------------------
-- simplicialComplexToHyperGraph
-- change the type of a simplicial complex to a (hyper)graph
---------------------------------------------------

simplicialComplexToHyperGraph = method()

simplicialComplexToHyperGraph SimplicialComplex := D -> (
	  hyperGraph flatten entries facets D
	  )




------------------------------------------------------
-- smallestCycleSize
-- length of smallest induced cycle in a graph
-------------------------------------------------------
smallestCycleSize = method();

smallestCycleSize Graph := G -> (
     if numTriangles G =!= 0 then return(3);
     R :=  res edgeIdeal complementGraph G;
     smallestCycle:=0;
     i := 1;
     -- this loop determines if there is a non-linear syzygy
     -- the first non-linear syzygy tells us the smallest induced
     -- cycle has lenght >= 4.  This is based upon 
     -- the paper of Eisenbud-Green-Hulek-Popescu,
     -- "Restricting linear syzygyies: algebra and geometry"
     while  ((smallestCycle == 0) and (i <= pdim betti R)) do (
	  A := R_i;
          B := flatten degrees A     ;
	  t := tally B;
	  if (t #? (i+1)) then (
               d := rank A;
	       if d == t#(i+1) then i = i+1 else smallestCycle = i+2;
               )	   
       	  else smallestCycle = i+2;     
       );
     -- If the resolution is linear, smallestCycle still has the value of 0
     -- Because the resolution is linear, the graph is chordal, by
     -- a result of Froberg.  Since we have taken care of the case
     -- that G has a triangle, the graph will be a tree.
     return (smallestCycle);
     );	 



------------------------------------------------------------
-- spanningTree
-- returna a spanning tree of a graph
-----------------------------------------------------------

spanningTree = method();
spanningTree Graph:= G-> (
     if (not isConnected G) then error "The graph must be connected";
     eG := G#"edges";
     numVert:=#G#"vertices";
     eT := {eG_0};
     count:=1;
     while #eT < numVert-1 do (
	  eTemp := append(eT,eG_count);
	  while (smallestCycleSize (graph eTemp) > 0) do (
	       count =count+1;
	       eTemp = append(eT,eG_count);
	       );
	  count = count+1;
	  eT = eTemp;
	  );
     spanTree = graph eT;
     return (spanTree);
     );


----------------------------------------------------
-- vertexCoverNumber
-- return the vertex cover number of a (hyper)graph
---------------------------------------------------

vertexCoverNumber = method();
vertexCoverNumber HyperGraph := H -> (
     min apply(flatten entries gens coverIdeal H,i->first degree i)
     )

----------------------------------------
-- vertexCovers
-- return all minimal vertex covers 
-- (these are the generators of the Alexander dual of the edge ideal)
----------------------------------------

vertexCovers  = method();
vertexCovers HyperGraph := H -> (
     flatten entries gens coverIdeal H
     )

-----------------------------------------
-- vertices
-- returns the vertices of the (hyper)graph
--------------------------------------------

vertices = method();
vertices HyperGraph := H -> H#"vertices";


---------------------------------------------------------
---------------------------------------------------------
-- Simple Doc information
---------------------------------------------------------
---------------------------------------------------------

--*******************************************************
-- DOCUMENTATION FOR PACKAGE
--*******************************************************

doc ///
       Key 
       	       EdgeIdeals
       Headline
       	       A package for working with the edge ideals of (hyper)graphs
       Description
      	       Text
               	    Edge ideals is a package to work with the edge ideals of (hyper)graphs.
		    
		    An edge ideal is a square-free monomial ideal where the generators of the monomial ideal correspond to the edges
		    of the (hyper)graph.  An edge ideal complements the Stanley-Reisner correspondence 
		    (see @TO SimplicialComplexes @) by providing an alternative combinatorial interpretation of the 
		    monomial generators.  
		    
		    This package exploits the correspondence between square-free monomial ideals and the combinatorial
		    objects, by using commutative algebra routines to derive information about (hyper)graphs.
		    For some of the mathematical background on this material, see Chapter 6 of the textbook 
		    {\it Monomial Algebras} by R. Villarreal and the survey paper
		    of T. Ha and A. Van Tuyl ("Resolutions of square-free monomial ideals via facet ideals: a survey," 
		    Contemporary Mathematics. 448 (2007) 91-117). 
		    
		    
		    {\bf Note:}  When we use the term "edge ideal of a hypergraph", we are actually referring to the edge ideal
		    of a clutter, a hypergraph where no edge is a subset of another edge.    If $H$ is a hypergraph that is not a 
		    clutter, then when we form its edge ideal
		    in a similar fashion, some information will be lost because not all of the edges of the hypergraph will
		    correspond to minimal generators.   The edge ideal of a hypergraph is similar to the facet ideal of a simplicial complex,
		    as defined by S. Faridi in  "The facet ideal of a simplicial complex," 
		    Manuscripta Mathematica 109, 159-174 (2002). 
///
 


--*******************************************************
-- DOCUMENTATION FOR TYPES
--*******************************************************

---------------------------------------------------------
-- DOCUMENTATION HyperGraph
---------------------------------------------------------


doc ///
	Key
		HyperGraph
	Headline 
		a class for hypergraphs.
///

doc ///
	Key
		Graph
	Headline 
		a class for graphs.
	Description
		Text
			This class represents simple graphs. This class extends @TO HyperGraph@ and hence
			inherits all HyperGraph methods.
	SeeAlso
		HyperGraph
///


---------------------------------------------------------
-- DOCUMENTATION hyperGraph
---------------------------------------------------------

doc ///
	Key
		hyperGraph
		(hyperGraph, PolynomialRing, List)
		(hyperGraph, MonomialIdeal)
		(hyperGraph, Ideal)
		(hyperGraph, List)
		(hyperGraph, Graph)
	Headline 
		constructor for HyperGraph.
	Usage
		H = hyperGraph(R,E) \n H = hyperGraph(I) \n H = hyperGraph(E) \n H = hyperGraph(G)
	Inputs
		R:PolynomialRing
			whose variables correspond to vertices of the hypergraph.
		E:List
			contain a list of edges, which themselves are lists of vertices.
		I:MonomialIdeal
			which must be square-free and whose generators become the edges of the hypergraph.
		J:Ideal
			which must be square-free monomial and whose generators become the edges of the hypergraph.
		G:Graph
			which is to be converted to a HyperGraph.
	Outputs 
		H:HyperGraph
        Description
	        Text	 
		        The function {\tt hyperGraph} is a constructor for @TO HyperGraph @.  The user
			can input a hypergraph in a number of different ways, which we describe below.
			The information decribing the hypergraph is stored in a hash table.
			
			For the first possiblity, the user inputs a polynomial ring, which specifices the vertices
			of graph, and a list of the edges of the graph.  The edges are represented as lists.
		Example
		        R = QQ[a..f]
			E = {{a,b,c},{b,c,d},{c,d,e},{e,d,f}}
			h = hyperGraph (R,E)
		Text
		        Altenatively, if the polynomial ring has already been defined, it suffices to simply enter
			the list of the edges.
		Example
		        S = QQ[z_1..z_8]
			E1 = {{z_1,z_2,z_3},{z_2,z_4,z_5,z_6},{z_4,z_7,z_8},{z_5,z_7,z_8}}
			E2 = {{z_2,z_3,z_4},{z_4,z_8},{z_7,z_6,z_8},{z_1,z_2}}
			h1 = hyperGraph E1
			h2 = hyperGraph E2      
		Text
		        The list of edges could also be entered as a list of square-free monomials.
		Example
		        T = QQ[w,x,y,z]
			e = {w*x*y,w*x*z,w*y*z,x*y*z}
			h = hyperGraph e           
		Text
		        Another option for defining an hypergraph is to use an @TO ideal @ or @TO monomialIdeal @.
		Example
		        C = QQ[p_1..p_6]
			i = monomialIdeal (p_1*p_2*p_3,p_3*p_4*p_5,p_3*p_6)
			hyperGraph i
			j = ideal (p_1*p_2,p_3*p_4*p_5,p_6)
			hyperGraph j
		Text
		        Since a graph is specific type of hypergraph, we can change the type
			of a graph to hypergraph.
		Example
		        D = QQ[r_1..r_5]
			g = graph {r_1*r_2,r_2*r_4,r_3*r_5,r_5*r_4,r_1*r_5}	
		        h = hyperGraph g
		Text
		        Some special care is needed it construct the empty hypergraph, that is, the hypergraph with no
			edges.  In this case, the input cannot be a list (since the constructor does not
		        know which ring to use).  To define the empty graph, use a polynomial ring and (monomial) ideal.
		Example
		        E = QQ[m,n,o,p]
			i = monomialIdeal(0_E)  -- the zero element of E (do not use 0)
			hyperGraph i
			j = ideal (0_E)
			hyperGraph j
        SeeAlso
       	        graph
///


---------------------------------------------------------
-- DOCUMENTATION graph
---------------------------------------------------------

doc ///
	Key
		graph
		(graph, PolynomialRing, List)
		(graph, MonomialIdeal)
		(graph, Ideal)
		(graph, List)
		(graph, HyperGraph)
	Headline 
		constructor for Graph.
	Usage
		G = graph(R,E) \n G = graph(I) \n G = graph(E) \\ G = graph(H)
	Inputs
		R:PolynomialRing
			whose variables correspond to vertices of the hypergraph.
		E:List
			contain a list of edges, which themselves are lists of vertices.
		I:MonomialIdeal
			which must be square-free, quadratic, and whose generators become the edges of the graph.
		J:Ideal
			which must be square-free, quadratic,  monomial and whose generators become the edges of the graph.
		H:HyperGraph
			which is to be converted to a graph. The edges in {\tt H} must be of size two.
	Outputs 
		G:Graph
        Description
	        Text	 
		        The function {\tt graph} is a constructor for @TO Graph @, a type of @TO HyperGraph @.  The user
			can input a graph in a number of different ways, which we describe below.  The information
			describing the graph is stored in a hash table.
			
			For the first possiblity, the user inputs a polynomial ring, which specifices the vertices
			of graph, and a list of the edges of the graph.  The edges are represented as lists.
		Example
		        R = QQ[a..f]
			E = {{a,b},{b,c},{c,f},{d,a},{e,c},{b,d}}
			g = graph (R,E) 
		Text
		        Altenatively, if the polynomial ring has already been defined, it suffices to simply enter
			the list of the edges.
		Example
		        S = QQ[z_1..z_8]
			E1 = {{z_1,z_2},{z_2,z_3},{z_3,z_4},{z_4,z_5},{z_5,z_6},{z_6,z_7},{z_7,z_8},{z_8,z_1}}
			E2 = {{z_1,z_3},{z_3,z_4},{z_5,z_2},{z_2,z_4},{z_7,z_8}}
			g1 = graph E1
			g2 = graph E2      
		Text
		        The list of edges could also be entered as a list of square-free quadratic monomials.
		Example
		        T = QQ[w,x,y,z]
			e = {w*x,w*y,w*z,x*y,x*z,y*z}
			g = graph e           
		Text
		        Another option for defining an graph is to use an @TO ideal @ or @TO monomialIdeal @.
		Example
		        C = QQ[p_1..p_6]
			i = monomialIdeal (p_1*p_2,p_2*p_3,p_3*p_4,p_3*p_5,p_3*p_6)
			graph i
			j = ideal (p_1*p_2,p_1*p_3,p_1*p_4,p_1*p_5,p_1*p_6)
			graph j
		Text
		        If a hypergraph has been defined that is also a graph, one can change the type of the hypergraph 
			into a graph.
		Example
		        D = QQ[r_1..r_5]
			h = hyperGraph {r_1*r_2,r_2*r_4,r_3*r_5,r_5*r_4,r_1*r_5}	
		        g = graph h
		Text
		        Some special care is needed it construct the empty graph, that is, the graph with no
			edges.  In this case, the input cannot be a list (since the constructor does not
		        know which ring to use).  To define the empty graph, use a polynomial ring and (monomial) ideal.
		Example
		        E = QQ[m,n,o,p]
			i = monomialIdeal(0_E)  -- the zero element of E (do not use 0)
			graph i
			j = ideal (0_E)
			graph j
        SeeAlso
       	        hyperGraph
///



---------------------------------------------------------------------------------------------

--**********************************************************
-- DOCUMENTATION FOR FUNCTIONS
--**********************************************************

	      
------------------------------------------------------------
-- DOCUMENTATION equality  ==
------------------------------------------------------------

doc ///
        Key
		(symbol ==, HyperGraph, HyperGraph)
	Headline
	        equality 
	Usage
	        g == h
	Inputs
	        g:HyperGraph
	        h:HyperGraph
	Outputs
	        b:Boolean
		       true if g and h are equal
        Description
	        Text
		       This function determines if two HyperGraphs are mathematically equal.
		       Two HyperGraphs are equal if they are defined over the same ring, have 
                       the same variables and have the same set of edges. In particular, 
                       the order of the edges and the order of variables within each edges 
                       does not matter.
		Example
                       R = QQ[a..f];
		       g = hyperGraph {{a,b,c},{b,c,d},{d,e,f}};
		       h = hyperGraph {{b,c,d},{a,b,c},{f,e,d}};
		       k = hyperGraph {{a,b},{b,c,d},{d,e,f}};
		       g == h
		       g == k
///

------------------------------------------------------------
-- DOCUMENTATION adjacencyMatrix
------------------------------------------------------------

doc ///
        Key
	        adjacencyMatrix
		(adjacencyMatrix, Graph)
	Headline
	        returns the adjacency Matrix of a graph
	Usage
	        m = adjacencyMatrix g
	Inputs
	        g:Graph
	Outputs
	        m:Matrix
		       the adjacency matrix of the graph
        Description
	        Text
		       This function returns the adjacency matrix of the inputed graph.  The (i,j)^{th} position
		       of the matrix is 1 if there is an edge between the i^{th} vertex and j^{th} vertex,
		       and 0 otherwise.  The rows and columns are indexed by the variables of the ring and uses the 
		       ordering of the variables for determining the order of the rows and columns.
		Example
                       S = QQ[a..f]
		       g = graph {a*b,a*c,b*c,c*d,d*e,e*f,f*a,a*d}
		       t = adjacencyMatrix g	  
		       T = QQ[f,e,d,c,b,a]
		       g = graph {a*b,a*c,b*c,c*d,d*e,e*f,f*a,a*d}
		       t = adjacencyMatrix g -- although the same graph, matrix is different since variables have different ordering
	SeeAlso
	    incidenceMatrix
	    vertices
///		      

------------------------------------------------------------
-- DOCUMENTATION allEvenHoles
------------------------------------------------------------

doc ///
	Key
		allEvenHoles
		(allEvenHoles, Graph)
	Headline 
		returns all odd holes in a graph
	Usage
		L = allEvenHoles G
	Inputs
		G:Graph
	Outputs 
		L:List
			returns all even holes contained in {\tt G}.
	Description
	     Text
	     	  The method is based on work of Francisco-Ha-Van Tuyl, looking at the associated primes
		  of the square of the Alexander dual of the edge ideal. An even hole is an even induced
		  cycle (necessarily of length at least four). The algorithm for allEvenHoles uses an 
		  observation of Mermin. Fix an edge, and split this edge into two different edges, 
		  introducing a new vertex. Find all the odd holes in that graph. Do that for each edge 
		  in the graph, one at a time, and pick out all the odd holes containing the additional 
		  vertex. Dropping this vertex from each of the odd holes gives all the even holes in 
		  the original graph.
	     Example
	     	  R=QQ[a..f]
		  G=cycle(R,6);
		  allEvenHoles G 
		  H=graph(monomialIdeal(a*b,b*c,c*d,d*e,e*f,a*f,a*d)) --6-cycle with a chord
		  allEvenHoles H --two 4-cycles
	SeeAlso
	     allOddHoles
	     hasOddHole
///

------------------------------------------------------------
-- DOCUMENTATION allOddHoles
------------------------------------------------------------

doc ///
	Key
		allOddHoles
		(allOddHoles, Graph)
	Headline 
		returns all odd holes in a graph
	Usage
		L = allOddHoles G
	Inputs
		G:Graph
	Outputs 
		L:List
			returns all odd holes contained in {\tt G}.
	Description
	     Text
	     	  The method is based on work of Francisco-Ha-Van Tuyl, looking at the associated primes
		  of the square of the Alexander dual of the edge ideal. An odd hole is an odd induced
		  cycle of length at least 5.
	     Example
	     	  R=QQ[x_1..x_6]
		  G=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6}) --5-cycle and a triangle
		  allOddHoles G --only the 5-cycle should appear
		  H=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6,x_1*x_4}) --no odd holes
		  allOddHoles H
	SeeAlso
	     allEvenHoles
	     hasOddHole
///
	      
	      
------------------------------------------------------------
-- DOCUMENTATION antiCycle
------------------------------------------------------------

doc ///
	Key
		antiCycle
		(antiCycle, Ring)
		(antiCycle, Ring, ZZ)
		(antiCycle, List)
	Headline
		returns a graph of an anticycle.
	Usage
		C = antiCycle R or C = antiCycle(R,N) or C = antiCycle L
	Inputs
		R:Ring
		N:ZZ
			length of anticycle
		L:List
			of vertices to make into the complement of a cycle in the order provided
	Outputs
		C:Graph
			which is a anticycle on the vertices in {\tt L} or on the variables of {\tt R}.
	Description
	        Text
		        This function is the reverse of the function @TO cycle @ by returning
			the graph which is the complement of a cycle.
		Example
			R = QQ[a,b,c,d,e]	   
			antiCycle R
			antiCycle(R,4)
			antiCycle {e,c,d,b}
			complementGraph antiCycle R == cycle R
        SeeAlso	    
	        cycle
///	


	      
------------------------------------------------------------
-- DOCUMENTATION chromaticNumber
------------------------------------------------------------

doc ///
        Key
	        chromaticNumber
		(chromaticNumber, HyperGraph)
	Headline
	        computes the chromatic number of a hypergraph
	Usage
	        c = chromaticNumber H
	Inputs
	        H:HyperGraph
	Outputs
	        i:ZZ
		       the chromatic number of {\tt H}
        Description
	        Text
		     Returns the chromatic number, the smallest number of colors needed to color a graph.  This method
		     is based upon a result of Francisco-Ha-Van Tuyl which relates the chromatic number to an ideal membership problem.
		Example
		     S = QQ[a..f]
		     c4 = cycle(S,4) -- 4-cycle; chromatic number = 2
		     c5 = cycle(S,5) -- 5-cycle; chromatic number = 3
		     k6 = completeGraph S  -- complete graph on 6 vertices; chormatic number = 6
		     chromaticNumber c4
		     chromaticNumber c5
		     chromaticNumber k6
///		      



------------------------------------------------------------
-- DOCUMENTATION cliqueComplex
------------------------------------------------------------

doc ///
        Key
	        cliqueComplex
		(cliqueComplex, Graph)
	Headline
	        returns the clique complex of a graph
	Usage
	        D = cliqueComplex G
	Inputs
	        G:Graph
	Outputs
	        D:SimplicialComplex
		       the clique complex of a {\tt G}
        Description
	        Text
		     This function returns the clique complex of a graph $G$.  This is the simplicial
		     complex whose faces correspond to the cliques in the graph.  That is,
		     $F = \{x_{i_1},...,x_{i_s}\}$ is a face of the clique complex of $G$ if and only
		     if the induced graph on $\{x_{i_1},...,x_{i_s}\}$ is a clique of $G$.
		Example
		     R=QQ[w,x,y,z]
		     e = graph {w*x,w*y,x*y,y*z}  -- clique on {w,x,y} and {y,z}
		     cliqueComplex e  -- max facets {w,x,y} and {y,z}
		     g = completeGraph R
		     cliqueComplex g
	SeeAlso
	     cliqueNumber
	     getCliques
	     getMaxCliques
///		      



------------------------------------------------------------
-- DOCUMENTATION cliqueNumber
------------------------------------------------------------

doc ///
        Key
	        cliqueNumber
		(cliqueNumber, Graph)
	Headline
	        computes the clique number of a graph
	Usage
	        c = cliqueNumber G
	Inputs
	        G:Graph
	Outputs
	        i:ZZ
		       the clique number of {\tt G}
        Description
	        Text
		     cliqueNumber returns the clique number of a graph, the size of the largest clique
		     contained in the graph.  This number is also related to the dimension of 
		     the clique complex of the graph.
		Example
		     R=QQ[a..d]
		     cliqueNumber completeGraph R
		     G = graph({a*b,b*c,a*c,a*d})
		     cliqueNumber G
		     dim cliqueComplex G + 1 == cliqueNumber G
	SeeAlso
	     cliqueComplex
	     getCliques
	     getMaxCliques
	     
///		      


	      
------------------------------------------------------------
-- DOCUMENTATION complementGraph
------------------------------------------------------------

doc ///
        Key
	        complementGraph
		(complementGraph, Graph)
		(complementGraph, HyperGraph)
	Headline
	        returns the complement of a graph or hypergraph 
	Usage
	        g = complementGraph G \n h = complementGraph H
	Inputs
	        G:Graph
		H:HyperGraph
	Outputs
	        g:Graph
		       the complement of G, whose edges are the set of edges not in G
		h:HyperGraph
		       the complement of H, whose edge set is found by taking the complement of each
		       edge of H in the vertex set
        Description
	        Text
		       The function complementGraph finds the complement of a graph and hypergraph.  Note
		       that function behaves differently depending upon the type.  When applied to a graph,
		       complementGraph returns the graph whose edge set is the set of edges not in G.
		       When applied to a hypergraph, the edge set is found by taking the complement of 
		       each edge of H in the vertex set.
		Example
		       R = QQ[a,b,c,d,e];
		       c5 = graph {a*b,b*c,c*d,d*e,e*a}; -- graph of the 5-cycle
		       complementGraph c5 -- the graph complement of the 5-cycle
		       c5hypergraph = hyperGraph c5 -- the 5-cycle, but viewed as a hypergraph
		       complementGraph c5hypergraph
	Caveat
	        Notice that {\tt complementGraph} works differently on graphs versus hypergraphs.
///	

------------------------------------------------------------
-- DOCUMENTATION completeGraph
------------------------------------------------------------

doc ///
	Key
		completeGraph
		(completeGraph, Ring)
		(completeGraph, Ring, ZZ)
		(completeGraph, List)
	Headline
		returns a complete graph.
	Usage
		K = completeGraph R \n K = completeGraph(R,N) \n K = completeGraph L
	Inputs
		R:Ring
		N:ZZ
			number of variables to use
		L:List
			of vertices to make into a complete graph
	Outputs
		K:Graph
			which is a complete graph on the vertices in {\tt L} or on the variables of {\tt R}
	Description
		Text
		        This function returns a special graph, the complete graph.  The input specifies a set of vertices that 
			will have the property that every vertex is adjacent to every other vertex.  Non-specified vertices are
			treated as isolated vertices.
		Example
			R = QQ[a,b,c,d,e];
			completeGraph R
			completeGraph(R,3)
			completeGraph {a,c,e}
///	

------------------------------------------------------------
-- DOCUMENTATION completeMulitPartite
------------------------------------------------------------

doc ///
	Key
		completeMultiPartite
		(completeMultiPartite, Ring, ZZ,ZZ)
		(completeMultiPartite, Ring, List)
	Headline
		returns a complete multipartite graph.
	Usage
		K = completeMultiPartite(R,N,M) \n K = completeMultiPartite(R,L)
	Inputs
		R:Ring
		N:ZZ
			number of partitions
		M:ZZ
			size of each partition
		L:List
			of integers giving the size of each partition, or a list of paritions which are lists of variables
	Outputs
		K:Graph
			which is the complete multipartite graph on the given partitions
	Description
		Text
			A complete multipartite graph is a graph with a partition of the vertices
			such that every pair of vertices, not both from the same partition, 
			is an edge of the graph. The partitions can be specified by their number 
			and size, by a list of sizes, or by an explicit partition of the variables. 
			Not all varibles of the ring need to be used.
		Example
			R = QQ[a,b,c,x,y,z];
			completeMultiPartite(R,2,3)
			completeMultiPartite(R,{2,4})
			completeMultiPartite(R,{{a,b,c,x},{y,z}})
		Text
		        When N is the number of variables and M = 1, we recover the complete graph.
		Example
		        R = QQ[a,b,c,d,e]
			t1 = completeMultiPartite(R,5,1)
			t2 = completeGraph R
			t1 == t2
        SeeAlso
     	        completeGraph 
///	

------------------------------------------------------------
-- DOCUMENTATION connectedComponents
------------------------------------------------------------

doc ///
	Key
		connectedComponents
		(connectedComponents, HyperGraph)
	Headline
		the connected components of a hypergraph
	Usage
		L = connectedComponents H
	Inputs
		H:HyperGraph
	Outputs
		L:List
			of lists of vertices. Each list of vertices is a connected component of H.
	Description
		Text
			The connected components of a hypergraph are sets of vertices in which
			each vertex is connected to each other by a path. Each connected component
			is disjoint and vertices that are not contained in any edge do not appear in
			any connected component.
		Example
			R = QQ[a..l]
			H = hyperGraph {a*b*c, c*d,d*e*f, h*i, i*j, l}
			L = connectedComponents H
			apply(L, C -> inducedGraph(H,C))
        SeeAlso
	     isConnected
	     numConnectedComponents
///	

 
	      
------------------------------------------------------------
-- DOCUMENTATION coverIdeal
------------------------------------------------------------

doc ///
        Key
	        coverIdeal
		(coverIdeal, HyperGraph)
	Headline
	        creates the cover ideal of a (hyper)graph
	Usage
	        i = coverIdeal H
	Inputs
	        H:HyperGraph
	Outputs
	        i:MonomialIdeal
		       the cover ideal of H
        Description
	        Text
		 Returns the monomial ideal generated by the minimal vertex covers.  This is also the Alexander Dual 
		 of the edge ideal of the hypergraph {\tt H}.
		Example
		 S= QQ[a,b,c,d,e,f]
		 k6 = completeGraph S  -- complete graph on 6 vertices
		 coverIdeal k6 -- each generator corresponds to a minimal vertex of k6
                 h = hyperGraph {a*b*c,c*d,d*e*f}
		 coverIdeal h
		 dual coverIdeal h == edgeIdeal h
	SeeAlso
	        edgeIdeal
		vertexCoverNumber
		vertexCovers
///		      

------------------------------------------------------------
-- DOCUMENTATION cycle
------------------------------------------------------------

doc ///
	Key
		cycle
		(cycle, Ring)
		(cycle, Ring, ZZ)
		(cycle, List)
	Headline
		returns a graph cycle.
	Usage
		C = cycle R \n C = cycle(R,N) \n C = cycle L
	Inputs
		R:Ring
		N:ZZ
			length of cycle
		L:List
			of vertices to make into a cycle in the order provided
	Outputs
		C:Graph
			which is a cycle on the vertices in {\tt L} or on the variables of {\tt R}.
	Description
		Text
		        Give a list of vertices (perhaps in some specified order), this function returns the graph of the
			cycle on those vertices, using the order given or the internal ordering of the
			@TO vertices @.  Unspecified vertices are treated as isolated vertices.
		Example
			R = QQ[a,b,c,d,e]	   
			cycle R
			cycle(R,3)
			cycle {e,c,d,b}
			R = QQ[a,c,d,b,e] -- variables given different order
			cycle R
	SeeAlso
	        antiCycle
///	


------------------------------------------------------------
-- DOCUMENTATION degreeVertex
------------------------------------------------------------
doc ///
	Key
		degreeVertex
		(degreeVertex, HyperGraph, ZZ)
		(degreeVertex, HyperGraph, RingElement)
	Headline 
		gives degree of a vertex.
	Usage
		D = degreeVertex(H,N) \n D = degreeVertex(H,V)
	Inputs
		H:HyperGraph
		N:ZZ
			the index of a vertex
		V:RingElement
			a vertex/variable of the HyperGraph
	Outputs 
		D:ZZ
			which is the degree of vertex {\tt V} (or vertex number {\tt N})
	Description
		Text
			The degree of a vertex in a hypergraph is the number of edges that contain the vertex.
			The degree is also the number of elements in the neighbor set of a vertex.
	        Example
		        S = QQ[a,b,c,d,e]
			k5 = completeGraph S
			dv = degreeVertex(k5,a)
			n = neighbors(k5,a)
			#n == dv
			degreeVertex(k5,2)
			h = hyperGraph {a*b*c,c*d,a*d*e,b*e,c*e}
			degreeVertex(h,a)
			degreeVertex(h,2) -- degree of c
	SeeAlso
		neighbors
		vertices
///



------------------------------------------------------------
-- DOCUMENTATION deleteEdges
------------------------------------------------------------
 
doc ///
        Key
	        deleteEdges 
		(deleteEdges, HyperGraph, List)
	Headline
	        returns the (hyper)graph with specified edges removed
	Usage
	        h = deleteEdges (H,S) 
	Inputs
		H:HyperGraph
		S:List
		     which is a subset of the edges of the graph or hypergraph
	Outputs
		h:HyperGraph
		       the hypergraph with edges in S removed
	Description
	        Text
		       This function enables the user to remove specified edges from a graph to form
		       a subgraph.
		Example
		       S=QQ[a,b,c,d,e]
		       g=cycle S
		       T = {{a,b},{d,e}}
		       gprime = deleteEdges (g,T)
		       h = hyperGraph {a*b*c,c*d*e,a*e}
		       T = edges h
                       hprime = deleteEdges (h,T)
///	



------------------------------------------------------------
-- DOCUMENTATION edgeIdeal
------------------------------------------------------------


doc ///
        Key
	     edgeIdeal
	     (edgeIdeal, HyperGraph)
	Headline
	     creates the edge ideal of a (hyper)graph
	Usage
	     i = edgeIdeal H
	Inputs
	     H:HyperGraph
	Outputs
	     i:MonomialIdeal
	          the edge ideal of H
	Description
	     Text
	     	  The edge ideal of a (hyper)graph is a square-free monomial ideal where the 
		  generators correspond to the edges of a (hyper)graph.  Along with @TO coverIdeal @,
		  the function edgeIdeal enables us to translate many graph theoretic properties into 
		  algebraic properties.
		  
		  When the input is a finite simple graph, that is, a graph with no loops or multiple
		  edges, then the edge ideal is a quadratic square-free monomial ideal generated by
		  terms of the form $x_ix_j$ whenever $\{x_i,x_j\}$ is an edge of the graph.
	     Example
	     	  S = QQ[a..e]
		  c5 = cycle S
		  edgeIdeal c5
		  graph flatten entries gens edgeIdeal c5 == c5 
		  k5 = completeGraph S
		  edgeIdeal k5             
     	     Text
	          When the input is a hypergraph, the edge ideal is a square-free monomial ideal
		  generated by monomials of the form $x_{i_1}x_{i_2}...x_{i_s}$ whenever
		  $\{x_{i_1},...,x_{i_s}\}$ is an edge of the hypergraph.  Because all of our
		  hypergraphs are clutters, that is, no edge is allowed to be a subset of another edge,
		  we have a bijection between the generators of the egde ideal of hypergraph and the edges
		  of the hypergraph.
	     Example
	     	  S = QQ[z_1..z_8]
		  h = hyperGraph {{z_1,z_2,z_3},{z_2,z_3,z_4,z_5},{z_4,z_5,z_6},{z_6,z_7,z_8}}
		  edgeIdeal h
        SeeAlso
	     coverIdeal
///		      



------------------------------------------------------------
-- DOCUMENTATION edges
------------------------------------------------------------


doc ///
	Key
		edges
		(edges, HyperGraph)
	Headline 
		gets the edges of a (hyper)graph.
	Usage
		E = edges(H)
	Inputs
		H:HyperGraph
	Outputs 
		E:List
			of the edges of {\tt H}.
	Description
	        Text
		      This function takes a (hyper)graph, and returns the edges set of the (hyper)graph.
	        Example
		       S = QQ[a..d]
		       g = graph {a*b,b*c,c*d,d*a} -- the four cycle
     	       	       edges (g)
		       h = hyperGraph{a*b*c}
     	       	       edges h	 
		       k4 = completeGraph S
		       edges k4
	SeeAlso
	        vertices
///


------------------------------------------------------------
-- DOCUMENTATION getCliques
------------------------------------------------------------

doc ///
	Key
		getCliques
		(getCliques, Graph, ZZ)
		(getCliques, Graph)
	Headline 
		returns cliques in a graph
	Usage
		c = getCliques(G,d) or c = getCliques G
	Inputs
		G:Graph
		d:ZZ
			representing the size of the cliques desired
	Outputs 
		c:List
			of cliques of size {\tt d} or, if no {\tt d} is entered, all cliques.
	SeeAlso
	        cliqueNumber
	Description
		Text
		     	A clique on a subset of the vertices is a subgraph where every vertex in the subgraph
			is adjacent to every other vertex in the graph.  This function returns all cliques
			of a specified size, and if no size is given, it returns all cliques.  Note that 
			all the edges of the graph are considered cliques of size two.
		Example
		     	R = QQ[a..d]
			G = completeGraph R 
     	       	    	getCliques(G,3)
			getCliques(G,4)
			getCliques G
	       
///


------------------------------------------------------------
-- DOCUMENTATION getEdge
------------------------------------------------------------

doc ///
	Key
		getEdge
		(getEdge, HyperGraph, ZZ)
	Headline 
		gets the n-th edge in a (hyper)graph
	Usage
		E = getEdge(H,N)
	Inputs
		H:HyperGraph
		N:ZZ
			an index of an edge in {\tt H}
	Outputs 
		E:List
			which is the {\tt N}-th edge of {\tt H}
	Description
	        Text
		        This function returns the n^{th} edge of the (hyper)graph.
		Example
		        S = QQ[a..f]
			g = cycle S
			edges g
			getEdge (g,3)  -- counting starts from 0, so the 4th element in the above list
			h = hyperGraph {a*b*c*d,d*e,a*f*c,a*d*f}
     	       	    	getEdge (h,0) -- first edge
	SeeAlso
	        edges
		getEdgeIndex
///

------------------------------------------------------------
-- DOCUMENTATION getEdgeIndex
------------------------------------------------------------

doc ///
	Key
		getEdgeIndex
		(getEdgeIndex, HyperGraph, List)
		(getEdgeIndex, HyperGraph, RingElement)
	Headline 
		finds the index of an edge in a HyperGraph
	Usage
		N = getEdgeIndex(H,E) or N = getEdgeIndex(H,M)
	Inputs
		H:HyperGraph
		E:List
			of vertices
		M:RingElement
			a monomial of vertices
	Outputs 
		N:ZZ
			which is the index of {\tt E} as an edge of {\tt H}. If {\tt E} is not in {\tt H}
			then -1 is returned
	Description
	        Text
		        This function returns the index of the edge of they (hyper)graph, where the ordering
			is determined by the internal ordering of the edges.
		Example
		     	S = QQ[z_1..z_8]
			h = hyperGraph {z_2*z_3*z_4,z_6*z_8,z_7*z_5,z_1*z_6*z_7,z_2*z_4*z_8}
			edges h
			getEdgeIndex (h,{z_2,z_4,z_8})  -- although entered last, edge is internally stored in 4th spot (counting begins at 0)
			getEdge(h,3)
			getEdgeIndex (h,{z_1,z_2}) -- not in the edge list
	SeeAlso
		getEdge
		isEdge
///

------------------------------------------------------------
-- DOCUMENTATION getGoodLeaf
------------------------------------------------------------

doc ///
	Key
		getGoodLeaf
		(getGoodLeaf, HyperGraph)
	Headline 
		returns an edge that is a good leaf
	Usage
		L = getGoodLeaf(H) 
	Inputs
		H:HyperGraph
	Outputs 
		L:List
			of vertices that are an edge in H that form a good leaf.
	Description
		Text
			A good leaf of a hypergraph H is an edge L whose intersections
			with all other edges form a totally ordered set. It follows that
			L must have a free vertex. In the graph setting, a good leaf is 
			an edge containing a vertex of degree one.  The notion of a good
			leaf was introduced by X. Zheng in her PhD thesis (2004).
		Example
		     	R = QQ[a..g];
			H = hyperGraph {a*b*c*d, b*c*d*e, c*d*f, d*g, e*f*g};
			getGoodLeaf(H)
	SeeAlso
		getGoodLeafIndex
		hasGoodLeaf
		isGoodLeaf
///

------------------------------------------------------------
-- DOCUMENTATION getGoodLeafIndex
------------------------------------------------------------

doc ///
	Key
		getGoodLeafIndex
		(getGoodLeafIndex, HyperGraph)
	Headline 
		returns the index of an edge that is a good leaf
	Usage
		N = getGoodLeafIndex(H) 
	Inputs
		H:HyperGraph
	Outputs 
		N:ZZ
			the index of an edge in H of a good leaf. 
			Returns -1 if H does not have a good leaf.
	Description
		Text
			A good leaf of hypergraph H is an edge L whose intersections
			with all other edges form a totally ordered set. It follows that
			L must have a free vertex. In the graph setting, a good leaf is 
			an edge containing a vertex of degree one.
			The notion of a good
			leaf was introduced by X. Zheng in her PhD thesis (2004).
		Example
		     	R = QQ[a..g];
			H = hyperGraph {b*c*d*e, a*b*c*d, c*d*f, d*g, e*f*g};
			getGoodLeaf(H)
			edges(H)
			getGoodLeafIndex(H)
	SeeAlso
		getGoodLeaf
		hasGoodLeaf
		isGoodLeaf
///

------------------------------------------------------------
-- DOCUMENTATION getMaxCliques
------------------------------------------------------------

doc ///
	Key
		getMaxCliques
		(getMaxCliques, Graph)
	Headline 
		returns maximal cliques in a graph
	Usage
		c = getMaxCliques G
	Inputs
		G:Graph
	Outputs 
		c:List
			of cliques of maximal size contained in {\tt G}
	Description
	     	Text
		     The function returns all cliques of maximal size in a graph as a list of lists.
		Example
		     	R = QQ[a..d]
			G = completeGraph R 
     	       	    	getMaxCliques G
			H=graph({a*b,b*c,a*c,c*d,b*d})
			getMaxCliques H
	SeeAlso
	        cliqueNumber
		getCliques
///

------------------------------------------------------------
-- DOCUMENTATION hasGoodLeaf
------------------------------------------------------------

doc ///
	Key
		hasGoodLeaf
		(hasGoodLeaf, HyperGraph)
	Headline 
		determines if a HyperGraph contains a good leaf
	Usage
		B = hasGoodLeaf(H) 
	Inputs
		H:HyperGraph
	Outputs 
		B:Boolean
			true if H contains an edge that is a good leaf.
	Description
		Text
			A good leaf of hypergraph H is an edge L whose intersections
			with all other edges form a totally ordered set. It follows that
			L must have a free vertex. In the graph setting, a good leaf is 
			an edge containing a vertex of degree one.  The notion of a good
			leaf was introduced by X. Zheng in her PhD thesis (2004).
		Example
		     	R = QQ[a..g];
			H = hyperGraph {b*c*d*e, a*b*c*d, c*d*f, d*g, e*f*g};
			hasGoodLeaf(H)
			getGoodLeaf(H)
	SeeAlso
		getGoodLeaf
		getGoodLeafIndex
		isGoodLeaf
///

------------------------------------------------------------
-- DOCUMENTATION hasOddHole
------------------------------------------------------------

doc ///
	Key
		hasOddHole
		(hasOddHole, Graph)
	Headline 
		tells whether a graph contains an odd hole.
	Usage
		B = hasOddHole G
	Inputs
		G:Graph
	Outputs 
		B:Boolean
			returns {\tt true} if {\tt G} has an odd hole and {\tt false} otherwise
	Description
	     Text
	     	  The method is based on work of Francisco-Ha-Van Tuyl, looking at the associated primes
		  of the square of the Alexander dual of the edge ideal. An odd hole is an odd induced
		  cycle of length at least 5.
	     Example
	     	  R=QQ[x_1..x_6]
		  G=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6}) --5-cycle and a triangle
		  hasOddHole G
		  H=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6,x_1*x_4}) --no odd holes
		  hasOddHole H
	SeeAlso
	     allOddHoles
///



------------------------------------------------------------
-- DOCUMENTATION hyperGraphToSimplicialComplex
------------------------------------------------------------

doc ///
	Key
		hyperGraphToSimplicialComplex
		(hyperGraphToSimplicialComplex, HyperGraph)
	Headline 
		turns a (hyper)graph into a simplicial complex
	Usage
		D = hyperGraphToSimplicialComplex H
	Inputs
		H:HyperGraph
	Outputs 
		D:SimplicialComplex
			whose facets are given by the edges of H
	Description
	     Text
	     	  This function changes the type of a (hyper)graph to a simplicial complex where
		  the facets of the simplicial complex are given by the edge set of the (hyper)graph.
		  This function is the reverse of @TO simplicialComplexToHyperGraph @.  This function enables the users
		  to make use of the functions in the package @TO SimplicialComplexes @
	     Example
	     	  R=QQ[x_1..x_6]
		  G=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6}) --5-cycle and a triangle
		  DeltaG = hyperGraphToSimplicialComplex G
		  hyperGraphDeltaG = simplicialComplexToHyperGraph DeltaG
	          GPrime = graph(hyperGraphDeltaG)
		  G === GPrime
	SeeAlso
	     simplicialComplexToHyperGraph     
///


------------------------------------------------------------
-- DOCUMENTATION incidenceMatrix
------------------------------------------------------------

doc ///
        Key
	        incidenceMatrix
		(incidenceMatrix, HyperGraph)
	Headline
	        returns the incidence matrix of a hypergraph
	Usage
	        M = incidenceMatrix H
	Inputs
	        H:HyperGraph
	Outputs
	        M:Matrix
		       the incidence matrix of the hypergraph
        Description
	        Text
			This function returns the incidence matrix of the inputed hypergraph. 
			The rows of the matrix are indexed by the variables of the hypergraph 
			and the columns are indexed by the edges. The (i,j)^{th} entry in the 
			matrix is 1 if vertex i is contained in edge j, and is 0 otherwise.
			The order of the rows and columns are determined by the internal order of
			the vertices and edges. See @TO edges@ and @TO vertices@.
		Example
                       S = QQ[a..f];
		       g = hyperGraph {a*b*c*d,c*e,e*f}
		       incidenceMatrix g	  
		       T = QQ[f,e,d,c,b,a];
		       h = hyperGraph {a*b*c*d,c*e,e*f}
		       incidenceMatrix h -- although the same graph, matrix is different since variables have different ordering
	SeeAlso
		adjacencyMatrix
		edges	
		vertices	
///		      

------------------------------------------------------------
-- DOCUMENTATION independenceComplex
------------------------------------------------------------


doc ///
        Key
	        independenceComplex
		(independenceComplex, HyperGraph)
	Headline
	        returns the independence complex of a (hyper)graph 
	Usage
	        D = independenceComplex H
	Inputs
	        H:HyperGraph
	Outputs
	        D:SimplicialComplex
		       the independence complex associated to the (hyper)graph
        Description
	        Text
		       This function associates to a (hyper)graph a simplicial complex whose faces correspond
		       to the independent sets of the (hyper)graph.  See, for example, the paper 
		       of A. Van Tuyl and R. Villarreal 
		       "Shellable graphs and sequentially Cohen-Macaulay bipartite graphs"
		       Journal of Combinatorial Theory, Series A 115 (2008) 799-814.
	        Example
		       S = QQ[a..e]
		       g = graph {a*b,b*c,c*d,d*e,e*a} -- the 5-cycle
		       independenceComplex g 
		       h = hyperGraph {a*b*c,b*c*d,d*e}
		       independenceComplex h
                Text
		       Equivalently, the independence complex is the simplicial complex associated
		       to the edge ideal of the (hyper)graph H via the Stanley-Reisner correspondence.
		Example
		       S = QQ[a..e]
		       g = graph {a*b,b*c,a*c,d*e,a*e}
		       Delta1 = independenceComplex g 
		       Delta2 = simplicialComplex edgeIdeal g
                       Delta1 == Delta2
	SeeAlso
	         independenceNumber       	  
///	
	      



------------------------------------------------------------
-- DOCUMENTATION independenceNumber
------------------------------------------------------------


doc ///
        Key
	        independenceNumber
		(independenceNumber, Graph)
	Headline
	        determines the independence number of a graph 
	Usage
	        d = independenceNumber G
	Inputs
	        G:Graph
	Outputs
	        d:ZZ
		       the independence number (the number of independent vertices) in {\tt G}
        Description
	        Text
		       This function returns the maximum number of independent vertices in a graph.  This number
		       can be found by computing the dimension of the simplicial complex whose faces are the independent
		       sets (see @TO independenceComplex @) and adding 1 to this number.
                Example
		       R = QQ[a..e]
		       c4 = graph {a*b,b*c,c*d,d*a} -- 4-cycle plus an isolated vertex!!!!
		       c5 = graph {a*b,b*c,c*d,d*e,e*a} -- 5-cycle
		       independenceNumber c4 
		       independenceNumber c5 
		       dim independenceComplex c4 + 1 == independenceNumber c4
		       
        SeeAlso
	        independenceComplex
///	
	      

------------------------------------------------------------
-- DOCUMENTATION inducedGraph
------------------------------------------------------------


doc ///
	Key
		inducedGraph
		(inducedGraph, HyperGraph, List)
	Headline
		returns the induced subgraph of a (hyper)graph.
	Usage
		h = inducedGraph H 
	Inputs
		H:HyperGraph
		L:List
			of vertices (i.e. variables in the ring of {\tt H} or {\tt G})
	Outputs
		h:HyperGraph
			the induced subgraph of {\tt H} whose edges are contained in {\tt L}
	Description
		Text
			This function returns the induced subgraph of a (hyper)graph on a specified set of vertices.  The function 
			enables the user to create subgraphs of the original (hyper)graph. 
			
			The ring of the induced subgraph contains only variables in {\tt L}.
			The current ring must be changed before working with the induced subgraph.
		Example
			R = QQ[a,b,c,d,e]	   
			G = graph {a*b,b*c,c*d,d*e,e*a} -- graph of the 5-cycle
			H1 = inducedGraph(G,{b,c,d,e})
			H2 = inducedGraph(G,{a,b,d,e})
			use H1#"ring"
			inducedGraph(H1,{c,d,e})
        SeeAlso
	        deleteEdges
///   



------------------------------------------------------------
-- DOCUMENTATION isBipartite
------------------------------------------------------------

doc ///
        Key
	        isBipartite
		(isBipartite, Graph)
	Headline
	        determines if a graph is bipartite
	Usage
	        B = isBipartite G
	Inputs
	        G:Graph
	Outputs
	        B:Boolean
		       returns {\tt true} if {\tt G} is bipartite, {\tt false} otherwise
        Description
	        Text
		       The function {\tt isBipartite} determines if a given graph is bipartite.  A graph is 
		       said to be bipartite if the vertices can be partitioned into two sets W and Y such
		       that every edge has one vertex in W and the other in Y.  Since a graph is bipartite
		       if and only if its chromatic number is 2, we can check if a graph is bipartite by 
		       computing its chromatic number.
                Example
		       S = QQ[a..e]
		       t = graph {a*b,b*c,c*d,a*e} -- a tree (and thus, bipartite)
		       c5 = cycle S -- 5-cycle (not bipartite)
		       isBipartite t
		       isBipartite c5
	SeeAlso
	        chromaticNumber
///		      



------------------------------------------------------------
-- DOCUMENTATION isChordal
------------------------------------------------------------

doc ///
        Key
	        isChordal
		(isChordal, Graph)
	Headline
	        determines if a graph is chordal
	Usage
	        B = isChordal G
	Inputs
	        G:Graph
	Outputs
	        B:Boolean
		       true if the graph is chordal
	Description
	        Text
		       A graph is chordal if the graph has no induced cycles of length 4 or more (triangles are allowed).
		       To check if a graph is chordal, we make use of a characterization of Fr\"oberg
		       (see "On Stanley-Reisner rings,"  Topics in algebra, Part 2 (Warsaw, 1988),  57-70, 
		       Banach Center Publ., 26, Part 2, PWN, Warsaw, 1990.) which says that a graph G is
		       chordal if and only if the edge ideal of G^c has a linear resolution.
		Example
		    S = QQ[a..e];
		    C = cycle S;
		    isChordal C
		    D = graph {a*b,b*c,c*d,a*c};
		    isChordal D
                    E = completeGraph S; 
		    isChordal E
 ///		      


------------------------------------------------------------
-- DOCUMENTATION isCM
------------------------------------------------------------

doc ///
        Key
	        isCM
		(isCM, HyperGraph)
	Headline
	        determines if a (hyper)graph is Cohen-Macaulay
	Usage
	        B = isCM H
	Inputs
	        H:HyperGraph
	Outputs
	        B:Boolean
		       true if the @TO edgeIdeal@ of {\tt H} is Cohen-Macaulay
	Description
	     	Text
		     This uses the edge ideal notion of Cohen-Macaulayness; a hypergraph is called C-M if
		     and only if its edge ideal is C-M.
		Example
		    R = QQ[a..e];
		    C = cycle R;
		    UnmixedTree = graph {a*b, b*c, c*d};
		    MixedTree = graph {a*b, a*c, a*d};
		    isCM C
		    isCM UnmixedTree
		    isCM MixedTree
	SeeAlso
		isSCM
		edgeIdeal
///		      

------------------------------------------------------------
-- DOCUMENTATION isConnected
------------------------------------------------------------

doc ///
        Key
	        isConnected
		(isConnected, HyperGraph)
	Headline
	        determines if a (hyper)graph is connected
	Usage
	        b = isConnected H
	Inputs
	        H:Graph
	Outputs
	        B:Boolean
		       returns {\tt true} if {\tt H} is connected, {\tt false} otherwise
        Description
	        Text
		       This function checks if the (hyper)graph is connected.  It relies on the @TO numConnectedComponents @.
		Example
		       S = QQ[a..e]
		       g = graph {a*b,b*c,c*d,d*e,a*e} -- the 5-cycle (connected)
		       h = graph {a*b,b*c,c*a,d*e} -- a 3-cycle and a disjoint edge (not connected)
		       isConnected g
		       isConnected h
	SeeAlso
	        connectedComponents
		numConnectedComponents
///		      






------------------------------------------------------------
-- DOCUMENTATION isEdge
------------------------------------------------------------

doc ///
	Key
		isEdge
		(isEdge, HyperGraph, List)
		(isEdge, HyperGraph, RingElement)
	Headline 
		determines if an edge is in a (hyper)graph
	Usage
		B = isEdge(H,E) \n B = isEdge(H,M)
	Inputs
		H:HyperGraph
		E:List
			of vertices.
		M:RingElement
			a monomial representing an edge.
	Outputs 
		B:Boolean
			which is true iff {\tt E} (or {\tt support M}) is an edge of {\tt H}
	Description
	        Text
		        This function checks if a given edge, represented either as a list or monomial, belongs
			to a given (hyper)graph.
	        Example
		        S = QQ[z_1..z_8]
			h = hyperGraph {z_2*z_3*z_4,z_6*z_8,z_7*z_5,z_1*z_6*z_7,z_2*z_4*z_8}
			edges h
			isEdge (h,{z_2,z_4,z_8})  
			isEdge (h,z_2*z_3*z_4)
			isEdge (h,{z_1,z_2}) 
	SeeAlso
		getEdgeIndex
///

------------------------------------------------------------
-- DOCUMENTATION isForest
------------------------------------------------------------

doc ///
	Key
		isForest
		(isForest, Graph)
		(isForest, HyperGraph)
	Headline 
		determines whether a (hyper)graph is a forest
	Usage
		B = isForest G or B = isForest H
	Inputs
		G:Graph
		H:HyperGraph
	Outputs 
		B:Boolean
			true if G (or H) is a forest
        Description
	     Text
	        This function determins if a graph or hypergraph is a forest.  A graph is a forest if 
		if the graph has no induced cycles.  We say that a hypergraph is forest if each
		connected component is a forest in the sense of S. Faridi.  See the paper
		"The facet ideal of a simplicial complex," Manuscripta Mathematica 109, 159-174 (2002).
	     Example
	        S = QQ[a..e]
		t = graph {a*b,a*c,a*e}
		isForest t
		T = QQ[a..f]
		h = hyperGraph {a*b*c,c*d*e,b*d*f}
		isForest h
///

------------------------------------------------------------
-- DOCUMENTATION isGoodLeaf
------------------------------------------------------------

doc ///
	Key
		isGoodLeaf
		(isGoodLeaf, HyperGraph, ZZ)
	Headline 
		returns an edge that is a good leaf
	Usage
		B = getGoodLeaf(H,N) 
	Inputs
		H:HyperGraph
		N:ZZ
			index of an edge
	Outputs 
		B:Boolean
			true if edge N of H is a good leaf.
	Description
		Text
			A good leaf of hypergraph H is an edge L whose intersections
			with all other edges form a totally ordered set. It follows that
			L must have a free vertex. In the graph setting, a good leaf is 
			an edge containing a vertex of degree one.  The notion of a good
			leaf was introduced by X. Zheng in her PhD thesis (2004).
		Example
		     	R = QQ[a..g];
			H = hyperGraph {a*b*c*d, b*c*d*e, c*d*f, d*g, e*f*g};
			edges(H)
			isGoodLeaf(H,0)
			isGoodLeaf(H,1)
	SeeAlso
		getGoodLeaf
		getGoodLeafIndex
		hasGoodLeaf
///

------------------------------------------------------------
-- DOCUMENTATION isGraph
------------------------------------------------------------

doc ///
        Key
	        isGraph
		(isGraph, HyperGraph)
	Headline
	        determines if a hypergraph is a graph 
	Usage
	        B = isGraph H
	Inputs
	        H:HyperGraph
	Outputs
	        B:Boolean
		       {\tt true} if all edges in {\tt H} have size two
        Description
	        Example
		    QQ[a,b,c,d];
		    isGraph(hyperGraph {a*b,b*c,c*d})
		    isGraph(hyperGraph {a*b,b*c*d})
		    isGraph(hyperGraph {a*b,b*c,d})
///		      

------------------------------------------------------------
-- DOCUMENTATION isLeaf
------------------------------------------------------------

doc ///
	Key
		isLeaf
		(isLeaf, Graph, ZZ )
		(isLeaf, HyperGraph, ZZ)
		(isLeaf, HyperGraph, RingElement )
	Headline 
		determines if an edge (or vertex) is a leaf of a (hyper)graph
	Usage
		B = isLeaf(G,N) or B = isLeaf(H,N) or B = isLeaf(H,V)
	Inputs
		G:Graph
		H:HyperGraph
		N:ZZ
			an index of an edge 
		V:RingElement
			a vertex 
	Outputs 
		B:Boolean
			true if edge N is a leaf or if vertex V has degree 1
        Description
	     Text
		  An edge in a graph is a leaf if it contains a vertex of degree one.
		  An edge E in a hypergraph is a leaf if there is another edge B with the
	          property that for all edges F (other than E), the intersection of F with E 
		  is contained in the interesection of B with E.

		  A vertex of a graph is a leaf if it has degree one.
		  A vertex of a hypergraph is a leaf if it is contained in precisely one
		  edge which is itself is leaf.
	     Example
     	       	  R = QQ[a..f];
		  G = graph {a*b,b*c,c*a,b*d};
		  isLeaf(G, d)
		  isLeaf(G, getEdgeIndex(G, {b,d}))
		  isLeaf(G, a)
		  isLeaf(G, getEdgeIndex(G, {a,b}))
		  H = hyperGraph {a*b*c,b*d,c*e,b*c*f};
		  K = hyperGraph {a*b*c,b*d,c*e};
		  isLeaf(H, a)
		  isLeaf(H, getEdgeIndex(H, {a,b,c}))
		  isLeaf(K, a)
		  isLeaf(K, getEdgeIndex(K, {a,b,c}))
	SeeAlso	
	    isForest
	    isGoodLeaf
///

------------------------------------------------------------
-- DOCUMENTATION isPerfect
------------------------------------------------------------

doc ///
	Key
		isPerfect
		(isPerfect, Graph)
	Headline 
		determines whether a graph is perfect
	Usage
		B = isPerfect G
	Inputs
		G:Graph
	Outputs 
		B:Boolean
			which is {\tt true} if {\tt G} is perfect and {\tt false} otherwise
        Description
	     Text
	     	  The algorithm uses the Strong Perfect Graph Theorem, which says that {\tt G} is
		  perfect if and only if neither {\tt G} nor its complement contains an odd hole.
		  @TO hasOddHole@ is used to determine whether these conditions hold.
	     Example
     	       	  R=QQ[x_1..x_7]
		  G=complementGraph cycle R; --odd antihole with 7 vertices
		  isPerfect G
		  H=cycle(R,4)
		  isPerfect H
		  	     	  
	SeeAlso
		hasOddHole
///

------------------------------------------------------------
-- DOCUMENTATION isSCM
------------------------------------------------------------

doc ///
        Key
	        isSCM
		(isSCM, HyperGraph)
	Headline
	        determines if a (hyper)graph is sequentially Cohen-Macaulay
	Usage
	        B = isSCM H
	Inputs
	        H:HyperGraph
	Outputs
	        B:Boolean
		       true if the @TO edgeIdeal@ of {\tt H} is sequentially Cohen-Macaulay
	Description
	     	Text
		     This uses the edge ideal notion of sequential Cohen-Macaulayness; a 
		     hypergraph is called SCM if and only if its edge ideal is SCM. The 
		     algorithm is based on work of Herzog and Hibi, using the Alexander 
		     dual. {\tt H} is SCM if and only if the Alexander dual of the edge ideal 
		     of {\tt H} is componentwise linear.
		     
		     There is an optional argument called @TO Gins@ for {\tt isSCM}. The 
		     default value is {\tt false}, meaning that {\tt isSCM} takes the 
		     Alexander dual of the edge ideal of {\tt H} and checks in all relevant 
		     degrees to see if the ideal in that degree has a linear resolution. In 
		     characteristic zero with the reverse-lex order, one can test for 
		     componentwise linearity using gins, which may be faster in some cases. This
		     approach is based on work of Aramova-Herzog-Hibi and Conca. 
		Example
		    R = QQ[a..f];
     	       	    G = cycle(R,4)
		    isSCM G
		    H = graph(monomialIdeal(a*b,b*c,c*d,a*d,a*e)); --4-cycle with whisker
		    isSCM H
		    isSCM(H,Gins=>true) --use Gins technique
	SeeAlso
		isCM
		edgeIdeal
///		      

------------------------------------------------------------
-- DOCUMENTATION lineGraph
------------------------------------------------------------

doc ///
	Key
		lineGraph
		(lineGraph, HyperGraph)
	Headline 
		gives the line graph of a (hyper)graph
	Usage
		L = lineGraph H
	Inputs
		H:HyperGraph
	Outputs 
		L:Graph
			the line graph of H
        Description
	     Text
	     	  The line graph L of a hypergraph H has a vertex for each edge in H. 
		  Two vertices in L are adjacent if their edges in H share a vertex.
		  The order of the vertices in L are determined by the implict order 
		  on the edges of H. See @TO edges@.
	     Example
     	       	  R = QQ[a..e]
		  G = graph {a*b,a*c,a*d,d*e}
		  lineGraph G
	SeeAlso
	     edges
///

------------------------------------------------------------
-- DOCUMENTATION neighbors
------------------------------------------------------------

doc ///
	Key
		neighbors
		(neighbors, HyperGraph, RingElement)
		(neighbors, HyperGraph, ZZ)
		(neighbors, HyperGraph, List)
	Headline 
		gives the neighbors of a vertex or list of vertices
	Usage
		N = neighbors(H,V) or N = neighbors(H,I) or N = neighbors(H,L)
	Inputs
		H:HyperGraph
		V:RingElement
			a vertex
		I:ZZ
			the index of a vertex
		L:List
			a list of vertices or indices of vertices
	Outputs 
		N:List
			of neighbors to the given vertex or vertices.
        Description
	    Text
		The vertices adjacent to vertex V are called the neighbors of V. The neighbors
		of a list of vertices L are those vertices which are not in L and are adjacent 
		to a vertex in L.
	    Example
     	       	R=QQ[a..f];
		G=graph {a*b, a*c, a*d, d*e, d*f};
		neighbors(G,a)
		neighbors(G,0)
		neighbors(G,{a,d})
		neighbors(G,{0,3})
        SeeAlso
	     degreeVertex
///

------------------------------------------------------------
-- DOCUMENTATION numConnectedComponents
------------------------------------------------------------

doc ///
	Key
		numConnectedComponents
		(numConnectedComponents, HyperGraph)
	Headline 
		returns the number of connected components in a (hyper)graph
	Usage
		d = numConnectedComponents H
	Inputs
		H:HyperGraph
	Outputs 
		d:ZZ
			the number of connected components of H
	Description
	     Text
	     	  The function returns the number of connected components of a (hyper)graph.  To count the number of components,
		  the algorithm turns H into a simplicial complex, and then computes the rank of the 0^{th} reduced
		  homology group.  This number plus 1 gives us the number of connected components.
	     Example
	     	   S = QQ[a..e]
		   g = graph {a*b,b*c,c*d,d*e,a*e} -- the 5-cycle (connected)
		   h = graph {a*b,b*c,c*a,d*e} -- a 3-cycle and a disjoint edge (not connected)
		   numConnectedComponents g
		   numConnectedComponents h
	SeeAlso
	     connectedComponents
	     isConnected
///


------------------------------------------------------------
-- DOCUMENTATION numTriangles
------------------------------------------------------------

doc ///
	Key
		numTriangles
		(numTriangles, Graph)
	Headline 
		returns the number of triangles in a graph
	Usage
		d = numTriangles G
	Inputs
		G:Graph
	Outputs 
		d:ZZ
			the number of triangles contained in {\tt G}
	Description
	     Text
	     	  The method is based on work of Francisco-Ha-Van Tuyl, looking at the associated primes
		  of the square of the Alexander dual of the edge ideal. The function counts the number
		  of these associated primes of height 3.
	     Example
	     	  R=QQ[x_1..x_6]
		  G=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6}) --5-cycle and a triangle
		  numTriangles G
		  H=completeGraph R;
		  numTriangles H == binomial(6,3)
	SeeAlso
	     allOddHoles
	     getCliques
///

------------------------------------------------------------
-- DOCUMENTATION randomGraph
------------------------------------------------------------

doc ///
	Key
		randomGraph
		(randomGraph,PolynomialRing, ZZ)
	Headline 
		returns a random graph
	Usage
		G = randomGraph(R,d)
	Inputs
		R:PolynomialRing
		     which gives the vertex set of {\tt G}
		d:ZZ
		     the number of edges in {\tt G}
	Outputs 
		G:Graph
			a graph with {\tt d} edges on vertex set determined by {\tt R}
	Description
	     Example
	     	  R=QQ[x_1..x_9]
		  randomGraph(R,4)
     	       	  randomGraph(R,4)  
	SeeAlso
	     randomHyperGraph
	     randomUniformHyperGraph
///


------------------------------------------------------------
-- DOCUMENTATION randomHyperGraph
------------------------------------------------------------


------------------------------------------------------------
-- DOCUMENTATION randomUniformHyperGraph
------------------------------------------------------------

doc ///
	Key
		randomUniformHyperGraph
		(randomUniformHyperGraph,PolynomialRing,ZZ,ZZ)
	Headline 
		returns a random uniform hypergraph
	Usage
		H = randomUniformHyperGraph(R,c,d)
	Inputs
		R:PolynomialRing
		     which gives the vertex set of {\tt H}
		c:ZZ
		     the cardinality of the edge sets
		d:ZZ
		     the number of edges in {\tt H}
	Outputs 
		H:HyperGraph
			a hypergraph with {\tt d} edges of cardinality {\tt c} on vertex set determined by {\tt R}
	Description
	     Example
	     	  R=QQ[x_1..x_9]
		  randomUniformHyperGraph(R,3,4)
     	       	  randomUniformHyperGraph(R,4,2)  
	SeeAlso
	     randomGraph
	     randomHyperGraph
///


---------------------------------------------------------
-- DOCUMENTATION simplicialComplexToHyperGraph
----------------------------------------------------------



doc ///
	Key
		simplicialComplexToHyperGraph
		(simplicialComplexToHyperGraph, SimplicialComplex)
	Headline 
		change the type of a simplicial complex to a (hyper)graph
	Usage
		h = simplicialComplexToHyperGraph(D) 
	Inputs
		D:SimplicialComplex
		        the input
	Outputs 		
	        h:HyperGraph
			whose edges are the facets of D
        Description
 	        Text
		        This function takes a simplicial complex and changes it type to a HyperGraph by
			returning a hypergraph whose edges are defined by the facets of the simplicial
			complex.  This is the reverse of the function @TO hyperGraphToSimplicialComplex @
		Example
	                S = QQ[a..f]
			Delta = simplicialComplex {a*b*c,b*c*d,c*d*e,d*e*f}
                        h = simplicialComplexToHyperGraph Delta
        SeeAlso
	        hyperGraphToSimplicialComplex
///
 

---------------------------------------------------------
-- DOCUMENTATION smallestCycleSize
----------------------------------------------------------
 
doc ///
        Key
	        smallestCycleSize 
		(smallestCycleSize, Graph)
	Headline
	        returns the size of the smallest induced cycle of a graph
	Usage
	        s = smallestCycleSize(G)
	Inputs
		G:Graph
		     the input
	Outputs
		s:ZZ
		     the size of the smallest induced cycle
        Description
	        Text
		     This function returns the size of the smallest induced cycle of a graph.
		     It is based upon Theorem 2.1 in the paper "Restricting linear syzygies:
		     algebra and geometry" by Eisenbud, Green, Hulek, and Popsecu.  This theorem
		     states that if G is graph, then the edge ideal of the complement of G satisfies
		     property N_{2,p}, that is, the resolution of I(G^c) is linear up to the p-th step,
		     if and only if, the smallest induced cycle of G has length p+3.  The algorithm
		     looks at the resolution of the edge ideal of the complement to determine the size
		     of the smallest cycle.    	  
		Example      
     	       	     T = QQ[x_1..x_9]
		     g = graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9,x_9*x_1} -- a 9-cycle
		     smallestCycleSize g
		     h = graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9} -- a tree (no cycles)
		     smallestCycleSize h
		     l =  graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9,x_9*x_1,x_1*x_4}
		     smallestCycleSize l
		Text
		     Note that if g is a tree if and only if {\tt smallestCycleSize g = 0}
///






------------------------------------------------------
-- DOCUMENTATION spanningTree
----------------------------------------------------------
 
doc ///
        Key
	        spanningTree 
		(spanningTree, Graph)
	Headline
	        returns a spanning tree of a connected graph
	Usage
	        t = spanningTree(G)
	Inputs
		G:Graph
		     the input
	Outputs
		t:Graph
		     the spanning tree of G
        Description
	        Text
		     This function returns the a spanning tree of a connected graph.  It will
		     not work on unconnected graphs.  The algorithm is very naive;  the first edge
		     of the tree is the first edge of the graph.  The algorithm then successively
		     adds the next edge in the graph, as long as no cycle is created.  The algorithm terminates once (n-1)
		     edges have been added, where n is the number of edges.
		Example      
     	       	     T = QQ[x_1..x_9]
		     g = graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9,x_9*x_1} -- a 9-cycle
		     spanningTree g
		     h = graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9} -- a tree (no cycles)
		     spanningTree h === h
///









---------------------------------------------------------
-- DOCUMENTATION vertexCoverNumber
---------------------------------------------------------

doc ///
	Key
		vertexCoverNumber
		(vertexCoverNumber, HyperGraph)
	Headline 
		find the vertex covering number of a (hyper)graph
	Usage
		c = vertexCoverNumber(H) 
	Inputs
		H:HyperGraph
		        the input
	Outputs 
		c:ZZ
			the vertex covering number
        Description
	        Text
		        This function takes a graph or hypergraph, and returns the vertex covering number, that is,
			the size of smallest vertex cover of the (hyper)graph.  This corresponds to the smallest
			degree of a generator of the cover ideal of the (hyper)graph.
		Example
	                S = QQ[a..d]
			g = graph {a*b,b*c,c*d,d*a} -- the four cycle
			vertexCoverNumber g
		        S = QQ[a..e]
			g = graph {a*b,a*c,a*d,a*e,b*c,b*d,b*e,c*d,c*e,d*e} -- the complete graph K_5
			vertexCoverNumber g
		      	h = hyperGraph {a*b*c,a*d,c*e,b*d*e}
			vertexCoverNumber(h)
        SeeAlso
	        coverIdeal
		vertexCovers
///
 

---------------------------------------------------------
-- DOCUMENTATION vertexCovers
---------------------------------------------------------

doc ///
	Key
		vertexCovers
		(vertexCovers, HyperGraph)
	Headline 
		list the minimal vertex covers of a (hyper)graph
	Usage
		c = vertexCovers(H) 
	Inputs
		H:HyperGraph
		        the input
	Outputs 
		c:List
			of the minimal vertex covers of {\tt H}.  The vertex covers are represented as monomials.
        Description
	        Text
		        This function takes a graph or hypergraph, and returns the minimal vertex cover of the graph or
			hypergraph.   A vertex cover is a subset of the vertices such that every edge of the (hyper)graph has
			non-empty intersection with this set.  The minimal vertex covers are given by the minimal generators
			of the cover ideal of H.
		Example
	                S = QQ[a..d]
			g = graph {a*b,b*c,c*d,d*a} -- the four cycle
			vertexCovers g
		        coverIdeal g
			flatten entries gens coverIdeal g == vertexCovers g
			S = QQ[a..e]
			h = hyperGraph {a*b*c,a*d,c*e,b*d*e}
			vertexCovers(h)
        SeeAlso
	        coverIdeal
		vertexCoverNumber
///
 
 
---------------------------------------------------------
-- DOCUMENTATION vertices
---------------------------------------------------------

doc ///
	Key
		vertices
		(vertices, HyperGraph)
	Headline 
		gets the vertices of a (hyper)graph
	Usage
		V = vertices(H) 
	Inputs
		H:HyperGraph
		        the input
	Outputs 
		V:List
			of the vertices of {\tt H}
        Description
	        Text
		        This function takes a graph or hypergraph, and returns the vertex set of the graph.
		Example
	                S = QQ[a..d]
			g = graph {a*b,b*c,c*d,d*a} -- the four cycle
			vertices(g)
			h = hyperGraph{a*b*c}
			vertices(h) -- the vertex d is treated as an isolated vertex
        SeeAlso 
	        edges
///

----------------------------
--Options documentation-----
----------------------------

------------------------------------------------------------
-- DOCUMENTATION Gins
------------------------------------------------------------

doc ///
        Key
	        Gins
	Headline
	        optional argument for isSCM
	Description
	     	Text
     	       	    Directs @TO isSCM@ to use generic initial ideals to determine whether the
		    Alexander dual of the edge ideal of a hypergraph is componentwise linear.
	SeeAlso
		isSCM
///

doc ///
     	  Key
	       [isSCM, Gins]
	  Headline
	       use gins inside isSCM
	  Usage
	       B = isSCM(H,Gins=>true)
	  Inputs
	       H:HyperGraph
	       	    the hypergraph being considered
     	  Outputs
	       B:Boolean
	       	    whether {\tt H} is SCM or not
	  Description
	       Text
	       	    The default value for {\tt Gins} is {\tt false} since using generic
		    initial ideals makes the @TO isSCM@ algorithm probabilistic.
	  SeeAlso
	       isSCM
///	       
	       

-----------------------------
-- Constructor Tests --------
-- Test hyperGraph and Graph
-----------------------------

TEST///
R = QQ[a,b,c]
H = hyperGraph(R, {{a,b},{b,c}})
assert(#(edges H) == 2)
assert(#(vertices H) == 3)
///

TEST///
R = QQ[a,b,c]
H = hyperGraph(R, {{a,b,c}})
assert(#(edges H) == 1)
assert(#(vertices H) == 3)
///

TEST///
R = QQ[a,b,c]
H = hyperGraph(R, {a*b,b*c})
assert(#(edges H) == 2)
assert(#(vertices H) == 3)
///

TEST///
R = QQ[a,b,c]
H = hyperGraph({{a,b},{b,c}})
assert(#(edges H) == 2)
assert(#(vertices H) == 3)
///

TEST///
R = QQ[a,b,c]
H = hyperGraph({a*b,b*c})
assert(#(edges H) == 2)
assert(#(vertices H) == 3)
///

TEST///
R = QQ[a,b,c]
H = hyperGraph(ideal {a*b,b*c})
assert(#(edges H) == 2)
assert(#(vertices H) == 3)
///

TEST///
R = QQ[a,b,c]
H = hyperGraph(monomialIdeal {a*b,b*c})
assert(#(edges H) === 2)
assert(#(vertices H) === 3)
///

-----------------------------
-- Test Equality ==
-----------------------------

TEST///
R = QQ[a,b,c,d]
G1 = hyperGraph(R, {{a,b},{b,c}})
G2 = hyperGraph(R, {{a,b},{b,c}})
G3 = hyperGraph(R, {{a,b},{c,b}})
G4 = hyperGraph(R, {{b,c}, {b,a}})
G5 = hyperGraph(R, {{b,c}, {a,c}})

S = QQ[a,b,c]
G6 = hyperGraph(S, {{a,b}, {b,c}})

assert(G1 == G1) 
assert(G1 == G2)
assert(G1 == G3)
assert(G1 == G4)
assert(G1 != G5)
assert(G1 != G6)
///

-----------------------------
-- Test adjacencyMatrix
-----------------------------

TEST///
R = QQ[a..d]
c4 = graph {a*b,b*c,c*d,d*a} -- 4-cycle plus an isolated vertex!!!!
adjacencyMatrix c4
m = matrix {{0,1,0,1},{1,0,1,0},{0,1,0,1},{1,0,1,0}}
assert(adjacencyMatrix c4 == m)
///

----------------------------
-- Test antiCycle
---------------------------

TEST///
S= QQ[a..d]
g = graph {a*c,b*d}
assert(antiCycle(S) == g)
assert(complementGraph antiCycle(S) == cycle(S))
///

------------------------
-- Test chromaticNumber
------------------------ 

TEST///
R = QQ[a..e]
c4 = graph {a*b,b*c,c*d,d*a} -- 4-cycle
c5 = graph {a*b,b*c,c*d,d*e,e*a} -- 5-cycle
assert(chromaticNumber c4 == 2)
assert(chromaticNumber c5 == 3)
///

--------------------------
-- Test cliqueComplex and cliqueNumber
-------------------------------

TEST///
R=QQ[w,x,y,z]
e = graph {w*x,w*y,x*y,y*z}  -- clique on {w,x,y} and {y,z}
Delta1 = cliqueComplex e  -- max facets {w,x,y} and {y,z}
Delta2 = simplicialComplex {w*x*y,y*z}
assert(Delta1 == Delta2)
assert(cliqueNumber e -1 == dim Delta1)
///

-----------------------------
-- Test complementGraph
-----------------------------

TEST///
R = QQ[a,b,c,d,e]	   
c5 = graph {a*b,b*c,c*d,d*e,e*a} 
c5c = graph {a*c,a*d,b*d,b*e,c*e}
assert(complementGraph c5 == c5c)
///

-----------------------------
-- Test completeGraph
-----------------------------

TEST///
R = QQ[a,b,c,d]	   
assert(completeGraph(R) == graph {a*b,a*c,a*d,b*c,b*d,c*d})
assert(completeGraph(R, 3) == graph {a*b,a*c,b*c})
///

-----------------------------
-- Test completeMultiPartite
-----------------------------

TEST///
R = QQ[a,b,c,d]	   
assert(completeMultiPartite(R, 2,2) == graph {a*d,a*c,b*c,b*d})
assert(completeMultiPartite(R, {1,3}) == graph {a*b,a*c,a*d})
assert(completeMultiPartite(R, {{b},{a,c,d}}) == graph {b*a,b*c,b*d})
///

-----------------------------
-- Test connectedComponents
-----------------------------

TEST///
R = QQ[a..k]	   
H = hyperGraph {a*b, c*d*e,e*k, b*f, g, f*i}
assert(# connectedComponents(H) == 3 )
R = QQ[a,b,c,d]
G = hyperGraph {a*b*c}
H = hyperGraph {a,b,c}
assert(# connectedComponents(G) == 1 )
assert(# connectedComponents(H) == 3 )
///

-----------------------------
-- Test coverIdeal
-----------------------------

TEST///
R = QQ[a,b,c]
i = monomialIdeal {a*b,b*c}
j = monomialIdeal {b,a*c}
h = hyperGraph i
assert((coverIdeal h) == j) 
///


-----------------------------
-- Test degreeVertex Test 
-----------------------------

TEST///
R = QQ[a,b,c,d]
H = hyperGraph(monomialIdeal {a*b,b*c,c*d,c*a})
assert( degreeVertex(H,a) == 2)
assert( degreeVertex(H,0) == 2)
assert( degreeVertex(H,b) == 2)
assert( degreeVertex(H,1) == 2)
assert( degreeVertex(H,c) == 3)
assert( degreeVertex(H,2) == 3)
assert( degreeVertex(H,d) == 1)
assert( degreeVertex(H,3) == 1)
///

-----------------------------
-- Test edgeIdeal
-----------------------------

TEST///
R = QQ[a,b,c]
i = monomialIdeal {a*b,b*c}
h = hyperGraph i
assert((edgeIdeal h) == i) 
///


-----------------------------
-- Test getEdgeIndex 
-----------------------------

TEST///
R = QQ[a,b,c]
H = hyperGraph(monomialIdeal {a*b,b*c})
assert( getEdgeIndex(H,{a,b}) == 0)
assert( getEdgeIndex(H,a*b) == 0)
assert( getEdgeIndex(H,{c,b}) == 1)
assert( getEdgeIndex(H,c*b) == 1)
assert( getEdgeIndex(H,{a,c}) == -1)
assert( getEdgeIndex(H,a*c) == -1)
///

-----------------------------
-- Test getGoodLeaf 
-- Test getGoodLeafIndex 
-- Test hasGoodLeaf 
-- Test isGoodLeaf 
-----------------------------

TEST///
R = QQ[a..g]
H = hyperGraph {a*b*c*d,b*c*d*e,c*d*f,d*g,e*f*g}
G = hyperGraph {b*c*d*e,d*g,e*f*g,a*b*c*d}
C = graph {a*b,b*c,c*d,d*e,e*a} -- 5-cycle
assert( getGoodLeaf(H) === {a,b,c,d})
assert( getGoodLeafIndex(H) === getEdgeIndex(H, {a,b,c,d}))
assert( getGoodLeaf(G) === {a,b,c,d})
assert( hasGoodLeaf G )
assert( isGoodLeaf(H, getEdgeIndex(H,{a,b,c,d})) )
assert( not isGoodLeaf(H, getEdgeIndex(H,{b,c,d,e})) )
assert( not hasGoodLeaf C )
///

-----------------------------
-- Test hasOddHole
-- Test isPerfect
-----------------------------

TEST///
R = QQ[a..g]
G = graph {a*b,b*c,c*d,d*e,e*f,f*g,a*g} 
H = complementGraph G
assert hasOddHole G
assert not hasOddHole H
assert not isPerfect G
///

-----------------------------
-- Test hyperGraphToSimplicialComplex
----------------------------------

TEST///
R=QQ[x_1..x_6]
G=graph({x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_1*x_5,x_1*x_6,x_5*x_6}) --5-cycle and a triangle
DeltaG = hyperGraphToSimplicialComplex G
hyperGraphDeltaG = simplicialComplexToHyperGraph DeltaG
GPrime = graph(hyperGraphDeltaG)
assert(G === GPrime)
///

-----------------------------
-- Test incidenceMatrix
-----------------------------

TEST///
R = QQ[a..f]
H = hyperGraph {a*b*c*d,c*d*e,f} 
assert(incidenceMatrix H == matrix {{1,0,0},{1,0,0},{1,1,0},{1,1,0},{0,1,0},{0,0,1}})
///

-----------------------------------
-- Test independenceComplex
-----------------------------------

TEST///
R = QQ[a..e]
c5 = graph {a*b,b*c,c*d,d*e,e*a}
D = simplicialComplex monomialIdeal (a*b,b*c,c*d,d*e,e*a)
assert(D == independenceComplex c5)
///


-----------------------------
-- Test independenceNumber
-----------------------------

TEST///
R = QQ[a..e]
c4 = graph {a*b,b*c,c*d,d*a} -- 4-cycle plus an isolated vertex!!!!
c5 = graph {a*b,b*c,c*d,d*e,e*a} -- 5-cycle
assert(independenceNumber c4 == 3)
assert(independenceNumber c5 == 2)
///


-----------------------------
-- Test isBipartite
-----------------------------

TEST///
R = QQ[a..e]
c4 = graph {a*b,b*c,c*d,d*a} -- 4-cycle
c5 = graph {a*b,b*c,c*d,d*e,e*a} -- 5-cycle
assert(isBipartite c4 == true)
assert(isBipartite c5 == false)
///


-----------------------------------
-- Test isChordal
----------------------------------

TEST///
R = QQ[a..e];
C = cycle R;
assert(isChordal C == false);
D = graph {a*b,b*c,c*d,a*c};
assert(isChordal D == true);
///

-----------------------------
-- Test isCM
-----------------------------

TEST///
R = QQ[a..e];
C = cycle R;
UnmixedTree = graph {a*b, b*c, c*d};
MixedTree = graph {a*b, a*c, a*d};
assert isCM C
assert isCM UnmixedTree
assert not isCM MixedTree
///		      

-----------------------------
-- Test isConnected
-----------------------------

TEST///
S = QQ[a..e]
g = graph {a*b,b*c,c*d,d*e,a*e} -- the 5-cycle (connected)
h = graph {a*b,b*c,c*a,d*e} -- a 3-cycle and a disjoint edge (not connected)
assert(isConnected g) 
assert(not isConnected h)
///

-----------------------------
-- Test isEdge 
-----------------------------

TEST///
R = QQ[a,b,c]
H = hyperGraph(monomialIdeal {a*b,b*c})
assert( isEdge(H,{a,b}) )
assert( isEdge(H,a*b) )
assert( isEdge(H,{c,b}) )
assert( isEdge(H,b*c) )
assert( not isEdge(H,{a,c}) )
assert( not isEdge(H,a*c) )
///

-----------------------------
-- Test isForest 
-----------------------------

TEST///
R = QQ[a..h]
H = hyperGraph {a*b*h, b*c*d, d*e*f, f*g*h, b*d*h*f}
K = hyperGraph {a*b*h, b*c*d, d*e*f, b*d*h*f}
G = graph {a*b,b*c,b*d,d*e, f*g, g*h}
J = graph {a*b,b*c,b*d,d*e, f*g, g*h, e*a}
assert( not isForest H )
assert( isForest K )
assert( isForest G )
assert( not isForest J )
assert( isForest hyperGraph G )
assert( not isForest hyperGraph J )
///

-----------------------------
-- Test isLeaf
-----------------------------

TEST///
R = QQ[a..e]
G = graph {a*b,b*c,c*d,d*a,a*e} 
H = hyperGraph {a*b*c,b*d,c*e} 
I = hyperGraph {a*b*c,b*c*d,c*e} 
assert(isLeaf(G,4))
assert(not isLeaf(G,1))
assert(not isLeaf(G,0))
assert(not isLeaf(G,a))
assert(isLeaf(G,e))
assert(not isLeaf(H,0))
assert(isLeaf(I,0))
///

-----------------------------
-- Test lineGraph
-----------------------------

TEST///
R = QQ[a..e]
G = graph {a*b,a*c,a*d,d*e} 
assert(adjacencyMatrix lineGraph G == matrix {{0,1,1,0},{1,0,1,0},{1,1,0,1},{0,0,1,0}})
///

-----------------------------
-- Test neighbors
-----------------------------

TEST///
S = QQ[a..f]
G = graph {a*b,a*c,a*d,d*e,d*f} 
assert(apply(gens S, V -> #neighbors(G, V)) == {3,1,1,3,1,1})
assert(apply(numgens S, N -> #neighbors(G, N)) == {3,1,1,3,1,1})
assert(neighbors(G, {a,c}) == {b,d})
assert(neighbors(G, {e,f}) == {d})
///


-----------------------------
-- Test numConnectedComponents
-----------------------------
TEST///
S = QQ[a..e]
g = graph {a*b,b*c,c*d,d*e,a*e} -- the 5-cycle (connected)
h = graph {a*b,b*c,c*a,d*e} -- a 3-cycle and a disjoint edge (not connected)
assert(numConnectedComponents g == 1) 
assert(numConnectedComponents h == 2)
///


-------------------------------------
-- Test randomGraph
-------------------------------------

-------------------------------------
-- Test randomHyperGraph
-------------------------------------

-------------------------------------
-- Test randomUniformHyperGraph
-------------------------------------

-------------------------------------
-- Test simplicialComplexToHyperGraph
-------------------------------------

TEST///
S = QQ[a..f]
Delta = simplicialComplex {a*b*c,b*c*d,c*d*e,d*e*f}
h = simplicialComplexToHyperGraph Delta
assert(class h === HyperGraph)
///

-----------------------------
-- Test smallestCycleSize
-----------------------------

TEST///
T = QQ[x_1..x_9]
g = graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9,x_9*x_1} -- a 9-cycle
assert(smallestCycleSize g == 9)
///

--------------------------------
-- Test spanningTree
------------------------------
TEST///
T = QQ[x_1..x_9]
h = graph {x_1*x_2,x_2*x_3,x_3*x_4,x_4*x_5,x_5*x_6,x_6*x_7,x_7*x_8,x_8*x_9} -- a tree (no cycles)
assert(spanningTree h === h)
///

-----------------------------
-- Test vertexCoverNumber
-----------------------------
TEST///
S = QQ[a..d]
g = graph {a*b,b*c,c*d,d*a} -- the four cycle
assert(vertexCoverNumber g == 2)
///

-----------------------------
-- Test vertexCovers
-----------------------------
TEST///
S = QQ[a..d]
g = graph {a*b,b*c,c*d,d*a} -- the four cycle
vertexCovers g
coverIdeal g
assert(flatten entries gens coverIdeal g == vertexCovers g)
///

-----------------------------
-- Test vertices
-----------------------------

TEST///
R = QQ[a..f]
G = graph {a*b,b*c,c*d,d*e,e*f} 
V = vertices(G)
assert(vertices(G) == {a,b,c,d,e,f})
///

end

restart
installPackage ("EdgeIdeals", UserMode=>true)
loadPackage "EdgeIdeals"
viewHelp

