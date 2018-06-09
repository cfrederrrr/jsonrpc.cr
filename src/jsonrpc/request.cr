require "json"

# `Request` object to be sent to the JSONRPC server
#
# `P` can be of any type parsable by `JSON::PullParser` and buildable
# with `JSON::Builder`
#
# According to
# [https://www.jsonrpc.org/specification#request_object](JSONRPC 2.0),
# specification the params key should be any "structured value that holds
# the parameter values to be used during the invocation of the method"
#
# If the method you are invoking per `@method` is one which expects
# positional parameters, `P` should build to a JSON array
# Otherwise it should build to a JSON object
#
# The server implementation always uses Request(JSON::Any)
class JSONRPC::Request(P)
  alias RID = String | Int32 | Nil

  # A `String` specifying the RPC method to be invoked.
  getter method : String

  # An `Array` or `Hash` that holds the parameter arguments.
  # - `Array` means positional arguments
  # - `Hash` means named arguments
  # - Omitting this key means no arguments.
  getter params : P

  # An identifier established by the client. If `nil` or excluded, then
  # the client does not expect a response - this is known as a
  # "notification" according to JSON RPC 2.0 specification
  getter id : RID

  # A `String` indicating the JSONRPC version
  getter jsonrpc : String

  JSON.mapping(
    jsonrpc: {
      type: String,
      getter: false,
      setter: false,
      default: "2.0"
    },
    method: {
      type: String,
      getter: false,
      setter: false
    },
    params: {
      type: P,
      getter: false,
      setter: false,
      nilable: true,
      emit_null: false
    },
    id: {
      type: RID,
      getter: false,
      setter: false,
      nilable: true,
      emit_null: false
    }
  )

  # Clientside can create a new `Request(P)` with direct arguments, rather than with a pullparser
  #
  def initialize(@method, @params : P = nil, @id : RID = nil, @jsonrpc = "2.0")
     if @jsonrpc != "2.0"
       error = InvalidRequest.new("jsonrpc must be '2.0'")
       error.id = @id if @id
       raise error
     end
  end

  def self.new(parser : JSON::PullParser)
    raise InvalidRequest.new unless parser.kind == :begin_object
    args = {} of Symbol => String | P | RID | Nil
    invalid = false

    parser.read_object do |key|
      case
      when key == "method"
        args[:method] = String.new(parser)
      when key == "id"
        args[:id] = case parser.kind
          when :int then Int32.new(parser)
          when :string then String.new(parser)
          else
            invalid = InvalidRequest.new "id must be string or int"
          end
      when key == "params"
        args[:params] = P.new(parser)
      when key == "jsonrpc"
        args[:jsonrpc] = String.new(parser)
      else
        invalid = InvalidRequest.new "unrecognized member: '#{key}'"
      end
    end

    if invalid
      args[:id]? ? invalid.id = args[:id]
      raise invalid
    end

    return new(
      args[:method]?.as(String),
      args[:params]?.as(P),
      args[:id]?.as(RID),
      args[:jsonrpc]?.as(String)
    )
  end

end
