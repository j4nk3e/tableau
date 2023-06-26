defmodule Mix.Tasks.Tableau.LogExtension do
  use Tableau.Extension, type: :pre_build

  def run(_site) do
    IO.puts("hi!")
    :ok
  end
end

defmodule Mix.Tasks.Tableau.FailExtension do
  use Tableau.Extension, type: :pre_build

  def run(_site) do
    :error
  end
end

defmodule Mix.Tasks.Tableau.BuildTest.About do
  import Tableau.Strung
  require EEx
  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/about"

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div class="<%= @class %>">
      hi
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.Index do
  import Tableau.Strung
  require EEx
  alias Mix.Tasks.Tableau.BuildTest.InnerLayout

  def __tableau_type__, do: :page
  def __tableau_parent__, do: InnerLayout
  def __tableau_permalink__, do: "/"

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="home">
      Home page!
    </div>
    '''html,
    [:_assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.InnerLayout do
  import Tableau.Strung
  import Tableau.Document.Helper, only: [render: 2]
  require EEx
  alias Mix.Tasks.Tableau.BuildTest.RootLayout

  def __tableau_type__, do: :layout
  def __tableau_parent__, do: RootLayout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <div id="inner-layout">
      <%= render(@inner_content, class: "text-red") %>
    </div>
    '''html,
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest.RootLayout do
  import Tableau.Strung
  import Tableau.Document.Helper, only: [render: 1]
  require EEx
  def __tableau_type__, do: :layout

  EEx.function_from_string(
    :def,
    :template,
    ~g'''
    <html>
      <head></head>
      <body>
        <%= render @inner_content %>
      </body>
    </html>
    '''html,
    [:assigns]
  )
end

defmodule Mix.Tasks.Tableau.BuildTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import ExUnit.CaptureLog

  alias Mix.Tasks.Tableau.Build

  @tag :tmp_dir
  test "renders all pages", %{tmp_dir: out} do
    assert capture_io(fn ->
             assert capture_log(fn ->
                      _documents = Build.run(["--out", out])
                    end) =~ "FailExtension failed to run"
           end) =~ "hi!"

    assert File.exists?(Path.join(out, "/index.html"))
    assert File.exists?(Path.join(out, "/about/index.html"))
  end
end
