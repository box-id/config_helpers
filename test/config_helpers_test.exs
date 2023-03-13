defmodule ConfigHelperTests do
  use ExUnit.Case
  doctest ConfigHelpers

  import ConfigHelpers

  setup do
    set_process_env(:dev)

    on_exit(fn ->
      System.delete_env("FOO_TEST")
    end)
  end

  describe "get_env with defaults" do
    test "gets env-specific default" do
      set_process_env(:dev)
      assert "some-default" == get_env("FOO_TEST", dev: "some-default")

      assert_raise ConfigHelpers.EnvError, fn ->
        set_process_env(:test)
        get_env("FOO_TEST", dev: "localhost")
      end
    end

    test "falls back to generic default" do
      set_process_env(:dev)
      assert "dev-default" == get_env("FOO_TEST", dev: "dev-default", default: "generic-default")

      set_process_env(:test)

      assert "generic-default" ==
               get_env("FOO_TEST", dev: "dev-default", default: "generic-default")
    end

    test "supports generic default shorthand that works in all envs" do
      for env <- [:dev, :test, :prod] do
        set_process_env(env)
        assert "generic-default" == get_env("FOO_TEST", "generic-default")
      end
    end

    test "supports `non_prod` pseudo-env" do
      set_process_env(:dev)
      assert "localhost" == get_env("FOO_TEST", non_prod: "localhost")

      set_process_env(:test)
      assert "localhost" == get_env("FOO_TEST", non_prod: "localhost")

      assert_raise ConfigHelpers.EnvError, fn ->
        set_process_env(:prod)
        get_env("FOO_TEST", non_prod: "localhost")
      end
    end

    test "spcific env take precedence over `non_prod`" do
    end
  end

  describe "get_env with as: integer" do
    test "supports casting env value to integer" do
      System.put_env("FOO_TEST", "10")
      assert 10 == get_env("FOO_TEST", as: :integer)

      System.put_env("FOO_TEST", "-42")
      assert -42 == get_env("FOO_TEST", as: :integer)

      assert_raise ArgumentError, fn ->
        System.put_env("FOO_TEST", "")
        get_env("FOO_TEST", as: :integer)
      end

      assert_raise ArgumentError, fn ->
        System.put_env("FOO_TEST", "foo")
        get_env("FOO_TEST", as: :integer)
      end
    end

    test "supports casting default values to integer" do
      assert 42 == get_env("FOO_TEST", "42", as: :integer)

      set_process_env(:dev)
      assert 42 == get_env("FOO_TEST", dev: "42", as: :integer)
    end

    test "supports passing through integer default values" do
      assert 42 == get_env("FOO_TEST", 42, as: :integer)

      set_process_env(:dev)
      assert 42 == get_env("FOO_TEST", dev: 42, as: :integer)
    end

    test "automatically casts to integer if default is given as integer" do
      System.put_env("FOO_TEST", "42")

      set_process_env(:dev)

      assert "42" == get_env("FOO_TEST", "12")
      assert 42 == get_env("FOO_TEST", 12)
      assert 42 == get_env("FOO_TEST", prod: 12)
    end
  end

  describe "get_env with as: boolean" do
    test "supports casting env value to boolean" do
      System.put_env("FOO_TEST", "")
      assert false == get_env("FOO_TEST", as: :boolean)

      System.put_env("FOO_TEST", "meh")
      assert false == get_env("FOO_TEST", as: :boolean)

      System.put_env("FOO_TEST", "true")
      assert true == get_env("FOO_TEST", as: :boolean)
    end

    test "supports casting default values to boolean" do
      assert false == get_env("FOO_TEST", "false", as: :boolean)

      set_process_env(:dev)
      assert false == get_env("FOO_TEST", dev: "0", as: :boolean)

      assert true == get_env("FOO_TEST", non_prod: "1", as: :boolean)
    end

    test "supports passing through boolean default values" do
      set_process_env(:dev)
      assert false == get_env("FOO_TEST", dev: false, as: :boolean)

      assert true == get_env("FOO_TEST", non_prod: true, as: :boolean)
    end

    test "automatically casts to boolean if default is given as boolean" do
      System.put_env("FOO_TEST", "true")

      set_process_env(:dev)

      assert "true" == get_env("FOO_TEST", "true")
      assert true == get_env("FOO_TEST", false)
      assert true == get_env("FOO_TEST", prod: false)
    end
  end

  defp set_process_env(env) do
    Process.put({Config, :opts}, {env})

    on_exit(fn ->
      Process.delete({Config, :opts})
    end)
  end
end
