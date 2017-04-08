module fluentasserts.core.array;

public import fluentasserts.core.base;

import std.algorithm;
import std.conv;
import std.traits;
import std.range;
import std.array;

struct ShouldList(T : T[]) {
  private const T[] testData;

  mixin ShouldCommons;

  void equal(T)(const T[] valueList, const string file = __FILE__, const size_t line = __LINE__) {
    import fluentasserts.core.numeric;
    addMessage("equal");
    addMessage("`" ~ valueList.to!string ~ "`");
    beginCheck;

    valueList.each!(value => contain(value, file, line));

    foreach(i; 0..valueList.length) {
      try {
        valueList[i].should.equal(testData[i], file, line);
      } catch(TestException e) {
        auto index = testData.countUntil(valueList[i]) + 1;
        auto msg = "`" ~ testData[i].to!string ~ "` should be at index `" ~ i.to!string ~ "` not `" ~ index.to!string ~ "`";

        result(false, msg, file, line);
      }
    }
  }

  void contain(const T[] valueList, const string file = __FILE__, const size_t line = __LINE__) {
    addMessage("contain");
    addMessage("`" ~ valueList.to!string ~ "`");
    beginCheck;

    valueList.each!(value => contain(value, file, line));
  }

  void contain(const T value, const string file = __FILE__, const size_t line = __LINE__) {
    auto strVal = "`" ~ value.to!string ~ "`";

    addMessage("contain");
    addMessage(strVal);
    beginCheck;

    auto isPresent = testData.canFind(value);

    result(isPresent, strVal ~ (isPresent ? " is present" : " is not present") ~ " in `" ~ testData.to!string ~ "`", file, line);
  }
}

@("array contain")
unittest {
  should.not.throwAnyException({
    [1, 2, 3].should.contain([2, 1]);
  });

  should.not.throwAnyException({
    [1, 2, 3].should.contain(1);
  });

  should.throwException!TestException({
    [1, 2, 3].should.contain([4, 5]);
  }).msg.should.contain("`4` is not present");

  should.throwException!TestException({
    [1, 2, 3].should.contain(4);
  }).msg.should.contain("`4` is not present");
}

@("array equals")
unittest {
 [1, 2, 3].should.equal([1, 2, 3]);
 
  should.throwException!TestException({
    [1, 2, 3].should.equal([4, 5]);
  }).msg.should.contain("`4` is not present");

  should.throwException!TestException({
    [1, 2, 3].should.equal([2, 3, 1]);
  }).msg.should.contain("`1` should be at index `0` not `2`");
}
