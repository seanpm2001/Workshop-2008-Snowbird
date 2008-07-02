newPackage(
	"Posets",
    	Version => "0.1", 
    	Date => "July 7th, 2008",
    	Authors => {
	     {Name => "Sonja Mapes", Email => "mapes@math.columbia.edu", HomePage => "http://www.math.columbia.edu/~mapes/"},
	     {Name => "Gwyn Whieldon", Email => "whieldon@math.cornell.edu", HomePage => "http://www.math.cornell.edu/People/Grads/whieldon.html"},
	     {Name => "Josephine Yu", Email => "jyu@math.mit.edu", HomePage => "http://www-math.mit.edu/~jyu/"}
	     },
    	Headline => "Package for processing posets and order complexes",
    	DebuggingMode => true
    	)
 
export {
     Poset,
     newPoset,
     FullRelationMatrix,
     RelationMatrix,
     compare,
     indexElement,
     nonnull,
     OrderIdeal,
     Filter
     }



Poset = new Type of HashTable

newPoset := (I,C) ->
     new Poset from {
	 symbol GroundSet => I,
	 symbol CRelations => C,
	 symbol cache => CacheTable
	 }
    


-- some toy examples
I={a,b,c,d,e,f,g,h}
C={(a,b),(a,c),(a,d),(b,e),(b,f),(c,e),(c,g),(d,f),(d,g),(e,h),(f,h),(g,h)}
P=newPoset(I,C)

I1={a,b,c,d,e}
C1={(a,c),(a,d),(b,c),(b,d),(c,e),(d,e)}
P1=newPoset(I1,C1)

-- input: A poset
-- output: a matrix indexed by I that has non zero entries for each pair of relations
-- usage:  RelationMatrix,compare
FullRelationMatrix:= (P) -> (
     M:=matrix apply (#P.GroundSet, i-> apply(#P.GroundSet, j-> if member((I#i,I#j), P.CRelations) then 1 else if i==j then 1 else 0));
     n:=#I;
     N:=M^n 
     )

--input:  A matrix or a poset
--output:  A matrix with ones in all the non-zero entries
--usage:
RelationMatrix = method()
RelationMatrix(Matrix):= (M) -> (
     N=matrix apply(numrows M, i-> apply(numcols M, j-> if (M_j)_i==0 then 0 else 1))
     )
RelationMatrix(Poset):=(P) -> (
     M:= FullRelationMatrix(P);
     N=RelationMatrix(M)
     )


-- input:  A poset, and two elements A and B from I
-- output: true if A<= B, false else
compare:= (P,A,B) -> (
     N:=FullRelationMatrix(P);
     Aindex:=indexElement(P,A);
     Bindex:=indexElement(P,B);
          if N_Bindex_Aindex==0 then false else true
     )


-- input: a poset, and an element A from I
-- output:  the index of A in the ground set of P
-- usage: compare, OrderIdeal 
indexElement:= (P,A) -> (
      sum apply(#P.GroundSet, i-> if P.GroundSet#i == A then i else 0))

-- input:  a list, potentially with nulls
-- output:  a list w/out nulls
-- usage:  OrderIdeal, Filter
nonnull:=(L) -> (
     select(L, i-> i =!= null))



-- input: a poset, and an element from I
-- output: the order ideal of a, i.e. all elements in the poset that are >= a
-- usage:
OrderIdeal:= (P, a) -> (
     M:=RelationMatrix (P);
     aindex := indexElement (P,a);
     GreaterThana:= entries((transpose(M))_aindex);
     nonnull(apply(#GreaterThana, i-> if GreaterThana_i == 1 then P.GroundSet#i)) 
     )	
	   

-- input: a poset, and an element from I
-- output:  the filter of a, i.e. all elements in the poset that are <= a
-- usage:
Filter:=(P,a) -> (
     M:=RelationMatrix (P);
     aindex := indexElement (P,a);
     LessThana:= entries M_aindex;
     nonnull(apply(#LessThana, i-> if LessThana_i == 1 then P.GroundSet#i))
     )



beginDocumentation()

document { Key => Poset,
     Headline => "Betti diagram routines",
     EM "BoijSoederberg", " is a package designed to help with the investigation of 
     the Boij-Soederberg conjectures and theorems.  For the definitions and conjectures, see
     math.AC/0611081, \"Graded Betti numbers of Cohen-Macaulay modules and 
     the Multiplicity conjecture\", by Mats Boij, Jonas Soederberg."
                    }

end

document { 
     Key => {},
     Headline => "",
     Usage => "",
     Inputs => {
	  },
     Outputs => {
	  },
     EXAMPLE lines ///
	  ///,
     Caveat => {},
     SeeAlso => {}
     }


