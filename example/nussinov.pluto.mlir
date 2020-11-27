#map0 = affine_map<(d0)[s0] -> (-d0 + s0 - 1)>
#map1 = affine_map<(d0) -> (d0 + 1)>
#map2 = affine_map<(d0) -> (d0)>
#map3 = affine_map<()[s0] -> (s0)>
#map4 = affine_map<() -> (0)>
#map5 = affine_map<(d0, d1) -> (d0, d1)>
#map6 = affine_map<(d0, d1) -> (d0, d1 - 1)>
#map7 = affine_map<(d0, d1) -> (d0 + 1, d1)>
#map8 = affine_map<(d0, d1) -> (d0 + 1, d1 - 1)>
#map9 = affine_map<(d0)[s0] -> (-d0 + s0)>
#map10 = affine_map<(d0) -> (d0 - 1)>
#map11 = affine_map<(d0, d1)[s0] -> (d0 * 32, -d1 + s0 + 1)>
#map12 = affine_map<(d0)[s0] -> (s0 - 1, d0 * 32 + 31)>
#map13 = affine_map<(d0, d1)[s0] -> (2, d0 * 32, d1 * -32 + s0 - 30)>
#map14 = affine_map<(d0)[s0] -> (0, (d0 * -32 + s0 - 61) ceildiv 32)>
#map15 = affine_map<()[s0] -> ((s0 - 1) floordiv 32)>

#set0 = affine_set<(d0) : (d0 - 1 >= 0)>
#set1 = affine_set<(d0)[s0] : (-d0 + s0 - 2 >= 0)>
#set2 = affine_set<(d0, d1) : (d1 - d0 - 2 >= 0)>
#set3 = affine_set<()[s0] : ((s0 + 2) mod 32 == 0)>
#set4 = affine_set<(d0)[s0] : (d0 - (s0 - 62) floordiv 32 == 0)>
#set5 = affine_set<(d0, d1, d2)[s0, s1] : (d0 - (d1 * -32 + s0 - 31) floordiv 32 == 0, d2 - (s1 floordiv 32 - 1) == 0)>
#set6 = affine_set<(d0, d1)[s0] : (d0 == 0, d1 - (s0 - 31) ceildiv 32 == 0)>
#set7 = affine_set<(d0, d1)[s0] : (d0 - (-d1 + s0) floordiv 32 == 0)>

