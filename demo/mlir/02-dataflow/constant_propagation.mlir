

func @example(%arg0 : i32, %arg1 : i32) -> i32 {
  %c1 = arith.constant 42 : i32
  %c2 = arith.constant 58 : i32
  %sum = arith.addi %c1, %c2 : i32
  %result = arith.addi %sum, %arg0 : i32
  return %result : i32
}