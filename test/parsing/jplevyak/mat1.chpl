var m = 100;
var n = 200;

var Mat = domain(1..m, 1..n);

var A = [Mat] float;

forall i,j in Mat {
  A(i,j) = i==j;
};

write(A);
