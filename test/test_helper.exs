ExUnit.start()

defmodule CompileTimeAssertions do
  defmacro assert_compile_time_raise(expected_exception, expected_message, fun) do
    # from: https://gist.github.com/henrik/1054546364ac68da4102
    # At compile-time, the fun is in AST form and thus cannot raise.
    # At run-time, we will evaluate this AST, and it may raise.
    fun_quoted_at_runtime = Macro.escape(fun)

    quote do
      assert_raise unquote(expected_exception), unquote(expected_message), fn ->
        Code.eval_quoted(unquote(fun_quoted_at_runtime))
      end
    end
  end
end
