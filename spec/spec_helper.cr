require "spec"
require "../src/json-rpc"

record SubtractionHelper, subtrahend : Int32, minuend : Int32 { include JSON::Serializable }
record SummationHelper, augend : Int32, addend : Int32 { include JSON::Serializable }
record UpdateHelper, state : Array(Int32) { include JSON::Serializable }

class InvalidJSON
  def to_json(io : IO)
    io << %<{"key": "value"]>
  end
end

class JSON::RPC::Spec::Handler < JSON::RPC::Handler
  getter logs : Array(JSON::RPC::Context)
  getter state : Array(Int32)

  def initialize
    @logs = [] of JSON::RPC::Context
    @state = UpdateHelper.new([0])
  end

  def notify
  end

  def log(context : Context)
    @logs.push(context) if context
  end

  @[JSON::RPC::Method("subtract")]
  def subtract(terms : Array(Int32)) : Int32
    minuend = terms.shift
    while terms.any?
      subtrahend = terms.shift
      minuend -= subtrahend
    end

    return minuend
  end

  @[JSON::RPC::Method("subtract")]
  def subtract(terms : SubtractionHelper) : Int32
    terms.minuend - terms.subtrahend
  end

  @[JSON::RPC::Method("sum")]
  def sum(terms : Array(Int32)) : Int32
    augend = terms.shift
    while terms.any?
      addend = terms.shift
      augend += addend
    end

    return augend
  end

  @[JSON::RPC::Method("sum")]
  def sum(terms : SummationHelper) : Int32
    terms.augend + terms.addend
  end

  @[JSON::RPC::Method("update")]
  def update(items : Array(Int32)) : Array(Int32)
    @state += items
    @state
  end
end

class JSON::RPC::Spec::Client < JSON::RPC::Client
  getter logs : Array(JSON::RPC::Context)

  # Gives control of handler to SpecClient. For the purpose of tests,
  # this is fine, but it would never happen like this in a real program
  def initialize(@handler : JSON::RPC::Handler)
    @logs = [] of JSON::RPC::Context
  end

  def log(context : Context? = nil)
    @log.push(context) if context
  end

  def submit_request(json)
    @handler.handle(json) do |context|
      printf %<Message from %s: "Handling %s">, Handler.inspect
      printf %<  Handling "%s">, context.request.method
      if context.error?
        printf %<  Error: "%s">, context.response.error
      elsif context.response.result
        printf %<  Result: "%s">, context.response.result
      end
    end
  end

  def submit_batch(json)
    json
  end

  rpc subtract,
    calls: "subtract",
    takes: {Array(Int32)},
    returns: Int32

  rpc subtract,
    calls: "subtract",
    takes: {subtrahend: Int32, minuend: Int32},
    returns: Int32

  rpc sum,
    calls: "sum",
    takes: {augend: Int32, addend: Int32},
    returns: Int32

  rpc sum,
    calls: "sum",
    takes: Array(Int32),
    returns: Int32

  rpc update,
    notifies: "update",
    takes: Array(Int32)

  rpc foobar,
    notifies: "foobar"

  def invalid_json
    req = %<{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]>
    res = submit_request(req)
    request = Request(Nil).new
    response = Response(Nil).new(res)
    context = Context(Nil, Nil).new(request, response)
    self.log(context)
    return response.result ? response.result : response.error
  end

  rpc invalid_json,
    calls: "non-viable-json",
    takes: InvalidJSON,
    returns: Int32
end

SpecHandler = JSON::RPC::Spec::Handler.new
SpecClient = JSON::RPC::Spec::Client.new SpecHandler
