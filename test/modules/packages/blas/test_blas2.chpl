use Random;
use BLAS;
use blas_helpers;


proc main() {
    //test_gbmv(); // bandMatrix
    test_gemv();
    test_ger();
    test_gerc();
    test_geru();
    //test_hbmv(); // bandMatrix;
    test_hemv();
    test_her();
    test_her2();
    //test_hpmv(); // bandMatrix
    //test_hpr();  // packedMatrix
    //test_hpr2(); // packedMatrix
    //test_sbmv(); // bandMatrix
    //test_spmv(); // packedMatrix
    //test_spr();  // packedMatrix
    //test_spr2(); // packedMatrix
    test_symv();
    test_syr();
    test_syr2();
    //test_tbmv(); // bandMatrix
    //test_tbsv(); // bandMatrix
    //test_tpmv(); // packedMatrix
    //test_tpsv(); // packedMatrix
    test_trmv();
    test_trsv();
}


//
// Tests
//

proc test_gbmv() {
    test_gbmv_helper(real(32));
    test_gbmv_helper(real(64));
    test_gbmv_helper(complex(64));
    test_gbmv_helper(complex(128));
}


proc test_gemv() {
    test_gemv_helper(real(32));
    test_gemv_helper(real(64));
    test_gemv_helper(complex(64));
    test_gemv_helper(complex(128));
}


proc test_ger() {
    test_ger_helper(real(32));
    test_ger_helper(real(64));
}


proc test_gerc() {
    test_gerc_helper(complex(64));
    test_gerc_helper(complex(128));
}


proc test_geru() {
    test_geru_helper(complex(64));
    test_geru_helper(complex(128));
}


proc test_hbmv() {
    test_hbmv_helper(complex(64));
    test_hbmv_helper(complex(128));
}


proc test_hemv() {
    test_hemv_helper(complex(64));
    test_hemv_helper(complex(128));
}


proc test_her() {
    test_her_helper(complex(64));
    test_her_helper(complex(128));
}


proc test_her2() {
    test_her2_helper(complex(64));
    test_her2_helper(complex(128));
}


proc test_hpmv() {
    test_hpmv_helper(complex(64));
    test_hpmv_helper(complex(128));
}


proc test_hpr() {
    test_hpr_helper(complex(64));
    test_hpr_helper(complex(128));
}


proc test_hpr2() {
    test_hpr2_helper(complex(64));
    test_hpr2_helper(complex(128));
}


proc test_sbmv() {
    test_sbmv_helper(real(32));
    test_sbmv_helper(real(64));
}


proc test_spmv() {
    test_spmv_helper(real(32));
    test_spmv_helper(real(64));
}


proc test_spr() {
    test_spr_helper(real(32));
    test_spr_helper(real(64));
}


proc test_spr2() {
    test_spr2_helper(real(32));
    test_spr2_helper(real(64));
}


proc test_symv() {
    test_symv_helper(real(32));
    test_symv_helper(real(64));
}


proc test_syr() {
    test_syr_helper(real(32));
    test_syr_helper(real(64));
}


proc test_syr2() {
    test_syr2_helper(real(32));
    test_syr2_helper(real(64));
}


proc test_tbmv() {
    //test_tbmv_helper(real(32));
    test_tbmv_helper(real(64));
    //test_tbmv_helper(complex(64));
    //test_tbmv_helper(complex(128));
}


proc test_tbsv() {
    test_tbsv_helper(real(32));
    test_tbsv_helper(real(64));
    test_tbsv_helper(complex(64));
    test_tbsv_helper(complex(128));
}


proc test_trmv() {
    test_trmv_helper(real(32));
    test_trmv_helper(real(64));
    test_trmv_helper(complex(64));
    test_trmv_helper(complex(128));
}


proc test_trsv() {
    //test_trsv_helper(real(32));
    test_trsv_helper(real(64));
    //test_trsv_helper(complex(64));
    //test_trsv_helper(complex(128));
}


//
// Helpers
//

