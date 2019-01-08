class JSON::PullParser

  # Replace the instance of `@lexer` with a new one. This is only implemented for use in
  # `#dup` and realistically has no other reason to exist. Don't use this method.
  protected def lexer=(@lexer : Lexer)
  end

  # Override of `JSON::PullParser#dup` so that `@lexer` is duped as well. This is somewhat a
  # violation of what `Object#dup` is supposed to do, but `@lexer` cannot be accessed except
  # internally. There is good reason for that, but in reality, the only reason to ever dup a
  # `JSON::PullParser` is to get a new instance of `@lexer` since the lexer is doing all the real
  # work. With standard behavior, the original and the duplicate share the same instance of
  # `@lexer` which is problematic when both parsers are using it at different times.
  def dup
    dupe = super
    dupe.lexer = @lexer.dup
    return dupe
  end
end
