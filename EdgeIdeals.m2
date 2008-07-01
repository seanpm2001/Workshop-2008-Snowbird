newPackage("EdgeIdeals", 
           Version => "0.1",
           Date => "July 1, 2008",
           Authors => {
											 {Name => "Christopher Francisco", 
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

export {HyperGraph, 
        hyperGraph, 
        vertices, 
        edges,   
        getEdge,
				isEdge,
				getEdgeIndex,
				complementGraph,
				inducedGraph,
				deleteEdges,
				stanleyReisnerComplex,
				independenceComplex,
				cliqueComplex,
				edgeIdeal,
				coverIdeal,
			  isBipartite,
				isCMHyperGraph,
			  isSCMHyperGraph,
				isPerfect,
				isChordal,
				isLeaf,
				isOddHole,
				isTree,
				isConnected,
				cliqueNumber,
				chromaticNumber,
				vertexCoverNumber,
				independenceNumber,
				numTriangles,
				degreeVertex,
				numConnectedComponents,
				smallestCycleSize,
				allOddHoles,
				allEvenHoles,
				connectedComponents,
				vertexCovers,
				neighborSet,
				getCliques,
				getMaxCliques,
				adjacencyMatrix,
				incidenceMatrix,
				cycle,
				completeGraph,
				completeMultiPartite,
				antiHole,
				spanningTree,
				lineGraph
        };

needsPackage "SimpleDoc"

HyperGraph = new Type of HashTable;

hyperGraph = method(TypicalValue => HyperGraph);
hyperGraph (Ring, List) := HyperGraph => (R, E) -> 
( 
	V := gens R;
	if all(E, e-> class class e === PolynomialRing) then E = apply(E, support);
  E = apply(E, unique); --- Enforces square-free
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
( hyperGraph monomialIdeal I
)

hyperGraph (List) := HyperGraph => (E) -> 
( 
	M := null; 
	if all(E, e-> class e === List) then M = monomialIdeal apply(E, product);
	if all(E, e-> class class e === PolynomialRing) then M = monomialIdeal E;
	if M === null then error "Edge must be represented by a list or a monomial.";
	if #E =!= numgens M then error "Edges satisfy an inclusion relation."; 
	hyperGraph M
)

vertices = method();
vertices HyperGraph := H -> H#"vertices";

edges = method();
edges HyperGraph := H -> H#"edges";

getEdge = method();
getEdge (HyperGraph, ZZ) := (H,N) -> H#"edges"#N;

isEdge = method();
isEdge (HyperGraph, List) := (H,E) -> (
		if class class E === PolynomialRing then E = support E;
		any(H#"edges", G->set G === set E)
	)
isEdge (HyperGraph, RingElement) := (H,E) -> (
		isEdge(H, support E)
	)

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

-- Graph Constructions

-- find the complement of G
complementGraph = method();

-- given a set of vertices, return induced graph on those vertices
inducedGraph = method();

-- remove edges from G
deleteEdges = method();

-- change type

 -- turn G from a graph to simplicial complex
stanleyReisnerComplex = method();

-- find independenceComplex
independenceComplex =method();

 -- clique complex of G
cliqueComplex =method();


-- return ideals

 -- edge ideal of G
edgeIdeal = method();

 -- Alexander dual of edge ideal
coverIdeal = method();


-- Boolean Functions

 -- Boolean function
isBipartite = method();

 -- Boolean function (True of False if graph is CM)
isCMhyperGraph = method();

 -- Boolean function (True of False if graph is SCM)
isSCMhyperGraph = method();

 -- Boolean function (True or False if graph is perfect)
isPefect = method();

 -- Boolean  function (True of False if graph is chordal)
isChordal = method();

 -- (True or False if edge of hyperGraph/Graph is leaf)
isLeaf = method();

 -- (True or False if exists odd hole (not triangle) )
isOddHole = method();

 -- (True or False if graph is a tree)
isTree = method();

 -- (True or False if graph is connected)
isConnected = method();



-- Numerical Values

 -- return clique number
cliqueNumber = method();

 -- return chromatic number
chromaticNumber = method();

 -- return vertex cover number
vertexCoverNumber = method();

 -- return independence number
independenceNumber = method();

 -- return number of triangles
numTriangles = method();

 -- return degree of vertex
degreeVertex = method();

 -- number of connected components
numConnectedComponents = method();

 -- length of smallest induced cycle
smallestCycleSize = method();



-- Return Lists


 -- return all odd holes
allOddHoles = method();

 -- return all even holes (this would be SLOWWW!)
allEvenHoles = method();

 -- return the connected components
connectedComponents = method();

 -- return all minimal vertex covers
vertexCovers  = method();

 -- return neighbors of a vertex of a set
neighborSet = method();

 -- return all cliques of the graph
getCliques = method();

 -- return all cliques of maximal size
getMaxCliques = method();



-- Return Matrices

 -- return the adjacency matrix
adjacencyMatrix = method();

 -- return the incidence matrix
incidenceMatrix = method();



-- special graphs (i.e. define functions to create special families)

 -- return graph of cycle on n vertices
cycle = method();

 -- return graph of complete n-graph
completeGraph = method();

 -- return the complete multi-partite graph
completeMultiPartite = method();

 -- return graph of anti-n-hole
antiHole = method();

 -- return spanning tree of a graph G
spanningTree = method();

 -- return the graph with E(G) as its vertices where two
 --         vertices are adjacent when their associated edges are adjacent in G.
lineGraph = method();


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
doc ///
	Key
		HyperGraph
	Headline 
		a class for hypergraphs.
///

doc ///
	Key
		hyperGraph
		(hyperGraph, Ring, List)
		(hyperGraph, MonomialIdeal)
		(hyperGraph, Ideal)
		(hyperGraph, List)
	Headline 
		constructor for HyperGraph.
	Usage
		H = hyperGraph(R,E) \n H = hyperGraph(I) \n H = hyperGraph(E)
	Inputs
		R:Ring
			whose variables correspond to vertices of the hypergraph.
		E:List
			contain a list of edges, which themselves are lists of vertices.
		I:MonomialIdeal
			which must be square-free and whose generators become the edges of the hypergraph.
		J:Ideal
			which must be square-free monomial and whose generators become the edges of the hypergraph.
	Outputs 
		H:HyperGraph
///

doc ///
	Key
		vertices
		(vertices, HyperGraph)
	Headline 
		gets the vertices of a HyperGraph.
	Usage
		V = vertices(H)
	Inputs
		H:HyperGraph
		        the input
	Outputs 
		V:List
			of the vertices of {\tt H}.
///

doc ///
	Key
		edges
		(edges, HyperGraph)
	Headline 
		gets the edges of a HyperGraph.
	Usage
		E = edges(H)
	Inputs
		H:HyperGraph
	Outputs 
		E:List
			of the edges of {\tt H}.
///

doc ///
	Key
		getEdge
		(getEdge, HyperGraph, ZZ)
	Headline 
		gets the n-th edge in a HyperGraph.
	Usage
		E = edges(H,N)
	Inputs
		H:HyperGraph
		N:ZZ
			an index of an edge in {\tt H}
	Outputs 
		E:List
			which is the {\tt N}-th edge of {\tt H}.
///

doc ///
	Key
		isEdge
		(isEdge, HyperGraph, List)
		(isEdge, HyperGraph, RingElement)
	Headline 
		determines if an edge is in a HyperGraph
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
			which is true iff {\tt E} (or {\tt support M}) is an edge of {\tt H}.
	SeeAlso
		getEdgeIndex
///

doc ///
	Key
		getEdgeIndex
		(getEdgeIndex, HyperGraph, List)
	Headline 
		finds the index of an edge in a HyperGraph
	Usage
		N = getEdgeIndex(H,E)
	Inputs
		H:HyperGraph
		E:List
			of vertices (or monomials).
	Outputs 
		N:ZZ
			which is the index of {\tt E} as an edge of {\tt H}. If {\tt E} is not in {\tt H}
			then -1 is returned.
	SeeAlso
		isEdge
///

-----------------------------
-- Constructor Tests --------
-----------------------------

TEST///
R = QQ[a,b,c]
H = hyperGraph(R, {{a,b},{b,c}})
assert(#(edges H) == 2)
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

----------------------------------
-- isEdge Test -------------------
----------------------------------
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

----------------------------------
-- getEdgeIndex Test -------------
----------------------------------
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

----------------------------------------------
end
restart
installPackage ("EdgeIdeals", UserMode=>true)
loadPackage "EdgeIdeals"
viewHelp