proc test_gbmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sgbmv".format(blasPrefix(t));

  // Simple test
  {
    const m = 3 : c_int,
          n = 3 : c_int;

    // Square
    var A : [{0.. #m, 0.. #n}]t,
        X : [{0.. #n}]t,
        Y : [{0.. #m}]t,
        R : [{0.. #m}]t; // Result

    //var rngint = makeRandomStream(eltType=int,algorithm=RNG.PCG);
    //var kl = rng.getNext(0, min(m, n)) ,
    //    ku = rng.getNext(0, min(m, n)) ;


    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);
    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);

    // Make A block-diagonal
    for (i, j) in A.domain {
      if i != j then A[i, j] = 0: t;
    }


    const kl = 0,
          ku = 0;

    // band-diagonal representation
    var a = bandArray(A, kl, ku);
    var b = transpose(a);

    writeln(A);
    writeln(a);
    writeln(X);
    writeln(Y);

    const alpha = 1: t;//rng.getNext();
    const beta = 1: t;//rng.getNext();

    // Compute Result vector
    for i in R.domain {
      var tmp = 0: t;
      for j in X.domain do tmp += A[i, j]*X[j];
      R[i] = beta*Y[i] + alpha*tmp;
    }

    //R[i] = beta*Y[i] + alpha*(+ reduce (A[i,..]*X[..]));
    writeln(R);

    gbmv(b, X, Y, alpha, beta, order=Order.Col);

    writeln(Y);

    var err = max reduce abs(Y-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);
  }
  printErrors(name, passed, failed, tests);
}


proc test_gemv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sgemv".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    // Square
    var A : [{0.. #m, 0.. #m}]t,
        X : [{0.. #m}]t,
        Y : [{0.. #m}]t,
        R : [{0.. #m}]t; // Result


    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);
    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);

    const alpha = rng.getNext();
    const beta = rng.getNext();

    // Compute Result vector
    for i in R.domain {
      R[i] = beta*Y[i] + alpha*(+ reduce (A[i,..]*X[..]));
    }

    gemv(A, X, Y, alpha, beta);

    var err = max reduce abs(Y-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);
  }
  printErrors(name, passed, failed, tests);
}


proc test_ger_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sger".format(blasPrefix(t));

  // Simple test
  {

    // Square case
    const m = 10 : c_int,
          n = 10 : c_int;

    var A : [{0.. #m, 0.. #n}] t,
        X : [{0.. #m}]t,
        Y : [{0.. #n}]t,
        R : [{0.. #m, 0..#n}] t; // Result


    // Populate values
    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);
    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);
    const alpha = rng.getNext();

    // Precompute result
    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*Y[j];
      }
    }
    R += A;

    ger(A, X, Y, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);
  }
  printErrors(name, passed, failed, tests);
}


proc test_gerc_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sgerc".format(blasPrefix(t));

  // Simple test
  {
    // Square case
    const m = 10 : c_int,
          n = 10 : c_int;

    var A : [{0.. #m, 0.. #n}] t,
        X : [{0.. #m}]t,
        Y : [{0.. #n}]t,
        R : [{0.. #m, 0..#n}] t; // Result


    // Populate values
    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);
    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);
    var alpha = rng.getNext();

    // Precompute result
    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*conjg(Y[j]);
      }
    }
    R += A;

    gerc(A, X, Y, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_geru_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sgeru".format(blasPrefix(t));
  // Simple test
  {
    // Square case
    const m = 10 : c_int,
          n = 10 : c_int;

    var A : [{0.. #m, 0.. #n}] t,
        X : [{0.. #m}]t,
        Y : [{0.. #n}]t,
        R : [{0.. #m, 0..#n}] t; // Result


    // Populate values
    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);
    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);
    var alpha = rng.getNext();

    // Precompute result
    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*Y[j];
      }
    }
    R += A;

    geru(A, X, Y, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }

  printErrors(name, passed, failed, tests);
}


proc test_hbmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%shbmv".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_hemv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%shemv".format(blasPrefix(t));
  // Simple test
  {
    //const m = 10 : c_int;
    const m = 2 : c_int;

    var A : [0.. #m, 0.. #m] t,
        X : [0.. #m] t,
        Y : [0.. #m] t,
        R : [0.. #m] t; // Result


    // Populate values
    var rng = makeRandomStream(eltType=t, algorithm=RNG.PCG);

    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);

    var alpha = rng.getNext(),
        beta = rng.getNext();

    makeHerm(A);

    // Precompute result
    for i in A.domain.dims()[2] {
      for j in A.domain.dims()[1] {
        R[i] += alpha*A[i, j]*X[j];
      }
    }

    R += beta*Y;

    hemv(A, X, Y, alpha, beta);

    var err = max reduce abs(Y-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_her_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sher".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}]t,
        R : [{0.. #m, 0..#m}] t; // Result

    var alphacomplex = rng.getNext(),
        alpha = alphacomplex.re;
    rng.fillRandom(A);
    rng.fillRandom(X);

    makeHerm(A);

    // Precompute result
    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*conjg(X[j]);
      }
    }
    R += A;

    // Resulting 'A' is only stored in upper triangular array
    zeroTri(A);
    zeroTri(R);

    her(A, X, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_her2_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sher2".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        Y : [{0.. #m}] t,
        R : [{0.. #m, 0..#m}] t; // Result

    var alpha = rng.getNext();
    rng.fillRandom(A);
    rng.fillRandom(X);

    makeHerm(A);

    // Precompute result
    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*conjg(Y[j]) + conjg(alpha)*Y[i]*conjg(Y[j]);
      }
    }
    R += A;

    // A result is only stored in upper triangular array
    zeroTri(A);
    zeroTri(R);

    her2(A, X, Y, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_hpmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%shpmv".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_hpr_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%shpr".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_hpr2_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%shpr2".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_sbmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%ssbmv".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_spmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sspmv".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_spr_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sspr".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_spr2_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%sspr2".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_symv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%ssymv".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        Y : [{0.. #m}] t,
        R : [{0.. #m}] t; // Result

    var alpha = rng.getNext(),
        beta = rng.getNext();

    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);

    makeSymm(A);

    // Precompute result
    for i in R.domain {
      R[i] = beta*Y[i] + alpha*(+ reduce (A[i,..]*X[..]));
    }

    // A result is only stored in upper triangular array
    zeroTri(A);

    symv(A, X, Y, alpha, beta);

    var err = max reduce abs(Y-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_syr_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%ssyr".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        R : [A.domain] t; // Result

    var alpha = rng.getNext();

    rng.fillRandom(A);
    rng.fillRandom(X);

    makeSymm(A);

    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*conjg(X[j]);
      }
    }

    R += A;

    // A result is only stored in upper triangular array
    zeroTri(R);
    zeroTri(A);

    syr(A, X, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_syr2_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%ssyr2".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        Y : [{0.. #m}] t,
        R : [A.domain] t; // Result

    var alpha = rng.getNext();

    rng.fillRandom(A);
    rng.fillRandom(X);
    rng.fillRandom(Y);

    makeSymm(A);

    for i in R.domain.dims()[1] {
      for j in R.domain.dims()[2] {
        R[i, j] = alpha*X[i]*conjg(Y[j]) + conjg(alpha)*Y[i]*conjg(X[j]);
      }
    }

    R += A;

    // A result is only stored in upper triangular array
    zeroTri(R);
    zeroTri(A);

    syr2(A, X, Y, alpha);

    var err = max reduce abs(A-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);


  }
  printErrors(name, passed, failed, tests);
}


proc test_tbmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%stbmv".format(blasPrefix(t));
  // TODO - try simple integers, and figure out what routine is doing differently
  // Simple test
  {
    const m = 5 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        R : [X.domain] t; // Result

    //rng.fillRandom(A);
    A = 1 : t;
    //rng.fillRandom(X);
    X = 1 : t;

    const k = m-1: c_int;

    // Triangulate Matrix
    zeroTri(A);

    // Create band matrix
    var AB = bandArrayTriangular(A, k, uplo=Uplo.Upper);
    //var AB = bandArray(A, k, 0);
    //A = bandArrayDense(AB, k, 0, m, m);

    // Precompute result
    for i in R.domain {
      R[i] = + reduce (A[i,..]*X[..]);
    }

    writeln('A:\n', A);
    writeln('AB:\n', AB);
    writeln('X input: ', X);

    tbmv(AB, X, k);

    writeln('X output: ', X);
    writeln('R output: ', R);

    var err = max reduce abs(X-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);


  }
  printErrors(name, passed, failed, tests);
}


proc test_tbsv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%stbsv".format(blasPrefix(t));
  // Simple test
  {

  }
  printErrors(name, passed, failed, tests);
}


proc test_trmv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%strmv".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        R : [X.domain] t; // Result

    rng.fillRandom(A);
    rng.fillRandom(X);

    // A result is only stored in upper triangular array
    zeroTri(A);

    for i in A.domain.dims()[2] {
      for j in A.domain.dims()[1] {
        R[i] += A[i, j]*X[j];
      }
    }


    trmv(A, X);

    var err = max reduce abs(X-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}


proc test_trsv_helper(type t){
  var passed = 0,
      failed = 0,
      tests = 0;
  const errorThreshold = blasError(t);
  var name = "%strsv".format(blasPrefix(t));
  // Simple test
  {
    const m = 10 : c_int;

    var rng = makeRandomStream(eltType=t,algorithm=RNG.PCG);

    var A : [{0.. #m, 0.. #m}] t,
        X : [{0.. #m}] t,
        R : [X.domain] t; // Result


    rng.fillRandom(A);
    rng.fillRandom(X);

    // Make A a triangular matrix
    zeroTri(A);

    // Store X
    const Xsave = X;

    trsv(A, X);

    for i in A.domain.dims()[2] {
      for j in A.domain.dims()[1] {
        R[i] += A[i, j]*X[j];
      }
    }

    var err = max reduce abs(Xsave-R);

    trackErrors(name, err, errorThreshold, passed, failed, tests);

  }
  printErrors(name, passed, failed, tests);
}
