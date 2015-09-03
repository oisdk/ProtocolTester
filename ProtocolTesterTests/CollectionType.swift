protocol FlexibleInitable : CollectionType {
  init<S : SequenceType where S.Generator.Element == Generator.Element>(_ s: S)
}

extension Array           : FlexibleInitable {}
extension ArraySlice      : FlexibleInitable {}
extension ContiguousArray : FlexibleInitable {}
extension Set             : FlexibleInitable {}
extension Dictionary      : FlexibleInitable {
  init<S : SequenceType where S.Generator.Element == Generator.Element>(_ s: S) {
    var result: [Key:Value] = [:]
    for (k, v) in s { result[k] = v }
    self = result
  }
}

import XCTest
import Foundation

private func randArs() -> [[Int]] {
  return (0..<10).map { n in
    (0..<n).map { _ in Int(arc4random_uniform(100000)) }
  }
}

extension FlexibleInitable where Generator.Element == Int {
  static func test() {
    testEmptyInit()
    testMultiPass()
  }
  static private func testEmptyInit() {
    let emptyArray: [Int] = []
    let emptySelf = Self(emptyArray)
    XCTAssert(emptySelf.isEmpty, "\nSelf initialized to empty was not empty. Contents were: \(Array(emptySelf))")
  }
  static private func testMultiPass() {
    for randAr in randArs() {
      let seq = Self(randAr)
      let first = Array(seq)
      let secnd = Array(seq)
      XCTAssert(first.elementsEqual(secnd), "\nFirst pass over self did not equal second pass over self\nFirst pass: \(first)\nSecond pass: \(secnd)")
    }
  }
}

protocol SameNumberUniques : FlexibleInitable {}

extension Array           : SameNumberUniques {}
extension ArraySlice      : SameNumberUniques {}
extension ContiguousArray : SameNumberUniques {}
extension Set             : SameNumberUniques {}
extension Dictionary      : SameNumberUniques {}

extension SameNumberUniques where Generator.Element == Int {
  static func test() {
    testEmptyInit()
    testMultiPass()
    testCount()
    testSeqInit()
  }
  static private func testCount() {
    for randSet in randArs().map(Set.init) {
      let seq = Self(randSet)
      XCTAssertEqual(randSet.count, Array(seq).count, "Did not contain the same number of elements as the unique collection of elements self was initialized to.\nUnique elements: \(randSet)\nSelf: \(Array(seq))")
    }
  }
  static private func testSeqInit() {
    for randSet in randArs().map(Set.init) {
      let seq = Self(randSet)
      let expectation = randSet.sort()
      let reality     = seq.sort()
      XCTAssert(expectation.elementsEqual(reality), "Self did not contain the same elements as the set it was initialized from.\nSet: \(expectation)\nSelf: \(reality)")
    }
  }
}

protocol SameOrder : SameNumberUniques {}

extension Array           : SameOrder {}
extension ArraySlice      : SameOrder {}
extension ContiguousArray : SameOrder {}

extension SameOrder where Generator.Element == Int, SubSequence.Generator.Element == Int {
  static func test() {
    testEmptyInit()
    testMultiPass()
    testCount()
    testSeqInit()
    testSameEls()
    testIndexing()
    testFirst()
    testRangeIndexing()
    testSplit()
  }
  static private func testSameEls() {
    for randAr in randArs() {
      let seq = Self(randAr)
      XCTAssert(randAr.elementsEqual(seq), "Did not contain the same elements as the array self was initialized from.\nArray: \(randAr)\nSelf: \(seq)")
    }
  }
  static private func testIndexing() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        XCTAssertEqual(randAr[iA], seq[iS], "Did not have correct element at index. \nExpected: \(randAr[iA])\nFound: \(seq[iS])\nFrom array: \(randAr)")
      }
    }
  }
  static private func testFirst() {
    for randAr in randArs() {
      let seq = Self(randAr)
      XCTAssert(seq.first == randAr.first, "first property did non return as expected.\nExpected: \(randAr.first)\nReceived: \(seq.first)\nFrom array: \(randAr)")
    }
  }
  static private func testRangeIndexing() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for (iA, iS) in zip(randAr.indices, seq.indices) {
        for (jA, jS) in zip(iA..<randAr.endIndex, iS..<seq.endIndex) {
          let arSlice  = randAr[iA...jA]
          let seqSlice = seq[iS...jS]
          XCTAssert(arSlice.elementsEqual(seqSlice), "Slice did not match corresponding array slice.\nExpected: \(arSlice)\nReceived: \(seqSlice)\nFrom array: \(randAr)")
        }
      }
    }
  }
  static private func testSplit() {
    for randAr in randArs() {
      let seq = Self(randAr)
      for maxSplit in randAr.indices {
        for allow in [true, false] {
          let splitFuncs: [Int -> Bool] = (0..<5).map { _ in
            let n = Int(arc4random_uniform(10))
            let splitFunc: Int -> Bool = { i in i % n == 0 }
            return splitFunc
          }
          for splitFunc in splitFuncs {
            let splittedAr = randAr.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            let splittedSeq = seq.split(maxSplit, allowEmptySlices: allow, isSeparator: splitFunc)
            XCTAssertEqual(splittedAr.count, splittedSeq.count, "Different number of splits returned.\nExpected: \(splittedAr)\nReceived: \(splittedSeq.map(Array.init))")
            for (arSl, seqSl) in zip(splittedAr, splittedSeq) {
              XCTAssert(arSl.elementsEqual(seqSl), "Slices did not match.\nExpected: \(arSl)\nReceived: \(seqSl)")
            }
          }
        }
      }
    }
  }
}
