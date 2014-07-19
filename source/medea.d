/*
 * Medea: Modern JSON for D
 */
module medea;

import std.json;
import std.traits;
import std.conv : text;

abstract class Value {
    public: 
        JSONValue toJSONValue();
}

string toJSONString(Value value, bool pretty = false) {
    JSONValue jval = value.toJSONValue();
    return (&jval).toJSON(pretty);
}

abstract class NumberValue : Value {
    
}

final class IntegerValue : NumberValue {
    private:
        long _n;
    public:
        this(in long n) {
            _n = n;
        }

        this() {
            this(0);
        }

        override JSONValue toJSONValue() {
            JSONValue v;
            v.integer = _n;
            return v;
        }
        @property long number() {
            return _n;
        }
}

final class UIntegerValue : NumberValue {
    private:
        ulong _n;
    public:
        this(in ulong n) {
            _n = n;
        }

        this() {
            this(0);
        }

        override JSONValue toJSONValue() {
            JSONValue v;
            v.uinteger = _n;
            return v;
        }
        @property ulong number() {
            return _n;
        }
}

final class FloatValue : NumberValue {
    private:
        real _n;
    public:
        this(in real n) {
            _n = n;
        }

        this() {
            this(0.0f);
        }

        override JSONValue toJSONValue() {
            JSONValue v;
            v.floating = _n;
            return v;
        }
        @property real number() {
            return _n;
        }
}

final class BoolValue : Value {
    private:
        bool _b;
    public:
        this(in bool b) {
            _b = b;
        }

        this() {
            this(false);
        }

        override JSONValue toJSONValue() {
            JSONValue v;
            v = _b;
            return v;
        }
        @property bool boolean() {
            return _b;
        }
}

final class StringValue : Value {
    private:
        string _str;

    public:
        this(in string str) {
            _str = str;
        }

        this() {
            this("");
        }

        override JSONValue toJSONValue() {
            JSONValue v;
            v.str = _str;
            return v;
        }

        @property string text() {
            return _str;
        }
}

final class ObjectValue : Value {
    private:
        Value[string] _values;

    public:
        this(Value[string] values) {
            _values = values;
        }

        this(JSONValue[string] values) {
            foreach(string name, ref JSONValue v; values) {
                this._values[name] = v.wrap();
            }
        }

        this() {

        }

        override JSONValue toJSONValue() {
            JSONValue v;
            JSONValue[string] props;
            foreach(string name, Value v; _values) {
                props[name] = v.toJSONValue();
            }
            v.object = props;
            return v;
        }

        @property Value[string] properties() {
            return _values;
        }

        auto opBinaryRight(string op : "in")(string k) const
        {
            return k in _values;
        }

        Value opIndex(string k)
        {
            if(k !in this) {
                return null;
            }
            return _values[k];
        }

        Value opIndexAssign(Value v, string k) {
            _values[k] = v;
            return v;
        }
}

final class ArrayValue : Value {
    private:
        Value[] _values;

    public:
        this(Value[] values) {
            _values = values;
        }

        this(JSONValue[] values) {
            foreach(ref JSONValue v; values) {
                this._values ~= v.wrap();
            }
        }

        this() {

        }

        override JSONValue toJSONValue() {
            JSONValue v;
            JSONValue[] items;
            foreach(ref Value i; _values) {
                items ~= i.toJSONValue();
            }
            v.array = items;
            return v;
        }

        @property Value[] items() {
            return _values;
        }

        Value opIndex(size_t i)
        {
            if(i > _values.length -1) {
                return null;
            }
            return _values[i];
        }
        Value opIndexAssign(Value v, size_t i) {
            _values[i] = v;
            return v;
        }
}

final class NullValue : Value {

    override JSONValue toJSONValue() {
        JSONValue v = null;
        return v;
    }
}

Value wrap(JSONValue value) {
    if(value == JSONValue.init) {
        return null;
    }
    switch(value.type) {
        case JSON_TYPE.STRING: {
            return new StringValue(value.str);
        }
        case JSON_TYPE.INTEGER: {
            return new IntegerValue(value.integer);
        }
        case JSON_TYPE.UINTEGER: {
            return new UIntegerValue(value.uinteger);
        }
        case JSON_TYPE.FLOAT: {
            return new FloatValue(value.floating);
        }
        case JSON_TYPE.OBJECT: {
            return new ObjectValue(value.object);
        }
        case JSON_TYPE.ARRAY: {
            return new ArrayValue(value.array);
        }
        case JSON_TYPE.NULL: {
            return new NullValue();
        }
        case JSON_TYPE.TRUE: {
            return new BoolValue(true);
        }
        case JSON_TYPE.FALSE: {
            return new BoolValue(false);
        }
        default:
            throw new Exception("Unknown JSON_TYPE");
    }
}

Value parse(string doc) {
    auto document = parseJSON(doc);  
    return document.wrap();
}

Value toValue(T)(T val) {
    static if(is(T: bool)) {
        return new BoolValue(val);
    }
    else static if(is(T : long)) {
        return new IntegerValue(val);
    } else static if(is(T: string)) {
        return new StringValue(val);
    } else static if(isFloatingPoint!(T)) {
        return new FloatValue(val);
    } else static if(isArray!(T)) {
        return new ArrayValue(val);
    } else static if(is(T : Value[Key], Key)) {
        static assert(is(Key : string), text("Key must be string but ", Key.stringof, " was given instead"));
        return new ObjectValue(val);
    } else {
        static assert(false, text(`unable to convert type "`, T.stringof, `" to json Value`));
    }
}

