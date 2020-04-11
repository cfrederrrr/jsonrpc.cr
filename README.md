# jsonrpc.cr

[![Build Status](https://travis-ci.com/galvertez/jsonrpc.cr.svg?branch=master)](https://travis-ci.com/galvertez/jsonrpc.cr)

## Usage

### Serverside
For serverside `jsonrpc.cr` provides an abstract handler class `JSONRPC::Handler`.

It takes serialized `JSONRPC::Request` in, and puts out a serialized `JSONRPC::Response` out, but not before yielding the request and response wrapped up in a `JSONRPC::Context` which works much like the standard library's `HTTP::Context`, but with some enhancements, since more is known about the content ahead of time.

The macro `expose_rpc` should be the last line of its descendents, as it uses the `@[JRONRPC::Method("name")]` annotation to create a lookup table for methods by name. This enables you to keep code related to the handling of JSONRPC out of your method definitions. Simply annotate any method you want exposed and write/document your code normally.

The caveat is that in order for `expose_rpc` to work, you must specify the return type of the method in its definition, as in the example below.

```crystal
class CustomHandler < JSONRPC::Handler
  @[JSONRPC::Method("some method")]
  def some_method(params : ParamsType) : ResultType
    ResultType.new(params + 1)
  end

  @[JSONRPC::Method("some-other-method")]
  def some_other_method(other_params : OtherParams) : OtherResult
    OtherResult.new(other_params)
  end

  @[JSONRPC::Method("TheThirdMethod")]
  def the_third_method(third_params : ThirdParams) : ThirdResult
    ThirdResult.new(third_params + " x 3")
  end

  expose_rpc
end
```

Then to use it, pass the serialized request to the `handle(String)` method and the handler sorts out which method it should run based on the `"method"` key, yields the de-serialized request and response (mostly for logging purposes), and returns a serialized response.

```crystal
rpc_handler = CustomHandler.new
response = rpc_handler.handle(request.body)
```

Easy!

### Clientside
Clientside usage is very simple. Since the client isn't doing any of the work, all we need to know is the name of the method, params type, and the result type. We don't actually need to define any behavior - using the macro `rpcdef(name, params, result)` we can define methods on the client class

```crystal
class CustomClient < JSONRPC::Client
  rpcdef "some method", ParamsType, ResultType
  rpcdef "some-other-method", OtherParams, OtherResult
  rpcdef "TheThirdMethod", ThirdParams, ThirdResult
end
```

yields a client class with methods `some_method`, `some_other_method` and `the_third_method`

That is, the method name should match what the server is expecting to see, and the method's name will be transformed to a crystal-friendly version.

Lastly, you need to define how the request is submitted to the server - that is, if your RPC is strictly TCP, then you would use a TCP client, if it's over HTTP/S then you would use an HTTP client. This offers you the flexibility to use your favorite transport client, or whichever one fits your environment best.

That is, `jsonrpc.cr` does not impose a transport client on you.
