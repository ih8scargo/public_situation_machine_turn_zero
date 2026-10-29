defmodule PublicSituationMachineTurnZero.Architecture.PullWitness do
  @moduledoc "Attendant measurement, explicitly without standing authority. No pointer trajectory is retained."
  def build(raw) when is_map(raw) do
    dx = number(raw["dx"])
    dy = number(raw["dy"])
    duration = number(raw["duration_ms"])
    distance = if dx && dy, do: :math.sqrt(dx * dx + dy * dy)
    speed = if distance && duration && duration > 0, do: distance * 1000 / duration
    bearing = if dx && dy && (dx != 0 || dy != 0), do: :math.atan2(dy, dx) * 180 / :math.pi()

    %{
      "performed_witness" => Map.new([{"dx", dx}, {"dy", dy}, {"duration_ms", duration}]),
      "computational_outreading" => %{
        "displacement_px" => distance,
        "mean_velocity_px_s" => speed,
        "bearing_degrees" => bearing
      },
      "affects_standing" => false,
      "notice" => "THIS RESULT DOES NOT AFFECT STANDING."
    }
  end

  def build(_), do: build(%{})
  defp number(n) when is_number(n) and n >= -10_000_000 and n <= 10_000_000, do: n
  defp number(_), do: nil
end
