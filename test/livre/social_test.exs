defmodule Livre.SocialTest do
  use LivreTest.DataCase, async: true
  import LivreTest.Factory
  alias Livre.Repo.User
  alias Livre.Social
  doctest Livre.Social
end