module {
  func @max_score(%arg0: i32, %arg1: i32) -> i32 {
    %0 = cmpi "sge", %arg0, %arg1 : i32
    %1 = select %0, %arg0, %arg1 : i32
    return %1 : i32
  }
  func @match(%arg0: i8, %arg1: i8) -> i32 {
    %c0_i32 = constant 0 : i32
    %c1_i32 = constant 1 : i32
    %c3_i8 = constant 3 : i8
    %0 = addi %arg0, %arg1 : i8
    %1 = cmpi "eq", %0, %c3_i8 : i8
    %2 = select %1, %c1_i32, %c0_i32 : i32
    return %2 : i32
  }
  func @pb_nussinov(%arg0: memref<?xi8>, %arg1: memref<?x?xi32>) {
    %c0 = constant 0 : index
    %0 = dim %arg0, %c0 : memref<?xi8>
    affine.for %arg2 = 0 to %0 {
      %1 = affine.apply #map0(%arg2)[%0]
      affine.for %arg3 = #map1(%1) to %0 {
        affine.if #set0(%arg3) {
          call @S0(%arg1, %arg3, %arg2, %0) : (memref<?x?xi32>, index, index, index) -> ()
        }
        affine.if #set1(%1)[%0] {
          call @S1(%arg1, %arg3, %arg2, %0) : (memref<?x?xi32>, index, index, index) -> ()
        }
        affine.if #set0(%arg3) {
          affine.if #set1(%1)[%0] {
            affine.if #set2(%1, %arg3) {
              call @S2(%arg1, %arg3, %arg2, %0, %arg0) : (memref<?x?xi32>, index, index, index, memref<?xi8>) -> ()
            } else {
              call @S3(%arg1, %arg3, %arg2, %0) : (memref<?x?xi32>, index, index, index) -> ()
            }
          }
        }
        affine.for %arg4 = #map1(%1) to #map2(%arg3) {
          call @S4(%arg1, %arg3, %arg2, %0, %arg4) : (memref<?x?xi32>, index, index, index, index) -> ()
        }
      }
    }
    return
  }
  func @S0(%arg0: memref<?x?xi32>, %arg1: index, %arg2: index, %arg3: index) attributes {scop.stmt} {
    %0 = affine.apply #map0(%arg2)[%arg3]
    %1 = affine.load %arg0[%0, %arg1] : memref<?x?xi32>
    %2 = affine.load %arg0[%0, %arg1 - 1] : memref<?x?xi32>
    %3 = call @max_score(%1, %2) : (i32, i32) -> i32
    affine.store %3, %arg0[%0, %arg1] : memref<?x?xi32>
    return
  }
  func @S1(%arg0: memref<?x?xi32>, %arg1: index, %arg2: index, %arg3: index) attributes {scop.stmt} {
    %0 = affine.apply #map0(%arg2)[%arg3]
    %1 = affine.load %arg0[%0, %arg1] : memref<?x?xi32>
    %2 = affine.load %arg0[%0 + 1, %arg1] : memref<?x?xi32>
    %3 = call @max_score(%1, %2) : (i32, i32) -> i32
    affine.store %3, %arg0[%0, %arg1] : memref<?x?xi32>
    return
  }
  func @S2(%arg0: memref<?x?xi32>, %arg1: index, %arg2: index, %arg3: index, %arg4: memref<?xi8>) attributes {scop.stmt} {
    %0 = affine.load %arg4[%arg1] : memref<?xi8>
    %1 = affine.apply #map0(%arg2)[%arg3]
    %2 = affine.load %arg4[%1] : memref<?xi8>
    %3 = call @match(%2, %0) : (i8, i8) -> i32
    %4 = affine.load %arg0[%1 + 1, %arg1 - 1] : memref<?x?xi32>
    %5 = addi %4, %3 : i32
    %6 = affine.load %arg0[%1, %arg1] : memref<?x?xi32>
    %7 = call @max_score(%6, %5) : (i32, i32) -> i32
    affine.store %7, %arg0[%1, %arg1] : memref<?x?xi32>
    return
  }
  func @S3(%arg0: memref<?x?xi32>, %arg1: index, %arg2: index, %arg3: index) attributes {scop.stmt} {
    %0 = affine.apply #map0(%arg2)[%arg3]
    %1 = affine.load %arg0[%0, %arg1] : memref<?x?xi32>
    %2 = affine.load %arg0[%0 + 1, %arg1 - 1] : memref<?x?xi32>
    %3 = call @max_score(%1, %2) : (i32, i32) -> i32
    affine.store %3, %arg0[%0, %arg1] : memref<?x?xi32>
    return
  }
  func @S4(%arg0: memref<?x?xi32>, %arg1: index, %arg2: index, %arg3: index, %arg4: index) attributes {scop.stmt} {
    %0 = affine.load %arg0[%arg4 + 1, %arg1] : memref<?x?xi32>
    %1 = affine.apply #map0(%arg2)[%arg3]
    %2 = affine.load %arg0[%1, %arg4] : memref<?x?xi32>
    %3 = addi %2, %0 : i32
    %4 = affine.load %arg0[%1, %arg1] : memref<?x?xi32>
    %5 = call @max_score(%4, %3) : (i32, i32) -> i32
    affine.store %5, %arg0[%1, %arg1] : memref<?x?xi32>
    return
  }
  func @pb_nussinov_new(%arg0: memref<?x?xi32>, %arg1: memref<?xi8>) {
    %c0 = constant 0 : index
    %0 = dim %arg1, %c0 : memref<?xi8>
    affine.for %arg2 = 0 to #map15()[%0] {
      affine.if #set4(%arg2)[%0] {
        affine.if #set3()[%0] {
          call @S0(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
          call @S1(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
          call @S2(%arg0, %c0, %c0, %0, %arg1) : (memref<?x?xi32>, index, index, index, memref<?xi8>) -> ()
          call @S3(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
        }
      }
      affine.for %arg3 = max #map14(%arg2)[%0] to #map15()[%0] {
        affine.if #set5(%arg2, %arg3, %arg3)[%0, %0] {
          call @S0(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
          call @S1(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
          call @S2(%arg0, %c0, %c0, %0, %arg1) : (memref<?x?xi32>, index, index, index, memref<?xi8>) -> ()
          call @S3(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
        }
        affine.if #set6(%arg2, %arg3)[%0] {
          call @S0(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
          call @S1(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
          call @S2(%arg0, %c0, %c0, %0, %arg1) : (memref<?x?xi32>, index, index, index, memref<?xi8>) -> ()
          call @S3(%arg0, %c0, %c0, %0) : (memref<?x?xi32>, index, index, index) -> ()
        }
        affine.for %arg4 = max #map13(%arg2, %arg3)[%0] to min #map12(%arg2)[%0] {
          affine.if #set7(%arg3, %arg4)[%0] {
            call @S0(%arg0, %c0, %arg4, %0) : (memref<?x?xi32>, index, index, index) -> ()
            call @S1(%arg0, %c0, %arg4, %0) : (memref<?x?xi32>, index, index, index) -> ()
            call @S2(%arg0, %c0, %arg4, %0, %arg1) : (memref<?x?xi32>, index, index, index, memref<?xi8>) -> ()
            call @S3(%arg0, %c0, %arg4, %0) : (memref<?x?xi32>, index, index, index) -> ()
          }
          affine.for %arg5 = max #map11(%arg3, %arg4)[%0] to min #map12(%arg3)[%0] {
            call @S0(%arg0, %arg5, %arg4, %0) : (memref<?x?xi32>, index, index, index) -> ()
            call @S1(%arg0, %arg5, %arg4, %0) : (memref<?x?xi32>, index, index, index) -> ()
            call @S2(%arg0, %arg5, %arg4, %0, %arg1) : (memref<?x?xi32>, index, index, index, memref<?xi8>) -> ()
            call @S3(%arg0, %arg5, %arg4, %0) : (memref<?x?xi32>, index, index, index) -> ()
            affine.for %arg6 = #map9(%arg4)[%0] to #map10(%arg5) {
              call @S4(%arg0, %arg5, %arg4, %0, %arg6) : (memref<?x?xi32>, index, index, index, index) -> ()
            }
          }
        }
      }
    }
    return
  }
}
// [pluto] compute_deps (isl)
// [Pluto] After tiling:
// T(S1): (0, i0/32, 0/32, i1/32, i0, 0, i1, 0, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S2): (0, i0/32, 0/32, i1/32, i0, 0, i1, 1, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S3): (0, i0/32, 0/32, i1/32, i0, 0, i1, 2, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S4): (0, i0/32, 0/32, i1/32, i0, 0, i1, 3, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S5): (0, i0/32, 0/32, i1/32, i0, 0, i1, 4, i2, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, loop, scalar)

// t9 {loop with stmts: S5, }
// t7 {loop with stmts: S1, S2, S3, S4, S5, }
// t5 {loop with stmts: S1, S2, S3, S4, S5, }
// [Pluto] After tile scheduling:
// T(S1): (0, i0/32+0/32, 0/32, i1/32, i0, 0, i1, 0, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S2): (0, i0/32+0/32, 0/32, i1/32, i0, 0, i1, 1, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S3): (0, i0/32+0/32, 0/32, i1/32, i0, 0, i1, 2, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S4): (0, i0/32+0/32, 0/32, i1/32, i0, 0, i1, 3, 0, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, scalar, scalar)

// T(S5): (0, i0/32+0/32, 0/32, i1/32, i0, 0, i1, 4, i2, 0)
// loop types (scalar, loop, loop, loop, loop, scalar, loop, scalar, loop, scalar)
