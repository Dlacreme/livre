defmodule LivreWeb.TimelineLiveComponent do
  use LivreWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= for post <- @posts do %>
        <div class="mb-4">
          <div class="flex items-start">
            <a href={"/profile/#{post.user.id}"}>
              <img src={post.user.picture_url} height="50px" width="50px" class="mr-4" />
            </a>

            <div class="flex-grow">
              <div class="flex">
                <a href={"/profile/#{post.user.id}"} class="font-bold text-brand flex-grow">
                  <%= post.user.name %>
                </a>
                <span class="text-slate-500 text-s">
                  <%= format_date(post.inserted_at) %>
                </span>
              </div>
              <p class="mt-2 mb-2 text-lg"><%= post.content %></p>

              <%= for comment <- order_comments(post.comments) do %>
                <div class="bg-brand/30 mb-1 flex items-start p-2">
                  <Presenter.profile user={comment.user} />
                  <p class="ml-1">
                    <%= comment.content %>
                  </p>
                </div>
              <% end %>
              <div class="actions">
                <form class="flex" phx-submit="comment">
                  <div class="flex-grow">
                    <input type="hidden" name="post_id" value={post.id} readonly />
                    <input type="hidden" name="post_owner_id" value={post.user_id} readonly />
                    <input
                      class="w-full p-1"
                      type="text"
                      name="content"
                      placeholder={gettext("Write a comment...")}
                    />
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp order_comments(comments) when is_list(comments) do
    comments
    |> Enum.sort(&(&1.inserted_at < &2.inserted_at))
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%I:%M %d-%m-%y")
  end
end
