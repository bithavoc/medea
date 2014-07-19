import medea;
import std.json;
import std.stdio;

unittest {
    q{
    ===
    medea JSON Objects Unit Tests
    ===
    }.writeln;

    {
        Value value = parse(q{
                "23"
        });
        assert(typeid(value) is typeid(StringValue), "value should be StringValue");
        assert((cast(StringValue)value).text == "23");
        value = parse(q{
                23
        });
        assert(typeid(value) is typeid(IntegerValue), "value should be IntegerValue");
        assert((cast(IntegerValue)value).number == 23);

        value = parse(q{
                34.5
        });
        assert(typeid(value) is typeid(FloatValue), "value should be FloatValue");

        value = parse(q{
                true
        });
        assert(typeid(value) is typeid(BoolValue), "value should be BoolValue");
        BoolValue bv = cast(BoolValue)value;
        assert(bv.boolean, "Value should be true");

        value = parse(q{
                false
        });
        assert(typeid(value) is typeid(BoolValue), "value should be BoolValue");
        bv = cast(BoolValue)value;
        assert(!bv.boolean, "Value should be false");

        value = parse(q{
                {
                    "i": 23,
                    "f": 23.4,
                    "s": "hello",
                    "o": {
                        "i": 10
                    },
                    "a": [23, "some textoo"],
                    "n": null
                }
        });
        assert(typeid(value) is typeid(ObjectValue), "value should be ObjectValue");
        ObjectValue obj = cast(ObjectValue)value;
        assert(obj.properties.length == 6, "object should have at least 6 properties");
        assert(typeid(obj.properties["i"]) is typeid(IntegerValue), "property i should be an integer value");
        assert(typeid(obj.properties["f"]) is typeid(FloatValue), "property f should be a float value");
        assert(typeid(obj.properties["s"]) is typeid(StringValue), "property s should be a string value");
        assert(typeid(obj.properties["o"]) is typeid(ObjectValue), "property o should be an object value");
        assert(typeid(obj.properties["a"]) is typeid(ArrayValue), "property a should be an object value");
        assert(typeid(obj.properties["n"]) is typeid(NullValue), "property a should be a null value");
    }
    {
        StringValue value = new StringValue("hello world");
        JSONValue val = value.toJSONValue();
        assert(val.type == JSON_TYPE.STRING, ".value type should be STRING");
        assert(val.str == "hello world", ".str should contain the string");
    }
    {
        IntegerValue value = new IntegerValue(234);
        JSONValue val = value.toJSONValue();
        assert(val.type == JSON_TYPE.INTEGER, ".value type should be INTEGER");
        assert(val.integer == 234, ".integer should contain the number");
    }
    {
        FloatValue value = new FloatValue(234.6);
        JSONValue val = value.toJSONValue();
        assert(val.type == JSON_TYPE.FLOAT, ".value type should be FLOAT");
        assert(val.floating == 234.6, ".floating should contain the number");
    }
    {
        Value[] items;
        items ~= new IntegerValue(29);
        items ~= new FloatValue(30.4);
        items ~= new StringValue("hello world");
        ArrayValue value = new ArrayValue(items);
        JSONValue val = value.toJSONValue();
        assert(val.type == JSON_TYPE.ARRAY, ".type should be ARRAY");
        assert(val.array.length == 3, ".array should contain 3 items");
    }
    {
        NullValue value = new NullValue();
        JSONValue val = value.toJSONValue();
        assert(val.type == JSON_TYPE.NULL, ".value type should be NULL");
    }
    {
        Value[string] values;
        values["i"] = new IntegerValue();
        values["f"] = new FloatValue();
        values["s"] = new StringValue();
        values["o"] = new ObjectValue();
        values["a"] = new ArrayValue();
        ObjectValue value = new ObjectValue(values);
        JSONValue val = value.toJSONValue();
        assert(val.type == JSON_TYPE.OBJECT, ".value type should be OBJECT");
        assert(val.object.length == 5, ".object should contain 5 properties");
    }
    {
        void assertType(T, V)(V val) {
            T v = cast(T)val;
            assert(v, std.conv.text(T.stringof, " expected but ", typeid(val), " was found instead"));
        }
        assertType!IntegerValue(20.toValue());
        assertType!FloatValue(20.3.toValue());
        assertType!StringValue("hello world".toValue());
        assertType!ArrayValue([cast(Value)new IntegerValue(20)].toValue());
        assertType!ObjectValue(["fav_number": cast(Value)new IntegerValue(20)].toValue());
        assertType!BoolValue(true.toValue());
        assertType!BoolValue(false.toValue());
    }
    {
        Value val = parse(q{
                {
                    "firstName": "Bit",
                    "lastName": "Havoc"
                } 
                });
        ObjectValue obj = cast(ObjectValue)val;

        assert("firstName" in obj, "ObjectValue should report the property as existent");
        assert("unknownStuff" !in obj, "ObjectValue should NOT report the property as existent");

        StringValue firstName = cast(StringValue)obj.properties["firstName"];
        assert(firstName, "property should not be returned as null");

        Value stuff = obj["stuff"];
        assert(!stuff, "property should be returned as null");

    }
    {
        Value val = parse(q{
                [50, "hello"]
                });
        ArrayValue obj = cast(ArrayValue)val;
        assert(obj.items.length == 2, "array should contain 2 items");
        IntegerValue fifty = cast(IntegerValue)obj[0];
        assert(fifty.number == 50, "number should be 50");

        StringValue hello = cast(StringValue)obj[1];
        assert(hello.text == "hello", "text should be 'hello'");

        Value outOfRangeItem = obj[10];
        assert(!outOfRangeItem, "not in range items should be null");
    }
    {
        Value val = parse(q{
                [50, "hello"]
                });
        string valStr = val.toJSONString();
        assert(valStr == `[50,"hello"]`, "formatted json doesnt match");
    }
    {
        ObjectValue obj = new ObjectValue();
        obj["hello"] = new StringValue("world");
        string valStr = obj.toJSONString();
        assert(valStr == `{"hello":"world"}`, "property was not set in object");
    }
    {
        ArrayValue obj = new ArrayValue([cast(Value)new IntegerValue(20)]);
        obj[0] = new StringValue("world");
        string valStr = obj.toJSONString();
        assert(valStr == `["world"]`, "index was not set in array");
    }
}
