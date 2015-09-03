# ProtocolTester #

This is a small framework to check that various types which conform to protocols do so correctly.

## CollectionTypes ##

There are three protocols here that you can make your protocol conform to, to enable easier testing. The first is `FlexibleInitable`: the only requirement is an initializer that takes a `SequenceType`. If your `CollectionType` will have the same number of unique elements as the `SequenceType` it was initialized from, make it conform to `SameNumberUniques`: this will allow testing of more properties. Finally, if your `CollectionType` will contain the same number of elements, in the same order (with possible duplicates) as the `SequenceType` it was initialized from, make it conform to `SameOrder`.

If there is some invariant in your type that should never be broken, add the `invariantPassed` property to your type, and it will be checked after every operation.

Then, to test, write: `MyType<Int>.test()`.

```swift
extension Deque : SameOrder {}
extension DequeSlice : SameOrder {}

extension Deque {
  var invariantPassed: Bool {
    return isBalanced
  }
}

extension DequeSlice {
  var invariantPassed: Bool {
    return isBalanced
  }
}

class DequeTests: XCTestCase {
  func testDeque() {
    Deque<Int>.test()
  }
  func testDequeSlice() {
    DequeSlice<Int>.test()
  }
}
```