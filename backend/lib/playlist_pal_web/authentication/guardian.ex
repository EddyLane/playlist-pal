defmodule PlaylistPalWeb.Guardian do
  use Guardian, otp_app: :playlist_pal

  alias PlaylistPal.Accounts
  alias GuardianDb

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.spotify_id)}
  end

  def resource_from_claims(%{"sub" => spotify_id}) do
    {:ok, Accounts.get_user_by_spotify_id(spotify_id) }
  end

  def resource_from_claims(_claims) do
    {:error, :no_sub}
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- GuardianDb.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- GuardianDb.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- GuardianDb.on_revoke(claims, token) do
      {:ok, claims}
    end
  end


end
